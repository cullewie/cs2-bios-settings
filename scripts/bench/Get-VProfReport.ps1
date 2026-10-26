param(
  [string]$Log = 'C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log',
  [Parameter(Mandatory = $true)][string]$Start,
  [string]$End = '',
  [string]$Name = 'asama',
  [string]$CompareStart = '', [string]$CompareEnd = '', [string]$CompareName = 'onceki',
  [int]$MinIntervals = 90, [int]$MaxIntervals = 160)
# console.log icindeki [VProf] benchmark kosularini (90-160 saniyelik) okur, medyan/aralik ve onceki asamayla karsilastirma yazar.
# Tarih bicimi: 'MM/dd HH:mm' veya 'MM/dd HH:mm:ss' (console.log ile ayni, yil 2026 varsayilir). Salt okunur.
$inv = [Globalization.CultureInfo]::InvariantCulture
function PT([string]$s) { return [datetime]::ParseExact('2026 ' + $s, [string[]]@('yyyy MM/dd HH:mm:ss', 'yyyy MM/dd HH:mm'), $inv, [Globalization.DateTimeStyles]::None) }
function Med($a) { $s = @($a | Sort-Object); $n = $s.Count; if ($n -eq 0) { return $null }; if ($n % 2) { return $s[[int](($n - 1) / 2)] } else { return ($s[$n / 2 - 1] + $s[$n / 2]) / 2 } }
$fs = [IO.File]::Open($Log, 'Open', 'Read', 'ReadWrite')
$sr = New-Object IO.StreamReader($fs, [Text.Encoding]::UTF8)
$txt = $sr.ReadToEnd(); $sr.Close(); $fs.Close()
$L = $txt -split "`r?`n"
$all = New-Object System.Collections.Generic.List[object]
for ($i = 0; $i -lt $L.Count; $i++) {
  if ($L[$i] -match '^(\d\d/\d\d \d\d:\d\d:\d\d) \[VProf\] FPS: Avg=([\d\.]+), P1=([\d\.]+)') {
    $tsStr = $Matches[1]
    $ts = PT $Matches[1]; $avg = [double]::Parse($Matches[2], $inv); $p1 = [double]::Parse($Matches[3], $inv)
    $frames = 0; $ints = 0
    $cand = @(); foreach ($d in 1, 2, 3, 4) { $cand += ($i - $d) }; foreach ($d in 1, 2, 3, 4) { $cand += ($i + $d) }
    foreach ($k in $cand) {
      if ($k -lt 0 -or $k -ge $L.Count) { continue }
      if ($L[$k].StartsWith($tsStr) -and $L[$k] -match 'Summary of (\d+) frames and (\d+) 1-second intervals') { $frames = [int]$Matches[1]; $ints = [int]$Matches[2]; break }
    }
    $m = $null
    for ($k = $i; $k -le [Math]::Min($L.Count - 1, $i + 14); $k++) {
      if ($L[$k].StartsWith($tsStr) -and $L[$k] -match '\[VProf\]\s+FrameTotal\s+([\d\.]+)\s+([\d\.]+)\s+(\d+)\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+(\d+)') { $m = $Matches; break }
    }
    if ($m) {
      $all.Add([pscustomobject]@{ Time = $ts; Avg = $avg; P1 = $p1; Frames = $frames; Ints = $ints
          AvgMs = [double]::Parse($m[1], $inv); P99 = [double]::Parse($m[2], $inv); S50 = [double]::Parse($m[6], $inv); S95 = [double]::Parse($m[7], $inv) })
    }
  }
}
function Window($s, $e) {
  $t0 = PT $s; $t1 = if ($e) { PT $e } else { [datetime]::MaxValue }
  return @($all | Where-Object { $_.Time -ge $t0 -and $_.Time -le $t1 -and $_.Ints -ge $MinIntervals -and $_.Ints -le $MaxIntervals })
}
$props = @(@('Avg', 'Avg FPS', 1), @('P1', 'P1 FPS', 1), @('P99', 'FrameTotal P99 ms', -1), @('AvgMs', 'Ort. kare suresi ms', -1), @('S50', '1s max P50 ms', -1), @('S95', '1s max P95 ms', -1))
function Stats($runs, $p) { $v = @($runs | ForEach-Object { $_.$p }); [pscustomobject]@{ Med = (Med $v); Min = ($v | Measure-Object -Minimum).Minimum; Max = ($v | Measure-Object -Maximum).Maximum } }
function Show($runs, $title) {
  "=== $title  (kosu sayisi: $($runs.Count))"
  if ($runs.Count -eq 0) { 'kosu bulunamadi'; return }
  'Kosu  Saat      Avg     P1      P99ms  OrtMs  1sP50  1sP95  Kare     Sn'
  $n = 1
  foreach ($r in $runs) { '{0,-5} {1} {2,7} {3,7} {4,6} {5,6} {6,6} {7,6} {8,7} {9,4}' -f $n, $r.Time.ToString('HH:mm:ss'), $r.Avg.ToString('0.0', $inv), $r.P1.ToString('0.0', $inv), $r.P99.ToString('0.00', $inv), $r.AvgMs.ToString('0.00', $inv), $r.S50.ToString('0.00', $inv), $r.S95.ToString('0.00', $inv), $r.Frames, $r.Ints; $n++ }
  foreach ($p in $props) { $s = Stats $runs $p[0]; '{0,-22} medyan {1}  aralik {2} - {3}' -f $p[1], $s.Med.ToString('0.00', $inv), $s.Min.ToString('0.00', $inv), $s.Max.ToString('0.00', $inv) }
  if ($runs.Count -lt 5) { "UYARI: kosu sayisi 5'ten az ($($runs.Count))" }
}
$cur = Window $Start $End
Show $cur $Name
if ($cur.Count -gt 0) {
  $t0 = $cur[0].Time
  try { $w = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-WHEA-Logger'; StartTime = $t0.AddMinutes(-1) } -ErrorAction Stop).Count } catch { $w = 0 }
  try { $kp = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-Power'; Id = 41; StartTime = $t0.AddMinutes(-1) } -ErrorAction Stop).Count } catch { $kp = 0 }
  "WHEA-Logger ($($t0.ToString('MM/dd HH:mm')) sonrasi): $w   Kernel-Power 41: $kp"
}
if ($CompareStart) {
  $prev = Window $CompareStart $CompareEnd
  ''
  Show $prev $CompareName
  if ($cur.Count -gt 0 -and $prev.Count -gt 0) {
    ''
    "=== Karsilastirma: $Name - $CompareName  (medyan farki; aralik cakisiyorsa sonuc yok)"
    foreach ($p in $props) {
      $a = Stats $cur $p[0]; $b = Stats $prev $p[0]
      $d = $a.Med - $b.Med; $pct = 100 * $d / $b.Med
      $overlap = ($a.Min -le $b.Max -and $a.Max -ge $b.Min)
      $verdict = if ($overlap) { 'SONUCSUZ (aralik cakisiyor)' } else { 'FARK GERCEK (aralik cakismiyor)' }
      $good = if (($d * $p[2]) -gt 0) { 'iyi yon' } elseif ($d -eq 0) { '' } else { 'kotu yon' }
      '{0,-22} {1} -> {2}   fark {3} ({4}%)  {5}  [{6}]' -f $p[1], $b.Med.ToString('0.00', $inv), $a.Med.ToString('0.00', $inv), $d.ToString('+0.00;-0.00', $inv), $pct.ToString('+0.00;-0.00', $inv), $verdict, $good
    }
  }
}
