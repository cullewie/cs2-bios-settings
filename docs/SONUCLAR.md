# Sonuçlar: CS2 / Ryzen 7 9800X3D / ROG STRIX X870-A / DDR5-8000

Bu belge 18–19 Ekim 2026'da yapılan tüm ölçümleri, neyin kazandırdığını, neyin zarar verdiğini ve sonuçların ne kadar güvenilir olduğunu anlatır. Her koşunun ham değeri `data/kosular.csv` dosyasında, test özetleri `data/ozet.csv` dosyasındadır. BIOS verilerinin anlamı [BIOS_VERILERI.md](BIOS_VERILERI.md), RAM ayarları [RAM_AYARLARI.md](RAM_AYARLARI.md), sistem ve oyun ayarları [SISTEM_VE_OYUN.md](SISTEM_VE_OYUN.md) dosyasındadır.

## Kısa özet

- **Ne kadar test:** 132 benchmark koşusu (86 kayıt, 44 ısınma, 2 ölçüm dışı) + 2 gerçek maç kaydı. 13 CS2 oturumu (12 benchmark + 1 maç), 8 farklı BIOS durumu, 13 NVRAM görüntüsü. Benchmark süresi toplam ~5,5 saat.
- **Toplam kazanç** (otomatik yöntemle ilk ölçüm → son yapılandırma, farklı oturumlar):

| | Başlangıç (BIOS varsayılan CPU, RAM 8000) | Son (PBO +200, CO −10, Core Tuning L2, CS2 CPU 0 hariç) | Fark |
|---|---|---|---|
| Ortalama FPS | 911,45 | 970,0 | **+%6,4** |
| Ortalama kare süresi | 1,10 ms | 1,03 ms | −0,07 ms |
| P1 FPS | 335,2 | 356,7 | +%6,4 (P1 gürültülü, tek tek adımlarda anlamlı değildi) |
| P99 kare süresi | 2,99 ms | 2,80 ms | −%6 |
| 1 sn'lik en kötü kare (P95) | 4,85 ms | 3,99 ms | −%18 |

Oturumlar arası sapma ±%0,6 olduğu için toplam kazanç ≈ %6 ± 0,6 olarak okunmalı.

- **Kazandıranlar:**
  1. PBO Advanced + PBO Limits Motherboard + CPU Boost Clock Override +200 MHz: **+%3,5 Avg** (BIOS'taki en büyük kazanç).
  2. CS2'yi CPU 0'dan (veya çekirdek 0'dan) uzak tutmak (Windows affinity): **+%1,8 ile +%2,5 Avg**, iki ayrı dönüşümlü testte. P1/P99 değişmedi.
  3. RAM'i JEDEC 5600'den ayarlı 8000'e çıkarmak (aynı anda BIOS 2402 → 2503): Avg +%1,2 (sonuçsuz), **P1 +%4,3 ve P99 −%4,0 (gerçek)**.
- **Zarar veren:** DDR5 Nitro Mode 1-3-1: **−%1,4 Avg** (geri alındı).
- **Ölçülebilir etkisi olmayanlar:** Curve Optimizer −10, Core Tuning Config Level 2, Latency Under Load + Medium Load Boostit + LLC Level 6, SMT kapalı, High işlem önceliği.

## 1. Ölçüm yöntemi

### Benchmark

- Harita: Steam Workshop `3240880604` (de_dust2 benchmark). Konsoldan `map_workshop 3240880604 de_dust2` ile açılır. Her koşu ~129 saniye sürer, sonunda CS2 `console.log`'a VProf özeti yazar (CS2 `-condebug` ile açık olmalı).
- Ayarlar her testte aynı: 1280×960, tam ekran, 360 Hz, `fps_max 0` (sınırsız), FACEIT kapalı, HWiNFO kapalı (HWiNFO testi hariç).
- 18 Ekim'deki iki aşama elle başlatıldı. 19 Ekim'den itibaren `bench/run_bench.ps1` koşuları otomatik başlattı: konsolu açar, komutu yazar, VProf satırını bekler, sıradaki koşuya geçer.
- **Elle ve otomatik yöntem birbirine karşılaştırılamaz.** Aynı BIOS ayarında otomatik yöntem Avg'yi %5,6 yüksek ölçtü (867,3 → 915,7). Bu yüzden toplam kazanç otomatik yöntemin ilk ölçümünden hesaplandı.

### VProf çıktısı ve sütunlar

Örnek:

```
[VProf] Summary of 122110 frames and 129 1-second intervals.
[VProf] FPS: Avg=943.7, P1=349.1
[VProf]           FrameTotal   1.06   2.86   122110   1.06   2.86     3.18   4.06      129   3.18   4.06
```

| Sütun (`kosular.csv`) | Kaynak | Anlamı |
|---|---|---|
| `Avg_FPS` | `FPS: Avg=` | Ortalama FPS |
| `P1_FPS` | `FPS: P1=` | %1 düşük FPS (VProf'un kendi hesabı) |
| `Ort_kare_ms` | FrameTotal 1. sayı | Tüm karelerin ortalama süresi (ms) |
| `P99_ms` | FrameTotal 2. sayı | Karelerin %99'u bu süreden kısa (ms) |
| `Kare` | Summary | Analize giren kare sayısı |
| `Maks1s_P50_ms`, `Maks1s_P95_ms` | FrameTotal 6. ve 7. sayı | Her 1 saniyedeki en uzun karenin medyanı ve 95. yüzdeliği (takılma göstergesi) |
| `Saniye` | Summary | 1 saniyelik aralık sayısı (benchmark ≈ 121–129) |

Not: P1 ve P99, VProf'un bazı kareleri analizden çıkarmasıyla hesaplanır ("frames excluded"). PresentMon/CapFrameX'in %1 low değeriyle aynı şey değildir.

### Isınma ve sapma

- **Oturum başı düşüş:** Her yeni CS2 oturumunda Avg ilk ~6 koşuda %1,2–1,3 düşüp sonra sabitleniyor. Örnekler: 925,3 → 913,0 ve 956,1 → 944,9. Bu yüzden BIOS testlerinde her oturumda 6 ısınma koşusu atıldı, sonraki 6 koşu kaydedildi.
- **Isınmadan sonra sapma yok:** 18 koşuluk testte eğim +0,05 FPS/koşu, 13 koşuluk testte +0,25 FPS/koşu.
- **Oturumlar arası sapma:** Aynı BIOS ayarı iki ayrı oturumda ölçüldü (CoreL2 → L2Tekrar): 947,45 → 942,20, yani **−%0,55**. Ayrı oturumlarda ölçülen ~%0,6'dan küçük farklar ayırt edilemez.

### Karar kuralı

- **Ayrı oturumlar (BIOS testleri):** n=6 kayıt koşusunun medyanı ve aralığı (min–maks) karşılaştırıldı. Aralıklar çakışmıyorsa "gerçek", çakışıyorsa "sonuçsuz". Ek olarak fark ~%0,6'dan küçükse oturum sapmasından ayrılamaz.
- **Aynı oturum (Windows testleri):** Koşullar dönüşümlü sırayla koşuldu (her koşul her sıra konumunda eşit sayıda). Aynı turdaki koşular eşleştirilip eşleştirilmiş t testi yapıldı (6 tur: |t| > 2,571; 3 tur: |t| > 4,30).

## 2. Tüm testler

Değerler kayıt koşularının medyanıdır (parantez içinde min–maks). Oturum kodları `data/kosular.csv` ile aynıdır.

| Oturum | Test | Değişen | n | Avg FPS | P1 FPS | P99 ms | Ort. kare ms | 1 sn maks P95 ms |
|---|---|---|---|---|---|---|---|---|
| O0 | Aşama 0 | BIOS 2402 varsayılan, RAM JEDEC 5600 | 5 | 857,3 (854,3–869,9) | 308,5 | 3,24 | 1,17 | 4,60 |
| O1 | Aşama 1 | BIOS 2503 + RAM 8000 PD profili | 5 | 867,3 (863,7–873,4) | 321,8 | 3,11 | 1,15 | 5,27 |
| O2 | W0 | otomatik yöntemin ilk koşuları | 5 | 915,7 (913,0–921,0) | 332,1 | 3,01 | 1,09 | 5,02 |
| O2 | CPU0 B | affinity 0xFFFF | 6 | 911,45 (910,3–914,7) | 335,2 | 2,99 | 1,10 | 4,85 |
| O2 | CPU0 A1 | CPU 0 hariç (0xFFFE) | 6 | 927,90 (925,7–931,3) | 331,4 | 3,02 | 1,08 | 4,75 |
| O2 | CPU0 A2 | çekirdek 0 hariç (0xFFFC) | 6 | 928,15 (926,5–930,9) | 327,65 | 3,05 | 1,08 | 4,38 |
| O3 | PBO200_MB | PBO Advanced + Motherboard + Boost +200 | 6 | 943,30 (939,4–946,2) | 348,4 | 2,87 | 1,06 | 4,09 |
| O4 | CO-10 | + Curve Optimizer All Cores −10 | 6 | 940,70 (936,2–943,3) | 346,15 | 2,89 | 1,06 | 4,04 |
| O5 | CoreL2 | + Core Tuning Config Level 2 | 6 | 947,45 (946,1–948,3) | 356,65 | 2,81 | 1,06 | 4,03 |
| O6 | NitroCombo | + Nitro 1-3-1 + LUL + MLB + LLC6 | 6 | 925,25 (923,6–926,2) | 339,25 | 2,95 | 1,08 | 4,14 |
| O7 | NitroAuto | Nitro → Auto (LUL/MLB/LLC6 kaldı) | 6 | 938,60 (935,2–939,8) | 334,6 | 2,99 | 1,07 | 4,15 |
| O8 | L2Tekrar | LUL/MLB/LLC → Auto (= CoreL2 durumu) | 6 | 942,20 (941,5–945,9) | 344,95 | 2,90 | 1,06 | 4,09 |
| O8 | HWiNFO | HWiNFO açık (karşılaştırmaya katılmaz) | 2 | 936,0 / 933,5 | 334,0 / 348,3 | 2,99 / 2,87 | – | 5,02 / 4,18 |
| O9 | PRI2x2 B | 0xFFFF, Normal | 3 | 945,70 (944,4–945,8) | 348,5 | 2,87 | 1,06 | 3,99 |
| O9 | PRI2x2 H | 0xFFFF, High | 3 | 946,50 (941,8–947,4) | 353,7 | 2,83 | 1,06 | 4,00 |
| O9 | PRI2x2 C | CPU 0 hariç, Normal | 3 | **970,00** (966,6–970,5) | 356,7 | 2,80 | 1,03 | 3,99 |
| O9 | PRI2x2 HC | CPU 0 hariç, High | 4 | 962,60 (957,7–966,6) | 354,55 | 2,82 | 1,04 | 3,99 |
| O10 | SMToff | SMT Control Disable (0xFF) | 3 | 942,6 (941,3–943,3) | 362,2 | 2,76 | 1,06 | 3,98 |
| O10 | SMToffC0 | SMT kapalı + çekirdek 0 hariç (0xFE) | 1 | 972,7 | 349,7 | 2,86 | 1,03 | 3,86 |

## 3. Ayar bazında katkı ve zarar

| Ayar | Katman | Avg | P1 / P99 | Güven | Karar |
|---|---|---|---|---|---|
| BIOS 2503 + RAM 8000 PD profili | BIOS | +%1,17 | P1 +%4,31, P99 −%4,01 | Avg sonuçsuz; P1/P99 gerçek. BIOS güncellemesi ile karışık. | Kullanılıyor |
| PBO Advanced + Limits Motherboard + Boost Override +200 | BIOS (AMD Overclocking) | **+%3,5** | +%3,9 / −%4 (sonuçsuz) | Gerçek (aralıklar çakışmıyor, sapmanın ~6 katı) | Kullanılıyor |
| Curve Optimizer All Cores −10 | BIOS | −%0,28 | sonuçsuz | Etki yok | Açık bırakıldı (zararsız) |
| Core Tuning Config for Gaming Level 2 | BIOS (Ai Tweaker) | +%0,72 | sonuçsuz | Tekrar ölçümde doğrulanmadı (sapma içinde) | Açık bırakıldı (zararsız) |
| DDR5 Nitro Mode 1-3-1 (8x/8x) | BIOS | **−%1,44** | sonuçsuz | Gerçek (sapmanın ~2,6 katı) | Geri alındı (Auto) |
| Latency Under Load + Medium Load Boostit + CPU LLC Level 6 | BIOS | +%0,38 (tahmini) | sonuçsuz | Sapmadan ayrılamadı | Geri alındı (Auto) |
| SMT Control Disable | BIOS (AMD CBS) | −%0,2 ile −%0,8 | sonuçsuz | Etki yok | Geri alındı (Auto) |
| CS2'yi CPU 0'dan uzak tutmak | Windows | **+%1,78** (t=11,5) / **+%2,51** (t=15,3) | sonuçsuz | Gerçek, iki ayrı oturumda | Elle uygulanıyor (steam.exe affinity) |
| Çekirdek 0'ın iki thread'ini dışlamak | Windows | +%1,82 (t=17,3) | sonuçsuz | Gerçek; CPU 0 hariçten farkı yok (t=0,27) | – |
| High işlem önceliği | Windows | −%0,01 (t=−0,05) | sonuçsuz | Etki yok; CPU 0 hariç ile birlikte −%0,6 (anlamsız) | Kullanılmıyor |

## 4. Test ayrıntıları

### Aşama 0 → Aşama 1: RAM 8000 (O0, O1)

- **Aşama 0:** BIOS 2402 varsayılan; RAM JEDEC 5600 MT/s (MCLK 2800), 46-45-45-90, tRFC 1146, 1,10 V; FCLK 1747 MHz, UCLK 1400 MHz; CPU SOC 0,898 V.
- **Aşama 1:** BIOS 2503 + PD profili: 8000 MT/s (MCLK 4000, UCLK 2000, FCLK 2000), 34-46-46-50, tRFC 664, VDD/VDDQ 1,60 V; CPU SOC 1,29 V (Auto). Tüm zamanlamalar [RAM_AYARLARI.md](RAM_AYARLARI.md) dosyasında.
- **Sonuç:**
  - Avg +%1,17, aralıklar çakışıyor → sonuçsuz.
  - P1 +%4,31 ve P99 −%4,01, aralıklar çakışmıyor → gerçek.
  - Ortalama kare −%1,7, sonuçsuz.
- **Sınırlama:** BIOS 2402 → 2503 güncellemesi RAM ayarıyla aynı anda yapıldı, bu yüzden fark yalnız RAM'e atfedilemez. Elle yöntemde 5 koşu yapıldı, ısınma atılmadı.

### CPU 0 dışlama, 18 koşu (O2)

- **Tasarım:** Aynı CS2 oturumunda, ısınma sonrası 6 tur × 3 koşul, 6 permütasyonla dönüşümlü sıra. Koşullar: B = 0xFFFF, A1 = 0xFFFE (mantıksal CPU 0 hariç), A2 = 0xFFFC (çekirdek 0'ın iki thread'i hariç).
- **A1 − B:** Avg +16,23 FPS (+%1,78), t=11,49, 6 turun 6'sında pozitif. Ortalama kare −0,02 ms (t=−5,48). P1 +3,82 (t=1,00) ve P99 −0,04 ms (t=−1,00) anlamsız.
- **A2 − B:** Avg +16,57 (+%1,82), t=17,26. P1 −4,28 (t=−0,60) anlamsız. 1 sn maks P95 −0,66 ms (t=−2,42, eşiğin hemen altında; 6 turun 6'sında B'den düşük).
- **A2 − A1:** +0,33 (t=0,27), fark yok.
- **Yorum:** CS2'nin en yoğun thread'i çekirdek 0'da çalışıyor (HWiNFO: Core 0 T0 efektif 3,9 GHz). Topluluk kaynaklarına göre Windows bazı kesmeleri ve DPC'leri varsayılan olarak CPU 0'a düşürüyor; bu Microsoft belgesiyle doğrulanmadı ve burada ölçülmedi. Ortalama kazanç tutarlı, en kötü kareler ise değişmiyor.

### PBO200_MB (O3)

- **BIOS:** AMD Overclocking → Precision Boost Overdrive = Advanced, PBO Limits = Motherboard, CPU Boost Clock Override = Enabled (Positive), Max CPU Boost Clock Override(+) = 200. Aynı ekranda FCLK 2000, UCLK DIV1 MODE = UCLK=MEMCLK/2 ve Power Down Disabled da elle yazıldı (zaten bu değerlerdeydi, etkin değişiklik değil).
- **NVRAM farkı:** Yalnız AodSetupRpl'de 8 bayt (bkz. BIOS_VERILERI.md).
- **Sonuç:** Avg 911,45 → 943,30 (+%3,5), aralıklar çakışmıyor. P1 +%3,9 ve P99 −%4 sonuçsuz. Ortalama kare 1,10 → 1,06 ms. 1 sn maks P95 4,85 → 4,09 ms.
- **Not:** Boost Override ve PBO limitleri birlikte değişti; etkileri ayrı ayrı atfedilemez. HWiNFO'da tüm çekirdekler 5425 MHz'de (bölüm 5). 9800X3D'nin resmi en yüksek boost'u 5,2 GHz olduğuna göre saat ~%4,3 artmış, FPS +%3,5 artmış. Kazancın kaynağı büyük olasılıkla bu; PBO öncesi saat ölçülmedi.

### CO-10 (O4)

- **BIOS:** Curve Optimizer = All Cores, Sign = Negative, Magnitude = 10.
- **Sonuç:** Avg −%0,28, sonuçsuz. Etki yok.
- **Neden:** İşlemci CS2'de zaten saat tavanında ve güç/sıcaklık sınırlarından çok uzakta. CO saati yükseltemez.

### CoreL2 (O5) ve L2Tekrar (O8)

- **BIOS:** Ai Tweaker → Core tunings Configuration for gaming = Level 2 (seçenekler: Auto, Legacy, Level 1, Level 2). ASUS yardım metni yok.
- **Sonuç:** CO-10'a göre +%0,72 (aralıklar çakışmıyordu). Aynı ayar ayrı bir oturumda yeniden ölçülünce (L2Tekrar) 942,20 çıktı: oturumlar arası −%0,55. L2Tekrar ile CO-10 farkı +%0,16, aralıklar çakışıyor. Level 2'nin etkisi **doğrulanmadı**.

### NitroCombo (O6) ve NitroAuto (O7)

- **NitroCombo, aynı anda değişen 4 ayar:**
  - DDR5 Nitro Mode Enabled: RX Data 1, TX Data 3, Control Line 1, Rx/Tx Burst 8x.
  - Latency Under Load Enabled.
  - Medium Load Boostit Enabled.
  - CPU Load-line Calibration Level 6.
- **Neden 1-3-1:** Kullanıcının daha önceki denemesinde Nitro 1-2-1 bu RAM ayarında açılmadı; bu yüzden TX bir kademe gevşek seçildi.
- **NitroCombo sonucu:** CoreL2'ye göre −%2,34. Aralıklar çakışmıyor, gerçek düşüş.
- **NitroAuto:** Yalnız Nitro → Auto yapıldı. NitroCombo'ya göre +%1,44, gerçek → **Nitro 1-3-1 Avg'yi düşürüyor.**
- **ASUS yardımına göre** RX/TX/Control Line yüksek değerleri frekans payını artırır, gecikmeyi artırır. Burst uzunluğu yalnız eğitim desenidir.
- **Kalan fark:** NitroAuto ile L2Tekrar arasındaki +%0,38 (LUL/MLB/LLC6'nın etkisi) oturum sapmasından küçük. Ayrılamadı, üçü de Auto'ya döndürüldü.

### PRI2x2: öncelik × CPU 0 (O9)

- **Tasarım:** Aynı oturumda 4 koşul, Williams sırası:
  - B: 0xFFFF / Normal
  - H: 0xFFFF / High
  - C: 0xFFFE / Normal
  - HC: 0xFFFE / High
- 4 ısınma + 13 kayıt (3 tam tur + 4. turdan HC). 14. koşu odak kaybıyla yarıda kaldı ve kayda alınmadı.
- **C − B:** Avg +23,73 (+%2,51), t=15,25 (eşik 4,30), 3/3 tur. Ortalama kare 1,06 → 1,03 ms. P1 +%3,96 (t=1,48) ve P99 −0,12 ms anlamsız.
- **HC − B:** +%1,86 (t=5,89). **H − B:** −%0,01 (t=−0,05). **HC − C:** −%0,6 (anlamsız, kötü yönde).
- **Faktöriyel:** CPU 0 hariç ana etkisi ≈ +%2,2, High öncelik ana etkisi ≈ −%0,3.
- **Sonuç:** CPU 0 dışlama ikinci kez doğrulandı. High öncelik fayda vermiyor.

### SMT kapalı (O10)

- **BIOS:** AMD CBS → SMT Control = Disable (Windows'ta 8 mantıksal işlemci görüldü). Geri açmak için tam kapatıp açma (power cycle) gerekir.
- **Ölçüm:** 3 ısınma + 3 kayıt, sıra konumu 4–6. Medyan 942,6. SMT açık referansında aynı sıra konumları 944,7–950,5 → fark −%0,2 ile −%0,8, oturum sapması içinde. **Etki yok.**
- **Ek tek koşu, SMT kapalı + çekirdek 0 hariç (0xFE):** 972,7 (+%3,2, n=1).
- **Sonra:** SMT geri açıldı. NVRAM'de SMT öncesi duruma göre CPU/RAM ayar farkı 0.

## 5. CS2 yükünde donanım (HWiNFO, CoreL2 durumu, 2 koşu, 1 sn örnekleme)

| Ölçüm | Değer | Anlamı |
|---|---|---|
| Çekirdek saati (tüm çekirdekler) | 5425 MHz sabit | Boost tavanı (5200 + 200 Override). Frequency Limit Global 5450 MHz |
| Bus clock (BCLK) | 100,0 MHz | Sabit |
| Tctl/Tdie | ort. 57, maks. 60,1 °C | Sıcaklık sınırına (80 °C) çok uzak |
| CCD1 Tdie | maks. 66,6 °C | |
| PPT | koşu sırasında ort. 75–76 W, maks. 85,8 W (sınırın %7,5'i) | Güç sınırına çok uzak |
| TDC / EDC | ort. 32 A (%3,2) / 57 A (%5,8), maks. 40 A / 87 A | Akım sınırına çok uzak |
| HTC / PROCHOT kısma | 0 | Kısma yok |
| Core VID | ort. 1,28 V (1,255–1,32) | |
| En yoğun thread | Core 0 T0, efektif 3,9 GHz | Core 5: 2,7, Core 1: 2,4–2,6, Core 3: 1,95, diğerleri ~1,0–1,15 GHz |
| GPU yükü | ort. %85, p50 %90, p95 %95–96, maks. %99 | Darboğaz kısmen GPU |
| GPU saati / gücü | ~2773 MHz / ort. 131 W, maks. 165 W (TDP'nin %44'ü) | Performance Limit yalnız "Reliability Voltage" |

Bunun anlamı:
- İşlemci saat tavanında, güç/akım/sıcaklık sınırlarına çok uzak.
- Curve Optimizer'ı derinleştirmek, PBO limitlerini değiştirmek, Thermal Limit ve Spread Spectrum ayarları saat kazandıramaz. Bu yüzden test listesinden çıkarıldı.
- Saati artırmanın tek yolu BCLK, o da test edilmedi (bkz. bölüm 9).

Tüm voltaj, sıcaklık ve güç değerleri: [BIOS_VERILERI.md](BIOS_VERILERI.md#5-okumalar-ve-anlamları-hwinfo).

## 6. Gerçek maç verisi (Aşama 1 durumu, 2 maç, de_dust2)

| Maç | Süre (sn) | Avg | P1 | P99 ms | Ort. kare ms | 1 sn maks P95 ms |
|---|---|---|---|---|---|---|
| 1 | 1290 | 634,4 | 355,1 | 2,82 | 1,58 | 7,28 |
| 2 | 1671 | 638,3 | 367,1 | 2,72 | 1,57 | 7,24 |

- **Benchmark ile farkı:** Maçta Avg benchmarktan ~%27 düşük, P1 ise %10–14 yüksek. Yük farklı olduğu için karşılaştırılamaz.
- **Takılma:** Maç 1'de tek bir 261,9 ms'lik takılma oldu. O anki log satırları: "Excessive frame time … clamped", "QueuePresentAndWait() looped for 23 iterations without a present event", "Slamming client tick to server tick".
- **Ping:** 32–36 ms.

## 7. Dış veri setiyle karşılaştırma

[cs2kitchen/cs2FpsBoostReal](https://github.com/cs2kitchen/cs2FpsBoostReal) aynı CPU ve GPU'yla (9800X3D + RTX 5070 Ti) 26 adımlık kümülatif bir test yayımladı (CapFrameX, 5 koşu/ayar). Ham JSON kayıtlarından:

- **Gürültü tabanı:** Değişmesi beklenmeyen adımlarda Avg ±%1, P1 ±%1,3.
- **Gürültünün üstündeki etkileri:**
  - PBO: +%1,16 / P1 +%3,62.
  - High öncelik: +%1,39 / −%1,19.
  - Çekirdek 0 hariç (Process Lasso): +%1,35 / P1 +%9,50.
  - HAGS: +%3,84.
  - 1080p: +%12,17.
- **Bizdeki karşılığı:**
  - PBO bizde daha büyük çıktı (+%3,5), Boost +200 dahil.
  - Çekirdek 0'ın Avg etkisi tekrarlandı (+%1,8–2,5), P1 +%9,5 tekrarlanmadı.
  - High öncelik bizde etkisiz.
  - HAGS bizde zaten açık.
- **Onların "12. SMT Disabled" adımı:** SMT'yi fiilen kapatmamış. CPU toplam yükü tüm adımlarda %23–26 kalmış; SMT kapansaydı yaklaşık iki katına çıkardı. Yani o adım boş bir test.
- **Gürültü içinde kalanlar:** Onların verisinde Windows Search, görünüm ayarları, Ultimate güç planı, Oyun Modu, overlay ve Win32PrioritySeparation gürültü içinde. Bu yüzden bunlar bu projede test edilmedi.

## 8. Son yapılandırma

**BIOS** (2503; tam liste [BIOS_VERILERI.md](BIOS_VERILERI.md#4-son-bios-durumu)):

- **RAM:** PD profili, 8000 MT/s Gear 2, FCLK 2000, 34-46-46-50, VDD/VDDQ 1,60 V.
- **PBO:** Advanced, PBO Limits Motherboard, CPU Boost Clock Override +200 MHz.
- **Curve Optimizer:** All Cores −10.
- **Core Tuning Config for Gaming:** Level 2.
- **Auto bırakılanlar:** Nitro, LUL, Medium Load Boostit, LLC, SMT, Global C-state, iGPU.
- **Fan/pompa:** Q-Fan Manual eğri. AIO pompa boşta 1238 rpm, Full Speed'de ~2780 rpm.

**Windows ve oyun:**

- HAGS açık.
- CS2 CPU 0 hariç: Görev Yöneticisi → Ayrıntılar → steam.exe → Benzeşimi ayarla → CPU 0'ı kaldır, sonra CS2'yi Steam'den aç. CS2 bu ayarı devralır, cs2.exe'ye dokunulmaz. Steam her yeniden başladığında tekrarlanmalı.
- Öncelik Normal.
- Oyun içi ayarlar değişmedi ([SISTEM_VE_OYUN.md](SISTEM_VE_OYUN.md)).

## 9. Test edilmeyenler ve nedenleri

| Ayar | Neden |
|---|---|
| Secure Boot, TPM, IOMMU, HVCI/VBS (Bellek Bütünlüğü), SVM, CSM, DMA koruması, Pluton, Windows güncellemeleri | FACEIT bunları denetliyor; dokunulmadı |
| Core Tuning Config = Legacy | Bu kurulumda tercih edilmedi |
| DDR5-6000 1:1 (UCLK = MCLK) | Bu kurulumda tercih edilmedi (RAM 8000 Gear 2'de kaldı) |
| iGPU kapatma | Bu kurulumda tercih edilmedi (açık; Windows'ta "Microsoft Temel Görüntü Bağdaştırıcısı", kod 10) |
| CS2 grafik ayarları (MSAA, Reflex vb.) | Bu kurulumda olduğu gibi bırakıldı; etkisi ölçülmedi |
| fps_max | Hep 0 (sınırsız) |
| BCLK | PCIe saatini de değiştirir, RAM 8000 → 8160 olur; önerilmedi |
| Thermal Limit, PBO limitleri, daha derin CO, Spread Spectrum | İşlemci saat tavanında, güç/sıcaklık sınırına uzak (bölüm 5) |
| Turbo Game Mode, Gaming Adaptive CCD Parker, Core Flex X3D Gaming Preset, CPPC Dynamic Preferred Cores | Çift CCD için; 9800X3D tek CCD. Core Flex X3D Gaming Preset'in içeriği BIOS kodundan okundu: yalnız CCD Priority/CCD Parker eylemleri var. |
| AI Cache Boost | ASUS yardım metnine göre AI araçları için |
| Process Lasso, PBO2 Tuner, Hydra, LatencyMon vb. | Çekirdek sürücüsü yükleyen araç kullanılmadı |

## 10. Sıradaki adaylar (ölçülmedi)

Ayrı bir kaynak araştırmasına göre kalan toplam pay ~%1–3:

1. **CPU 0 dışlamayı kalıcı yapmak:** Steam'i `cmd /c start "" /affinity FFFE "...\steam.exe"` kısayoluyla açmak. Kazanç zaten ölçüldü. FACEIT'in bu konuda resmi tutumu bulunamadı.
2. **FCLK 2100 / 2167 / 2200** (8000 Gear 2'de): Kontrollü oyun testi yok, tahmini %0–2. Kararsızlık WHEA 19 olarak görünür.
3. **NVIDIA Low Latency Mode On/Ultra**, yalnız cs2.exe profilinde: GPU yükü p95 %96 olduğu için etkisi olabilir. CS2 testi yok.
4. **`-vulkan` A/B:** NVIDIA'da mevcut veri DX11 lehine.
5. **RAM ikincil zamanlamaları:** tRFC, tRDRDSCL/tWRWRSCL 6, tRDWR 18. Tahmini %0–1,5.

## 11. Sınırlamalar

- **Tek sistem:** Tek CPU örneği, tek RAM kiti, tek anakart. Sonuçlar başka sistemlere doğrudan taşınmaz.
- **BIOS karşılaştırmaları:** BIOS ayarları açılıp kapatılamadığı için karşılaştırmalar ayrı oturumlarda yapıldı. ~%0,6'dan küçük farklar ayırt edilemez.
- **Ölçülmeyenler:** Gecikme LDAT veya Reflex Analyzer ile ölçülmedi; değerlendirme kare sürelerine dayanıyor. Fare girdisi ve atış sahnesi benchmarkta yok.
- **İlk karşılaştırma:** Aşama 0 → Aşama 1 karşılaştırmasında BIOS güncellemesi ve RAM ayarı birlikte değişti. Ölçüm elle yapıldı.
- **Benchmark ile maç farkı:** Benchmark haritası maç yükünü temsil etmez. Bot var, sunucu yükü yok (bkz. bölüm 6).

## 12. Sayılar

| | |
|---|---|
| Benchmark koşusu | 132 (86 kayıt, 44 ısınma, 2 ölçüm dışı) |
| Gerçek maç kaydı | 2 |
| CS2 oturumu | 13 (12 benchmark oturumu, O0'ın iki ayrı açılışı dahil; + 1 maç oturumu) |
| Ölçülen BIOS durumu | 8 farklı durum, 9 ölçüm (2402 varsayılan, Aşama 1, PBO200_MB, CO-10, CoreL2, NitroCombo, NitroAuto, SMToff; L2Tekrar = CoreL2 durumu) |
| BIOS değişikliği (ölçülen) | 7 (güncelleme + RAM'den sonra) |
| Windows seviyesi test | 3 (CPU 0 affinity, öncelik, SMT kapalıyken affinity) |
| NVRAM görüntüsü | 13 |
| Benchmark süresi | 132 × ~2,5 dk ≈ 5,5 saat |
| WHEA hatası / Kernel-Power 41 | 0 / 0 (tüm açılışlarda) |
