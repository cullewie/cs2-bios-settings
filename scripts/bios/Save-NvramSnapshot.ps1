param([Parameter(Mandatory=$true)][string]$OutDir, [string]$Label = '')
# Salt okunur: tum UEFI NVRAM degiskenlerinin dizinini (ad, GUID, oznitelik, boyut, SHA256) cikarir;
# yalniz ayar/setup ile ilgili degiskenlerin ham baytlarini OutDir'e kaydeder. Parola/anahtar/lisans iceren degiskenler kaydedilmez.
$src = @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public static class Nv3 {
  [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
  static extern uint GetFirmwareEnvironmentVariableExW(string lpName, string lpGuid, byte[] pBuffer, uint nSize, out uint pdwAttributes);
  [DllImport("ntdll.dll")]
  static extern int NtEnumerateSystemEnvironmentValuesEx(uint InformationClass, IntPtr Buffer, ref uint BufferLength);
  [DllImport("advapi32.dll", SetLastError=true)] static extern bool OpenProcessToken(IntPtr h, uint acc, out IntPtr tok);
  [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)] static extern bool LookupPrivilegeValue(string sys, string name, out long luid);
  [StructLayout(LayoutKind.Sequential, Pack=1)] struct TP { public int Count; public long Luid; public int Attr; }
  [DllImport("advapi32.dll", SetLastError=true)] static extern bool AdjustTokenPrivileges(IntPtr tok, bool dis, ref TP tp, int len, IntPtr prev, IntPtr ret);
  [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
  public static string EnablePriv() {
    IntPtr tok;
    if (!OpenProcessToken(GetCurrentProcess(), 0x28, out tok)) return "OpenProcessToken hata " + Marshal.GetLastWin32Error();
    long luid;
    if (!LookupPrivilegeValue(null, "SeSystemEnvironmentPrivilege", out luid)) return "LookupPrivilegeValue hata " + Marshal.GetLastWin32Error();
    TP tp = new TP(); tp.Count = 1; tp.Luid = luid; tp.Attr = 2;
    AdjustTokenPrivileges(tok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
    int e = Marshal.GetLastWin32Error();
    return e == 0 ? "etkin" : "son hata " + e;
  }
  public static List<string[]> Names() {
    List<string[]> res = new List<string[]>();
    uint len = 0x10000; IntPtr buf = IntPtr.Zero; int st = -1;
    for (int i = 0; i < 8; i++) {
      buf = Marshal.AllocHGlobal((int)len); uint l = len;
      st = NtEnumerateSystemEnvironmentValuesEx(1, buf, ref l);
      if (st == 0) break;
      Marshal.FreeHGlobal(buf); buf = IntPtr.Zero;
      if (st == unchecked((int)0xC0000023) || st == unchecked((int)0x80000005)) { len = Math.Max(l, len * 2); continue; }
      throw new Exception("NtEnumerateSystemEnvironmentValuesEx durum 0x" + st.ToString("X8"));
    }
    if (buf == IntPtr.Zero) throw new Exception("Tampon alinamadi");
    int off = 0;
    while (true) {
      int next = Marshal.ReadInt32(buf, off);
      byte[] g = new byte[16]; Marshal.Copy(IntPtr.Add(buf, off + 4), g, 0, 16);
      string name = Marshal.PtrToStringUni(IntPtr.Add(buf, off + 20));
      res.Add(new string[] { name, new Guid(g).ToString("B").ToUpper() });
      if (next == 0) break; off += next;
    }
    Marshal.FreeHGlobal(buf);
    return res;
  }
  public static byte[] Read(string name, string guid, out uint attr, out int err) {
    byte[] b = new byte[0x80000];
    uint n = GetFirmwareEnvironmentVariableExW(name, guid, b, (uint)b.Length, out attr);
    err = 0; if (n == 0) { err = Marshal.GetLastWin32Error(); return null; }
    Array.Resize(ref b, (int)n); return b;
  }
}
'@
Add-Type -TypeDefinition $src
[void][Nv3]::EnablePriv()
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
$save = '^(Setup|AmdSetup.*|AMD_PBS_SETUP|Aod.*|VARSTORE_OCMR.*|AsusQFanSetupData|AsusAI|MyFav|BiosSettingMappingTableV2|StdDefaults|FastBootOption|SetupAIFeatures|AsusFanSetupFeatures|UsbSupport|PcieSataSetupVar|AutoDetectData|SIBoardItemControl|AsusHwm.*|AsusPerspective.*)$'
$deny = '(?i)pass|pwd|admin|secret|license|lic|pubkey|^pk|kek|^db|dbx|offline|ek$|tpm'
$sha = [Security.Cryptography.SHA256]::Create()
$names = [Nv3]::Names()
$rows = New-Object System.Collections.Generic.List[object]
foreach ($n in $names) {
  [uint32]$a = 0; [int]$e = 0
  $b = [Nv3]::Read($n[0], $n[1], [ref]$a, [ref]$e)
  $size = -1; $h = ''
  if ($b) {
    $size = $b.Length
    $h = ([BitConverter]::ToString($sha.ComputeHash($b)) -replace '-', '')
    if ($n[0] -match $save -and $n[0] -notmatch $deny) {
      [IO.File]::WriteAllBytes((Join-Path $OutDir ($n[0] + '.bin')), $b)
    }
  }
  $rows.Add([pscustomobject]@{ Name = $n[0]; Guid = $n[1]; Attr = ('0x{0:X}' -f $a); Size = $size; Err = $e; Sha256 = $h })
}
$rows | Export-Csv -Path (Join-Path $OutDir 'index.csv') -NoTypeInformation -Encoding UTF8
$meta = "Etiket: $Label`nZaman: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + "`nBilgisayar acilis: " + (Get-CimInstance Win32_OperatingSystem).LastBootUpTime + "`nDegisken sayisi: " + $rows.Count
Set-Content -Path (Join-Path $OutDir 'meta.txt') -Value $meta -Encoding UTF8
$saved = @(Get-ChildItem $OutDir -Filter *.bin).Count
"Anlik goruntu: $OutDir"
"Degisken: " + $rows.Count + "  ham bayt kaydedilen: $saved  okunamayan: " + @($rows | Where-Object { $_.Size -lt 0 }).Count
Get-Content (Join-Path $OutDir 'meta.txt')
