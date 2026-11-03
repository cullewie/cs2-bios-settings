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
| Ekran kartı sürücüsü | NVIDIA 617.42 (26.10'a kadar), 621.01 (26.10 akşamı), 621.12 (02.11) |
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
- **Ayrı oturumlar (26.10 RAM ve BCLK testleri):** Her ayar ayrı bir oturumda 2 ısınma ve 3 kayıt koşusuyla ölçüldü. Koşular sıra numarasıyla eşleştirildi (eşleştirilmiş t testi, 5 sıra, |t| > 2,776). Ayrı oturumlar A-B-A sırasıyla kontrol edildi: ayar A, ayar B, sonra yine ayar A. Bu kontrol DDR5-6000 ve BCLK için tuttu: DDR5-6000'in (BCLK 100) iki oturumu arasındaki fark %0,03'tür (ısınma dahil 5 koşunun ortalaması; 3 kayıt koşusuyla %0,06). DDR5-8000 için tutmadı: aynı gün, aynı BIOS ayarıyla ölçülen iki oturum (`G20`, `G25`) arasında %1,22 fark çıktı (3 kayıt koşusu; 5 koşuyla %1,17). Bu nedenle DDR5-8000 ile yapılan karşılaştırma kesin sayılmadı ([BIOS: RAM](bios.md#ddr5-6000-11-alternatifi)).
- **Aynı oturum (Windows testleri):** Koşullar dönüşümlü sırayla çalıştırıldı. Eşleştirilmiş t testi uygulandı. 6 turda |t| > 2,571 ve 3 turda |t| > 4,30 olduğunda fark anlamlı kabul edildi.

## Isınma koşuları ve sapma

- Her yeni CS2 oturumunda ortalama FPS, ilk yaklaşık 6 koşuda %1,2 ile %1,3 düşer. Sonra değer sabitlenir.
- Bu nedenle BIOS testlerinde her oturumun ilk 6 koşusu **ısınma koşusu** sayıldı. Bu koşular sonuçlara alınmadı.
- Aynı BIOS ayarı iki ayrı oturumda ölçüldüğünde fark %0,03 ile %1,2 arasında çıktı (19.10: %0,55; 26.10, ısınma dahil 5 koşunun ortalamasıyla: DDR5-6000 ile %0,03, DDR5-8000 ile %1,17; 3 kayıt koşusuyla %0,06 ve %1,22).

## Ekran kartı ve Windows testleri

- Karşılaştırılan koşullar aynı CS2 oturumunda ABBA sırasıyla çalıştırıldı. 2×2 testte ikinci oturum ters sırayla çalıştırıldı. Bu yöntem oturum içindeki doğrusal kaymayı dengeler.
- 26.10'dan itibaren koşullar bloklu sırayla da ölçüldü: önce 2 ısınma koşusu, sonra her koşul art arda 3 koşu (A A A, B B B, C C C). Bu düzende sonraki bloklar oturum içi kaymadan etkilenir. Fark, blok içi eğimle düzeltilerek ve ham değerle birlikte verildi.
- 02.11 başlatma seçeneği testinde her blok yeni bir CS2 işlemiydi (2 ısınma ve 3 kayıt koşusu). Ortaya ve sona ek seçeneksiz kontrol blokları kondu (A, D, F). Her seçenek en yakın kontrol bloğuyla karşılaştırıldı. İlk kontrol bloğu, sonraki iki kontrol bloğundan %1,0 yüksek çıktı. Bu yüzden tek bir başlangıç kontrol bloğu yeterli değildir.
- Her koşuda `nvidia-smi` saniyede bir GPU saatini, bellek saatini, gücü ve sıcaklığı kaydetti.
- 03.11 güç planı testinde (`G49`) HWiNFO saniyede bir işlemci çekirdek saatlerini, efektif saati, C6 ve C0 kalış oranını, paket gücünü ve sıcaklığı kaydetti ([`Export-HwinfoLog.ps1`](../scripts/hwinfo/Export-HwinfoLog.ps1)). Değerler her koşunun VProf penceresinden hesaplandı.
- Her koşudan sonra System günlüğünde `nvlddmkm` ve Display 4101 (TDR) olayları kontrol edildi. CS2'nin açık olduğu kontrol edildi.
- Kesme örnekleyicisi açıkken yapılan koşular karşılaştırmaya alınmadı.

## Sapma kaynakları

Aynı ayarlarla farklı günlerde farklı sonuç alınabilir. Ölçülen nedenler:

| Neden | Etki | Not |
|---|---|---|
| Oturum içi kayma | İlk ~6 koşuda −%1,2 ile −%1,3, sonra koşu başına ~0,8 ile 1,3 FPS | Isınma koşuları ve dengeli sıra ile giderilir |
| Aynı ayar, iki ayrı oturum | Genelde %0,03 ile %0,55. Bir kez %1,2. | 26.10'da bir gece oturumu, aynı BIOS'un öğleden sonraki ölçümünden %1,2 düşük çıktı. Nedeni bulunamadı. O oturum, bir sürücü hatasından (TDR) 3 dakika sonra yeniden başlatma yapılmadan başlamıştı. Ayrı oturum farklarını A-B-A ile doğrulayın. |
| CS2 güncellemesi | %1 ile %2 | Her oturumdan önce `appmanifest_730.acf` içindeki `LastUpdated` değerine bakın |
| Arka planda çalışan uygulama | Ortalama FPS ~−%3, P1 ~−%8 | 25.10: Spotify'ın görüntü işleme süreci yaklaşık 1 çekirdek kullandı. Aynı oturumdaki dönüşümlü karşılaştırmalar etkilenmedi. |
| Oyun içi ayar | Gölge kalitesi Yüksek: ortalama FPS −%4,7 | 26.10'dan sonraki sonuçlar öncekilerle doğrudan karşılaştırılamaz |
| Windows oturumunun süresi | İlk ~40 dakikada −%1,0'a kadar, sonra sabit | 02.11: aynı ayarlı kontrol bloklarında ilk blok ile 41 dakika sonraki blok arasında −%1,0, sonraki 27 dakikada +%0,2. Aynı gün taze açılıştan yaklaşık 2 saat sonra −%0,7. |
| NVIDIA sürücüsü, CS2 ve Windows güncellemesi birlikte | −%0,8 ile −%1,3 | 26.10 ile 02.11 arasında üçü de değişti. Pay ayrılamadı ([Windows](windows.md#nvidia-sürücüsü-ve-sürücü-ayarları)). |

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

- Sürüm 2.6.0, konsol uygulaması (Intel, GitHub). Kurulum gerekmez. [`Compare-PresentMode.ps1`](../scripts/windows/Compare-PresentMode.ps1) CS2 oturumu boyunca canlı kayıt alır ve her koşu için özet çıkarır.
- **Canlı kayıt 02.11'den beri çalışmıyor:** PresentMon'un canlı oturumu saniyede ~7.900 ETW olayı kaybediyor ve hiç kare yazmıyor. Kaynak Win32k girdi olaylarıdır (8000 Hz fare). [`Measure-FrameLatency.ps1`](../scripts/windows/Measure-FrameLatency.ps1) bu yüzden olayları önce dosyaya yazar: WPR, [`presentmon-light.wprp`](../scripts/windows/presentmon-light.wprp) profilini kullanır. Profilde PresentMon'un kendi sağlayıcıları vardır, Win32k yoktur. Kayıp sıfırdır. Kayıt sonra `PresentMon --etl_file` ile işlenir. Bir benchmark koşusu ~1 GB tutar. Dosya işlendikten sonra silinir. Kayıt açıkken FPS değişmedi.
- **Gecikme:** "Kare başlangıcından ekrana" = (sunum zamanı − CPU kare başlangıcı) + `MsUntilDisplayed`. "PC gecikmesi" (`MsPCLatency`) CS2'nin Reflex PCLStats işaretlerinden hesaplanır: girdinin okunmasından ekrana kadar. CS2 bu işaretleri Reflex kapalıyken de gönderir, ancak yalnızca `--track_pc_latency` ile kayda geçer. İkisinde de fare, USB ve ekran panelinin süresi dahil değildir. Tıklamadan ekrana süre için donanım gerekir (LDAT, OSLTT veya ışık sensörlü Teensy).
- **Takılma:** 4 ms'den uzun kare sayısı kullanılır. "Medyanın iki katından uzun kare" ölçütü CS2'de anlamlı değildir: her koşuda karelerin ~%5'i bu sınırı aşar. Akıcılık için ayrıca aşağıdaki [akıcılık ölçütleri](#akıcılık-ölçütleri) kullanılır.
- **PresentMon'un FPS değerini kullanmayın.** Bu sistemde ETW olay kaybı yüzünden kareleri eksik saydı: Independent Flip'te %3, Legacy Flip'te %10 eksik. FPS için VProf kullanıldı. Gecikme ve sunum kipi değerleri kaydedilen karelerden hesaplanır.
- `--date_time` çıktısındaki saat bu sistemde yerel saatten 3 saat ileriydi. Betik farkı kendisi düzeltir.

## Akıcılık ölçütleri

Ortalama FPS ve P1 oyun hissini tek başına göstermez. 03.11'den beri her PresentMon kaydında aşağıdaki kararlılık ölçütleri de hesaplanır ([`FrameStabilityStats.cs`](../scripts/windows/FrameStabilityStats.cs)). Pencere, kare süresi ölçütleriyle aynıdır: VProf raporunun 125 ile 3 saniye öncesi arası. Hepsinde düşük değer daha akıcıdır.

| Ölçüt | Tanım | Neyi gösterir |
|---|---|---|
| Kare süresi sapması | Kare sürelerinin standart sapması | Kare sürelerinin ne kadar dağınık olduğu |
| Kareden kareye fark | Art arda iki karenin süre farkı (mutlak değer): ortalama ve 99. yüzdelik | Mikro takılma: kare temposunun düzensizliği |
| Saniyenin en uzun karesi | Her 1 saniyelik aralıktaki en uzun kare: medyan ve 95. yüzdelik | Anlık takılmalar. BIOS testlerindeki `Maks1s` ölçütüyle aynıdır. |
| 4, 6 ve 8 ms'den uzun kare | Kare sayısı | Belirgin takılmalar |
| Animasyon hatası | PresentMon `MsAnimationError` (mutlak değer): art arda iki karede oyunun simülasyon zamanındaki ilerleme ile karenin ekrana çıkış zamanındaki ilerleme arasındaki fark. Ortalama ve 99. yüzdelik. | Hareketin ekranda düzgün akıp akmadığı. Hisse en yakın ölçüttür. |
| Simülasyon aralığı sapması | `MsBetweenSimulationStart` değerinin standart sapması | Oyun döngüsünün ritmi |
| PC gecikmesi sapması | `MsPCLatency` değerinin standart sapması | Girdi gecikmesinin ne kadar oynadığı |

- 02.11 gecikme (`G47`) ve öncelik (`G48`) testlerinin PresentMon kayıtları bu ölçütlerle yeniden hesaplandı. Değerler [`latency-runs.csv`](../data/latency-runs.csv) dosyasındadır.
- Kontrol: Yeniden hesaplamada kare süresi p99 değerleri, kayıtlı değerlerle 42 koşunun hepsinde aynı çıktı.
- Oyun Modu ve custom OS testlerinde PresentMon kaydı yoktur. O testlerde akıcılık yalnızca VProf'un saniyelik en uzun karesiyle değerlendirildi.
- Bu ölçütler 2 dakikalık çevrimdışı benchmarktan hesaplanır. Ağ, sunucu tick'i ve maçtaki ani yükler kapsanmaz.

## Ölçüm sayıları

- **BIOS testleri:** 132 benchmark koşusu (86 kayıt, 44 ısınma, 2 ölçüm dışı), 2 maç, 13 CS2 oturumu ve 13 NVRAM görüntüsü. Hiçbir açılışta WHEA hatası veya Kernel-Power 41 olayı görülmedi.
- **Windows, ekran kartı, RAM, BCLK, sürücü, Curve Optimizer, başlatma seçeneği, custom OS, Oyun Modu, gecikme, öncelik ve güç planı testleri:** 49 CS2 oturumunda 305 tamamlanan koşu (216 kayıt, 87 ısınma, 2 geçersiz) ve 3 yarıda kalan koşu (2 TDR, 1 ses aygıtı çökmesi). 53 Superposition koşusu (7'si çökme ile bitti). 24 kararlılık testi (12'si çökme ile bitti).

Ham veri ve sütun açıklamaları: [data/README.md](../data/README.md).

---

[Belgeler dizini](README.md)
