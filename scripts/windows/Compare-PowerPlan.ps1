param(
  [string]$Plan = 'W1:0xFFFE:0:F,W2:0xFFFE:0:F,A1:0xFFFE:1:F,A2:0xFFFE:1:F,A3:0xFFFE:1:F,B1:0xFFFE:1:D,B2:0xFFFE:1:D,B3:0xFFFE:1:D,C1:0xFFFE:1:P,C2:0xFFFE:1:P,C3:0xFFFE:1:P,D1:0xFFFE:1:Y,D2:0xFFFE:1:Y,D3:0xFFFE:1:Y,E1:0xFFFE:1:A,E2:0xFFFE:1:A,E3:0xFFFE:1:A,F1:0xFFFE:1:R,F2:0xFFFE:1:R,F3:0xFFFE:1:R,G1:0xFFFE:1:I,G2:0xFFFE:1:I,G3:0xFFFE:1:I,H1:0xFFFE:1:F,H2:0xFFFE:1:F,H3:0xFFFE:1:F',
  [string]$Tag = 'GUC',
  [string]$OutDir = (Join-Path $PSScriptRoot 'sonuc'),
  [string]$EtlDir = (Join-Path $env:TEMP 'frame_latency'),
  [string]$Repo = (Split-Path (Split-Path $PSScriptRoot)),
  [string]$PmExe = (Join-Path $PSScriptRoot 'PresentMon-2.6.0-x64.exe'),
  [string]$HwinfoExe = 'C:\Program Files\HWiNFO64\HWiNFO64.EXE',
  [switch]$NoHwinfo,
  [switch]$DryRun,
  [switch]$KeepEtl
)
# Windows guc plani karsilastirmasi (docs/windows.md, "Guc plani"). Ayni CS2 oturumunda bloklar; plan 4. alan = kosul kodu:
#   F = baslangicta etkin olan plan (kontrol)      D = Dengeli, guc modu Dengeli (Windows varsayilani)
#   P = Dengeli + guc modu "En iyi performans" (Ayarlar > Sistem > Guc > Guc modu; overlay ded574b5)
#   Y = Yuksek performans                          A = Atlas Power Scheme (Nihai performans kopyasi + AtlasOS 0.5.0 DisablePowerSaving plan ayarlari)
#   R = RapidOS 1.3 "Balanced (RapidOS)" masaustu (Dengeli kopyasi: CPMINCORES 50, CPMINCORES1 100, PERFEPP 20, guc modu En iyi performans)
#   I = baslangic planinin kopyasi + islemci bosta kalma devre disi (IDLEDISABLE 1; "idle off" planlari)
# A, R ve I gecici planlardir (sabit test GUID'leri 1111..., 1211..., 1311...), sonda silinir. Baslangic plani ve guc modu sonda geri yuklenir.
# Her kayit kosusunda WPR (presentmon-light.wprp!PMLight, dosya modu) + PresentMon --etl_file: FrameLatencyStats (kare suresi, gecikme) ve
# FrameStabilityStats (akicilik). HWiNFO (gecici SensorsOnly; INI sonda geri) + scripts\hwinfo\Export-HwinfoLog.ps1 1 sn ornek:
# kosu penceresinde cekirdek saatleri, efektif saat, paket gucu, Tctl, C6/C0 ve cekirdek bazinda saat/C6 (AMD Ryzen 9800X3D'de sinandi).
# CS2 acik olmali (-condebug). FACEIT kapali olmali. Yonetici gerekir (WPR, powercfg). HWiNFO'da paylasilan bellek (Shared Memory Support) acik olmali.
# Invoke-Cs2Benchmark kosu sonunda odagi onceki pencereye verir; bu betik her kosudan once CS2'yi one alir (ALT + SetForegroundWindow).
# -DryRun: test planlarini olusturur, ayarlarini yazar, P/I/F kosullarini kisa sure uygular ve her seyi geri alir (CS2 kosusu yok).
# Durdurmak: <OutDir>\bench_stop.txt. Yalniz ASCII.
$ErrorActionPreference = 'Continue'
$bench = Join-Path $Repo 'scripts\bench\Invoke-Cs2Benchmark.ps1'
$backup = Join-Path $Repo 'scripts\bench\Backup-ConsoleLog.ps1'
$hsmp = Join-Path $Repo 'scripts\hwinfo\Export-HwinfoLog.ps1'
$prof = Join-Path $PSScriptRoot 'presentmon-light.wprp'
$hini = Join-Path (Split-Path $HwinfoExe) 'HWiNFO64.INI'
New-Item -ItemType Directory -Force $OutDir, $EtlDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmm'
$out = Join-Path $OutDir ('power_plan_{0}_{1}.txt' -f $Tag, $stamp)
$hcsv = Join-Path $OutDir ('hwinfo_{0}_{1}.csv' -f $Tag, $stamp)
$hyed = Join-Path $OutDir ('HWiNFO64.INI.yedek_{0}' -f $stamp)
$hstop = Join-Path $OutDir 'hw_stop.txt'
$prog = Join-Path $OutDir 'bench_progress.txt'
$stopFile = Join-Path $OutDir 'bench_stop.txt'
$inv = [Globalization.CultureInfo]::InvariantCulture
function Log([string]$m) { $l = '[' + (Get-Date -Format 'HH:mm:ss') + '] ' + $m; Write-Host $l; Add-Content -Path $out -Value $l -Encoding UTF8 }

# ---------- guc plani tanimlari ----------
$G_BAL = '381b4222-f694-41f0-9685-ff5bb260df2e'; $G_HIGH = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'; $G_ULT = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
$G_ATL = '11111111-1111-1111-1111-111111111111'; $G_RAP = '12111111-1211-1211-1211-121111111111'; $G_IDL = '13111111-1311-1311-1311-131111111111'
$OV_DEF = [Guid]::Empty; $OV_BEST = [Guid]'ded574b5-45a0-4f42-8737-46345c09c238'
Add-Type -Namespace W32 -Name Pm -MemberDefinition @'
[DllImport("powrprof.dll")] public static extern uint PowerGetUserConfiguredACPowerMode(out Guid g);
[DllImport("powrprof.dll")] public static extern uint PowerSetUserConfiguredACPowerMode(ref Guid g);
[DllImport("powrprof.dll")] public static extern uint PowerGetEffectiveOverlayScheme(out Guid g);
'@
Add-Type -Namespace W32 -Name Fg -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
[DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra);
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
[DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
'@
function FocusCs2 {
  $p = Get-Process cs2 -ErrorAction SilentlyContinue; if (-not $p) { return $false }
  $h = $p.MainWindowHandle
  for ($i = 0; $i -lt 6; $i++) {
    if ([W32.Fg]::GetForegroundWindow() -eq $h) { return $true }
    if ([W32.Fg]::IsIconic($h)) { [void][W32.Fg]::ShowWindow($h, 9); Start-Sleep -Milliseconds 800 }
    [W32.Fg]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero); [W32.Fg]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
    [void][W32.Fg]::SetForegroundWindow($h); Start-Sleep -Milliseconds 600
  }
  return ([W32.Fg]::GetForegroundWindow() -eq $h)
}
function ActiveGuid { $s = (& powercfg /getactivescheme) -join ' '; $m = [regex]::Match($s, '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'); if ($m.Success) { $m.Value.ToLower() } else { '' } }
function ActiveName { $s = (& powercfg /getactivescheme) -join ' '; $m = [regex]::Match($s, '\((.*)\)\s*$'); if ($m.Success) { $m.Groups[1].Value } else { '' } }
function GetOv { $g = [Guid]::Empty; [void][W32.Pm]::PowerGetUserConfiguredACPowerMode([ref]$g); $g }
function EffOv { $g = [Guid]::Empty; [void][W32.Pm]::PowerGetEffectiveOverlayScheme([ref]$g); $g }
function SetOv([Guid]$g) { $x = $g; [void][W32.Pm]::PowerSetUserConfiguredACPowerMode([ref]$x) }
function QAc([string]$scheme, [string]$sub, [string]$set) { $o = (& powercfg /qh $scheme $sub $set) -join "`n"; $m = [regex]::Match($o, 'Current AC Power Setting Index:\s*0x([0-9a-fA-F]+)'); if ($m.Success) { [Convert]::ToInt64($m.Groups[1].Value, 16) } else { '?' } }
function PlanSummary([string]$g) {
  $sp = '54533251-82be-4824-96c1-47b60b740d00'
  'min {0} | maks {1} | EPP {2} | boost {3} | park min {4} | idle off {5} | otonom {6} | PERFCHECK {7} ms | throttle {8}' -f (QAc $g $sp '893dee8e-2bef-41e0-89c6-b55d0929964c'), (QAc $g $sp 'bc5038f7-23e0-4960-96da-33abaf5935ec'), (QAc $g $sp '36687f9e-e3a5-4dbf-b1dc-15eb381c6863'), (QAc $g $sp 'be337238-0d82-4146-a960-4f3749d470c7'), (QAc $g $sp '0cc5b647-c1df-4637-891a-dec35c318583'), (QAc $g $sp '5d76a2ca-e8c0-402f-a133-2158492d58ad'), (QAc $g $sp '8baa4a8a-14c6-4451-8e8b-14bdbd197537'), (QAc $g $sp '4d2b0152-7d5c-498b-88e2-34345392a2c5'), (QAc $g $sp '3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb')
}
function SchemeExists([string]$g) { [bool]((& powercfg /list) -join ' ' | Select-String -SimpleMatch $g -Quiet) }
function DeleteTestSchemes {
  foreach ($g in $G_ATL, $G_RAP, $G_IDL) { if (SchemeExists $g) { if ((ActiveGuid) -eq $g) { & powercfg /setactive $script:origPlan | Out-Null }; & powercfg /delete $g | Out-Null } }
}
function CreateTestSchemes {
  DeleteTestSchemes
  # A: AtlasOS 0.5.0 DisablePowerSaving.ps1 plan bolumu (Nihai performans kopyasi)
  & powercfg /duplicatescheme $G_ULT $G_ATL | Out-Null
  & powercfg /changename $G_ATL 'TEST Atlas Power Scheme' 'Compare-PowerPlan gecici test plani' | Out-Null
  & powercfg /setacvalueindex $G_ATL 0012ee47-9041-4b5d-9b77-535fba8b1442 d3d55efd-c1ff-424e-9dc3-441be7833010 0
  & powercfg /setacvalueindex $G_ATL 0012ee47-9041-4b5d-9b77-535fba8b1442 d639518a-e56d-4345-8af2-b9f32fb26109 0
  & powercfg /setacvalueindex $G_ATL 0012ee47-9041-4b5d-9b77-535fba8b1442 fc7372b6-ab2d-43ee-8797-15e9841f2cca 0
  & powercfg /setacvalueindex $G_ATL 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 0
  & powercfg /setacvalueindex $G_ATL 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
  & powercfg /setacvalueindex $G_ATL 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 0
  & powercfg /setacvalueindex $G_ATL 54533251-82be-4824-96c1-47b60b740d00 3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb 0
  & powercfg /setacvalueindex $G_ATL 7516b95f-f776-4464-8c53-06167f40cc99 17aaa29b-8b43-4b94-aafe-35f64daaf1ee 0
  & powercfg /setacvalueindex $G_ATL 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0
  & powercfg /setacvalueindex $G_ATL 54533251-82be-4824-96c1-47b60b740d00 4d2b0152-7d5c-498b-88e2-34345392a2c5 200
  # R: RapidOS 1.3 Power.yml, masaustu dali (Dengeli kopyasi)
  & powercfg /duplicatescheme $G_BAL $G_RAP | Out-Null
  & powercfg /changename $G_RAP 'TEST Balanced (RapidOS)' 'Compare-PowerPlan gecici test plani' | Out-Null
  & powercfg /setacvalueindex $G_RAP SUB_PROCESSOR CPMINCORES 50
  & powercfg /setacvalueindex $G_RAP SUB_PROCESSOR CPMINCORES1 100
  & powercfg /setacvalueindex $G_RAP SUB_PROCESSOR PERFEPP 20
  # I: baslangic plani + IDLEDISABLE 1 (AtlasOS "Disable Idle.cmd" ile ayni ayar)
  & powercfg /duplicatescheme $script:origPlan $G_IDL | Out-Null
  & powercfg /changename $G_IDL 'TEST idle kapali' 'Compare-PowerPlan gecici test plani' | Out-Null
  & powercfg /setacvalueindex $G_IDL SUB_PROCESSOR 5d76a2ca-e8c0-402f-a133-2158492d58ad 1
  foreach ($g in $G_ATL, $G_RAP, $G_IDL) { if (-not (SchemeExists $g)) { throw "test plani olusturulamadi: $g" } }
}
$script:curCode = ''
function SetCond([string]$code) {
  $c = $Cond[$code]
  if ($script:curCode -ne $code) {
    if ((ActiveGuid) -ne $c.G) { & powercfg /setactive $c.G 2>&1 | Out-Null }
    if ((GetOv) -ne $c.Ov) { SetOv $c.Ov }
    Start-Sleep -Seconds 8
  }
  $now = ActiveGuid; $ov = GetOv
  if ($now -ne $c.G) { throw ('guc plani ayarlanamadi: {0} istenen {1}, etkin {2}' -f $code, $c.G, $now) }
  if ($ov -ne $c.Ov) { throw ('guc modu ayarlanamadi: {0} istenen {1}, etkin {2}' -f $code, $c.Ov, $ov) }
  if ($script:curCode -ne $code) { Log ('KOSUL {0} = {1} | plan {2} | guc modu {3} (etkin overlay {4}) | {5}' -f $code, $c.Ad, $c.G, $ov, (EffOv), (PlanSummary $c.G)) }
  $script:curCode = $code
}
function RestoreAll {
  if ((ActiveGuid) -ne $script:origPlan) { & powercfg /setactive $script:origPlan 2>&1 | Out-Null }
  if ((GetOv) -ne $script:origOv) { SetOv $script:origOv }
  DeleteTestSchemes
  Log ('geri yuklendi: plan {0} | guc modu {1} | test planlari {2}' -f (ActiveGuid), (GetOv), $(if ((SchemeExists $G_ATL) -or (SchemeExists $G_RAP) -or (SchemeExists $G_IDL)) { 'KALDI' } else { 'silindi' }))
}

# ---------- on kosullar ----------
$pre = @()
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $pre += 'yonetici degil' }
if (Get-Process | Where-Object { $_.Name -match 'faceit' }) { $pre += 'FACEIT calisiyor' }
if (-not $DryRun -and -not (Get-Process cs2 -ErrorAction SilentlyContinue)) { $pre += 'cs2 calismiyor' }
foreach ($f in $bench, $backup, $prof, $PmExe, (Join-Path $PSScriptRoot 'FrameLatencyStats.cs'), (Join-Path $PSScriptRoot 'FrameStabilityStats.cs')) { if (-not (Test-Path $f)) { $pre += "yok: $f" } }
if (-not $NoHwinfo) {
  foreach ($f in $HwinfoExe, $hsmp) { if (-not (Test-Path $f)) { $pre += "yok: $f (HWiNFO olmadan: -NoHwinfo)" } }
  if (Get-Process HWiNFO64 -ErrorAction SilentlyContinue) { $pre += 'HWiNFO zaten calisiyor (kapatin)' }
}
$script:origPlan = ActiveGuid; $script:origOv = GetOv; $origName = ActiveName
if (-not $script:origPlan) { $pre += 'etkin guc plani okunamadi' }
if ($script:origPlan -in $G_ATL, $G_RAP, $G_IDL) { $pre += 'etkin plan bir test plani; once kendi planinizi etkinlestirin' }
$Cond = @{
  F = @{ G = $script:origPlan; Ov = $script:origOv; Ad = ('baslangic plani ({0})' -f $origName) }
  D = @{ G = $G_BAL;  Ov = $OV_DEF;  Ad = 'Dengeli' }
  P = @{ G = $G_BAL;  Ov = $OV_BEST; Ad = 'Dengeli + En iyi performans' }
  Y = @{ G = $G_HIGH; Ov = $OV_DEF;  Ad = 'Yuksek performans' }
  A = @{ G = $G_ATL;  Ov = $OV_DEF;  Ad = 'Atlas Power Scheme' }
  R = @{ G = $G_RAP;  Ov = $OV_BEST; Ad = 'Balanced (RapidOS)' }
  I = @{ G = $G_IDL;  Ov = $script:origOv; Ad = 'baslangic plani + idle kapali' }
}
$items = @(foreach ($it in ($Plan -split ',' | Where-Object { $_.Trim() })) { $p = $it.Trim() -split ':'; [pscustomobject]@{ Name = $p[0]; Mask = $p[1]; Cap = ($p[2] -eq '1'); Pw = $(if ($p.Count -gt 3) { $p[3] } else { 'F' }) } })
foreach ($it in $items) { if (-not $Cond.ContainsKey($it.Pw)) { $pre += ('bilinmeyen kosul kodu: {0}' -f $it.Pw) } }
Log ('--- Compare-PowerPlan basladi | {0} | plan {1}' -f $Tag, (($items | ForEach-Object { '{0}:{1}{2}' -f $_.Name, $_.Pw, $(if ($_.Cap) { '*' } else { '' }) }) -join ' '))
Log ('baslangic: plan {0} ({1}) | guc modu {2}' -f $script:origPlan, $origName, $script:origOv)
if ($pre.Count) { foreach ($p in $pre) { Log "ON KOSUL: $p" }; Log 'durdu'; return }
Add-Type -Path (Join-Path $PSScriptRoot 'FrameLatencyStats.cs') -ReferencedAssemblies System.Core
Add-Type -Path (Join-Path $PSScriptRoot 'FrameStabilityStats.cs') -ReferencedAssemblies System.Core

if ($DryRun) {
  try {
    CreateTestSchemes
    foreach ($k in 'F', 'D', 'P', 'Y', 'A', 'R', 'I') { Log ('{0} {1}: {2}' -f $k, $Cond[$k].Ad, (PlanSummary $Cond[$k].G)) }
    foreach ($k in 'P', 'I', 'F') { SetCond $k }
  } catch { Log ('HATA (DryRun): ' + $_.Exception.Message) }
  finally { RestoreAll; Log 'DryRun bitti' }
  return
}

# ---------- olcum ----------
$runs = New-Object System.Collections.Generic.List[object]
$wprOn = $false; $hwOn = $false; $iniChanged = $false
try {
  CreateTestSchemes
  Log 'test planlari olusturuldu (Atlas, RapidOS, idle kapali)'
  if (-not $NoHwinfo) {
    if (Test-Path $hini) { Copy-Item $hini $hyed -Force; $t = [IO.File]::ReadAllText($hini) } else { $t = "[Settings]`r`n" }
    $iniChanged = $true
    if ($t -match '(?m)^SensorsOnly=') { $t = $t -replace '(?m)^SensorsOnly=.*$', 'SensorsOnly=1' } elseif ($t -match '(?m)^\[Settings\]') { $t = $t -replace '(?m)^\[Settings\]\r?$', "[Settings]`r`nSensorsOnly=1" } else { $t = "[Settings]`r`nSensorsOnly=1`r`n" + $t }
    [IO.File]::WriteAllText($hini, $t, [Text.Encoding]::ASCII)
    Start-Process $HwinfoExe
    $ok = $false
    for ($i = 0; $i -lt 60; $i++) { Start-Sleep 1; try { $m = [System.IO.MemoryMappedFiles.MemoryMappedFile]::OpenExisting('Global\HWiNFO_SENS_SM2', [System.IO.MemoryMappedFiles.MemoryMappedFileRights]::Read); $m.Dispose(); $ok = $true; break } catch {} }
    if (-not $ok) { throw 'HWiNFO paylasilan bellegi acilmadi (Settings > Shared Memory Support acik olmali)' }
    Start-Sleep 8
    Remove-Item $hstop -ErrorAction SilentlyContinue
    Start-Process powershell.exe -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"' + $hsmp + '"'), '-Out', ('"' + $hcsv + '"'), '-StopFile', ('"' + $hstop + '"'), '-IntervalMs', '1000', '-MaxSec', '10800' -WindowStyle Hidden | Out-Null
    $hwOn = $true
    Start-Sleep 5
    Log ('HWiNFO ornekleme basladi: ' + (Split-Path $hcsv -Leaf))
  }
  foreach ($it in $items) {
    if (Test-Path $stopFile) { Log 'bench_stop.txt var, durdu'; break }
    if (-not (Get-Process cs2 -ErrorAction SilentlyContinue)) { Log 'cs2 kapali, durdu'; break }
    SetCond $it.Pw
    $etl = Join-Path $EtlDir ('{0}_{1}_{2}.etl' -f $Tag, $it.Name, $stamp)
    if ($it.Cap) {
      & wpr -cancel 2>&1 | Out-Null
      $s = & wpr -start ($prof + '!PMLight') -filemode 2>&1
      if ($LASTEXITCODE -ne 0) { Log ('HATA: wpr baslamadi: ' + (($s | ForEach-Object { "$_" }) -join ' ')); break }
      $wprOn = $true
    }
    if (-not (FocusCs2)) { Log ('HATA: {0} oncesi CS2 one alinamadi, durdu' -f $it.Name); break }
    $res = $null
    & $bench -Plan ('{0}:{1}:1' -f $it.Name, $it.Mask) -Warmups 0 -Progress $prog 6>&1 | ForEach-Object {
      $l = "$_"; Add-Content -Path $out -Value $l -Encoding UTF8
      $m = [regex]::Match($l, '(\S+) kosu 1/1 \(\w+\) bitti: rapor (\d\d:\d\d:\d\d)\s+Avg=([\d\.]+) P1=([\d\.]+)')
      if ($m.Success) { $res = [pscustomobject]@{ Rapor = $m.Groups[2].Value; Avg = [double]::Parse($m.Groups[3].Value, $inv); P1 = [double]::Parse($m.Groups[4].Value, $inv) } }
      if ($l -match 'HATA|durduruldu') { Write-Host $l }
    }
    $tStop = Get-Date
    if ($it.Cap -and $wprOn) { $t = & wpr -stop $etl 2>&1; $wprOn = $false; if ($LASTEXITCODE -ne 0) { Log ('UYARI: wpr stop kodu ' + $LASTEXITCODE) } }
    if (-not $res) { Log ("HATA: {0} kosusunun VProf sonucu alinamadi, durdu" -f $it.Name); break }
    $runs.Add([pscustomobject]@{ Name = $it.Name; Mask = $it.Mask; Pw = $it.Pw; Cap = $it.Cap; Etl = $(if ($it.Cap) { $etl } else { $null }); Rapor = $res.Rapor; TStop = $tStop; Avg = $res.Avg; P1 = $res.P1 })
    Log ('{0} ({1}) bitti: VProf Avg {2} P1 {3}{4}' -f $it.Name, $it.Pw, $res.Avg.ToString($inv), $res.P1.ToString($inv), $(if ($it.Cap) { (' | ETL {0} MB' -f [int]((Get-Item $etl -ErrorAction SilentlyContinue).Length / 1MB)) } else { '' }))
  }
} catch {
  Log ('HATA (betik): {0} | satir {1}' -f $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber)
} finally {
  if ($wprOn) { & wpr -cancel 2>&1 | Out-Null; Log 'wpr iptal edildi' }
  RestoreAll
  if ($hwOn -or (Get-Process HWiNFO64 -ErrorAction SilentlyContinue)) {
    New-Item -ItemType File -Force $hstop | Out-Null; Start-Sleep 3
    Get-Process HWiNFO64 -ErrorAction SilentlyContinue | Stop-Process -Force; Start-Sleep 1
  }
  if ($iniChanged) {
    if (Test-Path $hyed) { Copy-Item $hyed $hini -Force; Log ('HWiNFO INI geri: ' + $(if ((Get-FileHash $hini).Hash -eq (Get-FileHash $hyed).Hash) { 'yedekle ayni' } else { 'FARKLI' })) }
    else { Remove-Item $hini -ErrorAction SilentlyContinue; Log 'HWiNFO INI (betigin olusturdugu) silindi' }
  }
  & $backup -Label ('PWR_' + $Tag) | ForEach-Object { Log $_ }
}

# ---------- HWiNFO penceresi ----------
$hw = $null
if ((-not $NoHwinfo) -and (Test-Path $hcsv)) {
  $hl = [IO.File]::ReadAllLines($hcsv)
  $hdr = ($hl[0] -split '","') | ForEach-Object { $_.Trim('"') }
  function Cols([string]$pat) { @(for ($i = 0; $i -lt $hdr.Count; $i++) { if ($hdr[$i] -match $pat) { $i } }) }
  $hc = @{ Clk = Cols '\| Core \d+ Clock \(perf'; Eff = Cols '\| Core \d+ T\d Effective Clock'; Avg = Cols '\| Average Effective Clock'; Pkg = Cols '\| CPU Package Power \['; Tc = Cols '\| CPU \(Tctl/Tdie\)'; C6 = Cols '\| Core \d+ C6 Residency'; C0 = Cols '\| Core \d+ C0 Residency' }
  $byTime = @{}; for ($j = 1; $j -lt $hl.Count; $j++) { $q = $hl[$j] -split ','; $byTime[$q[0]] = $q }
  $hw = @{ Rows = $byTime; C = $hc }
  Log ('HWiNFO: {0} ornek | sutun cekirdek saati {1}, efektif {2}, paket {3}, Tctl {4}, C6 {5}' -f ($hl.Count - 1), $hc.Clk.Count, $hc.Eff.Count, $hc.Pkg.Count, $hc.Tc.Count, $hc.C6.Count)
}
function HwWin([datetime]$rap) {
  if (-not $hw) { return $null }
  $nc = $hw.C.Clk.Count
  $acc = @{ ClkMax = 0.0; ClkAvg = 0.0; EffMax = 0.0; EffAvg = 0.0; Pkg = 0.0; C6 = 0.0; C0 = 0.0 }; $tcMax = [double]::NaN; $n = 0
  $pClk = New-Object 'double[]' $nc; $pC6 = New-Object 'double[]' ([Math]::Max(1, $hw.C.C6.Count))
  for ($sec = -125; $sec -le -3; $sec++) {
    $q = $hw.Rows[$rap.AddSeconds($sec).ToString('HH:mm:ss')]; if (-not $q) { continue }
    function V($i) { $x = 0.0; if ($i -lt $q.Count -and [double]::TryParse($q[$i], [Globalization.NumberStyles]::Float, $inv, [ref]$x)) { $x } else { [double]::NaN } }
    $n++
    $ck = @($hw.C.Clk | ForEach-Object { V $_ }); $ef = @($hw.C.Eff | ForEach-Object { V $_ })
    if ($ck.Count) { $acc.ClkMax += ($ck | Measure-Object -Maximum).Maximum; $acc.ClkAvg += ($ck | Measure-Object -Average).Average; for ($c = 0; $c -lt $nc; $c++) { $pClk[$c] += $ck[$c] } }
    if ($ef.Count) { $acc.EffMax += ($ef | Measure-Object -Maximum).Maximum }
    if ($hw.C.Avg.Count) { $acc.EffAvg += (V $hw.C.Avg[0]) }
    if ($hw.C.Pkg.Count) { $acc.Pkg += (V $hw.C.Pkg[0]) }
    if ($hw.C.Tc.Count) { $tc = V $hw.C.Tc[0]; if ([double]::IsNaN($tcMax) -or $tc -gt $tcMax) { $tcMax = $tc } }
    $c6 = @($hw.C.C6 | ForEach-Object { V $_ }); if ($c6.Count) { $acc.C6 += ($c6 | Measure-Object -Average).Average; for ($c = 0; $c -lt $c6.Count; $c++) { $pC6[$c] += $c6[$c] } }
    $c0 = @($hw.C.C0 | ForEach-Object { V $_ }); if ($c0.Count) { $acc.C0 += ($c0 | Measure-Object -Average).Average }
  }
  if (-not $n) { return $null }
  [pscustomobject]@{ N = $n; ClkMax = $acc.ClkMax / $n; ClkAvg = $acc.ClkAvg / $n; EffMax = $acc.EffMax / $n; EffAvg = $acc.EffAvg / $n; Pkg = $acc.Pkg / $n; TcMax = $tcMax; C6 = $acc.C6 / $n; C0 = $acc.C0 / $n
    CoreClk = (($pClk | ForEach-Object { ($_ / $n).ToString('0', $inv) }) -join '/'); CoreC6 = (($pC6 | ForEach-Object { ($_ / $n).ToString('0.0', $inv) }) -join '/') }
}

# ---------- isleme ----------
Log '--- ETL isleme (PresentMon etl_file + FrameLatencyStats + FrameStabilityStats) + HWiNFO pencereleri'
$rows = New-Object System.Collections.Generic.List[object]
foreach ($r in ($runs | Where-Object { $_.Cap })) {
  $rap = [datetime]::ParseExact($r.TStop.ToString('yyyy-MM-dd') + ' ' + $r.Rapor, 'yyyy-MM-dd HH:mm:ss', $inv)
  $lag = ($r.TStop - $rap).TotalSeconds
  $h = HwWin $rap
  $v = @([double]::NaN) * 14; $s = @([double]::NaN) * 26
  if ($r.Etl -and (Test-Path $r.Etl)) {
    $csv = [IO.Path]::ChangeExtension($r.Etl, '.csv'); Remove-Item $csv -ErrorAction SilentlyContinue
    $p = Start-Process $PmExe -ArgumentList @('--etl_file', ('"' + $r.Etl + '"'), '--process_name', 'cs2.exe', '--output_file', ('"' + $csv + '"'), '--date_time', '--no_console_stats', '--track_pc_latency') -WindowStyle Hidden -PassThru
    if (-not $p.WaitForExit(600000)) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue; Log "UYARI: $($r.Name) PresentMon zaman asimi" }
    elseif (Test-Path $csv) { $v = [FrameLatencyStats]::Run($csv, 'cs2.exe', $lag + 125, $lag + 3); $s = [FrameStabilityStats]::Run($csv, 'cs2.exe', $lag + 125, $lag + 3) }
    else { Log "UYARI: $($r.Name) CSV yok" }
    if (-not $KeepEtl) { Remove-Item $r.Etl -Force -ErrorAction SilentlyContinue }
  }
  $row = [pscustomobject]@{ Name = $r.Name; Kosul = $r.Pw; Avg = $r.Avg; P1 = $r.P1; Frames = $v[0]; FtP50 = $v[2]; FtP99 = $v[3]; FtP999 = $v[4]; Over4 = $v[6]; LatAvg = $v[7]; LatP99 = $v[9]; PclAvg = $v[11]; PclP99 = $v[13]
    FtSd = $s[2]; DiffAvg = $s[7]; DiffP99 = $s[8]; Max1sP50 = $s[10]; Max1sP95 = $s[11]; Over6 = $s[14]; Over8 = $s[15]; AnimAvg = $s[16]; AnimP99 = $s[17]; SimSd = $s[20]; PclSd = $s[23]
    HwN = $(if ($h) { $h.N } else { 0 }); ClkAvg = $(if ($h) { $h.ClkAvg } else { [double]::NaN }); ClkMax = $(if ($h) { $h.ClkMax } else { [double]::NaN }); EffAvg = $(if ($h) { $h.EffAvg } else { [double]::NaN }); EffMax = $(if ($h) { $h.EffMax } else { [double]::NaN })
    Pkg = $(if ($h) { $h.Pkg } else { [double]::NaN }); TcMax = $(if ($h) { $h.TcMax } else { [double]::NaN }); C6 = $(if ($h) { $h.C6 } else { [double]::NaN }); C0 = $(if ($h) { $h.C0 } else { [double]::NaN })
    CoreClk = $(if ($h) { $h.CoreClk } else { '' }); CoreC6 = $(if ($h) { $h.CoreC6 } else { '' }) }
  $rows.Add($row)
  Log ('{0} {1}: VProf {2} P1 {3} | kare p99 {4} p99.9 {5} | fark ort {6} | animasyon hatasi ort {7} | PC gecikmesi ort {8} | cekirdek {9} MHz (en hizli {10}), C6 %{11}, paket {12} W, Tctl maks {13}' -f $row.Name, $row.Kosul, $row.Avg.ToString($inv), $row.P1.ToString($inv), $row.FtP99.ToString('0.000', $inv), $row.FtP999.ToString('0.000', $inv), $row.DiffAvg.ToString('0.000', $inv), $row.AnimAvg.ToString('0.000', $inv), $row.PclAvg.ToString('0.000', $inv), $row.ClkAvg.ToString('0', $inv), $row.ClkMax.ToString('0', $inv), $row.C6.ToString('0.0', $inv), $row.Pkg.ToString('0.0', $inv), $row.TcMax.ToString('0.0', $inv))
}
$rows | ForEach-Object { $o = $_; $hh = [ordered]@{}; foreach ($n in $o.PSObject.Properties.Name) { $x = $o.$n; $hh[$n] = if ($x -is [double]) { $x.ToString('0.####', $inv) } else { "$x" } }; [pscustomobject]$hh } | Export-Csv -Path (Join-Path $OutDir ('power_plan_{0}_{1}.csv' -f $Tag, $stamp)) -NoTypeInformation -Encoding UTF8

# ---------- ozet ----------
Log '--- OZET (blok ortalamalari; kontrol bloklari F ile karsilastirin, oturum ici kaymayi hesaba katin)'
foreach ($g in ($rows | Group-Object { $_.Name.Substring(0, 1) })) {
  $x = $g.Group
  function A($p, $fmt) { $a = @($x | ForEach-Object { [double]$_.$p } | Where-Object { -not [double]::IsNaN($_) }); if ($a.Count) { ($a | Measure-Object -Average).Average.ToString($fmt, $inv) } else { 'NaN' } }
  Log ('{0} {1} n={2} | VProf {3} P1 {4} | kare p99 {5} p99.9 {6} | fark ort {7} p99 {8} | saniyelik en uzun kare {9} | animasyon hatasi ort {10} p99 {11} | PC gecikmesi ort {12} | cekirdek {13} MHz (en hizli {14}), efektif {15}, C6 %{16}, paket {17} W, Tctl maks {18}' -f $g.Name, $x[0].Kosul, $x.Count, (A 'Avg' '0.00'), (A 'P1' '0.0'), (A 'FtP99' '0.000'), (A 'FtP999' '0.000'), (A 'DiffAvg' '0.000'), (A 'DiffP99' '0.000'), (A 'Max1sP50' '0.00'), (A 'AnimAvg' '0.000'), (A 'AnimP99' '0.000'), (A 'PclAvg' '0.000'), (A 'ClkAvg' '0'), (A 'ClkMax' '0'), (A 'EffAvg' '0'), (A 'C6' '0.0'), (A 'Pkg' '0.0'), (A 'TcMax' '0.0'))
  if ($x[0].CoreClk) { Log ('{0} cekirdek bazinda (son kosu) saat MHz {1} | C6 % {2}' -f $g.Name, $x[-1].CoreClk, $x[-1].CoreC6) }
}
Log '--- Compare-PowerPlan bitti'
