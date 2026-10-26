# GPU saat hassasiyeti A/B: N = kilitsiz, L = nvidia-smi -lgc ile ust sinir (varsayilan 2600 MHz).
# Ayni CS2 oturumu, her kosu tek (bench\Invoke-Cs2Benchmark.ps1). Monitor PC'den ayrilirsa (WMI aktif monitor + yenileme hizi imzasi degisir) durur.
# Kilit her durumda (hata/durma dahil) finally'de kaldirilir: nvidia-smi -rgc. Yonetici gerekir, FACEIT kapali olmali.
# Kullanim: -Order 'N1,L1' sonra 'L2,N2' (ABBA). Sonuc: hassasiyet = %FPS farki / %GPU saat farki.
param([string]$Order = 'N1,L1', [int]$LockMHz = 2600, [string]$Mask = '0xFFFE', [string]$Tag = 'a',
  [string]$OutDir = (Join-Path $PSScriptRoot 'sonuc'))
$runBench = Join-Path (Split-Path $PSScriptRoot) 'bench\Invoke-Cs2Benchmark.ps1'
New-Item -ItemType Directory -Force $OutDir | Out-Null
function T { Get-Date -Format 'HH:mm:ss' }
function DispSig {
  $m = @(Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ErrorAction SilentlyContinue | Where-Object { $_.Active } | ForEach-Object { ($_.InstanceName -split '\\')[1] }) -join '+'
  $hz = @(Get-CimInstance Win32_VideoController | Where-Object { $_.Name -match 'NVIDIA' } | ForEach-Object { $_.CurrentRefreshRate }) -join '+'
  "$m@$hz"
}
$sig0 = DispSig
"[$(T)] ekran imzasi: $sig0"
if ($sig0 -match '^@') { "[$(T)] EKRAN YOK, test baslamadi"; return }
$smi = Start-Process nvidia-smi -ArgumentList '--query-gpu=timestamp,utilization.gpu,clocks.gr,clocks.mem,power.draw,temperature.gpu,clocks_event_reasons.active', '--format=csv', '-lms', '2000', '-f', (Join-Path $OutDir ('gpu_LGC_{0}_{1}.csv' -f $Tag, (Get-Date -Format 'yyyyMMdd'))) -WindowStyle Hidden -PassThru
try {
  foreach ($name in ($Order -split ',')) {
    if ($name -like 'L*') { $o = & nvidia-smi -lgc "210,$LockMHz" } else { $o = & nvidia-smi -rgc }
    "[$(T)] $name ayar: " + (($o | Where-Object { $_ }) -join ' | ')
    Start-Sleep -Seconds 3
    $s = DispSig
    if ($s -ne $sig0) { "[$(T)] EKRAN DEGISTI ($s), durdu"; return }
    & $runBench -Plan ('G{0}:{1}:1' -f $name, $Mask) -Warmups 0 -Progress (Join-Path $OutDir 'bench_progress.txt')
    $s = DispSig
    if ($s -ne $sig0) { "[$(T)] EKRAN KOSU SIRASINDA DEGISTI ($s), $name GECERSIZ"; return }
  }
} finally {
  $r = & nvidia-smi -rgc; "[$(T)] kilit kaldirildi: " + (($r | Where-Object { $_ }) -join ' | ')
  Stop-Process -Id $smi.Id -ErrorAction SilentlyContinue
  if (-not (Get-Process | Where-Object { $_.Name -match 'faceit' })) { $c = Get-Process cs2 -ErrorAction SilentlyContinue | Select-Object -First 1; if ($c) { $c.ProcessorAffinity = [IntPtr][Convert]::ToInt64($Mask.Replace('0x', ''), 16); "[$(T)] cs2 benzesim 0x{0:X}" -f [int64]$c.ProcessorAffinity } }
}
