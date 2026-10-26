param([Parameter(Mandatory = $true)][string]$Csv, [Parameter(Mandatory = $true)][string]$Start, [Parameter(Mandatory = $true)][string]$End,
  [string]$Pattern = 'Effective Clock|Core Clocks|Clock \(perf|Bus Clock|Tctl|Tdie|CPU Die|CCD|PPT|TDC|EDC|Thermal|Throttl|Limit|VID|Core Voltage|Vcore|GPU Core Load|GPU D3D|GPU Clock|GPU Temperature|GPU Power|Performance Limit|GPU Utilization|Frame')
# Salt okunur: Export-HwinfoLog.ps1 CSV'sinden [Start, End] (HH:mm:ss) araligindaki ornekleri alir; secili okumalar icin ort/min/p5/p50/p95/maks yazar.
$inv = [Globalization.CultureInfo]::InvariantCulture
# Basliklar tirnakli (ayni ad birden cok kez gecebilir), degerler tirnaksiz sayi; Import-Csv yinelenen adi kabul etmedigi icin elle ayristirilir.
$lines = Get-Content $Csv
$hdr = @([regex]::Matches($lines[0], '"([^"]*)"') | ForEach-Object { $_.Groups[1].Value })
$rows = @($lines | Select-Object -Skip 1 | ForEach-Object { , ($_ -split ',') } | Where-Object { $_[0] -ge $Start -and $_[0] -le $End })
"Ornek sayisi: $($rows.Count) ($Start - $End)"
if ($rows.Count -eq 0) { return }
function Q($s, $p) { $i = [Math]::Min($s.Count - 1, [Math]::Max(0, [int][Math]::Round($p * ($s.Count - 1)))); $s[$i] }
for ($j = 1; $j -lt $hdr.Count; $j++) {
  if ($hdr[$j] -notmatch $Pattern) { continue }
  $x = @($rows | ForEach-Object { [double]::Parse($_[$j], $inv) } | Sort-Object)
  $avg = ($x | Measure-Object -Average).Average
  '{0,-78} ort {1,9:0.##}  min {2,9:0.##}  p5 {3,9:0.##}  p50 {4,9:0.##}  p95 {5,9:0.##}  maks {6,9:0.##}' -f $hdr[$j], $avg, $x[0], (Q $x 0.05), (Q $x 0.5), (Q $x 0.95), $x[-1]
}
