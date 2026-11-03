# Başlamadan önce

Ayarları uygulamadan önce bu sayfadaki hazırlığı yapın. Taban ölçümü olmadan, bir ayarın sizin sisteminizde işe yarayıp yaramadığını göremezsiniz.

## 1. Depoyu indirin

1. GitHub sayfasında **Code → Download ZIP** seçin ve klasörü açın. Git kullanıyorsanız: `git clone https://github.com/cullewie/cs2-bios-settings`.
2. PowerShell'i **yönetici olarak** açın ve depo klasörüne geçin.
3. Betiklerin bu pencerede çalışmasına izin verin. Bu ayar yalnızca açık pencere için geçerlidir:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   ```

4. Mevcut durumu görün. Kontrol betiği yalnızca okur ([Kontrol](verification.md)):

   ```powershell
   .\scripts\check\Test-Configuration.ps1
   ```

## 2. Araçlar

Araçları yalnızca resmi sayfalarından indirin.

| Araç | Ne için | Gerekli mi |
|---|---|---|
| [MSI Afterburner](https://www.msi.com/Landing/afterburner/graphics-cards) | Ekran kartı profili ([Ekran kartı](gpu.md)) | Ekran kartı adımı için |
| [HWiNFO](https://www.hwinfo.com/download/) | FCLK, UCLK, saat ve sıcaklık kontrolü | Önerilir |
| [TestMem5](https://github.com/CoolCmd/TestMem5), [Karhu RAM Test](https://www.karhusoftware.com/ramtest/), [y-cruncher](http://www.numberworld.org/y-cruncher/) veya [MemTest86](https://www.memtest86.com/) | Bellek kararlılık testi ([BIOS](bios.md#bellek-kararlılık-testi)) | RAM'i elle ayarlıyorsanız zorunlu. EXPO/XMP'de önerilir. |
| [OCCT](https://www.ocbase.com/download) | İşlemci, ekran kartı ve ekran kartı belleği kararlılık testi | Hız aşırtma yapıyorsanız |
| [Unigine Superposition](https://benchmark.unigine.com/superposition), [MSI Kombustor](https://geeks3d.com/furmark/kombustor/) | Ekran kartı sınırını bulma ([Kendi sınırınızı bulma](gpu.md#kendi-sınırınızı-bulma)) | Ekran kartı sınırını kendiniz bulacaksanız |
| [CoreCycler](https://github.com/sp00n/corecycler) | Çekirdek bazında işlemci testi | Curve Optimizer değiştirecekseniz |
| [PresentMon 2.6.0](https://github.com/GameTechDev/PresentMon/releases) | Sunum kipi (Legacy Flip) kontrolü, gecikme ve akıcılık ölçümü | İsteğe bağlı. `PresentMon-2.6.0-x64.exe` dosyasını `scripts\windows\` klasörüne koyun. |

## 3. CS2'yi ölçüme hazırlayın

1. Benchmark haritasına abone olun: [CS2 FPS BENCHMARK DUST2](https://steamcommunity.com/sharedfiles/filedetails/?id=3240880604) (Workshop `3240880604`). Steam haritayı indirir.
2. CS2 → **Ayarlar → Oyun → Geliştirici konsolunu etkinleştir** değerini **Evet** yapın. Konsol tuşunu değiştirmeyin (1'in solundaki tuş). Otomasyon bu tuşu kullanır.
3. Steam → CS2 → **Özellikler → Başlatma seçenekleri** alanına `-condebug` ekleyin. Bu seçenek VProf sonuçlarını `console.log` dosyasına yazar. Yalnızca ölçüm için gerekir.
4. Ölçüm sırasında FACEIT'i kapatın. Otomasyon CS2'ye tuş gönderir.
5. Arka planda ağır çalışan uygulamaları kapatın. Bu sistemde Spotify'ın görüntü işleme süreci FPS'i ~%3 düşürdü ([Sapma kaynakları](methodology.md#sapma-kaynakları)).

Elle denemek için konsola `map_workshop 3240880604 de_dust2` yazın. Yaklaşık 129 saniye sonra konsolda `[VProf] FPS: Avg=…, P1=…` satırı görünür.

## 4. Taban ölçümü

Hiçbir ayarı değiştirmeden önce ölçün. CS2 açık ve ön planda olsun, konsol kapalı olsun. Koşu sırasında klavyeye ve fareye dokunmayın.

```powershell
# 1) 6 ısınma koşusu (~15 dakika). Yeni açılan CS2'de FPS ilk ~6 koşuda %1,2-1,3 düşer.
.\scripts\bench\Invoke-Cs2Benchmark.ps1 -Plan ISINMA:0xFFFF:6 -Warmups 6

# 2) 6 kayıt koşusu ve rapor
$bas = Get-Date -Format 'MM/dd HH:mm'
.\scripts\bench\Invoke-Cs2Benchmark.ps1 -Plan TABAN:0xFFFF:6 -Warmups 0
.\scripts\bench\Get-VProfReport.ps1 -Start $bas -Name TABAN
```

- Rapordaki Avg ve P1 medyanlarını not edin.
- Her ayar adımından sonra aynı iki komutu yeni bir CS2 oturumunda tekrarlayın (`TABAN` yerine adımın adını yazın).
- Ayrı oturumlar arasında ±%0,6 sapma normaldir. Daha küçük farklar ayar etkisi sayılmaz. Önemli bir kararı A-B-A sırasıyla doğrulayın: ayar A, ayar B, sonra yine ayar A ([Karar kuralı](methodology.md#karar-kuralı)).
- P1 tek koşuda ±%5 oynar. P1'i yalnızca çok koşunun ortalamasıyla değerlendirin.
- `0xFFFF` 16 mantıksal işlemcinin hepsini kullanır. CPU 0 dışlamasını ölçerken `0xFFFE` kullanın ([Windows](windows.md#cs2yi-cpu-0-dışında-çalıştırma)). Farklı işlemcide maskeyi şu komutla bulun: `'0x{0:X}' -f ((1 -shl [Environment]::ProcessorCount) - 1)`. Bu değer tüm işlemcilerdir. Bir eksiği CPU 0 hariçtir. Örnek: 12 mantıksal işlemcide `0xFFF` ve `0xFFE`. Betik, işlemci sayısını aşan maskeyi kabul etmez.

## 5. Yedek alın

- BIOS'ta mevcut ayarları profile kaydedin: **Tool → ASUS User Profile → Save to Profile**. Bir ayardan sonra sistem açılmazsa bu profile dönersiniz.
- BitLocker kullanıyorsanız kurtarma anahtarını hazır tutun.

---

**Sonraki adım:** [BIOS](bios.md) · [Belgeler dizini](README.md)
