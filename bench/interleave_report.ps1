param(
  [string]$Progress = (Join-Path $PSScriptRoot 'bench_progress.txt'),
  [string]$Marker = '=== ROT',
  [string]$Log = 'C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log',
  [string]$Base = 'B',
  [int]$RoundSize = 3)
# bench_progress.txt + console.log: kosullari (affinity) tur bazinda eslestirip karsilastirir. Salt okunur.
$inv = [Globalization.CultureInfo]::InvariantCulture
function Med($a) { $s = @($a | Sort-Object); $n = $s.Count; if ($n -eq 0) { return $null }; if ($n % 2) { return $s[[int](($n - 1) / 2)] } else { return ($s[$n / 2 - 1] + $s[$n / 2]) / 2 } }
function Mean($a) { return (@($a) | Measure-Object -Average).Average }
function Sd($a) { $v = @($a); if ($v.Count -lt 2) { return 0 }; $m = Mean $v; return [math]::Sqrt((($v | ForEach-Object { ($_ - $m) * ($_ - $m) } | Measure-Object -Sum).Sum) / ($v.Count - 1)) }
function F([double]$x, [string]$f = '0.00') { return $x.ToString($f, $inv) }
function FS([double]$x, [string]$f = '0.00') { return $x.ToString('+' + $f + ';-' + $f, $inv) }
$tcrit = @{ 1 = 12.706; 2 = 4.303; 3 = 3.182; 4 = 2.776; 5 = 2.571; 6 = 2.447; 7 = 2.365; 8 = 2.306; 9 = 2.262; 10 = 2.228 }
$pg = Get-Content $Progress
$idx = -1; for ($i = 0; $i -lt $pg.Count; $i++) { if ($pg[$i] -like ($Marker + '*')) { $idx = $i } }
if ($idx -lt 0) { 'isaret bulunamadi: ' + $Marker; return }
$items = New-Object System.Collections.Generic.List[object]
for ($i = $idx + 1; $i -lt $pg.Count; $i++) {
  if ($pg[$i] -like '===*') { break }
  if ($pg[$i] -match '\] (\S+) kosu (\d+)/(\d+) \((\w+)\) bitti: rapor (\d\d:\d\d:\d\d)\s+Avg=([\d\.]+) P1=([\d\.]+)(.*)$') {
    $items.Add([pscustomobject]@{ Cond = $Matches[1]; Kind = $Matches[4]; T = $Matches[5]; Lost = ($Matches[8] -match 'ODAK'); Order = $items.Count + 1 })
  }
}
$fs = [IO.File]::Open($Log, 'Open', 'Read', 'ReadWrite'); $sr = New-Object IO.StreamReader($fs, [Text.Encoding]::UTF8); $txt = $sr.ReadToEnd(); $sr.Close(); $fs.Close()
$L = $txt -split "`r?`n"; $vp = @{}
for ($i = 0; $i -lt $L.Count; $i++) {
  if ($L[$i] -match '^(\d\d/\d\d \d\d:\d\d:\d\d) \[VProf\] FPS: Avg=([\d\.]+), P1=([\d\.]+)') {
    $tsStr = $Matches[1]; $avg = [double]::Parse($Matches[2], $inv); $p1 = [double]::Parse($Matches[3], $inv)
    for ($k = $i; $k -le [Math]::Min($L.Count - 1, $i + 14); $k++) {
      if ($L[$k].StartsWith($tsStr) -and $L[$k] -match '\[VProf\]\s+FrameTotal\s+([\d\.]+)\s+([\d\.]+)\s+(\d+)\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+(\d+)') {
        $vp[$tsStr.Substring(6)] = [pscustomobject]@{ Avg = $avg; P1 = $p1; AvgMs = [double]::Parse($Matches[1], $inv); P99 = [double]::Parse($Matches[2], $inv); S50 = [double]::Parse($Matches[6], $inv); S95 = [double]::Parse($Matches[7], $inv); Frames = [int]$Matches[3] }
        break
      }
    }
  }
}
$runs = @()
foreach ($it in $items) {
  if ($it.Kind -ne 'KAYIT') { continue }
  $m = $vp[$it.T]
  if (-not $m) { continue }
  $runs += [pscustomobject]@{ Order = $it.Order; Round = [int][math]::Ceiling($it.Order / $RoundSize); Cond = $it.Cond; T = $it.T; Lost = $it.Lost; Avg = $m.Avg; P1 = $m.P1; P99 = $m.P99; AvgMs = $m.AvgMs; S50 = $m.S50; S95 = $m.S95; Frames = $m.Frames }
}
"Kayitli kosu: $($runs.Count)  (ilerleme dosyasindaki: $($items.Count))   odak kaybi olan: $(@($runs | Where-Object { $_.Lost }).Count)"
''
'Sira Tur Kosul Saat      Avg     P1      P99ms  OrtMs  1sP95  Kare    odak'
foreach ($r in $runs) { '{0,-4} {1,-3} {2,-5} {3} {4,7} {5,7} {6,6} {7,6} {8,6} {9,7} {10}' -f $r.Order, $r.Round, $r.Cond, $r.T, (F $r.Avg '0.0'), (F $r.P1 '0.0'), (F $r.P99), (F $r.AvgMs), (F $r.S95), $r.Frames, $(if ($r.Lost) { 'KAYIP' } else { '' }) }
$props = @(@('Avg', 'Avg FPS', 1), @('P1', 'P1 FPS', 1), @('P99', 'FrameTotal P99 ms', -1), @('AvgMs', 'Ort. kare suresi ms', -1), @('S95', '1s max P95 ms', -1))
$conds = @($runs | Select-Object -ExpandProperty Cond -Unique)
''
'=== Kosul basina medyan (min - maks)'
foreach ($p in $props) {
  $line = '{0,-22}' -f $p[1]
  foreach ($c in $conds) { $v = @($runs | Where-Object { $_.Cond -eq $c } | ForEach-Object { $_.($p[0]) }); $line += '  {0}: {1} ({2}-{3}, n={4})' -f $c, (F (Med $v)), (F ($v | Measure-Object -Minimum).Minimum), (F ($v | Measure-Object -Maximum).Maximum), $v.Count }
  $line
}
''
'=== Sapma (tum kosular, sira ile Avg FPS dogrusal egimi)'
if ($runs.Count -ge 4) {
  $x = @($runs | ForEach-Object { [double]$_.Order }); $y = @($runs | ForEach-Object { $_.Avg })
  $mx = Mean $x; $my = Mean $y; $num = 0.0; $den = 0.0
  for ($i = 0; $i -lt $x.Count; $i++) { $num += ($x[$i] - $mx) * ($y[$i] - $my); $den += ($x[$i] - $mx) * ($x[$i] - $mx) }
  'egim: {0} FPS/kosu  (toplam {1} kosuda ~{2} FPS)' -f (FS ($num / $den) '0.00'), $runs.Count, (FS (($num / $den) * ($runs.Count - 1)) '0.0')
}
$full = @($runs | Group-Object Round | Where-Object { $_.Count -eq $RoundSize -and @($_.Group | Select-Object -ExpandProperty Cond -Unique).Count -eq $RoundSize } | ForEach-Object { $_.Name })
''
"=== Eslesmis karsilastirma (ayni turdaki kosullar; tam tur sayisi: $($full.Count))"
foreach ($c in ($conds | Where-Object { $_ -ne $Base })) {
  foreach ($p in $props) {
    $d = @()
    foreach ($rd in $full) {
      $g = @($runs | Where-Object { $_.Round -eq [int]$rd })
      $a = ($g | Where-Object { $_.Cond -eq $c } | Select-Object -First 1).($p[0]); $b = ($g | Where-Object { $_.Cond -eq $Base } | Select-Object -First 1).($p[0])
      if ($null -ne $a -and $null -ne $b) { $d += ($a - $b) }
    }
    if ($d.Count -lt 3) { continue }
    $md = Mean $d; $sd = Sd $d; $se = $sd / [math]::Sqrt($d.Count)
    $t = if ($se -gt 0) { $md / $se } else { 0 }
    $df = $d.Count - 1; $tc = if ($tcrit.ContainsKey($df)) { $tcrit[$df] } else { 2.0 }
    $baseMed = Med (@($runs | Where-Object { $_.Cond -eq $Base } | ForEach-Object { $_.($p[0]) }))
    $pos = @($d | Where-Object { $_ -gt 0 }).Count
    $sig = if ([math]::Abs($t) -gt $tc) { 'ANLAMLI' } else { 'anlamsiz' }
    $good = if (($md * $p[2]) -gt 0) { 'iyi yon' } elseif ($md -eq 0) { '' } else { 'kotu yon' }
    '{0} - {1}  {2,-20} ort. fark {3} ({4}%)  t={5} (esik {6}, df={7})  tur: {8}/{9} pozitif  -> {10} [{11}]' -f $c, $Base, $p[1], (FS $md), (FS (100 * $md / $baseMed)), (F $t), (F $tc '0.00'), $df, $pos, $d.Count, $sig, $good
  }
}
if ($conds.Count -ge 3) {
  $others = @($conds | Where-Object { $_ -ne $Base })
  if ($others.Count -ge 2) {
    $c1 = $others[0]; $c2 = $others[1]
    foreach ($p in $props[0..1]) {
      $d = @(); foreach ($rd in $full) { $g = @($runs | Where-Object { $_.Round -eq [int]$rd }); $a = ($g | Where-Object { $_.Cond -eq $c2 } | Select-Object -First 1).($p[0]); $b = ($g | Where-Object { $_.Cond -eq $c1 } | Select-Object -First 1).($p[0]); if ($null -ne $a -and $null -ne $b) { $d += ($a - $b) } }
      if ($d.Count -ge 3) { $md = Mean $d; $se = (Sd $d) / [math]::Sqrt($d.Count); $t = if ($se -gt 0) { $md / $se } else { 0 }; $df = $d.Count - 1; $tc = if ($tcrit.ContainsKey($df)) { $tcrit[$df] } else { 2.0 }
        '{0} - {1}  {2,-20} ort. fark {3}  t={4} (esik {5})  -> {6}' -f $c2, $c1, $p[1], (FS $md), (F $t), (F $tc), $(if ([math]::Abs($t) -gt $tc) { 'ANLAMLI' } else { 'anlamsiz' }) }
    }
  }
}
''
'=== Aralik cakismasi (kosul medyanlari bagimsiz karsilastirma, projenin onceki yontemi)'
foreach ($c in ($conds | Where-Object { $_ -ne $Base })) {
  foreach ($p in $props[0..2]) {
    $a = @($runs | Where-Object { $_.Cond -eq $c } | ForEach-Object { $_.($p[0]) }); $b = @($runs | Where-Object { $_.Cond -eq $Base } | ForEach-Object { $_.($p[0]) })
    if ($a.Count -lt 2 -or $b.Count -lt 2) { continue }
    $ov = (($a | Measure-Object -Minimum).Minimum -le ($b | Measure-Object -Maximum).Maximum) -and (($a | Measure-Object -Maximum).Maximum -ge ($b | Measure-Object -Minimum).Minimum)
    '{0} vs {1}  {2,-20} medyan {3} -> {4} ({5}%)  {6}' -f $c, $Base, $p[1], (F (Med $b)), (F (Med $a)), (FS (100 * ((Med $a) - (Med $b)) / (Med $b))), $(if ($ov) { 'SONUCSUZ (aralik cakisiyor)' } else { 'FARK GERCEK (aralik cakismiyor)' })
  }
}
