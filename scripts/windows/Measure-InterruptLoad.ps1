# CPU basina kesme/DPC orneklemesi + imlec hareketi (salt okunur).
# Her saniye: Win32_PerfRawData_PerfOS_Processor farklari (dil bagimsiz) ve o saniyede imlecin kat ettigi yol (px).
# Sonunda saniyeleri "hareketli" (> MoveMin px) ve "durgun" (< 5 px) diye ayirip CPU basina ortalama ve farki yazar.
param([int]$Seconds = 45, [int]$MoveMin = 200, [string]$OutCsv = '')

Add-Type @'
using System; using System.Runtime.InteropServices;
public static class CurPos { [StructLayout(LayoutKind.Sequential)] public struct P { public int X; public int Y; }
  [DllImport("user32.dll")] public static extern bool GetCursorPos(out P p); }
'@

function Snap {
  $r = @{}
  foreach ($p in Get-CimInstance Win32_PerfRawData_PerfOS_Processor) { $r[$p.Name] = @([double]$p.InterruptsPersec, [double]$p.DPCsQueuedPersec, [double]$p.Timestamp_Sys100NS, [double]$p.PercentDPCTime, [double]$p.PercentInterruptTime) }
  $r
}

$rows = New-Object System.Collections.Generic.List[object]
$prev = Snap
for ($s = 1; $s -le $Seconds; $s++) {
  $dist = 0.0; $p0 = New-Object CurPos+P; [void][CurPos]::GetCursorPos([ref]$p0)
  $end = (Get-Date).AddSeconds(1)
  while ((Get-Date) -lt $end) {
    Start-Sleep -Milliseconds 20
    $p1 = New-Object CurPos+P; [void][CurPos]::GetCursorPos([ref]$p1)
    $dist += [Math]::Sqrt([double](($p1.X - $p0.X) * ($p1.X - $p0.X) + ($p1.Y - $p0.Y) * ($p1.Y - $p0.Y))); $p0 = $p1
  }
  $cur = Snap
  foreach ($k in $cur.Keys) {
    $dt = ($cur[$k][2] - $prev[$k][2]) / 1e7
    if ($dt -le 0) { continue }
    # Tam sayiya yuvarlanir: Turkce ondalik virgulu CSV'yi bozmasin. DpcBp/IntBp = sure yuzdesi x100 (1 = %0.01)
    $dtTicks = $cur[$k][2] - $prev[$k][2]
    $rows.Add([pscustomobject]@{ Sec = $s; Time = (Get-Date).ToString('HH:mm:ss'); Cpu = $k; Int = [int](($cur[$k][0] - $prev[$k][0]) / $dt); Dpc = [int](($cur[$k][1] - $prev[$k][1]) / $dt)
      DpcBp = [int](10000 * ($cur[$k][3] - $prev[$k][3]) / $dtTicks); IntBp = [int](10000 * ($cur[$k][4] - $prev[$k][4]) / $dtTicks); Move = [int]$dist })
  }
  $prev = $cur
}

if ($OutCsv) { $rows | Export-Csv $OutCsv -NoTypeInformation -Encoding UTF8 }

$moving = @($rows | Where-Object { $_.Cpu -eq '_Total' -and $_.Move -gt $MoveMin } | ForEach-Object Sec)
$still  = @($rows | Where-Object { $_.Cpu -eq '_Total' -and $_.Move -lt 5 } | ForEach-Object Sec)
"Hareketli saniye: {0}, durgun saniye: {1} (toplam {2})" -f $moving.Count, $still.Count, $Seconds
if ($moving.Count -eq 0 -or $still.Count -eq 0) { "UYARI: hareketli ya da durgun saniye yok; karsilastirma yapilamaz." }
$cpus = $rows | ForEach-Object Cpu | Sort-Object -Unique | Sort-Object { if ($_ -eq '_Total') { 999 } else { [int]$_ } }
"{0,-7} {1,10} {2,10} {3,10} | {4,9} {5,9} {6,9}" -f 'CPU', 'Int durgun', 'Int hrkt', 'Int fark', 'DPC durg', 'DPC hrkt', 'DPC fark'
foreach ($c in $cpus) {
  $m = @($rows | Where-Object { $_.Cpu -eq $c -and $moving -contains $_.Sec }); $st = @($rows | Where-Object { $_.Cpu -eq $c -and $still -contains $_.Sec })
  $im = if ($m.Count) { ($m | Measure-Object Int -Average).Average } else { 0 }; $is = if ($st.Count) { ($st | Measure-Object Int -Average).Average } else { 0 }
  $dm = if ($m.Count) { ($m | Measure-Object Dpc -Average).Average } else { 0 }; $ds = if ($st.Count) { ($st | Measure-Object Dpc -Average).Average } else { 0 }
  "{0,-7} {1,10:N0} {2,10:N0} {3,10:N0} | {4,9:N0} {5,9:N0} {6,9:N0}" -f $c, $is, $im, ($im - $is), $ds, $dm, ($dm - $ds)
}
