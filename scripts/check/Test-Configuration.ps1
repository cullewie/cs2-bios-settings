param(
  [string]$Hedef = (Join-Path $PSScriptRoot '..\..\config\bios-target-2503.csv'),
  [string]$IfrFile = '',
  [switch]$Fan,
  [string]$CsvOut = '',
  [int]$RamMts = -1,
  [switch]$NoGpu
)
# Canli BIOS ayarlarini (UEFI NVRAM), Windows ve ekran karti durumunu hedeflerle karsilastirir.
# SALT OKUNUR: NVRAM'e, kayit defterine, hicbir yere yazmaz. Yonetici PowerShell gerekir.
# Kullanim:  .\scripts\check\Test-Configuration.ps1            (BIOS 2503 ofsetleriyle)
#            .\scripts\check\Test-Configuration.ps1 -Fan       (fan/pompa egrileri dahil)
#            .\scripts\check\Test-Configuration.ps1 -IfrFile .\yeni_bios\ifr_all.tsv   (BIOS guncellemesinden sonra: ofsetleri yeni sozlukten ada gore bulur)
#            .\scripts\check\Test-Configuration.ps1 -RamMts 6000   (RAM hizi hedefi; varsayilan hedef listedeki Memory Frequency, 0 = kontrol etme)
#            .\scripts\check\Test-Configuration.ps1 -NoGpu         (ekran karti hiz asirtmasi kullanmiyorsaniz guc siniri kontrolunu atlar)
# Cikis kodu: farkli bulunan ayar sayisi (0 = her sey hedefte). BILGI satirlari sayilmaz.

$ErrorActionPreference = 'Stop'
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host 'Yonetici PowerShell gerekli (UEFI degiskenlerini okumak icin).' -ForegroundColor Red; exit 255
}
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class NvK {
  [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
  static extern uint GetFirmwareEnvironmentVariableExW(string lpName, string lpGuid, byte[] pBuffer, uint nSize, out uint pdwAttributes);
  [DllImport("advapi32.dll", SetLastError=true)] static extern bool OpenProcessToken(IntPtr h, uint acc, out IntPtr tok);
  [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)] static extern bool LookupPrivilegeValue(string sys, string name, out long luid);
  [StructLayout(LayoutKind.Sequential, Pack=1)] struct TP { public int Count; public long Luid; public int Attr; }
  [DllImport("advapi32.dll", SetLastError=true)] static extern bool AdjustTokenPrivileges(IntPtr tok, bool dis, ref TP tp, int len, IntPtr prev, IntPtr ret);
  [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
  public static void EnablePriv() {
    IntPtr tok; long luid;
    if (!OpenProcessToken(GetCurrentProcess(), 0x28, out tok)) return;
    if (!LookupPrivilegeValue(null, "SeSystemEnvironmentPrivilege", out luid)) return;
    TP tp = new TP(); tp.Count = 1; tp.Luid = luid; tp.Attr = 2;
    AdjustTokenPrivileges(tok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
  }
  public static byte[] Read(string name, string guid) {
    byte[] b = new byte[0x10000]; uint attr;
    uint n = GetFirmwareEnvironmentVariableExW(name, guid, b, (uint)b.Length, out attr);
    if (n == 0) return null;
    Array.Resize(ref b, (int)n); return b;
  }
}
'@
[NvK]::EnablePriv()

# Degiskenler ve BIOS 2503'teki boyutlari
$vars = @{
  OCMR  = @{ Name = 'VARSTORE_OCMR_SETTINGS_NAME'; Guid = '{A3A3B874-7636-4182-BA1E-F52C584494E3}'; Size = 10398 }
  AOD   = @{ Name = 'AodSetupRpl'; Guid = '{5ED15DC0-EDEF-4161-9151-6014C4CC630C}'; Size = 800 }
  CBS   = @{ Name = 'AmdSetupRPL'; Guid = '{3A997502-647A-4C82-998E-52EF9486A247}'; Size = 2016 }
  SETUP = @{ Name = 'Setup'; Guid = '{EC87D643-EBA4-4BB5-A1E5-3F3E36B20DA9}'; Size = 359 }
  QFAN  = @{ Name = 'AsusQFanSetupData'; Guid = '{EC87D643-EBA4-4BB5-A1E5-3F3E36B20DA9}'; Size = 343 }
}
$bios = Get-CimInstance Win32_BIOS; $board = Get-CimInstance Win32_BaseBoard
Write-Host ("Anakart: {0}   BIOS: {1}" -f $board.Product, $bios.SMBIOSBIOSVersion)
$sameBios = ($board.Product -eq 'ROG STRIX X870-A GAMING WIFI' -and $bios.SMBIOSBIOSVersion -eq '2503')
if (-not $sameBios -and -not $IfrFile) {
  Write-Host 'UYARI: Hedef liste ROG STRIX X870-A GAMING WIFI + BIOS 2503 ofsetleriyle yazildi. Farkli kart/surumde -IfrFile ile yeni sozluk ver (docs\verification.md) ya da docs\bios.md ile menuden elle kontrol et.' -ForegroundColor Yellow
}
$data = @{}; $layout = @{}
foreach ($k in $vars.Keys) {
  $b = [NvK]::Read($vars[$k].Name, $vars[$k].Guid)
  $data[$k] = $b
  $layout[$k] = if ($null -eq $b) { 'OKUNAMADI' } elseif ($b.Length -ne $vars[$k].Size) { "BOYUT FARKLI ($($b.Length) / 2503'te $($vars[$k].Size))" } else { 'ayni' }
}
# Istege bagli: yeni BIOS sozlugunden ofsetleri ada gore bul (AOD sozlukte yok, onlar sabit ofsetle kalir)
$ifr = $null
if ($IfrFile) { $ifr = Import-Csv $IfrFile -Delimiter "`t"; Write-Host "Sozluk: $IfrFile ($($ifr.Count) oge)" }
function Resolve($h) {
  if (-not $ifr -or -not $h.IFR_Ad) { return $h.Ofset }
  $vn = $vars[$h.Degisken].Name
  $m = @($ifr | Where-Object { $_.VarStore -eq $vn -and $_.Prompt -eq $h.IFR_Ad -and $_.Kind -ne 'String' -and $_.OffsetHex -ne '' } | Sort-Object { [Convert]::ToInt32($_.OffsetHex, 16) })
  if ($h.Degisken -eq 'QFAN') { $m = @($m | Where-Object { $_.Form -match 'Q-Fan|Chassis' }) }
  $s = @($m | Where-Object { [int]$_.Size -eq [int]$h.Bayt })
  if ($s.Count) { return $s[0].OffsetHex.ToUpper() } elseif ($m.Count) { return $m[0].OffsetHex.ToUpper() } else { return $null }
}

$rows = Import-Csv $Hedef
if (-not $Fan) { $rows = @($rows | Where-Object { $_.Grup -ne '6-Fan' }) }
$res = New-Object System.Collections.Generic.List[object]
foreach ($h in $rows) {
  $b = $data[$h.Degisken]; $off = Resolve $h; $cur = ''; $st = ''
  if ($null -eq $b) { $st = 'OKUNAMADI' }
  elseif ($null -eq $off) { $st = 'SOZLUKTE YOK' }
  elseif ($layout[$h.Degisken] -ne 'ayni' -and -not ($ifr -and $h.IFR_Ad)) { $st = 'DUZEN FARKLI' }
  else {
    $o = [Convert]::ToInt32($off, 16); $v = [int64]0
    if ($o + [int]$h.Bayt -gt $b.Length) { $st = 'OFSET DISI' }
    else {
      for ($i = [int]$h.Bayt - 1; $i -ge 0; $i--) { $v = $v * 256 + $b[$o + $i] }
      $cur = $v; $st = if ($v -eq [int64]$h.Hedef_ham) { 'TAMAM' } else { 'FARKLI' }
    }
  }
  $res.Add([pscustomobject]@{ Durum = $st; Grup = $h.Grup; Ayar = $h.Ayar; Hedef = "$($h.Hedef) [$($h.Hedef_ham)]"; Su_an = $cur; Menu = $h.Menu; Degisken = "$($h.Degisken)@$off"; Tur = $h.Tur })
}

# Windows tarafi (salt okunur)
$win = New-Object System.Collections.Generic.List[object]
function W($ad, $hedef, $su, $ok, $nasil) { $win.Add([pscustomobject]@{ Durum = $(if ($ok -eq $null) { 'BILGI' } elseif ($ok) { 'TAMAM' } else { 'FARKLI' }); Kontrol = $ad; Hedef = $hedef; Su_an = $su; Duzeltme = $nasil }) }
$cpu = @(Get-CimInstance Win32_Processor)
$lp = ($cpu | Measure-Object NumberOfLogicalProcessors -Sum).Sum; $nc = ($cpu | Measure-Object NumberOfCores -Sum).Sum
W 'Mantiksal islemci (SMT)' ("{0} (SMT acik, {1} cekirdek)" -f (2 * $nc), $nc) $lp ($lp -eq 2 * $nc) 'Advanced > AMD CBS > SMT Control = Auto, sonra tam kapat-ac'
# RAM hizi hedefi: -RamMts, yoksa hedef listedeki Memory Frequency satiri. EXPO/XMP kullaniyorsaniz kitin hizini -RamMts ile verin.
if ($RamMts -lt 0) { $mf = @(Import-Csv $Hedef | Where-Object { $_.Ayar -eq 'Memory Frequency' -and $_.Hedef_ham -match '^\d{4,5}$' }); $RamMts = if ($mf.Count) { [int]$mf[0].Hedef_ham } else { 0 } }
$ram = @(Get-CimInstance Win32_PhysicalMemory | ForEach-Object ConfiguredClockSpeed)
if ($RamMts -gt 0) { W 'RAM hizi (MT/s)' $RamMts ($ram -join ', ') (@($ram | Where-Object { $_ -ne $RamMts }).Count -eq 0 -and $ram.Count -gt 0) "RAM ayarlari (1-RAM grubu) uygulanmamis. EXPO/XMP kullaniyorsaniz -RamMts <kitin hizi> verin." }
else { W 'RAM hizi (MT/s)' '-' ($ram -join ', ') $null '' }
$sb = $null; try { $sb = Confirm-SecureBootUEFI } catch { $sb = $null }
W 'Secure Boot' 'Acik' $sb ($sb -eq $true) 'Boot > Secure Boot > OS Type = Windows UEFI mode; anahtar yoksa Key Management > Install Default Secure Boot Keys'
$tpm = $null; try { $tpm = Get-Tpm } catch { }
W 'TPM 2.0' 'Hazir' $(if ($tpm) { "Present=$($tpm.TpmPresent) Ready=$($tpm.TpmReady)" } else { 'okunamadi' }) ($tpm -and $tpm.TpmPresent -and $tpm.TpmReady) 'Advanced > AMD fTPM configuration > Firmware TPM switch = Enable Firmware TPM'
$dg = $null; try { $dg = Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard } catch { }
$hv = $dg -and (@($dg.SecurityServicesRunning) -contains 2)
W 'VBS / Bellek Butunlugu (HVCI)' 'Calisiyor' $(if ($dg) { "VBS=$($dg.VirtualizationBasedSecurityStatus) HVCI=$hv" } else { 'okunamadi' }) ($dg -and $dg.VirtualizationBasedSecurityStatus -eq 2 -and $hv) 'SVM Mode = Enabled; Windows Guvenligi > Cihaz guvenligi > Cekirdek yalitimi > Bellek butunlugu'
$hs = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name HwSchMode -ErrorAction SilentlyContinue).HwSchMode
W 'HAGS (GPU zamanlamasi)' 'Acik' $(if ($null -eq $hs) { 'kayit yok (Windows varsayilani)' } else { $hs }) $(if ($null -eq $hs) { $null } else { $hs -eq 2 }) 'Ayarlar > Sistem > Ekran > Grafik > Varsayilan grafik ayarlari > Donanim hizlandirmali GPU zamanlamasi; kesin durum icin dxdiag'
foreach ($pn in 'steam', 'cs2') {
  $p = Get-Process $pn -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($p) {
    $aff = [int64]$p.ProcessorAffinity
    W "$pn.exe affinity (CPU 0 haric)" 'CPU 0 isaretsiz' ('0x{0:X}' -f $aff) (($aff -band 1) -eq 0) 'Gorev Yoneticisi > Ayrintilar > steam.exe > Benzesimi ayarla > CPU 0 kaldir, sonra CS2''yi Steam''den ac'
  } else { W "$pn.exe affinity (CPU 0 haric)" 'CPU 0 isaretsiz' 'calismiyor' $null 'Steam acikken tekrar calistir' }
}
$boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$whea = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-WHEA-Logger'; StartTime = $boot } -ErrorAction SilentlyContinue).Count
W 'WHEA hatasi (acilistan beri)' '0' $whea ($whea -eq 0) 'RAM/FCLK kararsiz olabilir: once RAM ayarlarini kontrol et'
# cs2.exe tam ekran iyilestirmeleri kapali (Legacy Flip): Uyumluluk sekmesindeki kutu bu kayit degerini yazar
$lay = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -ErrorAction SilentlyContinue
$fso = @(if ($lay) { $lay.PSObject.Properties | Where-Object { $_.Name -like '*\cs2.exe' -and "$($_.Value)" -match 'DISABLEDXMAXIMIZEDWINDOWEDMODE' } })
W 'cs2.exe tam ekran iyilestirmeleri' 'Kapali (Legacy Flip)' $(if ($fso.Count) { 'kapali' } else { 'acik (kayit yok)' }) ($fso.Count -gt 0) 'cs2.exe > Ozellikler > Uyumluluk > Tam ekran iyilestirmelerini devre disi birak (docs\windows.md)'
# Guc plani: cekirdek park etme ve islemci bosta kalma. powercfg ciktisinda son iki onaltilik deger AC ve DC indeksidir (dil ayarindan bagimsiz).
function PowerAc([string]$alias) {
  $o = powercfg /qh scheme_current sub_processor $alias 2>$null
  if ($LASTEXITCODE -ne 0) { return $null }
  $hx = @([regex]::Matches(($o -join "`n"), '0x[0-9a-fA-F]{8}') | ForEach-Object Value)
  if ($hx.Count -lt 2) { return $null }
  [Convert]::ToInt32($hx[$hx.Count - 2], 16)
}
$cpMin = PowerAc 'CPMINCORES'
W 'Guc plani: cekirdek park etme' 'Kapali (en az %100 cekirdek)' $(if ($null -eq $cpMin) { 'okunamadi' } else { "en az %$cpMin cekirdek" }) $(if ($null -eq $cpMin) { $null } else { $cpMin -eq 100 }) 'Dengeli plana donun (powercfg /setactive SCHEME_BALANCED) veya plan ayarinda CPMINCORES AC = 100 yapin. Cekirdek park eden plan -%4,9 (docs\windows.md, Guc plani)'
$idleOff = PowerAc 'IDLEDISABLE'
W 'Guc plani: islemci bosta kalma' 'Acik' $(if ($null -eq $idleOff) { 'okunamadi' } elseif ($idleOff -eq 0) { 'acik' } else { 'kapali' }) $(if ($null -eq $idleOff) { $null } else { $idleOff -eq 0 }) 'Idle kapali plan -%7,4: Dengeli plana donun veya plan ayarinda IDLEDISABLE AC = 0 yapin (docs\windows.md, Guc plani)'
# Oyun Modu ve EEE: etkisi olculmedi veya sapma icinde, yalnizca bilgi
$gm = (Get-ItemProperty 'HKCU:\Software\Microsoft\GameBar' -Name AutoGameModeEnabled -ErrorAction SilentlyContinue).AutoGameModeEnabled
W 'Oyun Modu' 'Kapali veya acik (etki yok)' $(if ($null -eq $gm) { 'kayit yok (Windows varsayilani: acik)' } elseif ($gm -eq 0) { 'kapali' } else { 'acik' }) $null ''
$eee = @(Get-NetAdapterAdvancedProperty -RegistryKeyword '*EEE' -ErrorAction SilentlyContinue)
if ($eee.Count) { W 'Ethernet EEE' 'Kapali (olculmedi)' (($eee | ForEach-Object { "$($_.Name): $($_.DisplayValue)" }) -join ', ') $null '' }
# Ekran karti: Afterburner profili guc sinirini en yuksek degere ceker. Yeniden baslatma ve surucu hatasi (TDR) profili sifirlar.
# Saat ofseti NVML ile okunamaz (Afterburner'in yazdigi ofset NVML'de 0 gorunur); bu yuzden guc siniri gosterge olarak kullanilir.
if (-not $NoGpu) {
  $smi = Join-Path $env:SystemRoot 'System32\nvidia-smi.exe'
  if (Test-Path $smi) {
    $q = @(& $smi --query-gpu=power.limit,power.max_limit --format=csv,noheader,nounits 2>$null)
    $pl = $null; $pm = $null
    if ($q.Count -and $q[0] -match '^\s*([\d.]+)\s*,\s*([\d.]+)') { $pl = [double]::Parse($Matches[1], [Globalization.CultureInfo]::InvariantCulture); $pm = [double]::Parse($Matches[2], [Globalization.CultureInfo]::InvariantCulture) }
    W 'Ekran karti guc siniri (Afterburner profili)' $(if ($pm) { "$pm W (en yuksek)" } else { 'en yuksek' }) $(if ($null -eq $pl) { 'okunamadi' } else { "$pl W" }) $(if ($null -eq $pl) { $null } else { $pl -ge $pm - 0.5 }) 'Afterburner profili uygulanmamis: Afterburner''i acin ve Profil 1''i yukleyin (MSIAfterburner.exe -Profile1). Yeniden baslatma ve TDR sonrasi tekrarlayin (docs\gpu.md). Hiz asirtmasi kullanmiyorsaniz -NoGpu verin.'
  } else { W 'Ekran karti guc siniri (Afterburner profili)' 'en yuksek' 'nvidia-smi yok' $null '' }
  $tdr = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'nvlddmkm'; StartTime = $boot } -ErrorAction SilentlyContinue | Where-Object { $_.Id -in 13, 14, 153 }).Count
  $tdr += @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Display'; Id = 4101; StartTime = $boot } -ErrorAction SilentlyContinue).Count
  W 'Ekran karti surucu hatasi (TDR, acilistan beri)' '0' $tdr ($tdr -eq 0) 'Hiz asirtmasi kararsiz: cekirdegi 25 MHz dusurun. TDR guc sinirini ve ofsetleri sifirlar, profili yeniden yukleyin (docs\troubleshooting.md).'
}

# Rapor
Write-Host ''
Write-Host '== BIOS ayarlari ==' -ForegroundColor Cyan
foreach ($k in $vars.Keys) { if ($layout[$k] -ne 'ayni') { Write-Host ("  {0}: {1}" -f $vars[$k].Name, $layout[$k]) -ForegroundColor Yellow } }
$res | Format-Table Durum, Grup, Ayar, Hedef, Su_an -AutoSize | Out-String -Width 220 | Write-Host
$bad = @($res | Where-Object { $_.Durum -ne 'TAMAM' })
if ($bad.Count) {
  Write-Host '== Duzeltilecek BIOS ayarlari (menu yolu) ==' -ForegroundColor Yellow
  foreach ($x in $bad) { Write-Host ("  [{0}] {1} > {2} = {3}" -f $x.Durum, $x.Menu, $x.Ayar, $x.Hedef) }
}
Write-Host ''
Write-Host '== Windows ==' -ForegroundColor Cyan
$win | Format-Table Durum, Kontrol, Hedef, Su_an -AutoSize | Out-String -Width 220 | Write-Host
foreach ($x in ($win | Where-Object Durum -eq 'FARKLI')) { Write-Host ("  {0}: {1}" -f $x.Kontrol, $x.Duzeltme) -ForegroundColor Yellow }
$nOk = @($res | Where-Object Durum -eq 'TAMAM').Count; $nBad = $bad.Count + @($win | Where-Object Durum -eq 'FARKLI').Count
Write-Host ''
Write-Host ("Ozet: BIOS {0}/{1} tamam, Windows {2}/{3} tamam, toplam farkli: {4}" -f $nOk, $res.Count, @($win | Where-Object Durum -eq 'TAMAM').Count, $win.Count, $nBad) -ForegroundColor $(if ($nBad) { 'Yellow' } else { 'Green' })
if ($CsvOut) { $res | Export-Csv $CsvOut -NoTypeInformation -Encoding UTF8; Write-Host "CSV: $CsvOut" }
exit $nBad
