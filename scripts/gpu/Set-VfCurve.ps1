# MSI Afterburner'a VF egrisi undervolt profili yazar ve uygular (fpsheaven "undervolt + overclock" akisi).
# Sablon: profil dosyasindaki [Defaults] VFCurve (kartin stok egrisi). Hedef voltaj ve ustundeki noktalar hedef frekansa duzlenir;
# alttaki noktalar -LowOff ofsetinde kalir (hedef frekansi asmayacak sekilde kirpilir). Bellek/guc ofsetleri de yuvaya yazilir.
# VFCurve bicimi: u32 0x00020000, u32 nokta sayisi, u32 0; nokta basina 3 float (voltaj mV, taban MHz, ofset MHz); sonra ek alan (korunur).
# Frekans taban egriye gore nominaldir: yukte sicakliga gore daha dusuk calisir (bu kartta CS2'de ~58, Superposition'da ~75-95 MHz asagi).
# Fan satiri yazilmaz (kartin otomatik egrisi kalir). Afterburner kapatilir, yuva yazilir, "-ProfileN" ile acilir. Yonetici gerekir.
# Ornek: .\Set-VfCurve.ps1 -TargetMv 990 -FreqMhz 3245 -Slot 2
param([Parameter(Mandatory = $true)][int]$TargetMv, [Parameter(Mandatory = $true)][int]$FreqMhz, [int]$LowOff = 425,
  [int]$Mem = 3000, [int]$PL = 116, [ValidateRange(1, 5)][int]$Slot = 2, [string]$AbDir = 'C:\Program Files (x86)\MSI Afterburner')
$profs = @(Get-ChildItem (Join-Path $AbDir 'Profiles') -Filter 'VEN_10DE*.cfg' -ErrorAction SilentlyContinue)
if ($profs.Count -ne 1) { "HATA: Profiles klasorunde tek NVIDIA profil dosyasi bekleniyordu, bulunan: $($profs.Count). Afterburner'i bir kez acip kapatin."; return }
$prof = $profs[0].FullName
$enc = [Text.Encoding]::Default
$t = [IO.File]::ReadAllText($prof, $enc)
$hex = [regex]::Match([regex]::Match($t, '(?s)\[Defaults\](.*?)(?=\r?\n\[|\z)').Groups[1].Value, 'VFCurve=([0-9A-F]+)').Groups[1].Value
if (-not $hex) { 'HATA: [Defaults] bolumunde VFCurve yok (Afterburner stok egriyi bu dosyaya kaydetmemis).'; return }
$b = New-Object byte[] ($hex.Length / 2); for ($k = 0; $k -lt $b.Length; $k++) { $b[$k] = [Convert]::ToByte($hex.Substring($k * 2, 2), 16) }
$n = [BitConverter]::ToUInt32($b, 4); $tgtIdx = -1
for ($p = 0; $p -lt $n; $p++) {
  $o = 12 + $p * 12
  $v = [BitConverter]::ToSingle($b, $o); $base = [BitConverter]::ToSingle($b, $o + 4)
  if ($v -ge $TargetMv) { if ($tgtIdx -lt 0) { $tgtIdx = $p }; $off = [single]($FreqMhz - $base) }
  else { $off = [single][Math]::Min($LowOff, $FreqMhz - $base) }
  [Array]::Copy([BitConverter]::GetBytes([single]$off), 0, $b, $o + 8, 4)
}
if ($tgtIdx -lt 0) { 'HATA: hedef voltaj egride yok'; return }
$tv = [BitConverter]::ToSingle($b, 12 + $tgtIdx * 12); $tb = [BitConverter]::ToSingle($b, 12 + $tgtIdx * 12 + 4)
$newHex = -join ($b | ForEach-Object { $_.ToString('X2') })
$p = Get-Process MSIAfterburner -ErrorAction SilentlyContinue
if ($p) { [void]$p.CloseMainWindow(); for ($i = 0; $i -lt 20; $i++) { if (-not (Get-Process -Id $p.Id -ErrorAction SilentlyContinue)) { break }; Start-Sleep -Milliseconds 500 }; if (Get-Process -Id $p.Id -ErrorAction SilentlyContinue) { Stop-Process -Id $p.Id -Force } }
Copy-Item $prof "$prof.yedek" -Force
$t = [IO.File]::ReadAllText($prof, $enc)
$t = [regex]::Replace($t, "(?s)\[Profile$Slot\].*?(?=\r?\n\[|\z)", '').TrimEnd()
$t += "`r`n[Profile$Slot]`r`nFormat=2`r`nCoreVoltageBoost=0`r`nPowerLimit=$PL`r`nCoreClkBoost=0`r`nVFCurve=$newHex`r`nMemClkBoost=$($Mem * 1000)`r`n"
[IO.File]::WriteAllText($prof, $t, $enc)
Start-Process (Join-Path $AbDir 'MSIAfterburner.exe') -ArgumentList "-Profile$Slot"
Start-Sleep -Seconds 7
'Profil{0}: hedef nokta {1} mV (taban {2} MHz) -> {3} MHz, ustu duz, alti +{4} | bellek +{5} | guc %{6} | nvidia-smi: {7}' -f $Slot, $tv, $tb, $FreqMhz, $LowOff, $Mem, $PL, ((& nvidia-smi --query-gpu=power.limit,clocks.gr,clocks.mem --format=csv,noheader) -join '')
