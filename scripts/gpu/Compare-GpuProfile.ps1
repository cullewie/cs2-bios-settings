# CS2'de Afterburner profili ve CPU 0 karsilastirmasi, ayni CS2 oturumunda tek kosular (bench\Invoke-Cs2Benchmark.ps1).
# -Order 'ad:profil:maske,...' ornek: 'SF1:5:0xFFFF,SE1:5:0xFFFE,OF1:1:0xFFFF,OE1:1:0xFFFE' ve ikinci oturumda ters sira (dogrusal kayma dengelenir).
# Her kosu: profil gecisi (MSIAfterburner.exe -ProfilN, calisan ornege iletilir), guc limiti kontrolu, ekran imzasi, nvidia-smi 1 sn kaydi,
# Invoke-Cs2Benchmark tek kosu (-Warmups 0), sonrasinda CS2 acik mi + System gunlugunde nvlddmkm / Display 4101. Kararsizlikta durur.
# finally: Afterburner -Profile$EndProfile, cs2 benzesimi $EndMask, CS2 simge durumu + terminal one. Yonetici gerekir, FACEIT kapali olmali.
param(
  [Parameter(Mandatory = $true)][string]$Order,
  [int]$EndProfile = 1,
  [string]$EndMask = '0xFFFE',
  [string]$Tag = 'AB',
  [string]$OutDir = (Join-Path $PSScriptRoot 'sonuc'),
  [string]$AbDir = 'C:\Program Files (x86)\MSI Afterburner')
$runBench = Join-Path (Split-Path $PSScriptRoot) 'bench\Invoke-Cs2Benchmark.ps1'
$ab = Join-Path $AbDir 'MSIAfterburner.exe'
$profFile = @(Get-ChildItem (Join-Path $AbDir 'Profiles') -Filter 'VEN_10DE*.cfg' -ErrorAction SilentlyContinue)[0].FullName
$inv = [Globalization.CultureInfo]::InvariantCulture
$day = Get-Date -Format 'yyyyMMdd'
New-Item -ItemType Directory -Force $OutDir | Out-Null
$out = Join-Path $OutDir ('cs2_gpu_ab_{0}_{1}.txt' -f $Tag, $day)
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class GunW { [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c); [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h); }
'@
function T { Get-Date -Format 'HH:mm:ss' }
function Log([string]$m) { $l = "[$(T)] $m"; $l; Add-Content -Path $out -Value $l -Encoding UTF8 }
function DispSig {
  $m = @(Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ErrorAction SilentlyContinue | Where-Object { $_.Active } | ForEach-Object { ($_.InstanceName -split '\\')[1] }) -join '+'
  $hz = @(Get-CimInstance Win32_VideoController | Where-Object { $_.Name -match 'NVIDIA' } | ForEach-Object { $_.CurrentRefreshRate }) -join '+'
  "$m@$hz"
}
function GpuEvents([datetime]$since) { @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; StartTime = $since } -ErrorAction SilentlyContinue | Where-Object { $_.ProviderName -match 'nvlddmkm' -or ($_.ProviderName -eq 'Display' -and $_.Id -eq 4101) }) }
function PL { [double]::Parse((((& nvidia-smi --query-gpu=power.limit --format=csv,noheader,nounits) -join '').Trim()), $inv) }
function DefPL { [double]::Parse((((& nvidia-smi --query-gpu=power.default_limit --format=csv,noheader,nounits) -join '').Trim()), $inv) }
function MaxPL { [double]::Parse((((& nvidia-smi --query-gpu=power.max_limit --format=csv,noheader,nounits) -join '').Trim()), $inv) }
function SetProf([int]$n) { Start-Process $ab -ArgumentList "-Profile$n"; Start-Sleep -Seconds 4 }
function RunStats([string]$csv) {
  $rows = foreach ($r in (Get-Content $csv -ErrorAction SilentlyContinue | Select-Object -Skip 1)) { $q = $r -split ','; if ($q.Count -ge 7) { [pscustomobject]@{ U = [int]($q[1] -replace '[^\d]', ''); C = [int]($q[2] -replace '[^\d]', ''); M = [int]($q[3] -replace '[^\d]', ''); W = [double]::Parse(($q[4] -replace '[^\d\.]', ''), $inv); Tp = [int]($q[5] -replace '[^\d]', '') } } }
  $hi = @($rows | Where-Object { $_.U -ge 80 } | Sort-Object C)
  if (-not $hi.Count) { return 'GPU kaydi yok' }
  $u = @($hi | Sort-Object U)
  'yukte n={0}: saat medyan {1} (min {2} maks {3}) | bellek {4} | {5:N0} W | yuk medyan %{6} | maks {7} C' -f $hi.Count, $hi[[int][Math]::Floor(($hi.Count - 1) / 2)].C, $hi[0].C, $hi[-1].C, ($hi | Group-Object M | Sort-Object Count -Descending | Select-Object -First 1).Name, ($hi | Measure-Object W -Average).Average, $u[[int][Math]::Floor(($u.Count - 1) / 2)].U, ($hi | Measure-Object Tp -Maximum).Maximum
}
$sig0 = DispSig
Log "--- cs2_gpu_ab basladi | sira $Order | ekran $sig0"
if ($sig0 -match '^@') { Log 'EKRAN YOK, test baslamadi'; return }
if (Get-Process | Where-Object { $_.Name -match 'faceit' }) { Log 'FACEIT calisiyor, test baslamadi'; return }
if (-not (Get-Process cs2 -ErrorAction SilentlyContinue)) { Log 'cs2 calismiyor, test baslamadi'; return }
if (-not (Get-Process MSIAfterburner -ErrorAction SilentlyContinue)) { Log 'Afterburner calismiyor, test baslamadi'; return }
if (-not $profFile) { Log 'Afterburner profil dosyasi bulunamadi, test baslamadi'; return }
$defPL = DefPL; $maxPL = MaxPL
$smi = $null
try {
  foreach ($item in ($Order -split ',')) {
    $name, $pn, $mask = $item -split ':'; $pn = [int]$pn
    SetProf $pn
    # beklenen guc limiti = profildeki PowerLimit yuzdesi x varsayilan limit (kart azamisiyle sinirli)
    $pf = [IO.File]::ReadAllText($profFile, [Text.Encoding]::Default)
    $ppl = [int][regex]::Match([regex]::Match($pf, "(?s)\[Profile$pn\](.*?)(?=\r?\n\[|\z)").Groups[1].Value, 'PowerLimit=(\d+)').Groups[1].Value
    $pl = PL; $plOk = [Math]::Abs($pl - [Math]::Min($maxPL, $defPL * $ppl / 100)) -lt 10
    Log ("{0}: Afterburner Profil {1} | guc limiti {2:N0} W{3}" -f $name, $pn, $pl, $(if ($plOk) { '' } else { '  [BEKLENEN DEGIL]' }))
    if (-not $plOk) { Log 'profil gecisi dogrulanamadi, durdu'; break }
    $s = DispSig
    if ($s -ne $sig0) { Log "EKRAN DEGISTI ($s), durdu"; break }
    $csv = Join-Path $OutDir ('gpu_{0}_{1}_{2}.csv' -f $Tag, $name, $day)
    $smi = Start-Process nvidia-smi -ArgumentList '--query-gpu=timestamp,utilization.gpu,clocks.gr,clocks.mem,power.draw,temperature.gpu,clocks_event_reasons.active', '--format=csv', '-lms', '1000', '-f', $csv -WindowStyle Hidden -PassThru
    $ts = Get-Date
    try { & $runBench -Plan ('{0}:{1}:1' -f $name, $mask) -Warmups 0 -Progress (Join-Path $OutDir 'bench_progress.txt') | ForEach-Object { Add-Content -Path $out -Value $_ -Encoding UTF8; $_ } } catch { Log "run_bench hata: $($_.Exception.Message)" }
    Stop-Process -Id $smi.Id -ErrorAction SilentlyContinue; $smi = $null; Start-Sleep -Milliseconds 500
    Log ("{0} GPU: {1}" -f $name, (RunStats $csv))
    $ev = GpuEvents $ts
    $alive = [bool](Get-Process cs2 -ErrorAction SilentlyContinue)
    $evs = if ($ev.Count) { ' | ' + (($ev | ForEach-Object { '{0} {1} {2}' -f $_.TimeCreated.ToString('HH:mm:ss'), $_.ProviderName, $_.Id }) -join '; ') } else { '' }
    Log "$name sonrasi: cs2 acik=$alive, GPU olay=$($ev.Count)$evs"
    if (-not $alive -or $ev.Count) { Log "KARARSIZLIK BELIRTISI ($name), durdu"; break }
    $s = DispSig
    if ($s -ne $sig0) { Log "EKRAN KOSU SIRASINDA DEGISTI ($s), $name GECERSIZ, durdu"; break }
  }
} finally {
  if ($smi) { Stop-Process -Id $smi.Id -ErrorAction SilentlyContinue }
  SetProf $EndProfile
  Log ("bitis: Afterburner Profil {0} | guc limiti {1:N0} W" -f $EndProfile, (PL))
  if (-not (Get-Process | Where-Object { $_.Name -match 'faceit' })) {
    $c2 = Get-Process cs2 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c2) { $c2.ProcessorAffinity = [IntPtr][Convert]::ToInt64($EndMask.Replace('0x', ''), 16); Log ('cs2 benzesim 0x{0:X}' -f [int64]$c2.ProcessorAffinity); [void][GunW]::ShowWindow($c2.MainWindowHandle, 6); Start-Sleep -Milliseconds 500 }
  }
  $wtp = Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
  if ($wtp) { [void][GunW]::SetForegroundWindow($wtp.MainWindowHandle) }
  Log '--- cs2_gpu_ab bitti'
}
