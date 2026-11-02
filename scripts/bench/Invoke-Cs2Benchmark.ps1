param(
  [string]$Plan = 'W0:0xFFFF:6',
  [string]$MapCmd = 'map_workshop 3240880604 de_dust2',
  [int]$TimeoutSec = 360,
  [int]$MapLoadTimeoutSec = 100,
  [int]$GapSec = 12,
  [int]$Warmups = 1,
  [string]$Progress = (Join-Path $PSScriptRoot 'bench_progress.txt'),
  [string]$Log = 'C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log')
# CS2 benchmark kosularini otomatik calistirir. Turkce klavye: konsol tusu = tarama kodu 0x29. Baslangicta konsolun KAPALI oldugu varsayilir.
# Plan bicimi: 'ad:maske:kosuSayisi[:oncelik];ad2:maske2:n2' (oncelik istege bagli: N Normal, A AboveNormal, H High; verilmezse degistirilmez). Anti-cheat kapaliyken kullanilir.
# Plan ve console.log yolu (-Log) hicbir sey degismeden once dogrulanir. CS2'nin baslangictaki affinity ve onceligi kaydedilir ve her cikista
# (bitis, HATA, throw, bench_stop.txt, Ctrl+C) finally icinde geri yuklenir. CS2 PID + baslangic zamaniyla izlenir: surec kapanir veya PID baska surece gecerse ona dokunulmaz.
# Her kosuda console.log'un yalniz komuttan once kaydedilen konumdan sonra eklenen kismi okunur. VProf satiri ancak yeni harita satirindan sonra gelirse kosunun sonucudur.
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
# console.log paylasimli okunur (CS2 yazarken de). Dosya yoksa $null: silinip yeniden olusturulurken kisa sure yok olabilir.
function OpenLog { try { return [IO.File]::Open($Log, 'Open', 'Read', 'ReadWrite') } catch [IO.FileNotFoundException] { return $null } }
# Kosu basindaki konum: dosya uzunlugu ve ilk (en fazla 256) bayti. Poll yalniz bu konumdan sonra eklenenleri okur.
function LogMark {
  $fs = OpenLog; if (-not $fs) { return [pscustomobject]@{ Pos = [int64]0; Head = [byte[]]@() } }
  try { $n = $fs.Length; return [pscustomobject]@{ Pos = $n; Head = (New-Object IO.BinaryReader($fs)).ReadBytes([int][Math]::Min(256, $n)) } } finally { $fs.Close() }
}
# $mark konumundan sonra eklenen metin. Konum bir satirin ortasina duserse o satirin kalani atlanir (satir kosudan once baslamistir).
# Dosya kisaldiysa, ilk baytlari degistiyse veya yoksa (kesildi, yeniden olusturuldu) icindekiler kosu basindan sonra yazilmistir:
# konum 0'a cekilir ve kosunun geri kalaninda dosya bastan okunur. Reset yalniz bu ilk gorulmede $true olur.
# Satir sonu henuz yazilmamis son satir okunmaz (yarim deger alinmasin); sonraki yoklamada tamamlanmis olur.
function ReadLog($mark) {
  $fs = OpenLog; $reset = $false
  if (-not $fs) { $reset = $mark.Pos -gt 0 -or $mark.Head.Length -gt 0; $mark.Pos = [int64]0; $mark.Head = [byte[]]@(); return [pscustomobject]@{ Text = ''; Reset = $reset } }
  try {
    if ($fs.Length -lt $mark.Pos -or [Convert]::ToBase64String((New-Object IO.BinaryReader($fs)).ReadBytes($mark.Head.Length)) -ne [Convert]::ToBase64String($mark.Head)) { $reset = $true; $mark.Pos = [int64]0; $mark.Head = [byte[]]@() }
    $skip = $mark.Pos -gt 0
    [void]$fs.Seek($(if ($skip) { $mark.Pos - 1 } else { 0 }), 'Begin')
    $t = (New-Object IO.StreamReader($fs, [Text.Encoding]::UTF8, (-not $skip))).ReadToEnd()
    if ($skip) { $i = $t.IndexOf("`n"); $t = if ($i -ge 0) { $t.Substring($i + 1) } else { '' } }
    $e = $t.LastIndexOf("`n"); $t = if ($e -ge 0) { $t.Substring(0, $e + 1) } else { '' }
    return [pscustomobject]@{ Text = $t; Reset = $reset }
  } finally { $fs.Close() }
}
# Baslangicta secilen cs2 sureci. Surec kapandiysa veya PID baska bir surece gectiyse (baslangic zamani farkli) $null.
function Target {
  if (-not $script:cs2Id) { return $null }
  $p = Get-Process -Id $script:cs2Id -ErrorAction SilentlyContinue
  try { if ($p -and $p.StartTime -eq $script:cs2Start) { return $p } } catch { }
  return $null
}
function Guard {
  if (@(Get-Process | Where-Object { $_.Name -match 'faceit' }).Count -gt 0) { throw 'FACEIT calisiyor, durduruldu' }
  $p = Target
  if (-not $p) { throw 'cs2.exe kapandi veya PID baska bir surece gecti, durduruldu' }
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
function SetAff([int64]$m) {
  $p = Guard; $b = [int64]$p.ProcessorAffinity
  $script:affSet = $true; $p.ProcessorAffinity = [IntPtr]$m; $p.Refresh()
  Say ('affinity 0x{0:X} -> 0x{1:X}' -f $b, [int64]$p.ProcessorAffinity)
}
function SetPri([Diagnostics.ProcessPriorityClass]$pri) {
  $p = Guard; $b = $p.PriorityClass
  $script:priSet = $true; $p.PriorityClass = $pri; $p.Refresh()
  Say ('oncelik {0} -> {1}' -f $b, $p.PriorityClass)
}
# Tum mantiksal islemciler (SMT kapaliyken 0xFF, acikken 0xFFFF). Bunun disindaki bir bit "Parametre hatali" verir.
function FullMask { if ([Environment]::ProcessorCount -ge 64) { return [int64]-1 }; return ([int64]1 -shl [Environment]::ProcessorCount) - 1 }
# Plan dogrulama. Her blok ad:maske:kosu[:oncelik]: ad bosluksuz, maske 0 olmayan onaltilik ve FullMask icinde, kosu en az 1, oncelik N/A/H.
function ParsePlan([string]$plan) {
  $full = FullMask; $map = @{ N = 'Normal'; A = 'AboveNormal'; H = 'High' }; $out = @(); $err = @()
  foreach ($blk in ($plan -split ';')) {
    $f = @($blk -split ':'); $m = [int64]0; $n = 0; $pri = $null
    if ($f.Count -lt 3 -or $f.Count -gt 4 -or $f[0] -notmatch '^\S+$') { $err += "'$blk': bicim ad:maske:kosu[:oncelik] olmali, ad bosluksuz"; continue }
    if (-not [int64]::TryParse(($f[1] -replace '^0[xX]', ''), 'AllowHexSpecifier', $inv, [ref]$m) -or $m -eq 0 -or ($m -band -bnot $full)) { $err += ("'{0}': maske 0 olmayan onaltilik bir deger olmali ve 0x{1:X} icinde kalmali" -f $blk, $full); continue }
    if (-not [int]::TryParse($f[2], [ref]$n) -or $n -lt 1) { $err += "'$blk': kosu sayisi en az 1 olan bir tam sayi olmali"; continue }
    if ($f.Count -eq 4 -and $f[3]) { if (-not $map.ContainsKey($f[3])) { $err += "'$blk': oncelik N, A veya H olmali"; continue }; $pri = [Diagnostics.ProcessPriorityClass]$map[$f[3]] }
    $out += [pscustomobject]@{ Name = $f[0]; Mask = $m; N = $n; Pri = $pri }
  }
  return [pscustomobject]@{ Blocks = $out; Errors = $err }
}
# Baslangictaki affinity ve oncelige don. Guard cagrilmaz: bench_stop.txt veya FACEIT geri yuklemeyi engellemez.
# Yalniz ayni surece (PID + baslangic zamani) dokunur. Biri basarisiz olursa digeri yine denenir; kayit en sonda yazilir.
function Restore {
  if (-not ($script:affSet -or $script:priSet)) { return }
  $p = Target
  if (-not $p) { Say 'UYARI: cs2 kapandi veya PID baska bir surece gecti; geri yukleme yapilmadi, baska surece dokunulmadi'; return }
  $msg = @()
  if ($script:affSet) {
    try {
      $b = [int64]$p.ProcessorAffinity; $p.ProcessorAffinity = [IntPtr]$script:origAff; $p.Refresh(); $a = [int64]$p.ProcessorAffinity
      $msg += $(if ($a -eq $script:origAff) { 'affinity geri yuklendi: 0x{0:X} -> 0x{1:X}' -f $b, $a } else { 'HATA: affinity geri yuklenemedi: 0x{0:X} (baslangic 0x{1:X})' -f $a, $script:origAff })
    } catch { $msg += 'HATA: affinity geri yuklenemedi: ' + $_.Exception.Message }
  }
  if ($script:priSet) {
    try {
      $b = $p.PriorityClass; $p.PriorityClass = $script:origPri; $p.Refresh(); $a = $p.PriorityClass
      $msg += $(if ($a -eq $script:origPri) { 'oncelik geri yuklendi: {0} -> {1}' -f $b, $a } else { 'HATA: oncelik geri yuklenemedi: {0} (baslangic {1})' -f $a, $script:origPri })
    } catch { $msg += 'HATA: oncelik geri yuklenemedi: ' + $_.Exception.Message }
  }
  foreach ($l in $msg) { Say $l }
}
# Baslangictaki duzene don: CS2 simge durumundaydiysa yeniden kucult, onceki on plan penceresini (terminal) one al
function ReturnDesk {
  $p = Target
  if ($p -and $script:cs2WasIconic) { [Inp]::Minimize($p.MainWindowHandle); Start-Sleep -Milliseconds 500 }
  if ($script:prevFg -and $script:prevFg -ne [IntPtr]::Zero) { [void][Inp]::Focus($script:prevFg) }
  Say 'masaustu duzenine donuldu'
}
# console.log saati 'MM/dd HH:mm:ss' bicimindedir, yil yoktur. Yil calistirma tarihinden ($now) alinir; ileri bir tarihe dusen satir (yil donumu) onceki yila aittir.
# Yalniz kosu basindan ($mark) sonra eklenen ve saati t0'dan once olmayan satirlar sayilir. VProf satiri ancak bir harita satirindan sonra gelirse bu kosunundur.
function Poll([datetime]$t0, $mark, [datetime]$now = (Get-Date)) {
  $rd = ReadLog $mark
  $mapSeen = $false; $vp = $null; $ts = [datetime]::MinValue; $yr = '{0} ' -f $now.Year; $max = $now.AddDays(1)
  foreach ($line in ($rd.Text -split "`r?`n")) {
    if ($line.Length -lt 20) { continue }
    if ($line -notmatch '^(\d\d/\d\d \d\d:\d\d:\d\d) (.*)$') { continue }
    if (-not [datetime]::TryParseExact($yr + $Matches[1], 'yyyy MM/dd HH:mm:ss', $inv, 'None', [ref]$ts)) { continue }
    if ($ts -gt $max) { $ts = $ts.AddYears(-1) }
    $rest = $Matches[2]
    if ($ts -lt $t0) { continue }
    if ($rest -match '^\[Client\] Map: ') { $mapSeen = $true }
    elseif ($mapSeen -and -not $vp -and $rest -match '^\[VProf\] FPS: Avg=([\d\.]+), P1=([\d\.]+)') { $vp = [pscustomobject]@{ Time = $ts; Avg = [double]::Parse($Matches[1], $inv); P1 = [double]::Parse($Matches[2], $inv) } }
  }
  return [pscustomobject]@{ Map = $mapSeen; VProf = $vp; Reset = $rd.Reset }
}
if (-not (Test-Path -LiteralPath (Split-Path $Progress) -PathType Container)) { throw ('ilerleme dosyasinin klasoru yok: ' + (Split-Path $Progress)) }
Say ('--- run_bench basladi. Plan=' + $Plan)
# Dogrulama: hata varsa hicbir sey degismeden durur
$pp = ParsePlan $Plan; $err = @($pp.Errors)
if (-not (Test-Path -LiteralPath $Log -PathType Leaf)) { $err += "console.log bulunamadi: $Log (CS2 -condebug ile acik olmali; yol -Log ile verilir)" }
if ($err.Count) { foreach ($e in $err) { Say "HATA: $e" }; throw ('Gecersiz parametre, hicbir sey degistirilmedi: ' + ($err -join ' | ')) }
# Hedef: tek cs2.exe. PID, baslangic zamani, affinity ve oncelik kaydedilir; okunamazsa hicbir sey degismeden durur.
$cs = @(Get-Process cs2 -ErrorAction SilentlyContinue)
if ($cs.Count -eq 0) { throw 'cs2.exe calismiyor' }
if ($cs.Count -gt 1) { throw "$($cs.Count) cs2.exe sureci var, hedef belirsiz, durduruldu" }
try { $script:cs2Start = $cs[0].StartTime; $script:origAff = [int64]$cs[0].ProcessorAffinity; $script:origPri = $cs[0].PriorityClass } catch { throw ('cs2.exe durumu okunamadi: ' + $_.Exception.Message) }
$script:cs2Id = $cs[0].Id
$p0 = Guard
Say ('cs2 PID {0} (baslangic {1:HH:mm:ss}), pencere {2}, affinity 0x{3:X}, oncelik {4}, simge durumu={5}' -f $p0.Id, $script:cs2Start, $p0.MainWindowHandle, $script:origAff, $script:origPri, [Inp]::IsIconic($p0.MainWindowHandle))
$script:prevFg = [Inp]::GetForegroundWindow(); $script:cs2WasIconic = [Inp]::IsIconic($p0.MainWindowHandle)
$script:affSet = $false; $script:priSet = $false
$script:runNo = 0
try {
  if (-not (EnsureFocus)) { Say 'HATA: CS2 penceresi one getirilemedi'; return }
  Say 'CS2 on planda (konsol kapali varsayiliyor)'
  foreach ($blk in $pp.Blocks) {
    $name = $blk.Name; $n = $blk.N
    SetAff $blk.Mask
    if ($null -ne $blk.Pri) { SetPri $blk.Pri }
    for ($r = 1; $r -le $n; $r++) {
      $script:runNo++
      $kind = if ($script:runNo -le $Warmups) { 'ISINMA' } else { 'KAYIT' }
      [void](Guard)
      $t0 = (Get-Date).AddSeconds(-1); $mark = LogMark
      Say ("$name kosu $r/$n ($kind): komut gonderiliyor")
      SendConsole $MapCmd
      $res = $null; $lost = $false; $mapOk = $false; $sw = [Diagnostics.Stopwatch]::StartNew()
      while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
        Start-Sleep -Seconds 2
        $p = Guard
        if ([Inp]::GetForegroundWindow() -ne $p.MainWindowHandle -or [Inp]::IsIconic($p.MainWindowHandle)) { $lost = $true; Say 'UYARI: CS2 odak kaybetti, geri aliniyor'; [void][Inp]::Focus($p.MainWindowHandle) }
        $st = Poll $t0 $mark
        if ($st.Reset) { Say 'UYARI: console.log kisaldi veya yeniden olusturuldu; bu kosuda dosya bastan okunuyor (yalniz kosu basindan sonraki saatler sayilir)' }
        if ($st.Map -and -not $mapOk) { $mapOk = $true; Say ('harita yuklendi ({0:N0} sn)' -f $sw.Elapsed.TotalSeconds) }
        if ($st.VProf) { $res = $st.VProf; break }
        if (-not $mapOk -and $sw.Elapsed.TotalSeconds -gt $MapLoadTimeoutSec) { Say "HATA: komuttan sonra $MapLoadTimeoutSec sn icinde harita yuklenmedi, durduruldu"; return }
      }
      if (-not $res) { Say "HATA: $name kosu $r icin $TimeoutSec sn icinde VProf raporu gelmedi, durduruldu"; return }
      Say ('{0} kosu {1}/{2} ({3}) bitti: rapor {4}  Avg={5} P1={6}{7}' -f $name, $r, $n, $kind, $res.Time.ToString('HH:mm:ss'), $res.Avg.ToString('0.0', $inv), $res.P1.ToString('0.0', $inv), $(if ($lost) { '  [ODAK KAYBI VAR]' } else { '' }))
      Start-Sleep -Seconds $GapSec
    }
  }
  Say '--- run_bench bitti'
} finally {
  # Her cikista (bitis, HATA + return, throw, bench_stop.txt, CS2 kapanmasi, odak hatasi, Ctrl+C): once ozgun affinity ve oncelik, sonra masaustu duzeni
  try { Restore } catch { [Console]::WriteLine('HATA: geri yukleme tamamlanamadi: ' + $_.Exception.Message) }
  try { ReturnDesk } catch { [Console]::WriteLine('HATA: masaustu duzenine donulemedi: ' + $_.Exception.Message) }
}
