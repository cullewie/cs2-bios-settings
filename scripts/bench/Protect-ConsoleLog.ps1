param(
  [Parameter(Mandatory = $true)][string[]]$Path,
  [Parameter(Mandatory = $true)][string]$OutDir,
  [string[]]$Name = @(),
  [string]$MapOut = '')
# CS2 console.log yedeklerini yayin icin anonimlestirir. Kaynak dosyalara dokunmaz; ciktilar -OutDir altina yazilir.
# -Path: .log dosyalari veya klasorler (alt klasorler dahil). -Name: ek oyuncu adlari; ayni oyuncunun farkli yazimlari '|' ile ayrilir.
# - Oyuncu adlari -> player1, player2, ... Once -Name sirasi, sonra "ad<n><[U:1:...]>" satirlarindan bulunan insan oyuncular. Bot adlari degismez.
#   Ad eslesmesi buyuk/kucuk harf duyarsizdir ve harflerden sonra gelen birlesik aksanlari da kapsar.
# - SteamID64 (7656119 + 10 hane) -> ***, [U:1:n] -> [U:1:***], hesap numarasi (userdata\n ve [U:1:n] icinden bulunur) her yerde -> ***
# - IPv4 (0.0.0.0, 127.x, 255.255.255.255 haric) -> RFC 5737 belgeleme adreslerinden tutarli sahte adres (192.0.2.x, 198.51.100.x, 203.0.113.x). Port korunur.
# - "Ping location:" satirinin degeri -> *** (veri merkezi ping'leri yaklasik konumu verir)
# - Satir basi saati "MM/dd HH:mm:ss" -> ilk satirin tarihi + logun basindan gecen sure (gunun saati gizlenir)
# - Cikti adi: YYYY-AA-GG_<etiket>.log (Backup-ConsoleLog.ps1 adindan, saat kaldirilir). Ad bu bicimde degilse dosya adi korunur.
# - Birebir ayni loglar ve baska bir logun basi olan loglar yazilmaz. Satir sonu LF, UTF-8 (BOM yok).
# -MapOut: gercek -> sahte eslesme tablosu. Bu dosya kisisel bilgi icerir, yayimlamayin.
# Ciktiyi yayimlamadan once yine de gozle kontrol edin: betik yalniz yukaridaki kaliplari degistirir.
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding $false
$ic = [Text.RegularExpressions.RegexOptions]::IgnoreCase
New-Item -ItemType Directory -Force $OutDir | Out-Null

$files = foreach ($p in $Path) {
  if (Test-Path -LiteralPath $p -PathType Container) { Get-ChildItem -LiteralPath $p -Recurse -File -Filter *.log }
  elseif (Test-Path -LiteralPath $p -PathType Leaf) { Get-Item -LiteralPath $p }
  else { throw "bulunamadi: $p" }
}
$files = @($files | Sort-Object Name)
if ($files.Count -eq 0) { throw "log bulunamadi: $($Path -join ', ')" }
$text = @{}
foreach ($f in $files) { $text[$f.FullName] = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::UTF8).Replace("`r`n", "`n") }

# Baska bir logun basi olan (veya onunla ayni) loglar yazilmaz. CS2 her acilista console.log'u sifirlar; ayni oturumun ara yedekleri son yedegin basidir.
$skip = @{}
for ($i = 0; $i -lt $files.Count; $i++) {
  $a = $text[$files[$i].FullName]
  for ($j = 0; $j -lt $files.Count; $j++) {
    if ($i -eq $j) { continue }
    $b = $text[$files[$j].FullName]
    if (($b.Length -gt $a.Length -or ($b.Length -eq $a.Length -and $j -lt $i)) -and $b.StartsWith($a, [StringComparison]::Ordinal)) { $skip[$files[$i].FullName] = $files[$j].Name; break }
  }
}

# Oyuncular
function AliasPattern([string]$a) { ($a.ToCharArray() | ForEach-Object { [regex]::Escape([string]$_) + '\p{Mn}*' }) -join '' }
$players = New-Object System.Collections.Generic.List[object]
foreach ($n in $Name) { $al = @($n -split '\|' | Where-Object { $_ }); if ($al.Count) { $players.Add($al) } }
$found = foreach ($t in $text.Values) { foreach ($m in [regex]::Matches($t, '"([^"\n<>]{1,64})<\d+><\[U:1:\d+\]>')) { $m.Groups[1].Value } }
foreach ($fn in @($found | Sort-Object -Unique)) {
  $known = $false
  foreach ($al in $players) { foreach ($a in $al) { if ([regex]::IsMatch($fn.Normalize([Text.NormalizationForm]::FormC), '^' + (AliasPattern $a.Normalize([Text.NormalizationForm]::FormC)) + '$', $ic)) { $known = $true } } }
  if (-not $known) { $players.Add(@($fn)) }
}
$nameRes = New-Object System.Collections.Generic.List[object]
# Her ad hem birlesik (NFC) hem ayrik (NFD) Unicode yazimiyla aranir: "e" + birlesik aksan ile tek karakterlik aksanli "e" ayni ad sayilir.
for ($k = 0; $k -lt $players.Count; $k++) {
  # Select-Object -Unique kultur karsilastirmasi yapar ve NFC/NFD yazimlarini ayni sayar; bu yuzden sirali (ordinal) kume.
  $forms = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
  foreach ($a in $players[$k]) { [void]$forms.Add($a); [void]$forms.Add($a.Normalize([Text.NormalizationForm]::FormC)); [void]$forms.Add($a.Normalize([Text.NormalizationForm]::FormD)) }
  foreach ($a in $forms) { $nameRes.Add([pscustomobject]@{ Len = $a.Length; Re = [regex]::new((AliasPattern $a), $ic); Rep = 'player' + ($k + 1) }) }
}
$nameRes = @($nameRes | Sort-Object Len -Descending)

# Hesap numaralari (SteamID32)
$ids = foreach ($t in $text.Values) { foreach ($m in [regex]::Matches($t, '\[U:1:(\d+)\]|(?i:userdata)[\\/](\d+)')) { if ($m.Groups[1].Success) { $m.Groups[1].Value } else { $m.Groups[2].Value } } }
$idRes = @($ids | Where-Object { $_.Length -ge 5 } | Sort-Object -Unique | ForEach-Object { [regex]::new('(?<!\d)' + $_ + '(?!\d)') })

$ipMap = @{}; $script:next = 0
$pools = @('192.0.2.', '198.51.100.', '203.0.113.')
function FakeIp([string]$ip) {
  if (-not $ipMap.ContainsKey($ip)) {
    $n = $script:next; $script:next++
    if ($n -ge 762) { throw 'sahte IP havuzu bitti (762)' }
    $ipMap[$ip] = $pools[[int][Math]::Floor($n / 254)] + (($n % 254) + 1)
  }
  $ipMap[$ip]
}
$sid64Re = [regex]::new('\b7656119\d{10}\b')
$u1Re = [regex]::new('\[U:1:\d+\]')
$udRe = [regex]::new('(userdata[\\/])\d+', $ic)
$pingRe = [regex]::new('(Ping location:).*$')
$ipRe = [regex]::new('(?<![\d.])((?:25[0-5]|2[0-4]\d|1?\d?\d)(?:\.(?:25[0-5]|2[0-4]\d|1?\d?\d)){3})(?![\d.])')
$ipEval = [Text.RegularExpressions.MatchEvaluator] { param($mm) $ip = $mm.Groups[1].Value; if ($ip -eq '0.0.0.0' -or $ip -eq '255.255.255.255' -or $ip.StartsWith('127.')) { $ip } else { FakeIp $ip } }
$tsRe = [regex]::new('^(\d\d)/(\d\d) (\d\d):(\d\d):(\d\d)')

$report = New-Object System.Collections.Generic.List[object]
foreach ($f in $files) {
  # Atlanan loglar da islenir: sahte IP numaralari hangi loglarin yazildigindan bagimsiz kalir.
  $lines = $text[$f.FullName].Split("`n")
  if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq '') { $lines = $lines[0..($lines.Count - 2)] }
  $sb = New-Object System.Text.StringBuilder
  $t0 = $null; $d0 = $null
  foreach ($l in $lines) {
    $x = $l
    $tm = $tsRe.Match($x)
    if ($tm.Success) {
      $sec = [int]$tm.Groups[3].Value * 3600 + [int]$tm.Groups[4].Value * 60 + [int]$tm.Groups[5].Value
      if ($null -eq $t0) { $t0 = $sec; $d0 = $tm.Groups[1].Value + '/' + $tm.Groups[2].Value }
      $rel = $sec - $t0; if ($rel -lt 0) { $rel += 86400 }
      $x = ('{0} {1:00}:{2:00}:{3:00}' -f $d0, [Math]::Floor($rel / 3600), [Math]::Floor(($rel % 3600) / 60), ($rel % 60)) + $x.Substring($tm.Length)
    }
    foreach ($r in $nameRes) { $x = $r.Re.Replace($x, $r.Rep) }
    $x = $sid64Re.Replace($x, '***')
    $x = $u1Re.Replace($x, '[U:1:***]')
    $x = $udRe.Replace($x, '$1***')
    foreach ($r in $idRes) { $x = $r.Replace($x, '***') }
    $x = $pingRe.Replace($x, '$1 ***')
    $x = $ipRe.Replace($x, $ipEval)
    [void]$sb.Append($x).Append("`n")
  }
  if ($skip.ContainsKey($f.FullName)) { $report.Add([pscustomobject]@{ Kaynak = $f.Name; Cikti = '(yazilmadi: ' + $skip[$f.FullName] + ' basi)'; Satir = $lines.Count }); continue }
  $m = [regex]::Match($f.BaseName, '^(.*?)_?(20\d\d)(\d\d)(\d\d)_(\d{4,6})(?:_(.*))?$')
  if ($m.Success) {
    $label = (@($m.Groups[1].Value, $m.Groups[6].Value) | Where-Object { $_ }) -join '_'
    $base = '{0}-{1}-{2}_{3}' -f $m.Groups[2].Value, $m.Groups[3].Value, $m.Groups[4].Value, $label
  } else { $base = $f.BaseName }
  $outName = $base + '.log'; $k = 2
  while (Test-Path -LiteralPath (Join-Path $OutDir $outName)) { $outName = '{0}_{1}.log' -f $base, $k; $k++ }
  [IO.File]::WriteAllText((Join-Path $OutDir $outName), $sb.ToString(), $utf8)
  $report.Add([pscustomobject]@{ Kaynak = $f.Name; Cikti = $outName; Satir = $lines.Count })
}
$report | Format-Table -AutoSize | Out-String -Width 200
'yazilan: {0} / {1} log | oyuncu: {2} | hesap numarasi: {3} | farkli IP: {4}' -f @($report | Where-Object { $_.Cikti -notlike '(*' }).Count, $files.Count, $players.Count, $idRes.Count, $ipMap.Count
if ($MapOut) {
  $map = New-Object System.Collections.Generic.List[string]
  for ($k = 0; $k -lt $players.Count; $k++) { $map.Add(('player{0} <- {1}' -f ($k + 1), ($players[$k] -join ' | '))) }
  $ipMap.GetEnumerator() | Sort-Object Value | ForEach-Object { $map.Add(('{0} <- {1}' -f $_.Value, $_.Key)) }
  [IO.File]::WriteAllLines($MapOut, $map, $utf8)
}
