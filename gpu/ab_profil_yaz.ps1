# MSI Afterburner profil yuvasini yazar ve uygular. Birimler: Core/Mem MHz (Afterburner birimi, nvidia-smi ile 1:1), PL yuzde.
# Fan: -1 = fan satiri yazilmaz (kartin otomatik egrisi kalir), 0-100 = sabit yuzde (yalniz olcum tutarliligi icin).
# Afterburner kapatilir, [ProfileN] yeniden yazilir, "-ProfileN" ile acilir; sonra nvidia-smi ile dogrulanir. Yonetici gerekir.
# Ornek: .\ab_profil_yaz.ps1 -Slot 5 -Core 450 -Mem 3000 -PL 116
param([ValidateRange(1, 5)][int]$Slot = 5, [int]$Core = 0, [int]$Mem = 0, [int]$PL = 100, [int]$Fan = -1,
  [string]$AbDir = 'C:\Program Files (x86)\MSI Afterburner')
$profs = @(Get-ChildItem (Join-Path $AbDir 'Profiles') -Filter 'VEN_10DE*.cfg' -ErrorAction SilentlyContinue)
if ($profs.Count -ne 1) { "HATA: Profiles klasorunde tek NVIDIA profil dosyasi bekleniyordu, bulunan: $($profs.Count). Afterburner'i bir kez acip kapatin."; return }
$prof = $profs[0].FullName
$p = Get-Process MSIAfterburner -ErrorAction SilentlyContinue
if ($p) { [void]$p.CloseMainWindow(); for ($i = 0; $i -lt 20; $i++) { if (-not (Get-Process -Id $p.Id -ErrorAction SilentlyContinue)) { break }; Start-Sleep -Milliseconds 500 }; if (Get-Process -Id $p.Id -ErrorAction SilentlyContinue) { Stop-Process -Id $p.Id -Force } }
$enc = [Text.Encoding]::Default
Copy-Item $prof "$prof.yedek" -Force
$t = [IO.File]::ReadAllText($prof, $enc)
$t = [regex]::Replace($t, "(?s)\[Profile$Slot\].*?(?=\r?\n\[|\z)", '').TrimEnd()
$t += "`r`n[Profile$Slot]`r`nFormat=2`r`nPowerLimit=$PL`r`nCoreClkBoost=$($Core * 1000)`r`nMemClkBoost=$($Mem * 1000)`r`nCoreVoltageBoost=0`r`n"
# Fan satirlari yalniz sabit fan isteniyorsa; FanMode2/3 yazmak Afterburner'da FanSync'i kapatabiliyor
if ($Fan -ge 0) { $t += "FanMode=0`r`nFanSpeed=$Fan`r`n" }
[IO.File]::WriteAllText($prof, $t, $enc)
Start-Process (Join-Path $AbDir 'MSIAfterburner.exe') -ArgumentList "-Profile$Slot"
Start-Sleep -Seconds 7
'Profil{0}: cekirdek +{1} | bellek +{2} | guc %{3} | fan {4} | nvidia-smi: {5}' -f $Slot, $Core, $Mem, $PL, $(if ($Fan -lt 0) { 'otomatik' } else { "%$Fan" }), ((& nvidia-smi --query-gpu=power.limit,fan.speed,clocks.gr,clocks.mem --format=csv,noheader) -join '')
