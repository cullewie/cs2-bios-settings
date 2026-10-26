param([string]$Mask = '')
# cs2.exe islem affinity'sini okur; -Mask verilirse (ornek 0xFFFE) ayarlar. Kalici degil: CS2 kapaninca sifirlanir.
$ps = Get-Process cs2 -ErrorAction SilentlyContinue
if (-not $ps) { 'cs2.exe calismiyor'; return }
foreach ($p in $ps) {
  $before = [int64]$p.ProcessorAffinity
  if ($Mask) {
    $m = [Convert]::ToInt64($Mask.Replace('0x', ''), 16)
    $p.ProcessorAffinity = [IntPtr]$m
    $p.Refresh()
    $after = [int64]$p.ProcessorAffinity
    'cs2.exe PID {0}: affinity 0x{1:X} -> 0x{2:X}  ({3})  oncelik={4}' -f $p.Id, $before, $after, (Get-Date -Format 'HH:mm:ss'), $p.PriorityClass
  } else {
    'cs2.exe PID {0}: affinity 0x{1:X}  oncelik={2}  thread={3}  ({4})' -f $p.Id, $before, $p.PriorityClass, $p.Threads.Count, (Get-Date -Format 'HH:mm:ss')
  }
}
