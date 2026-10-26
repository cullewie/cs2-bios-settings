param([Parameter(Mandatory = $true)][string]$Tag,
  [string]$Order = 'W1:1:0xFFFE,W2:1:0xFFFE,R1:1:0xFFFE,R2:1:0xFFFE,R3:1:0xFFFE,R4:1:0xFFFE',
  [int]$EndProfile = 1, [string]$CsvDir = (Join-Path $env:TEMP 'pm_ab'),
  [string]$PresentMon = (Join-Path $PSScriptRoot 'PresentMon-2.6.0-x64.exe'))
# Bir CS2 oturumu: PresentMon 2.x (cs2.exe, tum oturum boyunca) + gpu\Compare-GpuProfile.ps1. Bitince PresentMon durdurulur;
# her kosunun VProf penceresi (rapor-125 .. rapor-3 sn) icin PresentMonReport.cs ozeti (FPS, P1, kare baslangici->ekran gecikmesi, sunum modu).
# Rapor: scripts\windows\sonuc\pm_<Tag>_<zaman>.txt. Ham CSV (buyuk) -CsvDir'de kalir. Yonetici gerekir.
$wt = $PSScriptRoot
$pm = $PresentMon  # Intel PresentMon 2.x konsol surumu (github.com/GameTechDev/PresentMon/releases)
$out = Join-Path $wt 'sonuc'; New-Item -ItemType Directory -Force $out, $CsvDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$csv = Join-Path $CsvDir "pm_$Tag`_$stamp.csv"
$since = Get-Date -Format 'HH:mm:ss'
$prog = Join-Path $out 'bench_progress.txt'
$progStart = @(Get-Content $prog -ErrorAction SilentlyContinue).Count
$p = Start-Process $pm -ArgumentList @('--process_name', 'cs2.exe', '--output_file', "`"$csv`"", '--date_time', '--no_console_stats',
  '--timed', '2400', '--terminate_after_timed', '--stop_existing_session', '--session_name', 'PM_AB') -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 3
try { & (Join-Path (Split-Path $wt) 'gpu\Compare-GpuProfile.ps1') -Order $Order -EndProfile $EndProfile -Tag $Tag -OutDir $out }
finally {
  & $pm --terminate_existing_session --session_name PM_AB 2>&1 | Out-Null
  if (-not $p.WaitForExit(15000)) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }
}
# Kosu pencereleri (bench_progress.txt, yalniz bu oturumda eklenen satirlar)
$all = @(Get-Content $prog)
$runs = foreach ($l in $all[$progStart..($all.Count - 1)]) {
  if ($l -match '^\[(\d\d:\d\d:\d\d)\] (\S+) kosu \d+/\d+ \(\w+\) bitti: rapor (\d\d:\d\d:\d\d)\s+Avg=([\d\.]+) P1=([\d\.]+)') {
    [pscustomobject]@{ Ad = $Matches[2]; Rapor = $Matches[3]; Avg = $Matches[4]; P1 = $Matches[5] }
  }
}
function SoD([string]$hms) { $t = [TimeSpan]::Parse($hms); $t.TotalSeconds }
$wins = ($runs | ForEach-Object { '{0}={1}-{2}' -f $_.Ad, ((SoD $_.Rapor) - 125), ((SoD $_.Rapor) - 3) }) -join ';'
# PresentMon --date_time saatinin yerel saatten farki (tam saat): son satir zamani - dosyanin son yazilma zamani
$last = (Get-Content $csv -Tail 1).Split(',')[8]
$pmSod = SoD ($last.Substring(11, 8))
$fileSod = (Get-Item $csv).LastWriteTime.TimeOfDay.TotalSeconds
$off = [math]::Round(($pmSod - $fileSod) / 3600) * 3600
Add-Type -Path (Join-Path $wt 'PresentMonReport.cs') -ReferencedAssemblies System.Core
$rep = [PmRapor]::Run($csv, $wins, $off)
$vp = ($runs | ForEach-Object { '{0} {1}/{2}' -f $_.Ad, $_.Avg, $_.P1 }) -join ' | '
$txt = "=== PresentMon $Tag ($since, CSV $([math]::Round((Get-Item $csv).Length / 1MB)) MB, saat farki $($off / 3600) sa)`r`nVProf Avg/P1: $vp`r`n$rep"
Set-Content -Path (Join-Path $out "pm_$Tag`_$stamp.txt") -Value $txt -Encoding UTF8
$txt
