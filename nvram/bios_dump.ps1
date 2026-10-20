param([Parameter(Mandatory=$true)][string]$SnapDir, [Parameter(Mandatory=$true)][string]$IfrFile, [Parameter(Mandatory=$true)][string]$OutCsv, [string]$OutMd = '')
# Salt okunur: bir NVRAM anlik goruntusundeki (nvram_snap.ps1 ciktisi) ham baytlari BIOS sozlugu (ifr_all.tsv) ile birlestirir,
# her ayari menu yolu + simdiki deger + secenek metni olarak yazar. OutMd verilirse (1) varsayilandan farkli ayarlari,
# (2) Ai Tweaker / RAM zamanlama / voltaj / PBO formlarinin tam listesini ayri bir okunur dosyaya yazar.
# Secenek metni sonundaki '*' = standart varsayilan, 'm' = uretim (MFG) varsayilani (BiosIfr.cs satir 420).
$bins = @{}
foreach ($f in (Get-ChildItem $SnapDir -Filter *.bin)) { $bins[[IO.Path]::GetFileNameWithoutExtension($f.Name)] = [IO.File]::ReadAllBytes($f.FullName) }
$rows = Import-Csv $IfrFile -Delimiter "`t"
# '*' ile isaretli secenek metinlerinden temiz kelime sozlugu (sondaki 'm' isaretini ayirt etmek icin)
$V = @{}
foreach ($r in $rows) { if ($r.Options) { foreach ($o in ($r.Options -split '; ')) { $p = $o -split '=', 2; if ($p.Count -eq 2 -and $p[1] -match '\*m?$') { $V[($p[1] -replace '\*m?$', '')] = 1 } } } }
function OptFlag([string]$t) {
  if ($t -match '\*m?$') { return 'S' }
  if ($t.Length -gt 1 -and $t.EndsWith('m') -and $V.ContainsKey($t.Substring(0, $t.Length - 1))) { return 'M' }
  return ''
}
function OptClean([string]$t) {
  $f = OptFlag $t
  if ($f -eq 'S') { return ($t -replace '\*m?$', '') }
  if ($f -eq 'M') { return $t.Substring(0, $t.Length - 1) }
  return $t
}
$seen = @{}
$out = New-Object System.Collections.Generic.List[object]
foreach ($r in $rows) {
  if (-not $r.VarStore -or -not $r.OffsetHex) { continue }
  if (-not $bins.ContainsKey($r.VarStore)) { continue }
  $sz = 0
  if (-not [int]::TryParse($r.Size, [ref]$sz)) { continue }
  if ($sz -ne 1 -and $sz -ne 2 -and $sz -ne 4 -and $sz -ne 8) { continue }
  $off = [Convert]::ToInt32($r.OffsetHex, 16); $b = $bins[$r.VarStore]
  if (($off + $sz) -gt $b.Length) { continue }
  $key = $r.VarStore + '|' + $r.OffsetHex + '|' + $r.Prompt
  if ($seen.ContainsKey($key)) { continue }
  $seen[$key] = 1
  [uint64]$val = 0
  if ($sz -eq 1) { $val = [uint64]$b[$off] } elseif ($sz -eq 2) { $val = [uint64][BitConverter]::ToUInt16($b, $off) } elseif ($sz -eq 4) { $val = [uint64][BitConverter]::ToUInt32($b, $off) } else { $val = [BitConverter]::ToUInt64($b, $off) }
  $vs = [string]$val
  $optText = ''
  $stdSet = New-Object 'System.Collections.Generic.HashSet[string]'; $altSet = New-Object 'System.Collections.Generic.HashSet[string]'
  foreach ($m in [regex]::Matches([string]$r.Defaults, '(\d+):(\d+)')) { if ($m.Groups[1].Value -eq '0') { [void]$stdSet.Add($m.Groups[2].Value) } else { [void]$altSet.Add($m.Groups[2].Value) } }
  if ($r.Options) {
    foreach ($o in ($r.Options -split '; ')) {
      $p = $o -split '=', 2
      if ($p.Count -ne 2) { continue }
      $fl = OptFlag $p[1]
      if ($fl -eq 'S') { [void]$stdSet.Add($p[0]) } elseif ($fl -eq 'M') { [void]$altSet.Add($p[0]) }
      if ($p[0] -eq $vs) { $optText = OptClean $p[1] }
    }
  }
  $isDef = '?'
  if ($stdSet.Count -gt 0) { $isDef = $(if ($stdSet.Contains($vs)) { 'E' } else { 'H' }) }
  elseif ($altSet.Count -gt 0) { $isDef = $(if ($altSet.Contains($vs)) { 'E' } else { 'H' }) }
  $out.Add([pscustomobject]@{ Form = $r.Form; Prompt = $r.Prompt; VarStore = $r.VarStore; Off = $r.OffsetHex.ToUpper(); Size = $sz; Value = $val; ValueHex = ('0x{0:X}' -f $val); Option = $optText; Default = $isDef; Sup = $r.Sup; Gray = $r.Gray; Range = $r.Range; Kind = $r.Kind })
}
$out | Export-Csv -Path $OutCsv -NoTypeInformation -Encoding UTF8
'satir: ' + $out.Count + '  (varsayilan: ' + @($out | Where-Object { $_.Default -eq 'E' }).Count + ', varsayilandan farkli: ' + @($out | Where-Object { $_.Default -eq 'H' }).Count + ', belirsiz: ' + @($out | Where-Object { $_.Default -eq '?' }).Count + ')'
if ($OutMd) {
  function Line($e) { return '- ' + $e.Prompt + ' = ' + $(if ($e.Option) { $e.Option + ' [' + $e.Value + ']' } else { [string]$e.Value }) + '  (' + $e.VarStore + '@' + $e.Off + ')' + $(if ($e.Sup -eq 'GIZLI') { ' (gizli)' } else { '' }) }
  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add('# BIOS durumu - okunur dokum (NVRAM anlik goruntusunden, salt okunur)')
  $lines.Add('')
  $lines.Add('Kaynak anlik goruntu: ' + $SnapDir)
  $lines.Add('Uretim zamani: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '. Tum ayarlar icin ayni klasordeki bios_durum_*.csv dosyasina bak.')
  $lines.Add('Menu yolu: Form > Ayar = secili deger [ham deger] (degisken@ofset). (gizli) = BIOS menusunde gorunmeyen oge.')
  $lines.Add('Voltaj kodu: volt = 0.79 + 0.01 x kod (DRAM VDD/VDDQ, ornek 81 = 1.60 V).')
  $lines.Add('')
  $lines.Add('## 1) Varsayilandan farkli ayarlar (yalniz secenekli ayarlar; aktif platform: AmdSetupPHX / AmdSetupSTXKRK kopyalari atlandi)')
  $lines.Add('')
  foreach ($g in ($out | Where-Object { $_.Default -eq 'H' -and $_.VarStore -ne 'AmdSetupPHX' -and $_.VarStore -ne 'AmdSetupSTXKRK' } | Group-Object Form | Sort-Object Name)) {
    $lines.Add('### ' + $g.Name)
    foreach ($e in $g.Group) { $lines.Add((Line $e)) }
    $lines.Add('')
  }
  $lines.Add('## 2) Tam liste: Ai Tweaker, RAM zamanlama/voltaj, PBO, Core Flex (varsayilan olsun olmasin)')
  $lines.Add('')
  foreach ($fm in 'Ai Tweaker', 'DRAM Timing Control', 'Advanced Memory Voltages', 'Precision Boost Overdrive', 'Core Flex') {
    $lines.Add('### ' + $fm)
    foreach ($e in ($out | Where-Object { $_.Form -eq $fm -and $_.VarStore -ne 'AmdSetupPHX' -and $_.VarStore -ne 'AmdSetupSTXKRK' })) { $lines.Add((Line $e)) }
    $lines.Add('')
  }
  $co = @($out | Where-Object { $_.Form -eq 'Curve Optimizer' })
  $coNz = @($co | Where-Object { $_.Value -ne 0 })
  $lines.Add('### Curve Optimizer')
  $lines.Add('- ' + $co.Count + ' alan okundu, 0 olmayan: ' + $coNz.Count + $(if ($coNz.Count -gt 0) { ' -> ' + (($coNz | ForEach-Object { $_.Prompt + '=' + $_.Value }) -join '; ') } else { ' (hepsi Auto/0)' }))
  $lines.Add('')
  [IO.File]::WriteAllLines($OutMd, $lines, (New-Object Text.UTF8Encoding($false)))
  'ozet yazildi: ' + $OutMd + '  (' + $lines.Count + ' satir)'
}
