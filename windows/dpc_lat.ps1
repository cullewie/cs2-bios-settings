param([Parameter(Mandatory = $true)][string]$Name, [int]$Sec = 60, [switch]$Bench, [switch]$Mouse, [int]$DelaySec = 0, [string]$EtlDir = '')
# -Mouse: imlec hareket edene kadar (en fazla 240 sn) bekler, sonra kaydi baslatir; kayit boyunca 50 ms'de bir imlec konumunu ornekler.
# DPC/ISR gecikme olcumu (LatencyMon benzeri, kurulum/surucu yok): NT Kernel Logger (dpc,isr,img) ile ETL kaydi, sonra DpcEtl.cs ile analiz.
# -Sec N: N saniye kayit. -Bench: kayit sirasinda run_bench ile tek CS2 kosusu (0xFFFE), sonra cs2 benzesimi 0xFFFE. Yonetici gerekir.
# Cikti: windows\sonuc\dpc_lat\<ad>_<zaman>.txt (ozet) ve .csv (surucu bazinda). ETL -EtlDir'e (varsayilan %TEMP%\dpc_lat_etl) yazilir.
$wt = $PSScriptRoot
$out = Join-Path $wt 'sonuc\dpc_lat'; New-Item -ItemType Directory -Force $out | Out-Null
if (-not $EtlDir) { $EtlDir = Join-Path $env:TEMP 'dpc_lat_etl' }
New-Item -ItemType Directory -Force $EtlDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$etl = Join-Path $EtlDir "$Name`_$stamp.etl"
if ($DelaySec) { Start-Sleep -Seconds $DelaySec }
if ($Mouse) {
  Add-Type -AssemblyName System.Windows.Forms
  $p0 = [System.Windows.Forms.Cursor]::Position; $w0 = Get-Date
  while ([System.Windows.Forms.Cursor]::Position -eq $p0) {
    if (((Get-Date) - $w0).TotalSeconds -gt 240) { 'imlec 240 sn hareket etmedi, olcum yapilmadi'; return }
    Start-Sleep -Milliseconds 50
  }
}
$t0 = Get-Date
& logman start 'NT Kernel Logger' -p 'Windows Kernel Trace' '(dpc,isr,img)' -ct perf -bs 1024 -nb 64 640 -o $etl -ets | Out-Null
if ($LASTEXITCODE -ne 0) { "logman start hata $LASTEXITCODE"; return }
$benchOut = @()
try {
  if ($Bench) {
    $bt = Join-Path (Split-Path $wt) 'bench'
    $benchOut = & (Join-Path $bt 'run_bench.ps1') -Plan "$Name`:0xFFFE:1" -Warmups 0 | Select-String 'bitti: rapor|HATA|hata' | ForEach-Object { $_.Line }
  } elseif ($Mouse) {
    $tot = 0; $mov = 0; $last = [System.Windows.Forms.Cursor]::Position; $end = (Get-Date).AddSeconds($Sec)
    while ((Get-Date) -lt $end) {
      Start-Sleep -Milliseconds 50; $c = [System.Windows.Forms.Cursor]::Position; $tot++
      if ($c -ne $last) { $mov++ }; $last = $c
    }
    $benchOut = @("imlec hareketli ornek: $mov / $tot (50 ms)")
  } else { Start-Sleep -Seconds $Sec }
} finally {
  $q = & logman query 'NT Kernel Logger' -ets
  & logman stop 'NT Kernel Logger' -ets | Out-Null
  if ($Bench) { & (Join-Path (Split-Path $wt) 'bench\cs2_affinity.ps1') -Mask 0xFFFE | Out-Null }
}
$t1 = Get-Date
Add-Type -Path (Join-Path $wt 'DpcEtl.cs') -ReferencedAssemblies System.Core
$rep = [DpcEtl]::Analyze($etl, (Join-Path $out "$Name`_$stamp.csv"))
$lost = ($q | Select-String 'Events Lost|Kay.p Olay|Olay Kayb' | ForEach-Object { $_.Line.Trim() }) -join '; '
$hdr = @("=== $Name  ($($t0.ToString('dd.MM HH:mm:ss')) - $($t1.ToString('HH:mm:ss')))  ETL $([math]::Round((Get-Item $etl).Length / 1MB, 1)) MB  logman: $lost")
if ($benchOut) { $hdr += $(if ($Bench) { 'CS2: ' } else { '' }) + ($benchOut -join ' | ') }
$txt = ($hdr -join "`r`n") + "`r`n" + $rep
Set-Content -Path (Join-Path $out "$Name`_$stamp.txt") -Value $txt -Encoding UTF8
$txt
