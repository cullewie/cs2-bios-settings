# CS2 BIOS, Windows ve ekran kartı ayar rehberi

Bu rehber, şu sistem için ölçülmüş CS2 ayarlarını açıklar:

- İşlemci: Ryzen 7 9800X3D
- Anakart: ASUS ROG STRIX X870-A
- Bellek: DDR5-8000, SK Hynix M-die
- Ekran kartı: RTX 5070 Ti

BIOS ayarları 132 benchmark koşusu ve 2 maç ile ölçüldü. Windows ve ekran kartı ayarları 48 benchmark koşusu ile ölçüldü. Ekran kartı ayarları ayrıca Superposition, OCCT ve Kombustor ile sınandı.

Bu rehberi üç durumda kullanın:

1. Aynı sistemi kurmak için ayarları sırayla uygulayın.
2. BIOS güncellemesinden veya CMOS sıfırlamasından sonra ayarları yeniden girin ve kontrol betiğini çalıştırın.
3. Başka bir sistemde denemek için [bölüm 10](#10-başka-sistemlere-uyarlama) bölümünü okuyun.

> **UYARI:** RAM hız aşırtması, ekran kartı hız aşırtması, voltaj artışı ve PBO garanti kapsamını etkileyebilir. Sistem kararsız çalışabilir ve veri kaybı olabilir. Tüm sorumluluk size aittir. Değerler tek bir sistemde denendi.

---

## İçindekiler

1. [Sonuç özeti](#1-sonuç-özeti)
2. [Sistem](#2-sistem)
3. [Başlamadan önce](#3-başlamadan-önce)
4. [BIOS: RAM](#4-bios-ram)
5. [BIOS: İşlemci](#5-bios-işlemci)
6. [BIOS: Auto olarak kalacak ayarlar](#6-bios-auto-olarak-kalacak-ayarlar)
7. [BIOS: FACEIT ve güvenlik](#7-bios-faceit-ve-güvenlik)
8. [Windows ve CS2 ayarları](#8-windows-ve-cs2-ayarları)
9. [Ekran kartı hız aşırtma](#9-ekran-kartı-hız-aşırtma)
10. [Başka sistemlere uyarlama](#10-başka-sistemlere-uyarlama)
11. [Kontrol](#11-kontrol)
12. [Ölçüm yöntemi](#12-ölçüm-yöntemi)
13. [Araçlar](#13-araçlar)
14. [Sorun giderme](#14-sorun-giderme)
15. [Sınırlar](#15-sınırlar)
16. [Depo yapısı](#16-depo-yapısı)

---

## 1. Sonuç özeti

| Adım | Ortalama FPS | Karar |
|---|---|---|
| RAM 8000 (BIOS 2402'den 2503'e geçişle birlikte) | +%1,2. Sonuç kesin değil. P1 +%4,3 ve P99 −%4,0 kesin. | Kullanın |
| PBO Advanced, PBO Limits Motherboard, Boost Override +200 | **+%3,5** | Kullanın |
| CS2'yi CPU 0 dışında çalıştırma (Windows affinity) | **+%1,8 ile +%2,5** | Kullanın |
| Curve Optimizer All Cores −10 | −%0,3. Etki yok. | Açık bırakın (zararsız) |
| Core Tuning Config for Gaming Level 2 | Doğrulanmadı | Açık bırakın (zararsız) |
| DDR5 Nitro Mode 1-3-1 | **−%1,4** | Auto bırakın |
| Latency Under Load, Medium Load Boostit, LLC 6 | Sapma içinde | Auto bırakın |
| SMT kapalı | Etki yok | Auto bırakın (açık) |
| Yüksek işlem önceliği | Etki yok | Normal bırakın |
| Ekran kartı hız aşırtma: çekirdek +400, bellek +2750, güç %116 | **+%2,6** | Kullanın. Günlük değer: +450 / +3000 / %116 ([bölüm 9](#9-ekran-kartı-hız-aşırtma)) |
| Yalnızca ekran kartı belleği (+200'den +2750'ye) | +%0,2 | Zararsız. Kazancın neredeyse tamamı çekirdekten gelir. |
| Ekran kartı maksimum voltaj %100 ve güç %116 (NVIDIA App) | Etki yok. Saat yalnızca 8 MHz arttı. | Voltajı varsayılan bırakın |
| Ekran kartı undervolt (VF eğrisi) | Fayda yok | Kullanmayın |
| Ethernet Energy Efficient Ethernet kapalı | Ölçülmedi | İsteğe bağlı |

**Toplam (BIOS ve CPU 0, 19.10):** Ortalama FPS 911'den 970'e çıktı (**+%6,4**). Ortalama kare süresi 1,10 ms'den 1,03 ms'ye düştü. P99 değeri 2,99 ms'den 2,80 ms'ye düştü.

**Toplam (Windows ve ekran kartı, 23.10):** Aynı BIOS ayarlarıyla, CPU 0 dışlama ve ekran kartı hız aşırtması birlikte ortalama FPS'i 926,8'den 971,4'e çıkardı (**+%4,8**). Ekran kartının payı +%2,6, CPU 0 dışlamanın payı +%2,2'dir. Ölçüm iki ayrı CS2 oturumunda ters sırayla yapıldı. Dört alt karşılaştırmanın hepsi aynı yönü gösterdi.

İki toplamı birbirine eklemeyin. İkisi de CPU 0 adımını içerir. Ayrıca iki ölçüm arasında CS2 güncellendi.

Oturumlar arası sapma ±%0,6'dır. Bu nedenle BIOS toplamını **yaklaşık %6 ± 0,6** olarak okuyun.

**Darboğaz:**
- **İşlemci:** CS2 sırasında tüm çekirdekler 5425 MHz'de çalıştı. Güç sınırının yalnızca %7,5'ini kullandı. Sıcaklık en fazla 60 °C oldu. Bu nedenle Curve Optimizer, PBO limitleri ve sıcaklık ayarları ek kazanç sağlamadı.
- **Ekran kartı:** GPU yük p95 değeri %96'dır. GPU saati %12 düşünce ortalama FPS %2,8 düştü. Saat 2920 MHz'in üstüne çıkınca kazanç azalır. Darboğaz kısmen GPU'dadır.
- **P1:** Hiçbir Windows veya ekran kartı ayarı P1 değerini ölçülebilir şekilde değiştirmedi. P1 değerinin koşudan koşuya sapması ±%5'tir.

---

## 2. Sistem

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

---

## 3. Başlamadan önce

### BIOS güncellemesinden önce

1. Mevcut ayarları profile kaydedin.
   - **Tool → ASUS User Profile → Save to Profile** seçin ve bir yuva seçin.
   - **Load/Save Profile from/to USB Drive** seçeneğiyle profili USB belleğe de kaydedin.
   - Profil dosyaları genellikle başka bir BIOS sürümüne yüklenemez. Bu rehberdeki adımları da yedek olarak saklayın.
2. İsteğe bağlı: Yönetici PowerShell ile BIOS görüntüsü alın.

   ```powershell
   .\nvram\nvram_snap.ps1 -OutDir .\snap_guncelleme_oncesi -Label "guncelleme oncesi"
   ```

3. BitLocker kullanıyorsanız kurtarma anahtarını hazır tutun. BIOS güncellemesi fTPM'i sıfırlarsa Windows kurtarma anahtarı ister.

### BIOS güncellemesinden veya CMOS sıfırlamasından sonra

- Adımları sırayla uygulayın: önce RAM, sonra işlemci, sonra güvenlik.
- Her büyük adımdan sonra kaydedin ve yeniden başlatın (**F10**).
- Son olarak kontrol betiğini çalıştırın ([bölüm 11](#11-kontrol)).

---

## 4. BIOS: RAM

Bu bölümü ilk olarak uygulayın.

**Ai Tweaker**

| Ayar | Değer |
|---|---|
| Ai Overclock Tuner | Manual |
| Memory Frequency | DDR5-8000 |
| FCLK Frequency | 2000 MHz |
| High DRAM Voltage Mode | Enabled. 1,435 V üstü DRAM voltajı için gerekir. |
| DRAM VDD Voltage | 1.600 |
| DRAM VDDQ Voltage | 1.600 |

**Ai Tweaker → DRAM Timing Control**

| Ayar | Değer | Ayar | Değer |
|---|---|---|---|
| Tcl | 34 | Trtp | 14 |
| Trcd Rd | 46 | TrrdL | 10 |
| Trcd Wr | 46 | TrrdS | 8 |
| Trp | 46 | Tfaw | 20 |
| Tras | 50 | TwtrL | 16 |
| Trc | 96 | TwtrS | 6 |
| Twr | 48 | TrdrdScl / TrdrdSc / TrdrdSd / TrdrdDd | 8 / 1 / 1 / 1 |
| Refresh Interval (tREFI) | 65535 | TwrwrScl / TwrwrSc / TwrwrSd / TwrwrDd | 8 / 1 / 1 / 1 |
| Trfc1 | 664 | Twrrd | 6 |
| Trfc2 | 852 | Trdwr | 20 |
| Trfcsb | 730 | | |

| Ayar | Değer |
|---|---|
| Memory Context Restore | Enabled. Her açılışta bellek eğitimi tekrarlanmaz. |
| Power Down Enable | Disabled |
| Gear Down Mode | Enabled |
| Bank Refresh Mode | Mixed (REFab/REFsb) |
| UCLK DIV1 MODE | Auto. 8000 MT/s değerinde UCLK = MEMCLK/2 olur. |
| DDR5 Nitro Mode | Auto. **Enabled yapmayın.** 1-3-1 ayarı Avg FPS değerini %1,4 düşürdü. |
| Diğer tüm ayarlar (RTT/ODT, sürücü dirençleri, VDDIO, SOC) | Auto |

**Kaydedin ve yeniden başlatın.** İlk açılışta bellek eğitimi birkaç dakika sürebilir. Ekran görünmeden kapatmayın.

**Bu kitin sınırları:**
- **Twr:** BIOS, 8000 MT/s değerinde 48'in altını kabul etmez.
- **TwtrL:** 14 değerinde açılmadı.
- **Trcd ve Trp:** 44 değerinde açılmadı.

**Auto olarak bırakılan voltajlar** (CS2 yükü altında ölçüldü):

| Hat | Değer |
|---|---|
| CPU SOC | 1,29 V |
| CPU VDDIO / MC | 1,46 V |
| CPU VDD_MISC | 1,10 V |
| DRAM VDD ve VDDQ | 1,60 V |

**Windows'ta kontrol:** Görev Yöneticisi → Performans → Bellek bölümünde hız **8000 MT/s** olmalıdır. Olay Görüntüleyicisi'nde WHEA hatası olmamalıdır.

---

## 5. BIOS: İşlemci

**Advanced → AMD Overclocking → Precision Boost Overdrive** yolunu izleyin. Menüye girerken çıkan uyarıyı kabul edin.

| Ayar | Değer |
|---|---|
| Precision Boost Overdrive | Advanced |
| PBO Limits | Motherboard |
| CPU Boost Clock Override | Enabled (Positive) |
| Max CPU Boost Clock Override(+) | 200. Bu değer 9800X3D için kullanıldı. Saat tavanı 5,2 GHz'den 5,425 GHz'e çıktı. |

**Precision Boost Overdrive → Curve Optimizer**

| Ayar | Değer |
|---|---|
| Curve Optimizer | All Cores |
| All Core Curve Optimizer Sign | Negative |
| All Core Curve Optimizer Magnitude | 10. Etkisi ölçülmedi. Zararsızdır. İsterseniz Auto bırakın. |

**Ai Tweaker**

| Ayar | Değer |
|---|---|
| Core tunings Configuration for gaming | Level 2. Etkisi doğrulanmadı. Zararsızdır. İsterseniz Auto bırakın. |

**Notlar:**
- AMD Overclocking menüsü, kullanılan BIOS ayar sözlüğünde yoktur. Menü yolu ekran görüntülerinden ve NVRAM farkından çıkarıldı.
- Aynı PBO ayarları **Ai Tweaker → Precision Boost Overdrive** altında da bulunur. Bu kurulumda bu ayarlar Auto olarak bırakıldı.

---

## 6. BIOS: Auto olarak kalacak ayarlar

Bu ayarlar denendi. Fayda sağlamadılar veya zarar verdiler. Auto olarak bırakın.

| Menü | Ayar | Değer | Neden |
|---|---|---|---|
| AMD Overclocking / DRAM Timing Control | DDR5 Nitro Mode | Auto | 1-3-1 ayarı Avg FPS'i %1,4 düşürdü |
| Advanced → AMD CBS → CPU Common Options | Latency Under Load | Auto | Ölçülebilir etki yok |
| Ai Tweaker → Precision Boost Overdrive | Medium Load Boostit | Auto | Ölçülebilir etki yok |
| Ai Tweaker → DIGI + VRM | CPU Load-line Calibration | Auto | Ölçülebilir etki yok. LLC 6 ile sapma içinde kaldı. |
| Advanced → AMD CBS | SMT Control | Auto | Kapatmanın etkisi yok. Kapatılırsa tam kapatma ve açma gerekir. |
| Advanced → AMD CBS | Global C-state Control | Auto | Kanıt yok |
| Ai Tweaker | AI Cache Boost | Auto | ASUS'a göre AI araçları içindir |
| Ai Tweaker | Turbo Game Mode, Gaming Adaptive CCD Parker | Disabled | Çift CCD'li işlemciler içindir. 9800X3D tek CCD'lidir. |
| Ai Tweaker → Precision Boost Overdrive | Thermal Limit | Varsayılan (Level 2, 80 °C) | İşlemci CS2'de en fazla 60 °C olur. |

---

## 7. BIOS: FACEIT ve güvenlik

FACEIT şu ayarları denetler: Secure Boot, TPM 2.0, IOMMU ve Bellek Bütünlüğü (HVCI/VBS). BIOS güncellemesi bu ayarları varsayılana döndürebilir. Güncellemeden sonra kontrol edin.

| Menü | Ayar | Değer |
|---|---|---|
| Boot → Secure Boot | OS Type | Windows UEFI mode |
| Boot → Secure Boot → Key Management | Install Default Secure Boot Keys | Secure Boot "Disabled" veya anahtar yok görünüyorsa çalıştırın |
| Boot → CSM | Launch CSM | Disabled |
| Advanced → AMD fTPM configuration | Firmware TPM switch | Enable Firmware TPM |
| Advanced → CPU Configuration | SVM Mode | Enabled. VBS ve HVCI için gerekir. |
| Advanced → AMD CBS | IOMMU | Auto |
| Advanced → PCI Subsystem Settings | Above 4G Decoding / Resize BAR | Enabled / Enabled |

---

## 8. Windows ve CS2 ayarları

### Windows

| Ayar | Değer | Not |
|---|---|---|
| Donanım hızlandırmalı GPU zamanlaması (HAGS) | Açık | Ayarlar → Sistem → Ekran → Grafik |
| CS2'yi CPU 0 dışında çalıştırma | Uygulayın | Aşağıdaki adımlar. Ölçülen kazanç +%1,8 ile +%2,5. |
| İşlem önceliği | Normal | Yüksek öncelik denendi. Etkisi yok. |
| Bellek Bütünlüğü (HVCI) | Açık | FACEIT için gerekir. |
| Oyun Modu | Kapalı | Test edilmedi. |
| Ethernet: Energy Efficient Ethernet | Kapalı | Aygıt Yöneticisi → ağ bağdaştırıcısı → Gelişmiş. Etkisi ölçülmedi. Bağlantı kısa bir süre kopar. |
| Win32PrioritySeparation | Varsayılan (2) | Değiştirmeyin. Ayrıntı aşağıda. |
| Kesme yerleşimi (Interrupt Affinity) | Varsayılan | Değiştirmeyin. GPU ve USB DPC işi zaten CPU 0'da çalışır. |
| Güç planı | En az işlemci durumu %100, çekirdek park etme kapalı | Değişiklik ölçülmedi. |

### CS2'yi CPU 0 dışında çalıştırma

Bu adımı her Steam açılışında tekrarlayın.

1. Steam açıkken Görev Yöneticisi'nde **Ayrıntılar** sekmesini açın.
2. `steam.exe` satırına sağ tıklayın ve **Benzeşimi ayarla** seçin.
3. **CPU 0** kutusunun işaretini kaldırın ve **Tamam** seçin.
4. CS2'yi Steam'den başlatın. CS2 bu ayarı Steam'den devralır. `cs2.exe` dosyasına ayrıca dokunmanız gerekmez.

CS2'yi NVIDIA App ile başlatırsanız CS2 yine `steam.exe` altında açılır ve ayarı devralır. Bu durum denendi ve doğrulandı.

### CPU 0 neden önemlidir

`windows/irq_sample.ps1` ile CPU başına kesme ve DPC sayısı ölçüldü:

- CS2 benchmark sırasında saniyede yaklaşık 9700 DPC oluştu. Bunların %99'dan fazlası CPU 0'da çalıştı.
- CPU 0 zamanının yaklaşık %24'ü kesme ve DPC işine gitti.
- Fare hareket edince (8000 Hz) saniyede yaklaşık 4300 ek DPC oluştu. Bunların hepsi CPU 0'da çalıştı.
- Diğer çekirdeklerde DPC yok denecek kadar azdı.

Windows, GPU ve USB işini zaten CPU 0'da çalıştırır. Bu nedenle kesmeleri kayıt defteriyle CPU 0'a bağlamak yeni bir şey değiştirmez. CS2'yi CPU 0'dan uzak tutmak, bu işi oyundan ayırır.

### Win32PrioritySeparation

Bu sistemde (Windows 11, derleme 26300) varsayılan değer 2'dir. Ölçüm şunu gösterdi: Ön plandaki uygulamanın iş parçacıklarının önceliği 8'den 10'a çıkar. Aynı çekirdeği paylaşan ön plan uygulaması zamanın %99'unu alır, arka plan uygulaması %1'ini alır.

İnternette önerilen 0x2A değeri sabit zaman dilimi seçer. Bu değer burada ölçülmedi. Aynı işlemci ve ekran kartıyla yapılan bir dış veri setinde (cs2kitchen/cs2FpsBoostReal) bu ayarın etkisi ölçüm sapmasının içinde kaldı. Varsayılan değeri değiştirmeyin.

**Kalıcı yol (denenmedi):** Steam'i şu komutla başlatabilirsiniz:

```
cmd /c start "" /affinity FFFE "C:\Program Files (x86)\Steam\steam.exe"
```

FACEIT'in bu yöntemle ilgili resmi bir açıklaması yoktur.

### CS2 oyun içi ayarları

Ölçümler sırasında bu ayarlar sabit tutuldu. Kaynak: `cs2_video.txt`.

| Ayar | Değer |
|---|---|
| Çözünürlük | 1280 × 960 (4:3), tam ekran |
| Yenileme hızı | 360 Hz |
| V-Sync | Kapalı |
| `fps_max` | 0 (sınırsız) |
| MSAA | 2x |
| Anizotropik filtre | 16x |
| Gölge ve doku kalitesi | Düşük |
| Dinamik gölgeler | Tümü |
| Parçacık ve ortam aydınlatması | Düşük veya kapalı |
| FSR | Kapalı |
| NVIDIA Reflex | Kapalı |
| Başlatma seçenekleri | `+exec crosshair.cfg -condebug` |

`-condebug` seçeneği, VProf sonuçlarının `console.log` dosyasına yazılması için gerekir.

### FACEIT nedeniyle değiştirilmeyen ayarlar

Ölçüm sırasında bu ayarlara dokunulmadı: Secure Boot, CSM, Firmware TPM, IOMMU, SVM, DMA koruması, Pluton, VBS/HVCI ve Windows Update.

### Fan ve pompa (isteğe bağlı)

Fan ayarları performans ölçümünün parçası değildir.

- **CPU ve kasa fanı:** PWM Mode, Manual eğri. 20, 30, 40, 50, 60, 67, 70 ve 100 °C noktalarında %20, 26, 34, 45, 60, 80, 100 ve 100.
- **AIO pompa:** PWM Mode, Manual eğri. 30, 40, 50, 58, 65, 70, 85 ve 100 °C noktalarında %20, 20, 36, 52, 68, 84, 100 ve 100.
- **Ölçülen pompa devri:** Boşta yaklaşık 1240 rpm. Tam hızda yaklaşık 2780 rpm.

---

## 9. Ekran kartı hız aşırtma

Kart: GIGABYTE RTX 5070 Ti AERO OC 16G. Her kart farklıdır. Bu değerleri doğrudan kopyalamayın. Kendi sınırınızı aşağıdaki yöntemle bulun.

### Günlük ayar (MSI Afterburner, Profil 1)

| Ayar | Değer |
|---|---|
| Core Voltage | 0. Değiştirmeyin. |
| Power Limit | %116 (350 W, kartın en yüksek değeri) |
| Core Clock | +450 MHz |
| Memory Clock | +3000 MHz. Sürücünün izin verdiği en yüksek değerdir. |
| Fan | Otomatik (kartın kendi eğrisi) |

CS2 yükünde çekirdek yaklaşık 3225 MHz'de çalışır (stok 2775 MHz). Bellek 17001 MHz'de çalışır (stok 14001 MHz, 28 Gbps yerine 34 Gbps). CS2'de güç yaklaşık 150 W'tır. Güç sınırına ulaşılmaz.

### Uygulama

1. NVIDIA App → **Sistem → Performans** bölümünde **Otomatik Ayarlama** açıksa kapatın ve **GERİ YÜKLE** seçin. İki araç aynı anda ofset yazmamalıdır.
2. MSI Afterburner'ı MSI'nin resmi sitesinden kurun. Kurulumda Norton seçeneğinin işaretini kaldırın. RivaTuner Statistics Server gerekmez.
3. Power Limit, Core Clock ve Memory Clock değerlerini girin ve **Apply** seçin.
4. **Save** seçin ve **1** yuvasına kaydedin. Kilit simgesiyle profilleri kilitleyin. Kilit yalnızca kaydetmeyi engeller. Profili yüklemeyi engellemez.
5. Her Windows açılışında Afterburner'ı açın ve **1** seçin. Afterburner'ın kendi açılışta uygulama ayarı bu sistemde yeniden başlatmadan sonra değerleri uygulamadı. `MSIAfterburner.exe -Profile1` komutu çalışır.
6. Kontrol: Afterburner'da +450, +3000 ve 116 görünmelidir. `nvidia-smi` güç sınırını 350 W göstermelidir.

Afterburner'ın RTCore64 sürücüsü, Bellek Bütünlüğü (HVCI) açıkken yüklendi. Secure Boot, TPM ve HVCI ayarları değişmedi.

### CS2 etkisi

| Karşılaştırma | Ortalama FPS | Yöntem |
|---|---|---|
| Stok → +400 / +2750 / %116 | **+%2,6** | 2×2, iki oturum, ters sıra, hücre başına 2 koşu |
| Bellek +200 → +2750 (çekirdek +400) | +%0,2 | Aynı oturum, ABBA |
| Bellek −1000 MHz (çekirdek stok) | −%0,2 (sapma içinde) | Aynı oturum, MNNM |
| Çekirdek +155 → +300 | +%0,7 | Aynı oturum, 6 koşu |
| Çekirdek +155 → +450 | +%1,35 | Aynı oturum, tek koşular |
| GPU saati 2930 → 2572 MHz (−%12) | −%2,8 | Aynı oturum, ABBA, `nvidia-smi -lgc` |
| Maksimum voltaj %100 ve güç %116 | Sapma içinde (saat +8 MHz) | Aynı oturum |

P1 değeri hiçbir ekran kartı ayarında ölçülebilir şekilde değişmedi.

### Kendi sınırınızı bulma

Yöntem, fpsheaven GPU hız aşırtma rehberinin akışını izler. Ölçüm aracı: Unigine Superposition 1.1, 1080p Extreme.

1. Stok puanı 2 veya 3 koşu ile ölçün.
2. **Çekirdek:** Bellek 0 ve Power Limit en yüksek değerde olsun. +200'den başlayın. 25 MHz adımlarla artırın.
3. Her adımı 2 koşu ile ölçün. Bu kartta puanlar aynı saatte iki kümede çıktı (yaklaşık %4,5 fark).
4. Çökme (TDR) veya puan düşüşü görürseniz durun. Son temiz değer sınırdır.
5. **Bellek:** Çekirdeği sabit tutun. +1000'den başlayın. 250 veya 500 MHz adımlarla artırın.
6. **Günlük değer:** Sınırdan çekirdekte 25–50 MHz, bellekte 100–250 MHz geri gelin.
7. **Doğrulama:** Sırayla OCCT 3D Adaptive (Switch, %30/%100, 500 ms) 1 saat, MSI Kombustor PBR-Donut (artefakt tarayıcı açık) 1 saat, OCCT VRAM %98 ve CS2 çalıştırın.

**Bu karttaki sınırlar:**

| Test | Geçen en yüksek değer | Çöken değer |
|---|---|---|
| Superposition (sabit yük) | +500 / +3000 | +525 / +3000 |
| OCCT 3D Adaptive Switch (yük geçişi) | +450 / +3000, 1 saat | +475 / +3000, 4. dakikada |
| CS2 benchmark (kısa koşu) | +450 / +200 | +500 / +200, harita yüklenirken |

Yük geçişi, sabit yükten daha zordur. Superposition'da geçen değer OCCT Switch testinde çökebilir. Günlük değeri OCCT Switch ile doğrulayın.

**+450 / +3000 doğrulaması:** OCCT 3D Adaptive Switch 1 saat hatasız. Kombustor 1 saat, artefakt 0. OCCT VRAM %98 21 dakika hatasız. CS2 3 koşu sorunsuz. En yüksek sıcaklık 72 °C.

### Notlar

- **Undervolt:** VF eğrisinde 3217 MHz için 1000, 990 ve 985 mV denendi. Gerçek voltaj yine yaklaşık 1005 mV oldu. 970 mV'de güç 20 W düştü ama puan da düştü. Bu kartta undervolt fayda sağlamadı.
- **TDR sonrası:** Sürücü güç sınırını ve ofsetleri sıfırlar. Afterburner'da profili yeniden yükleyin.
- **NVIDIA App Otomatik Ayarlama:** Bu kartta +182 / +200 buldu. Yükte saat yaklaşık 2930 MHz oldu.
- **Afterburner'sız yol:** NVIDIA sürücüsünün `nvml.dll` kütüphanesindeki `nvmlDeviceSetClockOffsets` işlevi ek sürücü kurmadan ofset yazar. Bellek birimi Afterburner biriminin 2 katıdır. Ayar yeniden başlatmada silinir. NVIDIA App ayarının üzerine yazar.
- **OCCT:** Açılışta HWiNFO çekirdek sürücüsünü yükler. Sürücü, Windows yeniden başlayana kadar yüklü kalır.
- **Kombustor:** Akıllı Uygulama Denetimi açıksa sensör DLL'si engellenir. Sensörler N/A görünür. Test ve artefakt tarayıcısı yine çalışır.

---

## 10. Başka sistemlere uyarlama

| Durum | Yapılacak işlem |
|---|---|
| Aynı işlemci ve anakart, farklı RAM | Önce Ai Overclock Tuner = EXPO veya XMP deneyin. Bu bölümdeki zamanlamaları yalnızca **SK Hynix 24 Gbit M-die, 2 × 24 GB, tek rank** kitinde başlangıç noktası olarak kullanın. PBO, Windows ve FACEIT adımları aynen geçerlidir. |
| Başka X3D işlemci | Boost Override üst sınırı işlemciye göre değişir. Çift CCD'li X3D işlemcilerde (9900X3D, 9950X3D) Turbo Game Mode, CCD Parker ve Core Flex X3D preset anlamlı olabilir. Bu değerler burada test edilmedi. |
| Başka ASUS AM5 anakart | Menü adları büyük ölçüde aynıdır. NVRAM ofsetleri farklıdır. Kendi BIOS dosyanızdan ayar sözlüğü çıkarın ve `-IfrFile` ile kontrol edin. |
| Başka marka anakart | Menü adları farklıdır. Ayarların anlamı aynıdır. Kontrol betiği çalışmaz. Listeyi elle uygulayın. |
| Tüm durumlar | Her seferde tek ayarı değiştirin. Her değişiklikten sonra ölçün ve WHEA hatası olup olmadığına bakın. |

### Kendi ayar listenizi oluşturma

1. Ayarlarınızı BIOS'tan elle girin.
2. BIOS görüntüsü alın ve döküm oluşturun:

   ```powershell
   .\nvram\nvram_snap.ps1 -OutDir .\snap_benim
   .\nvram\bios_dump.ps1 -SnapDir .\snap_benim -IfrFile .\sozluk\ifr_all.tsv -OutCsv .\benim.csv -OutMd .\benim.md
   ```

3. `ayarlar/hedef_ayarlar_2503.csv` dosyasının kopyasında `Hedef` ve `Hedef_ham` sütunlarını kendi değerlerinizle değiştirin.
4. Kontrolü kendi listenizle çalıştırın:

   ```powershell
   .\kontrol\ayar_kontrol.ps1 -Hedef .\benim_hedeflerim.csv
   ```

---

## 11. Kontrol

Yönetici PowerShell'de depo klasörünü açın ve şu komutları çalıştırın:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\kontrol\ayar_kontrol.ps1          # BIOS ve Windows
.\kontrol\ayar_kontrol.ps1 -Fan     # Fan ve pompa eğrileriyle birlikte
```

Bu betik **yalnızca okur**. Hiçbir dosyaya yazmaz.

Betik şunları yapar:
- Canlı BIOS değerlerini (UEFI NVRAM) `ayarlar/hedef_ayarlar_2503.csv` listesiyle karşılaştırır.
- Windows'ta şunları denetler: SMT, RAM hızı (8000), Secure Boot, TPM, VBS/HVCI, HAGS, `steam.exe` ve `cs2.exe` CPU 0 durumu ve WHEA hataları.
- Her farklı ayar için menü yolunu yazar.
- Çıkış kodu, farklı ayar sayısını verir. 0 ise tüm ayarlar doğrudur.

### Yeni BIOS sürümü kullanıyorsanız

Ayarların NVRAM içindeki konumu değişmiş olabilir. Yeni BIOS dosyasından sözlük oluşturun ve kontrolü bu sözlükle yapın:

```powershell
Add-Type -Path .\tools\BiosIfr.cs, .\tools\EfiDec3b.cs
[Prog]::Main(@('C:\indirilenler\BIOS.CAP', '.\yeni_sozluk'))
.\kontrol\ayar_kontrol.ps1 -IfrFile .\yeni_sozluk\ifr_all.tsv
```

AMD Overclocking ayarları (PBO ve Curve Optimizer) sözlükte yoktur. Değişkenin boyutu değiştiyse betik "DUZEN FARKLI" uyarısı verir. Bu ayarları menüden elle kontrol edin.

Ayrıntılı fark için güncelleme öncesi ve sonrası görüntüleri karşılaştırın:

```powershell
.\nvram\nvram_snap.ps1 -OutDir .\snap_sonra -Label sonra
.\nvram\nvram_diff.ps1 -A .\snap_guncelleme_oncesi -B .\snap_sonra
```

---

## 12. Ölçüm yöntemi

### Benchmark

- **Harita:** Steam Workshop `3240880604` (de_dust2). Konsolda `map_workshop 3240880604 de_dust2` komutunu yazın.
- **Koşu süresi:** Yaklaşık 129 saniye. Koşu sonunda CS2, VProf özetini `console.log` dosyasına yazar.
- **Ayarlar:** Tüm koşularda aynıydı: 1280×960, tam ekran, 360 Hz, `fps_max 0` ve FACEIT kapalı. HWiNFO yalnızca bir testte açıktı.

### Karar kuralı

- **Ayrı oturumlar (BIOS testleri):** Her ayar için 6 kayıt koşusunun medyanı ve aralığı karşılaştırıldı. Aralıklar çakışmıyorsa fark **kesin** kabul edildi. Fark %0,6'dan küçükse oturum sapmasından ayırt edilemez.
- **Aynı oturum (Windows testleri):** Koşullar dönüşümlü sırayla çalıştırıldı. Eşleştirilmiş t testi uygulandı. 6 turda |t| > 2,571 ve 3 turda |t| > 4,30 olduğunda fark anlamlı kabul edildi.

### Isınma koşuları ve sapma

- Her yeni CS2 oturumunda ortalama FPS, ilk yaklaşık 6 koşuda %1,2 ile %1,3 düşer. Sonra değer sabitlenir.
- Bu nedenle her oturumun ilk 6 koşusu **ısınma koşusu** sayıldı. Bu koşular sonuçlara alınmadı.
- Aynı BIOS ayarı iki ayrı oturumda ölçüldüğünde fark %0,55 çıktı.

### Ekran kartı ve Windows testleri

- Karşılaştırılan koşullar aynı CS2 oturumunda ABBA sırasıyla çalıştırıldı. 2×2 testte ikinci oturum ters sırayla çalıştırıldı. Bu yöntem oturum içindeki doğrusal kaymayı dengeler.
- Her koşuda `nvidia-smi` saniyede bir GPU saatini, bellek saatini, gücü ve sıcaklığı kaydetti.
- Her koşudan sonra System günlüğünde `nvlddmkm` ve Display 4101 (TDR) olayları kontrol edildi. CS2'nin açık olduğu kontrol edildi.
- Kesme örnekleyicisi açıkken yapılan koşular karşılaştırmaya alınmadı.

### CS2 güncellemesi

CS2 güncellemesi sonuçları %1 ile %2 arasında kaydırabilir. Bir ölçümde CS2 iki oturum arasında güncellendi ve aynı ayarla %1–2 fark görüldü. Bu nedenle:

- Her oturumdan önce `steamapps\appmanifest_730.acf` dosyasındaki `LastUpdated` değerine bakın.
- Ayrı oturumlardaki tek koşuları karşılaştırırken sapmayı en az %1–2 kabul edin.

### VProf çıktısı

```
[VProf] Summary of 122110 frames and 129 1-second intervals.
[VProf] FPS: Avg=943.7, P1=349.1
[VProf]           FrameTotal   1.06   2.86   122110   1.06   2.86     3.18   4.06      129   3.18   4.06
```

VProf bazı kareleri analizden çıkarır. Bu nedenle P1 ve P99 değerleri, PresentMon veya CapFrameX değerleriyle birebir aynı değildir.

---

## 13. Araçlar

Tüm betikler **Windows PowerShell 5.1** ile test edildi. Çıktılar Türkçedir. Gerekirse önce `Set-ExecutionPolicy -Scope Process Bypass` komutunu çalıştırın.

### `bench/`: CS2 ölçümü

CS2, `-condebug` seçeneğiyle açık olmalıdır. `console.log` yolu betiklerin başında tanımlıdır. Steam farklı bir klasördeyse yolu değiştirin.

| Betik | Görevi |
|---|---|
| `run_bench.ps1` | Konsolu açar, haritayı yükler, `[VProf] FPS:` satırını bekler ve sonraki koşuya geçer. Plan biçimi: `-Plan ad:maske:koşu[:öncelik];…`. Öncelik değeri N, A veya H olabilir. `-Warmups` ısınma koşusu sayısını belirler. `bench_stop.txt` dosyası oluşturulursa betik durur. Bitince affinity ve önceliği varsayılana döndürür. CS2 başta simge durumundaysa yeniden simge durumuna alır ve önceki pencereyi öne getirir. |
| `vprof_stage.ps1` | Belirli bir zaman aralığındaki koşuları okur. Avg, P1, P99, ortalama kare süresi, WHEA ve Kernel-Power 41 sayısını verir. |
| `interleave_report.ps1` | Dönüşümlü koşuları eşleştirilmiş t testi ile karşılaştırır. |
| `snap_console.ps1` | `console.log` dosyasını yedekler. CS2 her açılışta bu dosyayı sıfırlar. |
| `cs2_affinity.ps1` | `cs2.exe` affinity değerini okur veya ayarlar (`-Mask 0xFFFE`). Bu değer kalıcı değildir. |

```powershell
# CS2 açık olsun. FACEIT kapalı olsun. BIOS değişikliğinden sonra yeni oturumda:
.\bench\run_bench.ps1 -Plan AYAR:0xFFFF:12 -Warmups 6
.\bench\vprof_stage.ps1 -Start '10/19 12:30' -Name AYAR
```

**Notlar:**
- `Start-Process` ile `-Plan` değeri geçirirken tek tırnak kullanmayın. Tek tırnak değeri olduğu gibi iletir ve hiçbir koşu çalışmaz.
- Tarihler `console.log` biçimindedir: `MM/dd HH:mm`. Yıl betiklerde 2026 olarak sabittir.

### `nvram/`: BIOS okuma (yalnızca okur)

| Betik | Görevi |
|---|---|
| `nvram_snap.ps1` | Tüm NVRAM değişkenlerinin dizinini kaydeder: ad, GUID, boyut ve SHA256. Ayar değişkenlerinin ham baytlarını da kaydeder. Parola, anahtar, lisans ve TPM içeren değişkenleri kaydetmez. |
| `nvram_diff.ps1` | İki görüntüyü karşılaştırır. `-Decoded` ve `-IfrFile` ile ayar adlarını da gösterir. |
| `bios_dump.ps1` | Görüntüyü ayar sözlüğüyle birleştirir ve okunur döküm oluşturur (CSV ve Markdown). |

### `kontrol/`: ayar kontrolü

`ayar_kontrol.ps1` betiğinin açıklaması [bölüm 11](#11-kontrol) bölümündedir.

### `hwinfo/`: sensör kaydı

Bu betikler HWiNFO'nun paylaşılan belleğini okur. HWiNFO'da **Shared Memory Support** seçeneği açık olmalıdır.

| Betik | Görevi |
|---|---|
| `hw_sample.ps1` | Tüm sensörleri 1 saniye aralıkla CSV dosyasına yazar. |
| `hw_report.ps1` | CSV dosyasından özet çıkarır. |
| `hwinfo_sm_read.ps1` | Anlık değerleri listeler. |

### `gpu/`: ekran kartı ölçümü

Bu betikler yönetici PowerShell ister. MSI Afterburner ve `nvidia-smi` gerekir. Sonuçlar `gpu\sonuc\` klasörüne yazılır.

| Betik | Görevi |
|---|---|
| `ab_profil_yaz.ps1` | Afterburner profil yuvasını yazar ve uygular (`-Slot 5 -Core 450 -Mem 3000 -PL 116`). Önce profil dosyasının yedeğini alır. Fan değeri verilmezse fan satırı yazmaz ve fan otomatik kalır. |
| `cs2_gpu_ab.ps1` | Afterburner profillerini ve CPU 0 ayarını aynı CS2 oturumunda karşılaştırır. Her koşuda GPU kaydı tutar ve TDR olayını kontrol eder. Kararsızlık görürse durur. |
| `gpu_saat_kilit_ab.ps1` | `nvidia-smi -lgc` ile GPU saatini sınırlar ve kilitsiz durumla karşılaştırır. Kilidi her durumda kaldırır. |

```powershell
# 2x2 test: Profil 5 = stok (0/0/100), Profil 1 = günlük ayar. İkinci oturumda sırayı ters çevirin.
.\gpu\cs2_gpu_ab.ps1 -Order 'SF1:5:0xFFFF,SE1:5:0xFFFE,OF1:1:0xFFFF,OE1:1:0xFFFE' -EndProfile 1 -Tag GUN
```

### `windows/`: kesme ve çökme analizi (yalnızca okur)

| Betik | Görevi |
|---|---|
| `irq_sample.ps1` | Her saniye CPU başına kesme ve DPC sayısını ölçer. Fare hareketli ve durgun saniyeleri ayırır. Sonuçta CPU başına farkı yazar. `-OutCsv` ile ham veriyi kaydeder. |
| `dump_ozet.ps1` | Minidump dosyasını (`.dmp`, `.mdmp`) okur. İstisna kodunu, hatalı modülü ve yığındaki modülleri yazar. |

### `tools/`: BIOS ayar sözlüğü

```powershell
Add-Type -Path .\tools\BiosIfr.cs, .\tools\EfiDec3b.cs
[Prog]::Main(@('C:\yol\BIOS.CAP', '.\sozluk'))     # sozluk\ifr_all.tsv dosyasını oluşturur
```

Bu araç AMI Aptio BIOS kapsülünü (`.CAP`) açar. BIOS 2503 için 9304 ayar çıkarır. Bunların 408'i gizlidir. Sözlük, üreticinin telifli BIOS dosyasından çıkarıldığı için depoda yoktur. Kendi BIOS dosyanızdan oluşturun.

---

## 14. Sorun giderme

| Belirti | Çözüm |
|---|---|
| RAM ayarından sonra açılmıyor veya bellek eğitimi bitmiyor | Bekleyin. Açılmazsa **Clear CMOS** yapın ve ayarları yeniden girin. Hâlâ açılmazsa bir kademe gevşetin (örneğin Trcd/Trp +2, Trfc1 +32). Bu gevşek değerler denenmedi. |
| Rastgele çökme veya WHEA hatası | Önce RAM sıcaklığını kontrol edin. tREFI 65535 sıcaklığa duyarlıdır. Sonra FCLK değerini kontrol edin. Gerekirse RAM'i EXPO veya XMP profiline alın. |
| FACEIT, Secure Boot, TPM veya VBS hatası | [Bölüm 7](#7-bios-faceit-ve-güvenlik) ayarlarını kontrol edin. Windows Güvenliği → Cihaz güvenliği → Çekirdek yalıtımı → Bellek bütünlüğü açık olmalıdır. |
| Windows 8 mantıksal işlemci gösteriyor | SMT kapalı kalmıştır. Advanced → AMD CBS → SMT Control değerini Auto yapın ve bilgisayarı tamamen kapatıp açın. |
| BIOS güncellemesinden sonra BitLocker anahtarı isteniyor | fTPM sıfırlanmıştır. Kurtarma anahtarını girin. Sonra fTPM'in açık olduğunu kontrol edin. |
| Steam yeniden başlatıldıktan sonra CPU 0 ayarı kayboldu | [Bölüm 8](#cs2yi-cpu-0-dışında-çalıştırma) adımlarını tekrarlayın. |
| Ekran bir an kararıyor, oyun kapanıyor. Olay Görüntüleyicisi'nde `nvlddmkm` 153 veya 14 var. | Ekran kartı hız aşırtması kararsızdır (TDR). Çekirdeği 25 MHz düşürün. TDR sonrası sürücü ofsetleri ve güç sınırını sıfırlar. Afterburner'da profili yeniden yükleyin. |
| Yeniden başlatmadan sonra ekran kartı stok saatte | Afterburner'ı açın ve Profil 1'i yükleyin ([bölüm 9](#9-ekran-kartı-hız-aşırtma)). |
| CS2 aniden kapandı. Döküm `soundsystem.dll` içinde. | Kablosuz kulaklık alıcısı oyun açıkken yeniden bağlanmıştır. CS2 ses aygıtını yeniden başlatırken çöker. CS2 açıkken alıcıyı çıkarıp takmayın. Dökümü `windows\dump_ozet.ps1` ile okuyun. |

---

## 15. Sınırlar

**Sınırlar:**
- **Tek sistem:** Ölçümler tek işlemci, tek RAM kiti ve tek anakartla yapıldı. Sonuçları başka sistemlere doğrudan uygulamayın.
- **Oturum sapması:** Oturumlar arasında ±%0,6 sapma vardır. Bundan küçük farklar ayırt edilemez.
- **BIOS karşılaştırmaları:** BIOS güncellemesi ve RAM ayarı aynı anda yapıldı. Bu nedenle FPS farkını yalnızca RAM ayarına bağlayamazsınız.
- **Gecikme ölçülmedi:** LDAT veya Reflex Analyzer kullanılmadı. Değerlendirme kare sürelerine dayanır.
- **Benchmark ve maç farkı:** Benchmark haritasında bot vardır, sunucu yükü yoktur. Maçta ortalama FPS, benchmarka göre yaklaşık %27 düşük ölçüldü. Benchmark sonuçları maç performansının birebir karşılığı değildir.
- **Ekran kartı kararlılığı:** Günlük ayar sentetik testlerle (toplam yaklaşık 2 saat 20 dakika) ve kısa CS2 koşularıyla doğrulandı. Uzun oyun oturumlarında ve sıcak ortamda kararlılığı ayrıca izleyin.
- **CS2 sürümü:** Windows ve ekran kartı testleri, BIOS testlerinden sonraki bir CS2 sürümünde yapıldı. İki gruptaki FPS değerlerini doğrudan karşılaştırmayın.

**Test edilmeyen konular:**

| Konu | Neden |
|---|---|
| Secure Boot, TPM, IOMMU, HVCI, SVM, CSM | FACEIT denetler. Bu ayarlara dokunulmadı. |
| DDR5-6000 1:1 | Bu kurulumda tercih edilmedi. |
| iGPU kapatma | Bu kurulumda tercih edilmedi. |
| CS2 grafik ayarları (MSAA, Reflex vb.) | Etkisi ölçülmedi. |
| BCLK | PCIe saatini de değiştirir. Önerilmez. |
| Thermal Limit, PBO limitleri, daha derin Curve Optimizer | İşlemci saat tavanındadır ve güç sınırından uzaktır. Kazanç beklenmez. |
| Turbo Game Mode, Gaming Adaptive CCD Parker | Çift CCD'li işlemciler içindir. 9800X3D tek CCD'lidir. |
| Process Lasso, PBO2 Tuner gibi çekirdek sürücüsü yükleyen araçlar | Kullanılmadı. |
| Ekran kartı çekirdek voltajı artırma | NVIDIA App'te maksimum voltaj saati yalnızca 8 MHz artırdı. Afterburner'da denenmedi. |
| Kesmeleri kayıt defteriyle başka çekirdeğe taşıma | Varsayılan yerleşim zaten CPU 0'dır. CS2'yi CPU 0'dan uzak tutmak daha basittir. |

**Sıradaki adaylar (ölçülmedi):**
1. **FCLK 2100, 2167 veya 2200:** Tahmini etki %0 ile %2 arasındadır. Kararsızlık WHEA 19 olarak görünür.
2. **NVIDIA Low Latency Mode (On veya Ultra), yalnızca `cs2.exe` profilinde:** GPU yükü p95 %96 olduğu için etkisi olabilir.
3. **tRDRDSCL ve tWRWRSCL 8'den 6'ya, tRDWR 20'den 18'e:** Düşük riskli ikincil zamanlamalardır. Tahmini etki %0 ile %1,5 arasındadır.

---

## 16. Depo yapısı

| Klasör veya dosya | İçerik |
|---|---|
| `README.md` | Bu rehber |
| `ayarlar/hedef_ayarlar_2503.csv` | 125 hedef ayar. Menü yolu, değer, NVRAM konumu, beklenen ham değer ve ölçülen etki. |
| `kontrol/ayar_kontrol.ps1` | Canlı BIOS ve Windows durumunu hedef listeyle karşılaştırır. Salt okunur çalışır. |
| `bench/` | CS2 benchmark otomasyonu ve analiz betikleri |
| `nvram/` | BIOS okuma, görüntü alma, karşılaştırma ve döküm betikleri |
| `hwinfo/` | HWiNFO sensör kaydı betikleri |
| `tools/` | BIOS ayar sözlüğü oluşturma (`BiosIfr.cs`) ve EFI açıcı (`EfiDec3b.cs`) |
| `gpu/` | Afterburner profil yazma ve ekran kartı A/B ölçüm betikleri |
| `windows/` | CPU başına kesme/DPC ölçümü ve minidump özeti |
| `data/kosular.csv` | BIOS testlerinin tüm benchmark koşuları ve maçlar (134 satır) |
| `data/gpu_windows_kosular.csv` | Windows ve ekran kartı testlerinin CS2 koşuları (50 satır). GPU saati, bellek saati ve güç dahil. |
| `data/gpu_superposition.csv` | Superposition 1080p Extreme puanları: stok, çekirdek ve bellek adımları, undervolt, çökmeler |
| `data/gpu_kararlilik.csv` | Kararlılık testleri: OCCT, Kombustor, Superposition ve CS2. Süre, sonuç, saat, güç ve sıcaklık. |
| `data/ozet.csv` | Test ve koşul başına medyan, en düşük ve en yüksek değerler |
| `data/testler.csv` | Her testin BIOS durumu, değişen ayar, affinity, öncelik ve sonuç |
| `data/bios_son_durum.csv` | Son BIOS durumunun tam dökümü. Ham baytlar ayar sözlüğüyle çözüldü. |
| `data/bios_aod_alanlari.csv` | AMD Overclocking değişkeninin 226 alanı (PBO, Curve Optimizer vb.) |

**`kosular.csv` sütunları:**

| Sütun | Anlamı |
|---|---|
| `Oturum` | CS2 oturumu. Örnek: O0 = Aşama 0, O3 = PBO200_MB, O9 = öncelik ve CPU 0 testi. |
| `Tip` | `isinma` (karşılaştırmaya girmez), `kayit`, `olcum-disi` veya `mac` |
| `Avg_FPS`, `P1_FPS` | Ortalama FPS ve %1 düşük FPS |
| `P99_ms` | Karelerin %99'unun altında kaldığı süre |
| `Ort_kare_ms` | Ortalama kare süresi |
| `Maks1s_P50_ms`, `Maks1s_P95_ms` | Her saniyedeki en uzun karenin medyanı ve 95. yüzdeliği. Takılmayı gösterir. |
| `Not` | Özel durumlar |

**`gpu_windows_kosular.csv` sütunları:** `Oturum` (G1–G7), `Test`, `Kosul`, `GPU_ayar` (çekirdek / bellek / güç), `Benzesim` (0xFFFF tüm çekirdekler, 0xFFFE CPU 0 hariç), `Tip` (`kayit`, `isinma`, `gecersiz`, `cokme`), `Avg_FPS`, `P1_FPS`, `GPU_MHz`, `Bellek_MHz` (yük altında medyan, nvidia-smi birimi), `GPU_W`, `Not`. Boş hücre: değer kaydedilmedi.

**Ölçüm sayıları:**
- **BIOS testleri:** 132 benchmark koşusu (86 kayıt, 44 ısınma, 2 ölçüm dışı), 2 maç, 13 CS2 oturumu ve 13 NVRAM görüntüsü. Hiçbir açılışta WHEA hatası veya Kernel-Power 41 olayı görülmedi.
- **Windows ve ekran kartı testleri:** 7 CS2 oturumunda 48 tamamlanan koşu (40 kayıt, 7 ısınma, 1 geçersiz) ve 2 yarıda kalan koşu (1 TDR, 1 ses aygıtı çökmesi). 34 Superposition koşusu (2'si TDR ile bitti). 11 kararlılık testi.

---

**Lisans:** Bu depoda lisans tanımlanmamıştır.
