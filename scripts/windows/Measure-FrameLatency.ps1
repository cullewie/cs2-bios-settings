param(
  [string]$Plan = 'W1:0xFFFE:0,W2:0xFFFE:0,A1:0xFFFE:1,A2:0xFFFE:1,A3:0xFFFE:1,B1:0xFFFF:1,B2:0xFFFF:1,B3:0xFFFF:1,C1:0xFFFE:1,C2:0xFFFE:1,C3:0xFFFE:1',
  [string]$Tag = 'CPU0',
  [string]$BgPriority = 'Idle',
  [string]$OutDir = (Join-Path $PSScriptRoot 'sonuc'),
  [string]$EtlDir = (Join-Path $env:TEMP 'frame_latency'),
  [string]$Repo = (Split-Path (Split-Path $PSScriptRoot)),
  [string]$PmExe = (Join-Path $PSScriptRoot 'PresentMon-2.6.0-x64.exe'),
  [switch]$KeepEtl
)
# Gecikme + akicilik bloklu testi (docs/windows.md). AYAR DEGISTIRMEZ: yalniz cs2 surecinin calisma anindaki CPU maskesi kosu basina
# Invoke-Cs2Benchmark ile ayarlanir (sonda baslangic maskesine doner). Ayni CS2 oturumu, yeniden baslatma yok.
# Plan: 'ad:maske:kayit[:L]' virgulle; kayit=1 ise kosu boyunca WPR (presentmon-light.wprp!PMLight, dosya modu, kayipsiz) calisir.
# L: kosu boyunca oturumdaki arka plan uygulamalarinin onceligi -BgPriority (varsayilan Idle) yapilir (Process Lasso benzeri; CS2, Windows kabugu,
# svchost, Defender, NVIDIA/Broadcast, ses ve test araclari haric). L olmayan kosudan once ve sonda ozgun oncelikler geri yuklenir.
# Ornek: -Tag ONCELIK -Plan 'W1:0xFFFE:0,W2:0xFFFE:0,A1:0xFFFE:1,A2:0xFFFE:1,A3:0xFFFE:1,B1:0xFFFE:1:L,B2:0xFFFE:1:L,B3:0xFFFE:1:L,C1:0xFFFE:1,C2:0xFFFE:1,C3:0xFFFE:1'
# Kosulardan sonra her ETL PresentMon --etl_file ile islenir; VProf penceresi (rapor-125 .. rapor-3 sn) icin FrameLatencyStats.cs:
# kare suresi p50/p99/p99.9, kare > 2x medyan (CS2'de ~%5 olagan, takilma olcutu degil), kare > 4 ms (takilma), kare baslangici->ekran ve PC gecikmesi (Reflex isaretleri) ort/p50/p99.
# CS2 acik olmali (-condebug). FACEIT kapali olmali. Yonetici gerekir (WPR). PresentMon-2.6.0-x64.exe bu klasorde olmali (-PmExe ile degisir).
# Gercek zamanli PresentMon 8000 Hz farede olay kaybeder (Win32k girdi olaylari); bu yuzden kayit dosyaya alinir. Durdurmak: <OutDir>\bench_stop.txt. Yalniz ASCII.
$ErrorActionPreference = 'Continue'
$bench = Join-Path $Repo 'scripts\bench\Invoke-Cs2Benchmark.ps1'
$backup = Join-Path $Repo 'scripts\bench\Backup-ConsoleLog.ps1'
$prof = Join-Path $PSScriptRoot 'presentmon-light.wprp'
New-Item -ItemType Directory -Force $OutDir, $EtlDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmm'
$out = Join-Path $OutDir ('frame_latency_{0}_{1}.txt' -f $Tag, $stamp)
$prog = Join-Path $OutDir 'bench_progress.txt'
$stopFile = Join-Path $OutDir 'bench_stop.txt'
$inv = [Globalization.CultureInfo]::InvariantCulture
function Log([string]$m) { $l = '[' + (Get-Date -Format 'HH:mm:ss') + '] ' + $m; Write-Host $l; Add-Content -Path $out -Value $l -Encoding UTF8 }

$pre = @()
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $pre += 'yonetici degil' }
if (Get-Process | Where-Object { $_.Name -match 'faceit' }) { $pre += 'FACEIT calisiyor' }
if (-not (Get-Process cs2 -ErrorAction SilentlyContinue)) { $pre += 'cs2 calismiyor' }
foreach ($f in $bench, $backup, $prof, $PmExe, (Join-Path $PSScriptRoot 'FrameLatencyStats.cs')) { if (-not (Test-Path $f)) { $pre += "yok: $f" } }
$items = @(foreach ($it in ($Plan -split ',' | Where-Object { $_.Trim() })) { $p = $it.Trim() -split ':'; [pscustomobject]@{ Name = $p[0]; Mask = $p[1]; Cap = ($p[2] -eq '1'); Low = ($p.Count -gt 3 -and $p[3] -eq 'L') } })
Log ('--- Measure-FrameLatency basladi | {0} | plan {1}' -f $Tag, (($items | ForEach-Object { '{0}:{1}{2}' -f $_.Name, $_.Mask, $(if ($_.Cap) { '*' } else { '' }) }) -join ' '))
if ($pre.Count) { foreach ($p in $pre) { Log "ON KOSUL: $p" }; Log 'durdu'; return }
Add-Type -Path (Join-Path $PSScriptRoot 'FrameLatencyStats.cs') -ReferencedAssemblies System.Core

# ---------- arka plan onceligi (Process Lasso benzeri, calisma aninda; sonda geri) ----------
$ExcludeNames = @('cs2','explorer','dwm','csrss','winlogon','fontdrvhost','sihost','ctfmon','TextInputHost','ShellExperienceHost','StartMenuExperienceHost','SearchHost','SearchApp','RuntimeBroker','audiodg','powershell','pwsh','claude','node','WindowsTerminal','OpenConsole','conhost','lsass','services','smss','wininit','System','Idle','Registry','Memory Compression','ApplicationFrameHost','SystemSettings','LockApp','dllhost','taskhostw','backgroundTaskHost','smartscreen','SecurityHealthSystray','wpr','PresentMon-2.6.0-x64','WmiPrvSE','cmd','UserOOBEBroker','Widgets','WidgetService','PhoneExperienceHost','CrossDeviceResume','svchost','ShellHost','DefenderSessionHelper','MsMpEng','SecurityHealthService','MpDefenderCoreService')
$script:origPri = @{}
function LowerBg {
  $sid = (Get-Process -Id $PID).SessionId; $done = New-Object System.Collections.Generic.List[string]
  foreach ($p in (Get-Process)) {
    if ($p.SessionId -ne $sid -or $p.Id -eq $PID) { continue }
    if ($p.ProcessName -in $ExcludeNames -or $p.ProcessName -match '(?i)nvidia|broadcast|nvcontainer|nvdisplay|faceit|audio|lghub') { continue }
    try {
      if (-not $script:origPri.ContainsKey($p.Id)) { $script:origPri[$p.Id] = [pscustomobject]@{ Name = $p.ProcessName; Pri = $p.PriorityClass; Start = $p.StartTime } }
      if ($p.PriorityClass -ne $BgPriority) { $p.PriorityClass = $BgPriority }
      $done.Add($p.ProcessName)
    } catch { }
  }
  Log ('arka plan onceligi {0}: {1} surec ({2})' -f $BgPriority, $done.Count, (($done | Group-Object | ForEach-Object { if ($_.Count -gt 1) { '{0} x{1}' -f $_.Name, $_.Count } else { $_.Name } }) -join ', '))
}
function RestoreBg {
  if (-not $script:origPri.Count) { return }
  $n = 0; $miss = 0
  foreach ($id in @($script:origPri.Keys)) {
    $o = $script:origPri[$id]; $p = Get-Process -Id $id -ErrorAction SilentlyContinue
    if ($p) { try { if ($p.StartTime -eq $o.Start) { $p.PriorityClass = $o.Pri; $n++ } } catch { $miss++ } } else { $miss++ }
  }
  $script:origPri.Clear()
  Log ('arka plan onceligi geri yuklendi: {0} surec{1}' -f $n, $(if ($miss) { " ($miss surec kapanmis veya erisilemedi)" } else { '' }))
}

$runs = New-Object System.Collections.Generic.List[object]
$wprOn = $false
try {
  foreach ($it in $items) {
    if (Test-Path $stopFile) { Log 'bench_stop.txt var, durdu'; break }
    if (-not (Get-Process cs2 -ErrorAction SilentlyContinue)) { Log 'cs2 kapali, durdu'; break }
    if ($it.Low) { LowerBg } else { RestoreBg }
    $etl = Join-Path $EtlDir ('{0}_{1}_{2}.etl' -f $Tag, $it.Name, $stamp)
    if ($it.Cap) {
      & wpr -cancel 2>&1 | Out-Null
      $s = & wpr -start ($prof + '!PMLight') -filemode 2>&1
      if ($LASTEXITCODE -ne 0) { Log ('HATA: wpr baslamadi: ' + (($s | ForEach-Object { "$_" }) -join ' ')); break }
      $wprOn = $true
    }
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
    $runs.Add([pscustomobject]@{ Name = $it.Name; Mask = $it.Mask; Cap = $it.Cap; Etl = $(if ($it.Cap) { $etl } else { $null }); Rapor = $res.Rapor; TStop = $tStop; Avg = $res.Avg; P1 = $res.P1 })
    Log ('{0} ({1}) bitti: VProf Avg {2} P1 {3}{4}' -f $it.Name, $it.Mask, $res.Avg, $res.P1, $(if ($it.Cap) { (' | ETL {0:N0} MB' -f ((Get-Item $etl -ErrorAction SilentlyContinue).Length / 1MB)) } else { '' }))
  }
} catch {
  Log ('HATA (betik): {0} | satir {1}' -f $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber)
} finally {
  if ($wprOn) { & wpr -cancel 2>&1 | Out-Null; Log 'wpr iptal edildi' }
  RestoreBg
  & $backup -Label ('LAT_' + $Tag) | ForEach-Object { Log $_ }
}

# ---------- isleme ----------
Log '--- ETL isleme (PresentMon etl_file + FrameLatencyStats)'
$rows = New-Object System.Collections.Generic.List[object]
foreach ($r in ($runs | Where-Object { $_.Cap -and $_.Etl -and (Test-Path $_.Etl) })) {
  $csv = [IO.Path]::ChangeExtension($r.Etl, '.csv'); Remove-Item $csv -ErrorAction SilentlyContinue
  $p = Start-Process $PmExe -ArgumentList @('--etl_file', ('"' + $r.Etl + '"'), '--process_name', 'cs2.exe', '--output_file', ('"' + $csv + '"'), '--date_time', '--no_console_stats', '--track_pc_latency') -WindowStyle Hidden -PassThru
  if (-not $p.WaitForExit(600000)) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue; Log "UYARI: $($r.Name) PresentMon zaman asimi"; continue }
  if (-not (Test-Path $csv)) { Log "UYARI: $($r.Name) CSV yok"; continue }
  $rap = [datetime]::ParseExact($r.TStop.ToString('yyyy-MM-dd') + ' ' + $r.Rapor, 'yyyy-MM-dd HH:mm:ss', $inv)
  $lag = ($r.TStop - $rap).TotalSeconds
  $v = [FrameLatencyStats]::Run($csv, 'cs2.exe', $lag + 125, $lag + 3)
  $row = [pscustomobject]@{ Name = $r.Name; Mask = $r.Mask; Avg = $r.Avg; P1 = $r.P1; Frames = $v[0]; PmFps = $v[1]; FtP50 = $v[2]; FtP99 = $v[3]; FtP999 = $v[4]; Stutter = $v[5]; Over4 = $v[6]; LatAvg = $v[7]; LatP50 = $v[8]; LatP99 = $v[9]; PclN = $v[10]; PclAvg = $v[11]; PclP50 = $v[12]; PclP99 = $v[13] }
  $rows.Add($row)
  Log ('{0} {1}: kare {2} | VProf {3:N1} | kare suresi p50 {4:N3} p99 {5:N3} p99.9 {6:N3} | takilma {7} | >4ms {8} | kare->ekran ort {9:N3} p99 {10:N3} | PC gecikmesi ort {11:N3} p99 {12:N3} (n {13})' -f $row.Name, $row.Mask, $row.Frames, $row.Avg, $row.FtP50, $row.FtP99, $row.FtP999, $row.Stutter, $row.Over4, $row.LatAvg, $row.LatP99, $row.PclAvg, $row.PclP99, $row.PclN)
  if (-not $KeepEtl) { Remove-Item $r.Etl -Force -ErrorAction SilentlyContinue }
}
$rows | Export-Csv -Path (Join-Path $OutDir ('frame_latency_{0}_{1}.csv' -f $Tag, $stamp)) -NoTypeInformation -Encoding UTF8

# ---------- ozet ----------
Log '--- OZET (blok ortalamalari)'
$grp = $rows | Group-Object { $_.Name.Substring(0, 1) }
foreach ($g in $grp) {
  $x = $g.Group
  Log ('{0} ({1}) n={2} | VProf Avg {3:N2} P1 {4:N1} | kare suresi p99 {5:N3} p99.9 {6:N3} | takilma {7:N1} | >4ms {8:N1} | kare->ekran ort {9:N3} p99 {10:N3} | PC gecikmesi ort {11:N3} p99 {12:N3}' -f $g.Name, $x[0].Mask, $x.Count, ($x | Measure-Object Avg -Average).Average, ($x | Measure-Object P1 -Average).Average, ($x | Measure-Object FtP99 -Average).Average, ($x | Measure-Object FtP999 -Average).Average, ($x | Measure-Object Stutter -Average).Average, ($x | Measure-Object Over4 -Average).Average, ($x | Measure-Object LatAvg -Average).Average, ($x | Measure-Object LatP99 -Average).Average, ($x | Measure-Object PclAvg -Average).Average, ($x | Measure-Object PclP99 -Average).Average)
}
Log '--- Measure-FrameLatency bitti'
