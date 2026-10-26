param([Parameter(Mandatory=$true)][string]$A, [Parameter(Mandatory=$true)][string]$B,
      [string]$Decoded = '', [string]$IfrFile = '')
# Salt okunur: iki NVRAM anlik goruntusunu karsilastirir, degisen baytlari alan/ayar adlariyla yazar.
$ia = Import-Csv (Join-Path $A 'index.csv'); $ib = Import-Csv (Join-Path $B 'index.csv')
$ha = @{}; foreach ($r in $ia) { $ha[$r.Name + '|' + $r.Guid] = $r }
$hb = @{}; foreach ($r in $ib) { $hb[$r.Name + '|' + $r.Guid] = $r }
"A: " + ((Get-Content (Join-Path $A 'meta.txt') -TotalCount 2) -join ' / ')
"B: " + ((Get-Content (Join-Path $B 'meta.txt') -TotalCount 2) -join ' / ')
$storeOf = @{ 'VARSTORE_OCMR_SETTINGS_NAME' = 'OCMR'; 'AodSetupRpl' = 'AOD'; 'AmdSetupRPL' = 'CBS'; 'AMD_PBS_SETUP' = 'PBS'; 'Setup' = 'SETUP' }
$dec = @{}
if ($Decoded -and (Test-Path $Decoded)) {
  foreach ($r in (Import-Csv $Decoded)) { if (-not $dec.ContainsKey($r.Store)) { $dec[$r.Store] = New-Object System.Collections.Generic.List[object] }; $dec[$r.Store].Add([pscustomobject]@{ Off = [Convert]::ToInt32($r.Off, 16); W = [int]$r.W; Name = $r.Name }) }
}
$ifrMap = @{}
if ($IfrFile -and (Test-Path $IfrFile)) {
  foreach ($r in (Import-Csv $IfrFile -Delimiter "`t")) {
    $blob = (($r.Blob -split '/')[-1] -replace ' \[.*', '').Substring(0, 8)
    if ($r.VarStore -and $r.OffsetHex -and ($blob -eq '899407D7' -or $blob -eq 'B8B6F485')) {
      $k = $r.VarStore + '|' + $r.OffsetHex.ToUpper()
      if (-not $ifrMap.ContainsKey($k)) { $ifrMap[$k] = $r }
    }
  }
}
function OptText($opts, $val) {
  if (-not $opts) { return '' }
  foreach ($o in ($opts -split '; ')) { $p = $o -split '=', 2; if ($p.Count -eq 2 -and $p[0] -eq [string]$val) { return $p[1].TrimEnd('*', 'm') } }
  return ''
}
$changedVars = 0
foreach ($k in $hb.Keys) {
  $rb = $hb[$k]
  if (-not $ha.ContainsKey($k)) { "YENI degisken: " + $rb.Name + " " + $rb.Guid + " boyut=" + $rb.Size; continue }
  $ra = $ha[$k]
  if ($ra.Sha256 -eq $rb.Sha256) { continue }
  $changedVars++
  $fa = Join-Path $A ($rb.Name + '.bin'); $fb = Join-Path $B ($rb.Name + '.bin')
  if (-not ((Test-Path $fa) -and (Test-Path $fb))) { "DEGISTI (ham bayt kaydedilmedi): " + $rb.Name + " boyut " + $ra.Size + " -> " + $rb.Size; continue }
  $xa = [IO.File]::ReadAllBytes($fa); $xb = [IO.File]::ReadAllBytes($fb)
  $n = [Math]::Min($xa.Length, $xb.Length)
  $diffs = New-Object System.Collections.Generic.List[int]
  for ($i = 0; $i -lt $n; $i++) { if ($xa[$i] -ne $xb[$i]) { $diffs.Add($i) } }
  "=== " + $rb.Name + "  boyut " + $xa.Length + " -> " + $xb.Length + "  degisen bayt: " + $diffs.Count
  $store = $storeOf[$rb.Name]
  $shown = 0
  foreach ($i in $diffs) {
    if ($shown -ge 80) { "   ... (" + ($diffs.Count - $shown) + " bayt daha)"; break }
    $field = ''
    if ($store -and $dec.ContainsKey($store)) { foreach ($e in $dec[$store]) { if ($i -ge $e.Off -and $i -lt ($e.Off + $e.W)) { $field = $store + '.' + $e.Name + ' @' + ('{0:X4}' -f $e.Off); break } } }
    $menu = ''
    $ik = $rb.Name + '|' + ('{0:X4}' -f $i)
    if ($ifrMap.ContainsKey($ik)) { $q = $ifrMap[$ik]; $menu = ' | ' + $q.Form + ' > ' + $q.Prompt; $ot = OptText $q.Options $xb[$i]; $oo = OptText $q.Options $xa[$i]; if ($ot -or $oo) { $menu += '  [' + $oo + ' -> ' + $ot + ']' } }
    "   @{0:X4}  {1} -> {2}   {3}{4}" -f $i, $xa[$i], $xb[$i], $field, $menu
    $shown++
  }
}
"Degisen degisken sayisi: $changedVars"
