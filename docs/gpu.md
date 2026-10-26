# Ekran kartı hız aşırtma

Kart: GIGABYTE GeForce RTX 5070 Ti AERO OC 16G. Her kart farklıdır. Bu değerleri doğrudan kopyalamayın. Kendi sınırınızı [aşağıdaki yöntemle](#kendi-sınırınızı-bulma) bulun.

> [!WARNING]
> Ekran kartı hız aşırtması kararsızlığa, oyun çökmesine ve sürücü sıfırlamasına (TDR) neden olabilir. Tüm sorumluluk size aittir.

## Günlük ayar (MSI Afterburner, Profil 1)

| Ayar | Değer |
|---|---|
| Core Voltage | 0. Değiştirmeyin. |
| Power Limit | %116 (350 W, kartın en yüksek değeri) |
| Core Clock | +425 MHz. +450 iki kez sürücü hatası verdi. Bir hata daha olursa +400 yapın, FPS değişmez. |
| Memory Clock | +3000 MHz. Sürücünün izin verdiği en yüksek değerdir. |
| Fan | Otomatik (kartın kendi eğrisi) |

Afterburner'da yalnızca bu profil vardır (yuva 1). Diğer yuvalar boştur.

CS2 yükünde çekirdek yaklaşık 3195 MHz'de çalışır (stok 2775 MHz). Bellek 17001 MHz'de çalışır (stok 14001 MHz, 28 Gbps yerine 34 Gbps). CS2'de güç gölge Düşük ile yaklaşık 150 W, gölge Yüksek ile 165 W'tır. Güç sınırına ulaşılmaz.

**+450 ve +425:** +450 aşağıdaki stres testlerinin hepsini geçti. Ama CS2'de iki kez sürücü hatası verdi (`nvlddmkm` 153). 24.10'daki hata, shader önbelleği temizlendikten sonraki ilk oturumdaydı. 26.10'daki hata, yeni açılan CS2'nin ilk koşusundaydı. Kart soğukken (42–45 °C) ve yük hafifken (harita yüklenirken, menüde) +450'de saat 3255–3262 MHz'e çıkar. Bu, ölçülen çökme sınırının (3247–3250 MHz) üstündedir. Isınmış kartta en yüksek değer 3232–3247 MHz'tir. +425'te aynı soğuk durumda en yüksek değer 3232 MHz'tir. CS2, +400, +425 ve +450 ile aynı FPS'i verdi. Bu yüzden günlük değer +425'tir. Sürücü hatası olursa +400'e düşün. FPS kaybı olmaz.

**CS2'nin çalıştığı frekans stres testlerinden yüksektir.** CS2 hafif bir yüktür. Kart V/F eğrisinin en üst noktasında çalışır. +450 ile CS2'de 3225 MHz, OCCT'nin hafif fazında 3210 MHz, Kombustor'da 3172 MHz ölçüldü. Günlük değeri seçerken CS2'deki saati, özellikle soğuk açılıştaki en yüksek değeri, çökme sınırıyla karşılaştırın.

## Uygulama

1. NVIDIA App → **Sistem → Performans** bölümünde **Otomatik Ayarlama** açıksa kapatın ve **GERİ YÜKLE** seçin. İki araç aynı anda ofset yazmamalıdır.
2. MSI Afterburner'ı MSI'nin resmi sitesinden kurun. Kurulumda Norton seçeneğinin işaretini kaldırın. RivaTuner Statistics Server gerekmez.
3. Power Limit, Core Clock ve Memory Clock değerlerini girin ve **Apply** seçin.
4. **Save** seçin ve **1** yuvasına kaydedin. Kilit simgesiyle profilleri kilitleyin. Kilit yalnızca kaydetmeyi engeller. Profili yüklemeyi engellemez.
5. Her Windows açılışında Afterburner'ı açın ve **1** seçin. Afterburner'ın kendi açılışta uygulama ayarı bu sistemde yeniden başlatmadan sonra değerleri uygulamadı. `MSIAfterburner.exe -Profile1` komutu çalışır.
6. Kontrol: Afterburner'da +425, +3000 ve 116 görünmelidir. `nvidia-smi` güç sınırını 350 W göstermelidir.

Afterburner'ın RTCore64 sürücüsü, Bellek Bütünlüğü (HVCI) açıkken yüklendi. Secure Boot, TPM ve HVCI ayarları değişmedi.

## CS2 etkisi

| Karşılaştırma | Ortalama FPS | Yöntem |
|---|---|---|
| Stok → +400 / +2750 / %116 | **+%2,6** | 2×2, iki oturum, ters sıra, hücre başına 2 koşu |
| Stok → +425 / +3000 / %116, gölge Yüksek | **+%3,3** | Aynı oturum, bloklu, kayma düzeltmeli (ham +%3,6) |
| Bellek +200 → +2750 (çekirdek +400) | +%0,2 | Aynı oturum, ABBA |
| Bellek −1000 MHz (çekirdek stok) | −%0,2 (sapma içinde) | Aynı oturum, MNNM |
| Çekirdek +155 → +300 | +%0,7 | Aynı oturum, 6 koşu |
| Çekirdek +155 → +450 | +%1,35 | Aynı oturum, tek koşular |
| GPU saati 2930 → 2572 MHz (−%12) | −%2,8 | Aynı oturum, ABBA, `nvidia-smi -lgc` |
| Maksimum voltaj %100 ve güç %116 | Sapma içinde (saat +8 MHz) | Aynı oturum |

P1 değeri hiçbir ekran kartı ayarında ölçülebilir şekilde değişmedi.

**Aynı CS2 oturumunda, sıra A B C D D C B A, HWiNFO ile efektif saat ölçümü:**

| Profil | Ortalama FPS | GPU saati (bildirilen / efektif) | Voltaj | Güç |
|---|---|---|---|---|
| +450 / +3000, voltaj 0 | 989,2 | 3225 / 3225 MHz | 1,010 V | 156 W |
| +425 / +3000, voltaj 0 | 990,8 | 3195 / 3195 MHz | 1,010 V | 151 W |
| +400 / +3000, voltaj 0 | 990,1 | 3172 / 3169 MHz | 1,010 V | 152 W |
| +400 / +3000, voltaj %100 | 991,5 | 3225 / 3221 MHz | 1,025 V | 160 W |

- Fark ölçüm sapmasının içindedir (±3 FPS).
- CS2'de efektif saat bildirilen saate eşittir. Saat kırpılması yoktur.
- Core Voltage %100, Crossbar ve System saatlerini ~%2 artırır (2302 → 2347 MHz). FPS değişmez, güç 8 W artar.

## Voltaj kilidini açmak (Core Voltage %100)

- Aynı ofsette voltaj 1,010'dan 1,030 V'a çıkar. Saat ~45 MHz artar.
- Çökme frekansı değişmez. Superposition'da voltaj 0 ile 3225 MHz geçti, ~3250 MHz çöktü. Voltaj %100 ile 3232 MHz geçti, 3247 MHz çöktü.
- Bu kartın frekans sınırı ~3240 MHz'dir ve voltaja bağlı değildir. Voltaj yalnızca ısı ve güç ekler.

## Undervolt (VF eğrisi)

Yöntem fpsheaven rehberinin "undervolt + hız aşırtma" adımıdır. Hedef frekansı seçin. Hedef voltaj noktasını bu frekansa çekin. Üstündeki noktaları aynı frekansta düzleyin. Voltajı 10 mV adımlarla düşürün. Çökmede durun ve geri gelin. [`Set-VfCurve.ps1`](../scripts/gpu/Set-VfCurve.ps1) bu eğriyi Afterburner profil yuvasına yazar.

Hedef 3245 MHz nominaldir (+425 ile aynı saat). Bu frekans eğrinin taban değerine göredir. Kart yükte daha düşük saatte çalışır: CS2'de 3187 MHz, Superposition'da 3150–3172 MHz.

**Çökme sınırı (Superposition 1080p Extreme ve CS2):**

| Hedef | Geçen | Çöken |
|---|---|---|
| 3245 MHz | 990 mV (uzun doğrulama, aşağıda). 975 mV (Superposition 2 koşu, CS2 8 koşu). | 970 mV (60. saniyede). 965 mV (yüklenirken). |
| 3195 MHz | 965 mV (1 koşu) | 960 mV (ikinci koşunun 170. saniyesinde, ilk koşu geçti). 950 mV (anında). |

- Çökme noktası rastgeledir. Aynı ayar bir koşuyu geçebilir, sonraki koşuda çökebilir. Bir veya iki temiz koşu kanıt değildir. Pay bırakın.
- Saati 50 MHz düşürmek, voltajı yalnızca ~10 mV düşürmeye izin verdi.
- Superposition puanı bu aralıkta saate bağlı değil. Puanlar yine iki kümede çıktı (~16050 ve ~16680).

**Aynı CS2 oturumunda karşılaştırma (dengeli sıra, koşul başına 3 koşu, gölge Düşük):**

| Profil | Ortalama FPS | CS2'de saat | Voltaj | Güç (HWiNFO) |
|---|---|---|---|---|
| +450 / +3000 / %116 | 953,9 | 3225 MHz | 1,010 V | 144 W |
| 3245 MHz @ 990 mV | 951,2 (−%0,2) | 3187 MHz | 0,985 V | 138 W |
| 3195 MHz @ 990 mV | 950,0 (−%0,45) | 3157 MHz | 0,985 V | 139 W |
| 3145 MHz @ 990 mV | 948,3 (−%0,5) | 3112 MHz | 0,980 V | 136 W |

- Önceki oturumda 3245 MHz @ 990 mV, +450'den +%0,11 yüksekti. İki oturumun ortalaması −%0,05'tir. Fark yoktur.
- Aynı voltajda saati düşürmek FPS'i biraz düşürür, gücü değiştirmez. Güç voltaja bağlıdır. En iyi nokta, seçilen voltajda kararlı en yüksek saattir.
- +450'de CS2 saati anlık 3232–3247 MHz'e çıkar. Bu, ölçülen çökme sınırıdır. 3245 MHz @ 990 mV'de anlık en yüksek değer 3195–3232 MHz'tir.

**3245 MHz @ 990 mV doğrulaması:** Kombustor 1 saat, artefakt 0. OCCT 3D Adaptive Switch 1 saat hatasız. OCCT VRAM %98 20 dakika hatasız. CS2 benchmark art arda 19 koşu (49 dakika) ve 7 karşılaştırma koşusu sorunsuz. En yüksek sıcaklık 71 °C (OCCT), CS2'de 50 °C.

**Sonra sürücü hatası:** Koşular bittikten sonra CS2 aynı profille açık kaldı. İlk koşudan yaklaşık 1 saat 45 dakika sonra sürücü hatası oldu (`nvlddmkm` 153, TDR). O anda yük kaydı yoktu. 990 mV, çöken 970 mV'nin yalnızca 20 mV üstündedir. Bu pay uzun oturum için yetmedi.

**Sonuç:** Undervolt FPS kazandırmaz. Kazancı yaklaşık 5 W'tır. Daha fazla pay için saati düşürmek gerekir (örneğin 3195 MHz @ 990 mV), bu da FPS'i %0,4 düşürür. Undervolt kullanmayın. Gölge Yüksek ile de sonuç aynıdır (aşağıda). Günlük değer +425 / +3000 / %116'dır.

## Gölge kalitesi Yüksek ile (26.10)

Gölge kalitesi Düşük'ten Yüksek'e alındıktan sonra üç profil aynı CS2 oturumunda ölçüldü. Sıra bloklu: önce 2 ısınma koşusu, sonra her profil art arda 3 koşu (A A A, B B B, C C C). CPU 0 hariç, Legacy Flip.

| Profil | Ortalama FPS (3 koşu) | P1 | CS2'de saat | Güç | En yüksek sıcaklık |
|---|---|---|---|---|---|
| +425 / +3000 / %116 | 934,8 | 331,5 | 3187–3195 MHz | 165 W | 58 °C |
| Stok | 902,2 | 345,7 | 2775 MHz | 152 W | 55 °C |
| 3245 MHz @ 990 mV | 928,0 | 343,7 | 3187 MHz | 160 W | 58 °C |

- Bloklu sırada FPS oturum boyunca koşu başına ~0,8 düşer. Bu kayma düzeltildiğinde +425, stoktan **+%3,3** hızlıdır (ham fark +%3,6). Gölge Düşük ile bu fark +%2,6 idi.
- Undervolt, +425'ten %0,2 yavaştır (ham fark %0,7). Bu fark ölçüm sapmasının içindedir. Kazancı 5 W'tır.
- Gölge Yüksek, GPU yükünü %90'dan %92–93'e, gücü ~151 W'tan 165 W'a çıkardı. Güç sınırı (350 W) ve sıcaklık sınırı yine uzaktır. Bu yüzden undervolt yine FPS kazandırmaz.
- Undervolt, hafif yükte +425 ile aynı en yüksek saate (3232 MHz) çıkar, ama 20 mV daha düşük voltajda çalışır. Uzun oturumdaki sürücü hatası bununla açıklanabilir.
- P1 değerleri 326 ile 357 arasında dağınıktır. Profiller arasında fark yoktur.
- **Gölge Yüksek'in maliyeti:** 24.10'daki aynı ayarlı oturumla (+425, Legacy Flip, CPU 0 hariç, aynı CS2 sürümü ve BIOS) koşu sıraları eşleştirildi. Bu oturuma göre fark −%5,8'dir. Ama aynı BIOS ve aynı profil öğleden sonra yeniden ölçüldüğünde bu oturumdan %1,2 yüksek çıktı ([Sapma kaynakları](methodology.md#sapma-kaynakları)). Tekrar ölçümle ortalama FPS beş sıranın hepsinde %4,4 ile %5,0 arasında düşüktür (ortalama **−%4,7**, yaklaşık 47 FPS). P1 değişmedi. Bu tablodaki profil karşılaştırmaları aynı oturumda yapıldığı için geçerlidir.

## Kendi sınırınızı bulma

Yöntem, fpsheaven GPU hız aşırtma rehberinin akışını izler. Ölçüm aracı: Unigine Superposition 1.1, 1080p Extreme.

1. Stok puanı 2 veya 3 koşu ile ölçün.
2. **Çekirdek:** Bellek 0 ve Power Limit en yüksek değerde olsun. +200'den başlayın. 25 MHz adımlarla artırın.
3. Her adımı 2 koşu ile ölçün. Bu kartta puanlar aynı saatte iki kümede çıktı (yaklaşık %4,5 fark).
4. Çökme (TDR) veya puan düşüşü görürseniz durun. Son temiz değer sınırdır.
5. **Bellek:** Çekirdeği sabit tutun. +1000'den başlayın. 250 veya 500 MHz adımlarla artırın.
6. **Günlük değer:** Sınırdan çekirdekte 25–50 MHz, bellekte 100–250 MHz geri gelin.
7. **Doğrulama:** Sırayla OCCT 3D Adaptive (Switch, %30/%100, 500 ms) 1 saat, MSI Kombustor PBR-Donut (artefakt tarayıcı açık) 1 saat, OCCT VRAM %98 ve CS2 çalıştırın. CS2'yi soğuk açılışta da deneyin.

**Bu karttaki sınırlar:**

| Test | Geçen en yüksek değer | Çöken değer |
|---|---|---|
| Superposition (sabit yük) | +500 / +3000 | +525 / +3000 |
| Superposition, Core Voltage %100 | +450 / +3000 (3232 MHz) | +475 / +3000 (3247 MHz) |
| OCCT 3D Adaptive Switch (yük geçişi) | +450 / +3000, 1 saat | +475 / +3000, 4. dakikada |
| CS2 benchmark (kısa koşu) | +425 / +3000 (soğuk açılış dahil) | +450 / +3000 (soğuk açılışta), +500 / +200 (harita yüklenirken) |

Yük geçişi, sabit yükten daha zordur. Superposition'da geçen değer OCCT Switch testinde çökebilir. Günlük değeri OCCT Switch ile ve soğuk açılışta CS2 ile doğrulayın.

**+450 / +3000 doğrulaması:** OCCT 3D Adaptive Switch 1 saat hatasız. Kombustor 1 saat, artefakt 0. OCCT VRAM %98 21 dakika hatasız. CS2 3 koşu sorunsuz. En yüksek sıcaklık 72 °C. Buna rağmen +450 sonradan CS2'de iki kez çöktü (yukarıda).

## Notlar

- **Undervolt, ilk deneme:** 3217 MHz için 1000, 990 ve 985 mV hedeflerinde gerçek voltaj yaklaşık 1005 mV kaldı. Neden bulunamadı. Stok eğri şablonuyla yapılan ölçüm [Undervolt](#undervolt-vf-eğrisi) bölümündedir.
- **TDR sonrası:** Sürücü güç sınırını ve ofsetleri sıfırlar. Afterburner'da profili yeniden yükleyin.
- **NVIDIA App Otomatik Ayarlama:** Bu kartta +182 / +200 buldu. Yükte saat yaklaşık 2930 MHz oldu.
- **Afterburner'sız yol:** NVIDIA sürücüsünün `nvml.dll` kütüphanesindeki `nvmlDeviceSetClockOffsets` işlevi ek sürücü kurmadan ofset yazar. Bellek birimi Afterburner biriminin 2 katıdır. Ayar yeniden başlatmada silinir. NVIDIA App ayarının üzerine yazar.
- **OCCT:** Açılışta HWiNFO çekirdek sürücüsünü yükler. Sürücü, Windows yeniden başlayana kadar yüklü kalır.
- **Kombustor:** Akıllı Uygulama Denetimi açıksa sensör DLL'si engellenir. Sensörler N/A görünür. Test ve artefakt tarayıcısı yine çalışır.

---

**Önceki adım:** [Windows ve CS2](windows.md) · **Sonraki adım:** [Kontrol](verification.md) · [Belgeler dizini](README.md)
