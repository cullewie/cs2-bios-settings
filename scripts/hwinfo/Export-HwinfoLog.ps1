param([Parameter(Mandatory = $true)][string]$Out, [string]$StopFile = '', [int]$IntervalMs = 1000, [int]$MaxSec = 900)
# Salt okunur: HWiNFO paylasilan bellegini (Global\HWiNFO_SENS_SM2) belirli araliklarla okur, tum okumalari CSV'ye yazar.
# StopFile olusunca veya MaxSec dolunca durur.
Add-Type -AssemblyName System.Core
$mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile]::OpenExisting('Global\HWiNFO_SENS_SM2', [System.IO.MemoryMappedFiles.MemoryMappedFileRights]::Read)
$v = $mmf.CreateViewAccessor(0, 0, [System.IO.MemoryMappedFiles.MemoryMappedFileAccess]::Read)
function Str($off, $len) { $b = New-Object byte[] $len; [void]$v.ReadArray($off, $b, 0, $len); $s = [Text.Encoding]::UTF8.GetString($b); $i = $s.IndexOf([char]0); if ($i -ge 0) { $s = $s.Substring(0, $i) }; $s }
$so = $v.ReadUInt32(20); $ss = $v.ReadUInt32(24); $sn = $v.ReadUInt32(28)
$ro = $v.ReadUInt32(32); $rs = $v.ReadUInt32(36); $rn = $v.ReadUInt32(40)
$sens = @{}; for ($i = 0; $i -lt $sn; $i++) { $sens[$i] = Str ($so + $i * $ss + 8) 128 }
$cols = for ($i = 0; $i -lt $rn; $i++) {
  $o = $ro + $i * $rs; $idx = $v.ReadUInt32($o + 4)
  '"' + ($sens[[int]$idx] + ' | ' + (Str ($o + 12) 128) + ' [' + (Str ($o + 268) 16) + ']').Replace('"', "'") + '"'
}
$inv = [Globalization.CultureInfo]::InvariantCulture
$sw = New-Object IO.StreamWriter($Out, $false, [Text.Encoding]::UTF8)
$sw.WriteLine('"Zaman",' + ($cols -join ','))
$t0 = Get-Date
while ($true) {
  if ($StopFile -and (Test-Path $StopFile)) { break }
  if (((Get-Date) - $t0).TotalSeconds -gt $MaxSec) { break }
  $vals = for ($i = 0; $i -lt $rn; $i++) { $v.ReadDouble($ro + $i * $rs + 284).ToString('0.###', $inv) }
  $sw.WriteLine((Get-Date -Format 'HH:mm:ss') + ',' + ($vals -join ','))
  $sw.Flush()
  Start-Sleep -Milliseconds $IntervalMs
}
$sw.Close(); $v.Dispose(); $mmf.Dispose()
