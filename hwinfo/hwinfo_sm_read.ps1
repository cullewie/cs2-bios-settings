Add-Type -AssemblyName System.Core
$mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile]::OpenExisting('Global\HWiNFO_SENS_SM2', [System.IO.MemoryMappedFiles.MemoryMappedFileRights]::Read)
$v = $mmf.CreateViewAccessor(0,0,[System.IO.MemoryMappedFiles.MemoryMappedFileAccess]::Read)
$sig=$v.ReadUInt32(0); $poll=$v.ReadInt64(12)
$so=$v.ReadUInt32(20); $ss=$v.ReadUInt32(24); $sn=$v.ReadUInt32(28)
$ro=$v.ReadUInt32(32); $rs=$v.ReadUInt32(36); $rn=$v.ReadUInt32(40)
"sig=$sig sensors=$sn readings=$rn poll=$poll"
function Str($off,$len){ $b=New-Object byte[] $len; [void]$v.ReadArray($off,$b,0,$len); $s=[Text.Encoding]::UTF8.GetString($b); $i=$s.IndexOf([char]0); if($i -ge 0){$s=$s.Substring(0,$i)}; $s }
$names=@{}
for($i=0;$i -lt $sn;$i++){ $names[$i]=Str ($so+$i*$ss+8) 128 }
for($i=0;$i -lt $rn;$i++){
 $o=$ro+$i*$rs
 $idx=$v.ReadUInt32($o+4)
 $lab=Str ($o+12) 128
 $unit=Str ($o+12+256) 16
 $val=$v.ReadDouble($o+12+256+16)
 $mn=$v.ReadDouble($o+12+256+16+8); $mx=$v.ReadDouble($o+12+256+16+16); $av=$v.ReadDouble($o+12+256+16+24)
 "{0} | {1} | {2} | {3} | min {4} | max {5} | avg {6}" -f $names[[int]$idx],$lab,$val,$unit,$mn,$mx,$av
}
