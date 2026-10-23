param(
  [string]$Plan = 'W0:0xFFFF:6',
  [string]$MapCmd = 'map_workshop 3240880604 de_dust2',
  [int]$TimeoutSec = 360,
  [int]$MapLoadTimeoutSec = 100,
  [int]$GapSec = 12,
  [int]$Warmups = 1,
  [string]$Progress = (Join-Path $PSScriptRoot 'bench_progress.txt'))
# CS2 benchmark kosularini otomatik calistirir. Turkce klavye: konsol tusu = tarama kodu 0x29. Baslangicta konsolun KAPALI oldugu varsayilir.
# Plan bicimi: 'ad:maske:kosuSayisi[:oncelik];ad2:maske2:n2' (oncelik istege bagli: N Normal, A AboveNormal, H High; verilmezse degistirilmez). Anti-cheat kapaliyken kullanilir.
$logPath = 'C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log'
$stopFile = Join-Path (Split-Path $Progress) 'bench_stop.txt'
$inv = [Globalization.CultureInfo]::InvariantCulture
$src = @'
using System;
using System.Runtime.InteropServices;
public static class Inp {
  [StructLayout(LayoutKind.Sequential)] public struct MOUSEINPUT { public int dx; public int dy; public uint mouseData; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
  [StructLayout(LayoutKind.Sequential)] public struct KEYBDINPUT { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
  [StructLayout(LayoutKind.Explicit)] public struct INPUTUNION { [FieldOffset(0)] public MOUSEINPUT mi; [FieldOffset(0)] public KEYBDINPUT ki; }
  [StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public INPUTUNION u; }
  [DllImport("user32.dll", SetLastError=true)] static extern uint SendInput(uint n, INPUT[] inputs, int size);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("kernel32.dll")] static extern uint GetCurrentThreadId();
  [DllImport("user32.dll")] static extern bool AttachThreadInput(uint a, uint b, bool attach);
  public static void Scan(ushort sc, bool up) { INPUT[] i = new INPUT[1]; i[0].type = 1; i[0].u.ki.wScan = sc; i[0].u.ki.dwFlags = 8u | (up ? 2u : 0u); SendInput(1, i, Marshal.SizeOf(typeof(INPUT))); }
  public static void Minimize(IntPtr h) { ShowWindow(h, 6); }
  public static void Uni(char c, bool up) { INPUT[] i = new INPUT[1]; i[0].type = 1; i[0].u.ki.wScan = (ushort)c; i[0].u.ki.dwFlags = 4u | (up ? 2u : 0u); SendInput(1, i, Marshal.SizeOf(typeof(INPUT))); }
  public static bool Focus(IntPtr h) {
    if (IsIconic(h)) { ShowWindow(h, 9); System.Threading.Thread.Sleep(1000); }
    if (GetForegroundWindow() != h) {
      uint pid; uint fgThread = GetWindowThreadProcessId(GetForegroundWindow(), out pid);
      uint cur = GetCurrentThreadId(); bool att = false;
      if (fgThread != cur) att = AttachThreadInput(cur, fgThread, true);
      SetForegroundWindow(h);
      if (att) AttachThreadInput(cur, fgThread, false);
      System.Threading.Thread.Sleep(400);
    }
    return GetForegroundWindow() == h && !IsIconic(h);
  }
}
'@
Add-Type -TypeDefinition $src
function Say([string]$m) { $l = '[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $m; [Console]::WriteLine($l); Add-Content -Path $Progress -Value $l -Encoding UTF8 }
function ReadLog { $fs = [IO.File]::Open($logPath, 'Open', 'Read', 'ReadWrite'); $sr = New-Object IO.StreamReader($fs, [Text.Encoding]::UTF8); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); return $t }
function Guard {
  if (@(Get-Process | Where-Object { $_.Name -match 'faceit' }).Count -gt 0) { throw 'FACEIT calisiyor, durduruldu' }
  $p = Get-Process cs2 -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $p) { throw 'cs2.exe calismiyor' }
  if (Test-Path $stopFile) { throw 'bench_stop.txt bulundu, durduruldu' }
  return $p
}
function EnsureFocus { $p = Guard; for ($i = 0; $i -lt 5; $i++) { if ([Inp]::Focus($p.MainWindowHandle)) { return $true }; Start-Sleep -Milliseconds 600 }; return $false }
function PressScan([int]$sc) { [Inp]::Scan([uint16]$sc, $false); Start-Sleep -Milliseconds 40; [Inp]::Scan([uint16]$sc, $true); Start-Sleep -Milliseconds 150 }
function TypeText([string]$s) { foreach ($c in $s.ToCharArray()) { [Inp]::Uni($c, $false); [Inp]::Uni($c, $true); Start-Sleep -Milliseconds 30 } }
function SendConsole([string]$cmd) {
  if (-not (EnsureFocus)) { throw 'CS2 penceresi one getirilemedi' }
  PressScan 0x29; Start-Sleep -Milliseconds 600
  TypeText $cmd; Start-Sleep -Milliseconds 300
  PressScan 0x1C; Start-Sleep -Milliseconds 500
  PressScan 0x29
}
function SetAff([string]$mask) {
  $p = Guard; $m = [Convert]::ToInt64($mask.Replace('0x', ''), 16); $b = [int64]$p.ProcessorAffinity
  $p.ProcessorAffinity = [IntPtr]$m; $p.Refresh()
  Say ('affinity 0x{0:X} -> 0x{1:X}' -f $b, [int64]$p.ProcessorAffinity)
}
function SetPri([string]$pri) {
  $p = Guard; $map = @{ N = 'Normal'; A = 'AboveNormal'; H = 'High' }; $b = $p.PriorityClass
  $p.PriorityClass = [Diagnostics.ProcessPriorityClass]$map[$pri.ToUpper()]; $p.Refresh()
  Say ('oncelik {0} -> {1}' -f $b, $p.PriorityClass)
}
# Tum mantiksal islemciler (SMT kapaliyken 0xFF, acikken 0xFFFF); sabit 0xFFFF SMT kapaliyken "Parametre hatali" veriyordu
function FullMask { '0x{0:X}' -f (([int64]1 -shl [Environment]::ProcessorCount) - 1) }
function Restore { if ($usedMask) { SetAff (FullMask) }; if ($usedPri) { SetPri 'N' } }
# Baslangictaki duzene don: CS2 simge durumundaydiysa yeniden kucult, onceki on plan penceresini (terminal) one al
function ReturnDesk {
  $p = Get-Process cs2 -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($p -and $script:cs2WasIconic) { [Inp]::Minimize($p.MainWindowHandle); Start-Sleep -Milliseconds 500 }
  if ($script:prevFg -and $script:prevFg -ne [IntPtr]::Zero) { [void][Inp]::Focus($script:prevFg) }
  Say 'masaustu duzenine donuldu'
}
function Poll([datetime]$t0) {
  $mapSeen = $false; $vp = $null
  foreach ($line in ((ReadLog) -split "`r?`n")) {
    if ($line.Length -lt 20) { continue }
    if ($line -notmatch '^(\d\d/\d\d \d\d:\d\d:\d\d) (.*)$') { continue }
    $ts = [datetime]::ParseExact('2026 ' + $Matches[1], 'yyyy MM/dd HH:mm:ss', $inv); $rest = $Matches[2]
    if ($ts -lt $t0) { continue }
    if ($rest -match '^\[Client\] Map: ') { $mapSeen = $true }
    if ($rest -match '^\[VProf\] FPS: Avg=([\d\.]+), P1=([\d\.]+)' -and -not $vp) { $vp = [pscustomobject]@{ Time = $ts; Avg = [double]::Parse($Matches[1], $inv); P1 = [double]::Parse($Matches[2], $inv) } }
  }
  return [pscustomobject]@{ Map = $mapSeen; VProf = $vp }
}
Say ('--- run_bench basladi. Plan=' + $Plan)
$p0 = Guard
Say ('cs2 PID {0}, pencere {1}, affinity 0x{2:X}, simge durumu={3}' -f $p0.Id, $p0.MainWindowHandle, [int64]$p0.ProcessorAffinity, [Inp]::IsIconic($p0.MainWindowHandle))
$script:prevFg = [Inp]::GetForegroundWindow(); $script:cs2WasIconic = [Inp]::IsIconic($p0.MainWindowHandle)
if (-not (EnsureFocus)) { Say 'HATA: CS2 penceresi one getirilemedi'; return }
Say 'CS2 on planda (konsol kapali varsayiliyor)'
$usedMask = $false; $usedPri = $false
$script:runNo = 0
try {
  foreach ($blk in ($Plan -split ';')) {
    $f = $blk -split ':'; $name = $f[0]; $mask = $f[1]; $n = [int]$f[2]
    SetAff $mask; if ($mask -notmatch '^0x[fF]+$') { $usedMask = $true }
    if ($f.Count -ge 4 -and $f[3]) { SetPri $f[3]; if ($f[3].ToUpper() -ne 'N') { $usedPri = $true } }
    for ($r = 1; $r -le $n; $r++) {
      $script:runNo++
      $kind = if ($script:runNo -le $Warmups) { 'ISINMA' } else { 'KAYIT' }
      [void](Guard)
      $t0 = (Get-Date).AddSeconds(-1)
      Say ("$name kosu $r/$n ($kind): komut gonderiliyor")
      SendConsole $MapCmd
      $res = $null; $lost = $false; $mapOk = $false; $sw = [Diagnostics.Stopwatch]::StartNew()
      while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
        Start-Sleep -Seconds 2
        $p = Guard
        if ([Inp]::GetForegroundWindow() -ne $p.MainWindowHandle -or [Inp]::IsIconic($p.MainWindowHandle)) { $lost = $true; Say 'UYARI: CS2 odak kaybetti, geri aliniyor'; [void][Inp]::Focus($p.MainWindowHandle) }
        $st = Poll $t0
        if ($st.Map -and -not $mapOk) { $mapOk = $true; Say ('harita yuklendi ({0:N0} sn)' -f $sw.Elapsed.TotalSeconds) }
        if ($st.VProf) { $res = $st.VProf; break }
        if (-not $mapOk -and $sw.Elapsed.TotalSeconds -gt $MapLoadTimeoutSec) { Say "HATA: komuttan sonra $MapLoadTimeoutSec sn icinde harita yuklenmedi, durduruldu"; Restore; return }
      }
      if (-not $res) { Say "HATA: $name kosu $r icin $TimeoutSec sn icinde VProf raporu gelmedi, durduruldu"; Restore; return }
      Say ('{0} kosu {1}/{2} ({3}) bitti: rapor {4}  Avg={5} P1={6}{7}' -f $name, $r, $n, $kind, $res.Time.ToString('HH:mm:ss'), $res.Avg.ToString('0.0', $inv), $res.P1.ToString('0.0', $inv), $(if ($lost) { '  [ODAK KAYBI VAR]' } else { '' }))
      Start-Sleep -Seconds $GapSec
    }
  }
  Restore
  Say '--- run_bench bitti'
} finally {
  # Hata/durdurma (throw veya return) dahil her cikista
  ReturnDesk
}
