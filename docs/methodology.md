# Ölçüm yöntemi

Bu sayfa, sonuçların nasıl ölçüldüğünü ve nasıl okunacağını açıklar.

## Test sistemi

| Parça | Değer |
|---|---|
| İşlemci | AMD Ryzen 7 9800X3D (8 çekirdek, 16 thread, tek CCD, 3D V-Cache) |
| Anakart | ASUS ROG STRIX X870-A GAMING WIFI |
| BIOS | 2503 (2402 sürümünden güncellendi) |
| Bellek | G.Skill F5-8000J4048F24GX2-TZ5RK, 2 × 24 GB, SK Hynix M-die, tek rank, A2 ve B2 yuvaları |
| Ekran kartı | GIGABYTE GeForce RTX 5070 Ti AERO OC 16G |
| Ekran | Alienware AW2523HF, 1920×1080, 360 Hz, DisplayPort |
| Soğutucu | Arctic Liquid Freezer III Pro 360 |
| Depolama | Samsung 980 PRO 500 GB |
| İşletim sistemi | Windows 11 Pro, derleme 26300 |
| Ekran kartı sürücüsü | NVIDIA 617.42 |
| Ekran kartı ayar aracı | MSI Afterburner 4.6.6 |
| Ağ bağdaştırıcısı | Intel I226-V, 2,5 Gbps |
| Fare | 8000 Hz yoklama hızı, kablosuz alıcı |

## Benchmark

- **Harita:** Steam Workshop `3240880604` (de_dust2). Konsolda `map_workshop 3240880604 de_dust2` komutunu yazın.
- **Koşu süresi:** Yaklaşık 129 saniye. Koşu sonunda CS2, VProf özetini `console.log` dosyasına yazar.
- **Ayarlar:** Tüm koşularda aynıydı: 1280×960, tam ekran, 360 Hz, `fps_max 0` ve FACEIT kapalı. Gölge kalitesi 26.10'a kadar Düşük, sonra Yüksek. HWiNFO yalnızca bazı testlerde açıktı.
- **Otomasyon:** [`Invoke-Cs2Benchmark.ps1`](../scripts/bench/Invoke-Cs2Benchmark.ps1) konsolu açar, haritayı yükler ve sonucu bekler. Ayrıntı: [scripts/README.md](../scripts/README.md).

## Karar kuralı

- **Ayrı oturumlar (BIOS testleri):** Her ayar için 6 kayıt koşusunun medyanı ve aralığı karşılaştırıldı. Aralıklar çakışmıyorsa fark **kesin** kabul edildi. Fark %0,6'dan küçükse oturum sapmasından ayırt edilemez.
- **Aynı oturum (Windows testleri):** Koşullar dönüşümlü sırayla çalıştırıldı. Eşleştirilmiş t testi uygulandı. 6 turda |t| > 2,571 ve 3 turda |t| > 4,30 olduğunda fark anlamlı kabul edildi.

## Isınma koşuları ve sapma

- Her yeni CS2 oturumunda ortalama FPS, ilk yaklaşık 6 koşuda %1,2 ile %1,3 düşer. Sonra değer sabitlenir.
- Bu nedenle BIOS testlerinde her oturumun ilk 6 koşusu **ısınma koşusu** sayıldı. Bu koşular sonuçlara alınmadı.
- Aynı BIOS ayarı iki ayrı oturumda ölçüldüğünde fark %0,55 çıktı.

## Ekran kartı ve Windows testleri

- Karşılaştırılan koşullar aynı CS2 oturumunda ABBA sırasıyla çalıştırıldı. 2×2 testte ikinci oturum ters sırayla çalıştırıldı. Bu yöntem oturum içindeki doğrusal kaymayı dengeler.
- 26.10'dan itibaren koşullar bloklu sırayla da ölçüldü: önce 2 ısınma koşusu, sonra her koşul art arda 3 koşu (A A A, B B B, C C C). Bu düzende sonraki bloklar oturum içi kaymadan etkilenir. Fark, blok içi eğimle düzeltilerek ve ham değerle birlikte verildi.
- Her koşuda `nvidia-smi` saniyede bir GPU saatini, bellek saatini, gücü ve sıcaklığı kaydetti.
- Her koşudan sonra System günlüğünde `nvlddmkm` ve Display 4101 (TDR) olayları kontrol edildi. CS2'nin açık olduğu kontrol edildi.
- Kesme örnekleyicisi açıkken yapılan koşular karşılaştırmaya alınmadı.

## Sapma kaynakları

Aynı ayarlarla farklı günlerde farklı sonuç alınabilir. Ölçülen nedenler:

| Neden | Etki | Not |
|---|---|---|
| Oturum içi kayma | İlk ~6 koşuda −%1,2 ile −%1,3, sonra koşu başına ~0,8 ile 1,3 FPS | Isınma koşuları ve dengeli sıra ile giderilir |
| Aynı ayar, iki ayrı oturum | %0,23 ile %0,55 | Bu değerden küçük farklar ayırt edilemez |
| CS2 güncellemesi | %1 ile %2 | Her oturumdan önce `appmanifest_730.acf` içindeki `LastUpdated` değerine bakın |
| Arka planda çalışan uygulama | Ortalama FPS ~−%3, P1 ~−%8 | 25.10: Spotify'ın görüntü işleme süreci yaklaşık 1 çekirdek kullandı. Aynı oturumdaki dönüşümlü karşılaştırmalar etkilenmedi. |
| Oyun içi ayar | Gölge kalitesi Yüksek: ortalama FPS −%5,8 | 26.10'dan sonraki sonuçlar öncekilerle doğrudan karşılaştırılamaz |

> [!TIP]
> Farklı günlerin sonuçlarını karşılaştırmadan önce CS2 sürümünü, oyun ayarlarını ve arka planda çalışan uygulamaları kontrol edin. En güvenilir karşılaştırma, aynı oturumda dönüşümlü sırayla yapılır.

## VProf çıktısı

```text
[VProf] Summary of 122110 frames and 129 1-second intervals.
[VProf] FPS: Avg=943.7, P1=349.1
[VProf]           FrameTotal   1.06   2.86   122110   1.06   2.86     3.18   4.06      129   3.18   4.06
```

VProf bazı kareleri analizden çıkarır. Bu nedenle P1 ve P99 değerleri, PresentMon veya CapFrameX değerleriyle birebir aynı değildir.

P1 değeri tek koşuda çok değişkendir. Aynı oturumda, aynı ayarla 333 ile 380 arasında değerler ölçüldü (±%5). P1 farklarını yalnızca çok koşunun ortalamasıyla değerlendirin.

## PresentMon

- Sürüm 2.6.0, konsol uygulaması (Intel, GitHub). Kurulum gerekmez. [`Compare-PresentMode.ps1`](../scripts/windows/Compare-PresentMode.ps1) CS2 oturumu boyunca kayıt alır ve her koşu için özet çıkarır.
- **Gecikme:** "Kare başlangıcından ekrana" = (sunum zamanı − CPU kare başlangıcı) + `MsUntilDisplayed`. Fare, USB ve ekran panelinin süresi dahil değildir. Tıklamadan ekrana süre için donanım gerekir (LDAT, OSLTT veya ışık sensörlü Teensy).
- CS2, Reflex kapalıyken PC Latency verisi göndermez (`MsPCLatency` = NA).
- **PresentMon'un FPS değerini kullanmayın.** Bu sistemde ETW olay kaybı yüzünden kareleri eksik saydı: Independent Flip'te %3, Legacy Flip'te %10 eksik. FPS için VProf kullanıldı. Gecikme ve sunum kipi değerleri kaydedilen karelerden hesaplanır.
- `--date_time` çıktısındaki saat bu sistemde yerel saatten 3 saat ileriydi. Betik farkı kendisi düzeltir.

## Ölçüm sayıları

- **BIOS testleri:** 132 benchmark koşusu (86 kayıt, 44 ısınma, 2 ölçüm dışı), 2 maç, 13 CS2 oturumu ve 13 NVRAM görüntüsü. Hiçbir açılışta WHEA hatası veya Kernel-Power 41 olayı görülmedi.
- **Windows ve ekran kartı testleri:** 20 CS2 oturumunda 129 tamamlanan koşu (99 kayıt, 29 ısınma, 1 geçersiz) ve 3 yarıda kalan koşu (2 TDR, 1 ses aygıtı çökmesi). 53 Superposition koşusu (7'si çökme ile bitti). 24 kararlılık testi (12'si çökme ile bitti).

Ham veri ve sütun açıklamaları: [data/README.md](../data/README.md).

---

[Belgeler dizini](README.md)
