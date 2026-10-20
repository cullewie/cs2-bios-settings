# CS2 BIOS ve Windows ayar rehberi

Bu rehber, **Ryzen 7 9800X3D + ASUS ROG STRIX X870-A + DDR5-8000 (SK Hynix M-die) + RTX 5070 Ti** sistemi için ölçülmüş CS2 ayarlarını anlatır. Ayarlar 132 benchmark koşusu ve 2 gerçek maçla ölçüldü.

Bu rehber üç iş için kullanılır:

1. **Aynı sistemi kurmak:** Ayarları sırayla uygulayın.
2. **BIOS güncellemesi veya CMOS sıfırlamasından sonra:** Ayarları geri girin ve kontrol betiğini çalıştırın.
3. **Başka bir sistemde denemek:** [Benzer sistemlere uyarlama](#9-benzer-sistemlere-uyarlama) bölümüne bakın.

> **Uyarı:** RAM hız aşırtması, voltaj artışı ve PBO garanti kapsamını etkileyebilir. Sistem kararsızlığına ve veri kaybına yol açabilir. Tüm riskler size aittir. Değerler tek bir sistemde denendi.

---

## İçindekiler

1. [Sonuç özeti](#1-sonuç-özeti)
2. [Sistem](#2-sistem)
3. [Başlamadan önce](#3-başlamadan-önce)
4. [BIOS: RAM](#4-bios-ram)
5. [BIOS: İşlemci](#5-bios-işlemci)
6. [BIOS: Auto kalması gerekenler](#6-bios-auto-kalması-gerekenler)
7. [BIOS: FACEIT ve güvenlik](#7-bios-faceit-ve-güvenlik)
8. [Windows ve CS2 ayarları](#8-windows-ve-cs2-ayarları)
9. [Benzer sistemlere uyarlama](#9-benzer-sistemlere-uyarlama)
10. [Kontrol: her şey yerinde mi?](#10-kontrol-her-şey-yerinde-mi)
11. [Ölçüm nasıl yapıldı](#11-ölçüm-nasıl-yapıldı)
12. [Araçlar](#12-araçlar)
13. [Sorun giderme](#13-sorun-giderme)
14. [Sınırlamalar ve test edilmeyenler](#14-sınırlamalar-ve-test-edilmeyenler)
15. [Depo yapısı](#15-depo-yapısı)

---

## 1. Sonuç özeti

| Adım | Ortalama FPS | Karar |
|---|---|---|
| RAM 8000 (BIOS 2402 → 2503 ile birlikte) | +%1,2, sonuçsuz. P1 +%4,3 ve P99 −%4,0 gerçek. | Kullanılıyor |
| PBO Advanced + Limits Motherboard + Boost Override +200 | **+%3,5** | Kullanılıyor |
| CS2'yi CPU 0'dan uzak tutmak (Windows affinity) | **+%1,8 ile +%2,5** | Kullanılıyor |
| Curve Optimizer All Cores −10 | −%0,3, etki yok | Açık (zararsız) |
| Core Tuning Config for Gaming Level 2 | Doğrulanmadı | Açık (zararsız) |
| DDR5 Nitro Mode 1-3-1 | **−%1,4** | Auto (kapalı) |
| Latency Under Load, Medium Load Boostit, LLC 6 | Sapma içinde | Auto |
| SMT kapalı | Etki yok | Auto (açık) |
| High işlem önceliği | Etki yok | Normal |

**Toplam:** Ortalama FPS 911 → 970 (**+%6,4**). Ortalama kare süresi 1,10 → 1,03 ms. P99 2,99 → 2,80 ms. Oturumlar arası sapma ±%0,6 olduğu için toplam kazanç yaklaşık **%6 ± 0,6** olarak okunmalı.

**Darboğaz:**
- **İşlemci:** CS2 sırasında tüm çekirdekler 5425 MHz'de (boost tavanı) çalıştı. Güç sınırının yalnız %7,5'ini ve en fazla 60 °C kullandı. Bu yüzden Curve Optimizer, PBO limitleri ve sıcaklık ayarları ek saat kazandırmadı.
- **Ekran kartı:** GPU yük p95 değeri %96. Darboğaz kısmen GPU'da.

---

## 2. Sistem

| Parça | Değer |
|---|---|
| İşlemci | AMD Ryzen 7 9800X3D (8 çekirdek, 16 thread, tek CCD, 3D V-Cache) |
| Anakart | ASUS ROG STRIX X870-A GAMING WIFI |
| BIOS | 2503 (2402'den güncellendi) |
| Bellek | G.Skill F5-8000J4048F24GX2-TZ5RK, 2 × 24 GB, SK Hynix M-die, tek rank, A2 ve B2 yuvaları |
| Ekran kartı | GIGABYTE GeForce RTX 5070 Ti AERO OC 16G |
| Ekran | Alienware AW2523HF, 1920×1080, 360 Hz, DisplayPort |
| Soğutma | Arctic Liquid Freezer III Pro 360 |
| Depolama | Samsung 980 PRO 500 GB |
| İşletim sistemi | Windows 11 Pro, derleme 26300 |
| Sürücü | NVIDIA 617.42 |

---

## 3. Başlamadan önce

### BIOS güncellemesinden önce

1. Mevcut ayarları profile kaydedin:
   - **Tool → ASUS User Profile → Save to Profile** ile bir yuvaya kaydedin.
   - **Load/Save Profile from/to USB Drive** ile USB belleğe de kaydedin.
   - Profil dosyaları genellikle başka bir BIOS sürümünde yüklenemez. Bu yüzden rehber adımları da hazır tutun.
2. İsteğe bağlı: Yönetici PowerShell'de BIOS görüntüsü alın.

   ```powershell
   .\nvram\nvram_snap.ps1 -OutDir .\snap_guncelleme_oncesi -Label "guncelleme oncesi"
   ```

3. BitLocker kullanıyorsanız kurtarma anahtarını hazır tutun. BIOS güncellemesi fTPM'i sıfırlarsa Windows kurtarma anahtarı isteyebilir.

### BIOS güncellemesinden veya CMOS sıfırlamasından sonra

- Adımları sırayla uygulayın: önce RAM, sonra işlemci, sonra güvenlik ayarları.
- Her büyük adımdan sonra kaydedin ve açın (**F10**).
- En sonda kontrol betiğini çalıştırın ([bölüm 10](#10-kontrol-her-şey-yerinde-mi)).

---

## 4. BIOS: RAM

Bu adımı önce uygulayın.

**Ai Tweaker**

| Ayar | Değer |
|---|---|
| Ai Overclock Tuner | Manual |
| Memory Frequency | DDR5-8000 |
| FCLK Frequency | 2000 MHz |
| High DRAM Voltage Mode | Enabled (1,435 V üstü DRAM voltajı için gerekli) |
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
| Memory Context Restore | Enabled (açılışta bellek eğitimi tekrarlanmaz) |
| Power Down Enable | Disabled |
| Gear Down Mode | Enabled |
| Bank Refresh Mode | Mixed (REFab/REFsb) |
| UCLK DIV1 MODE | Auto. 8000 MT/s'de UCLK = MEMCLK/2 olur. |
| DDR5 Nitro Mode | Auto. **Açmayın.** 1-3-1 ölçümünde −%1,4 düşüş oldu. |
| Diğer her şey (RTT/ODT, sürücü dirençleri, VDDIO, SOC) | Auto |

**Kaydedin ve açın.** İlk açılışta bellek eğitimi birkaç dakika sürebilir. Ekran gelmeden kapatmayın.

**Bu kitte sınırlar:**
- **Twr:** BIOS, 8000 MT/s'de 48'in altını kabul etmiyor.
- **TwtrL:** 14 ile açılmadı.
- **Trcd ve Trp:** 44 ile açılmadı.

**Auto bırakılan voltajlar** (CS2 yükü altında ölçüldü):

| Hat | Değer |
|---|---|
| CPU SOC | 1,29 V |
| CPU VDDIO / MC | 1,46 V |
| CPU VDD_MISC | 1,10 V |
| DRAM VDD ve VDDQ | 1,60 V |

**Windows'ta kontrol:** Görev Yöneticisi → Performans → Bellek → Hız **8000 MT/s** görünmeli. Olay Görüntüleyicisi'nde WHEA hatası olmamalı.

---

## 5. BIOS: İşlemci

**Advanced → AMD Overclocking → Precision Boost Overdrive** (menüye girerken çıkan uyarıyı kabul edin)

| Ayar | Değer |
|---|---|
| Precision Boost Overdrive | Advanced |
| PBO Limits | Motherboard |
| CPU Boost Clock Override | Enabled (Positive) |
| Max CPU Boost Clock Override(+) | 200 (9800X3D için kullanılan değer; saat tavanı 5,2 GHz'den 5,425 GHz'e çıktı) |

**Precision Boost Overdrive → Curve Optimizer**

| Ayar | Değer |
|---|---|
| Curve Optimizer | All Cores |
| All Core Curve Optimizer Sign | Negative |
| All Core Curve Optimizer Magnitude | 10 (etkisi ölçülmedi; zararsız, isterseniz Auto bırakın) |

**Ai Tweaker**

| Ayar | Değer |
|---|---|
| Core tunings Configuration for gaming | Level 2 (etkisi doğrulanmadı; zararsız, isterseniz Auto bırakın) |

**Notlar:**
- AMD Overclocking menüsü, kullanılan BIOS ayar sözlüğünde yer almıyor. Menü yolu, ekran görüntülerine ve NVRAM farkına göre yazıldı.
- Aynı PBO ayarları **Ai Tweaker → Precision Boost Overdrive** altında da var. Bu kurulumda onlar Auto bırakıldı.

---

## 6. BIOS: Auto kalması gerekenler

Bu ayarlar denendi. Ya fayda sağlamadı ya da zarar verdi.

| Menü | Ayar | Değer | Neden |
|---|---|---|---|
| AMD Overclocking / DRAM Timing Control | DDR5 Nitro Mode | Auto | 1-3-1, Avg FPS'i %1,4 düşürdü |
| Advanced → AMD CBS → CPU Common Options | Latency Under Load | Auto | Ölçülebilir etki yok |
| Ai Tweaker → Precision Boost Overdrive | Medium Load Boostit | Auto | Ölçülebilir etki yok |
| Ai Tweaker → DIGI + VRM | CPU Load-line Calibration | Auto | Ölçülebilir etki yok (LLC 6 ile sapma içinde kaldı) |
| Advanced → AMD CBS | SMT Control | Auto | Kapatmanın etkisi yok. Kapatılırsa geri açmak için tam kapat-aç gerekir. |
| Advanced → AMD CBS | Global C-state Control | Auto | Kanıt yok |
| Ai Tweaker | AI Cache Boost | Auto | ASUS'a göre AI araçları için |
| Ai Tweaker | Turbo Game Mode, Gaming Adaptive CCD Parker | Disabled | Çift CCD'li işlemciler için. 9800X3D tek CCD. |
| Ai Tweaker → Precision Boost Overdrive | Thermal Limit | Varsayılan (Level 2, 80 °C) | İşlemci CS2'de en fazla 60 °C |

---

## 7. BIOS: FACEIT ve güvenlik

FACEIT; Secure Boot, TPM 2.0, IOMMU ve Bellek Bütünlüğü'nü (HVCI/VBS) denetler. BIOS güncellemesi bu ayarları varsayılana döndürebilir. Güncellemeden sonra mutlaka kontrol edin.

| Menü | Ayar | Değer |
|---|---|---|
| Boot → Secure Boot | OS Type | Windows UEFI mode |
| Boot → Secure Boot → Key Management | Install Default Secure Boot Keys | Secure Boot "Disabled / anahtar yok" görünüyorsa çalıştırın |
| Boot → CSM | Launch CSM | Disabled |
| Advanced → AMD fTPM configuration | Firmware TPM switch | Enable Firmware TPM |
| Advanced → CPU Configuration | SVM Mode | Enabled (VBS/HVCI için gerekli) |
| Advanced → AMD CBS | IOMMU | Auto |
| Advanced → PCI Subsystem Settings | Above 4G Decoding / Resize BAR | Enabled / Enabled |

---

## 8. Windows ve CS2 ayarları

### Windows

| Ayar | Değer | Not |
|---|---|---|
| Donanım hızlandırmalı GPU zamanlaması (HAGS) | Açık | Ayarlar → Sistem → Ekran → Grafik |
| CS2'yi CPU 0'dan uzak tutmak | Uygulanır | Aşağıda. Ölçülen etki +%1,8 ile +%2,5. |
| İşlem önceliği | Normal | High denendi, etkisi yok |
| Bellek Bütünlüğü (HVCI) | Açık | FACEIT için |
| Oyun Modu | Kapalı | Test edilmedi |

### CS2'yi CPU 0'dan uzak tutmak

Bu adımı her Steam açılışında tekrarlayın.

1. Steam açıkken **Görev Yöneticisi → Ayrıntılar → `steam.exe`** satırına sağ tıklayın.
2. **Benzeşimi ayarla** seçin. **CPU 0** işaretini kaldırın ve **Tamam** deyin.
3. CS2'yi Steam'den başlatın. CS2, bu ayarı Steam'den devralır. `cs2.exe` dosyasına doğrudan dokunmanız gerekmez.

**Kalıcı yol (denenmedi):** Steam'i bu komutla başlatabilirsiniz:

```
cmd /c start "" /affinity FFFE "C:\Program Files (x86)\Steam\steam.exe"
```

FACEIT'in bu yöntem hakkında resmi bir açıklaması bulunamadı.

### CS2 oyun içi ayarları

Bu ayarlar ölçümlerde sabit tutuldu. `cs2_video.txt` dosyasından alındı.

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
| Parçacık ve ortam aydınlatması | Düşük / kapalı |
| FSR | Kapalı |
| NVIDIA Reflex | Kapalı |
| Başlatma seçenekleri | `+exec crosshair.cfg -condebug` |

`-condebug`, VProf sonuçlarının `console.log` dosyasına yazılması için gerekir.

### FACEIT nedeniyle dokunulmayanlar

Bu ayarlara ölçüm sırasında dokunulmadı: Secure Boot, CSM, Firmware TPM, IOMMU, SVM, DMA koruması, Pluton, VBS/HVCI ve Windows Update.

### Fan ve pompa (isteğe bağlı)

Fan ayarları performans ölçümünün parçası değildi.

- **CPU ve kasa fanı:** PWM Mode, Manual eğri. 20/30/40/50/60/67/70/100 °C noktalarında %20/26/34/45/60/80/100/100.
- **AIO pompa:** PWM Mode, Manual eğri. 30/40/50/58/65/70/85/100 °C noktalarında %20/20/36/52/68/84/100/100.
- **Ölçülen pompa devri:** Boşta ~1240 rpm, tam hızda ~2780 rpm.

---

## 9. Benzer sistemlere uyarlama

| Durum | Ne yapılmalı |
|---|---|
| Aynı işlemci ve anakart, farklı RAM | Ayarlı RAM için önce Ai Overclock Tuner = EXPO/XMP deneyin. Bu bölümdeki zamanlamaları yalnız **SK Hynix 24 Gbit M-die, 2 × 24 GB, tek rank** kitte başlangıç noktası olarak kullanın. PBO, Windows ve FACEIT adımları aynen geçerlidir. |
| Başka X3D işlemci | Boost Override üst sınırı işlemciye göre değişir. Çift CCD'li X3D'lerde (9900X3D, 9950X3D) Turbo Game Mode, CCD Parker ve Core Flex X3D preset anlamlı olabilir. Burada test edilmedi. |
| Başka ASUS AM5 anakart | Menü adları büyük ölçüde aynı, NVRAM ofsetleri farklı. Kendi BIOS dosyanızdan ayar sözlüğü çıkarıp `-IfrFile` ile kontrol edin. |
| Başka marka anakart | Menü adları farklı, ayarların anlamı aynı. Kontrol betiği çalışmaz; listeyi elle uygulayın. |
| Her durumda | Tek seferde tek ayar değiştirin. Her değişiklikten sonra ölçün ve WHEA hatası olup olmadığına bakın. |

### Kendi ayar listenizi oluşturmak

1. Ayarlarınızı BIOS'tan elle girin.
2. Ham değerleri görmek için BIOS görüntüsü alın ve döküm üretin:

   ```powershell
   .\nvram\nvram_snap.ps1 -OutDir .\snap_benim
   .\nvram\bios_dump.ps1 -SnapDir .\snap_benim -IfrFile .\sozluk\ifr_all.tsv -OutCsv .\benim.csv -OutMd .\benim.md
   ```

3. `ayarlar/hedef_ayarlar_2503.csv` dosyasının bir kopyasında `Hedef` ve `Hedef_ham` sütunlarını kendi değerlerinizle değiştirin.
4. Kontrolü kendi listenizle çalıştırın:

   ```powershell
   .\kontrol\ayar_kontrol.ps1 -Hedef .\benim_hedeflerim.csv
   ```

---

## 10. Kontrol: her şey yerinde mi?

Yönetici PowerShell'de, depo klasöründe:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\kontrol\ayar_kontrol.ps1          # BIOS + Windows
.\kontrol\ayar_kontrol.ps1 -Fan     # fan ve pompa eğrileri dahil
```

Betik **salt okunurdur**. Hiçbir yere yazmaz.

Betik şunları yapar:
- Canlı BIOS'u (UEFI NVRAM) `ayarlar/hedef_ayarlar_2503.csv` listesiyle karşılaştırır.
- Windows tarafında şunları kontrol eder: SMT, RAM hızı (8000), Secure Boot, TPM, VBS/HVCI, HAGS, `steam.exe` ve `cs2.exe` CPU 0 durumu, WHEA hataları.
- Farklı her ayar için menü yolunu yazar.
- Çıkış kodu, farklı ayar sayısıdır. 0 ise her şey tamamdır.

### Yeni BIOS sürümüne geçtiyseniz

Ayarların NVRAM içindeki yeri değişmiş olabilir. Yeni BIOS dosyasından sözlük çıkarın ve kontrolü onunla yapın:

```powershell
Add-Type -Path .\tools\BiosIfr.cs, .\tools\EfiDec3b.cs
[Prog]::Main(@('C:\indirilenler\BIOS.CAP', '.\yeni_sozluk'))
.\kontrol\ayar_kontrol.ps1 -IfrFile .\yeni_sozluk\ifr_all.tsv
```

AMD Overclocking (PBO ve Curve Optimizer) ayarları sözlükte yoktur. Değişken boyutu değiştiyse betik "DUZEN FARKLI" uyarısı verir. Bu ayarları menüden elle kontrol edin.

Ayrıntılı fark için güncelleme öncesi ve sonrası görüntüleri karşılaştırın:

```powershell
.\nvram\nvram_snap.ps1 -OutDir .\snap_sonra -Label sonra
.\nvram\nvram_diff.ps1 -A .\snap_guncelleme_oncesi -B .\snap_sonra
```

---

## 11. Ölçüm nasıl yapıldı

### Benchmark

- **Harita:** Steam Workshop `3240880604` (de_dust2). Konsoldan `map_workshop 3240880604 de_dust2` komutuyla açılır.
- **Koşu süresi:** Yaklaşık 129 saniye. Sonunda CS2, `console.log` dosyasına VProf özeti yazar.
- **Ayarlar:** Tüm koşularda aynıydı (1280×960, tam ekran, 360 Hz, `fps_max 0`, FACEIT kapalı). HWiNFO yalnız bir testte açıktı.

### Karar kuralı

- **Ayrı oturumlar (BIOS testleri):** Her ayar için 6 kayıt koşusunun medyanı ve aralığı karşılaştırıldı. Aralıklar çakışmıyorsa fark **gerçek** kabul edildi. Fark ~%0,6'dan küçükse oturum sapmasından ayırt edilemez.
- **Aynı oturum (Windows testleri):** Koşullar dönüşümlü sırayla çalıştırıldı. Eşleştirilmiş t testi uygulandı (6 turda |t| > 2,571; 3 turda |t| > 4,30).

### Isınma ve sapma

- Her yeni CS2 oturumunda ortalama FPS ilk ~6 koşuda %1,2–1,3 düşüp sabitleniyor. Bu yüzden her oturumun ilk 6 koşusu **ısınma** sayıldı ve sonuçlara alınmadı.
- Aynı BIOS ayarı iki ayrı oturumda ölçüldüğünde fark %0,55 çıktı.

### VProf çıktısı

```
[VProf] Summary of 122110 frames and 129 1-second intervals.
[VProf] FPS: Avg=943.7, P1=349.1
[VProf]           FrameTotal   1.06   2.86   122110   1.06   2.86     3.18   4.06      129   3.18   4.06
```

P1 ve P99, VProf'un bazı kareleri analizden çıkarmasıyla hesaplanır. PresentMon veya CapFrameX'in %1 low değeriyle aynı değildir.

---

## 12. Araçlar

Tüm betikler **Windows PowerShell 5.1** ile test edildi. Çıktılar Türkçedir. Gerekirse önce `Set-ExecutionPolicy -Scope Process Bypass` komutunu çalıştırın.

### `bench/`: CS2 ölçümü

CS2 `-condebug` ile açık olmalıdır. `console.log` yolu betiklerin başında tanımlıdır. Steam farklı bir klasöredeyse yolu değiştirin.

| Betik | Ne yapar |
|---|---|
| `run_bench.ps1` | Konsolu açar, haritayı yükler, `[VProf] FPS:` satırını bekler, sıradaki koşuya geçer. Plan biçimi: `-Plan ad:maske:koşu[:öncelik];…` (öncelik: N/A/H). `-Warmups` ısınma koşusu sayısıdır. `bench_stop.txt` oluşturulursa durur. Bitince affinity'yi ve önceliği varsayılana döndürür. |
| `vprof_stage.ps1` | Belirli bir zaman aralığındaki koşuları okur: Avg, P1, P99, ortalama kare, WHEA ve Kernel-Power 41 sayısı. |
| `interleave_report.ps1` | Dönüşümlü koşuları eşleştirilmiş t testi ile karşılaştırır. |
| `snap_console.ps1` | `console.log` dosyasını yedekler. CS2 her açılışta bu dosyayı sıfırlar. |
| `cs2_affinity.ps1` | `cs2.exe` affinity değerini okur veya ayarlar (`-Mask 0xFFFE`). Kalıcı değildir. |

```powershell
# CS2 açık, FACEIT kapalı. BIOS değişikliğinden sonra yeni oturumda:
.\bench\run_bench.ps1 -Plan AYAR:0xFFFF:12 -Warmups 6
.\bench\vprof_stage.ps1 -Start '10/19 12:30' -Name AYAR
```

**Notlar:**
- `-Plan` değerini `Start-Process` ile başka bir PowerShell'e geçirirken tek tırnak kullanmayın. Tek tırnak betiğe aynen geçer ve hiç koşu yapılmaz.
- Tarihler `console.log` biçimindedir (`MM/dd HH:mm`). Yıl betiklerde 2026 olarak sabittir.

### `nvram/`: BIOS okuma (yalnız okur)

| Betik | Ne yapar |
|---|---|
| `nvram_snap.ps1` | Tüm NVRAM değişkenlerinin dizinini (ad, GUID, boyut, SHA256) ve ayar değişkenlerinin ham baytını kaydeder. Parola, anahtar, lisans ve TPM içeren değişkenleri kaydetmez. |
| `nvram_diff.ps1` | İki görüntüyü karşılaştırır. `-Decoded` ve `-IfrFile` ile ayar adlarını da gösterir. |
| `bios_dump.ps1` | Görüntüyü ayar sözlüğüyle birleştirir ve okunur döküm (CSV ve Markdown) üretir. |

### `kontrol/`: ayar kontrolü

`ayar_kontrol.ps1`: [bölüm 10](#10-kontrol-her-şey-yerinde-mi).

### `hwinfo/`: sensör kaydı

HWiNFO'nun paylaşılan belleğinden sensör değerlerini okur. HWiNFO'da **Shared Memory Support** açık olmalıdır.

| Betik | Ne yapar |
|---|---|
| `hw_sample.ps1` | Tüm sensörleri 1 saniye aralıkla CSV'ye yazar. |
| `hw_report.ps1` | CSV'den özet çıkarır. |
| `hwinfo_sm_read.ps1` | Anlık değerleri listeler. |

### `tools/`: BIOS ayar sözlüğü

```powershell
Add-Type -Path .\tools\BiosIfr.cs, .\tools\EfiDec3b.cs
[Prog]::Main(@('C:\yol\BIOS.CAP', '.\sozluk'))     # sozluk\ifr_all.tsv üretir
```

AMI Aptio BIOS kapsülünü (`.CAP`) açar. BIOS 2503 için 9304 ayar çıkarır (408'i gizli). Sözlük, üreticinin telifli BIOS dosyasından çıkarıldığı için depoda yoktur. Kendi BIOS dosyanızdan üretin.

---

## 13. Sorun giderme

| Belirti | Çözüm |
|---|---|
| RAM ayarından sonra açılmıyor veya eğitim bitmiyor | Bekleyin. Açılmazsa **Clear CMOS** yapın ve ayarları yeniden girin. Hâlâ açılmıyorsa bir kademe gevşetin (ör. Trcd/Trp +2, Trfc1 +32). Bu gevşek değerler denenmedi. |
| Rastgele çökme veya WHEA hatası | Önce RAM sıcaklığına bakın (tREFI 65535 sıcaklığa duyarlıdır). Sonra FCLK'yi kontrol edin. Gerekirse RAM'i EXPO/XMP'ye alın. |
| FACEIT Secure Boot, TPM veya VBS hatası | [Bölüm 7](#7-bios-faceit-ve-güvenlik) ayarlarını kontrol edin. Windows Güvenliği → Cihaz güvenliği → Çekirdek yalıtımı → Bellek bütünlüğü açık olmalı. |
| Windows 8 mantıksal işlemci gösteriyor | SMT kapalı kalmış. Advanced → AMD CBS → SMT Control = Auto yapın ve tam kapat-aç yapın. |
| BIOS güncellemesinden sonra BitLocker anahtarı istiyor | fTPM sıfırlanmış. Kurtarma anahtarını girin, sonra fTPM'in açık olduğunu kontrol edin. |
| Steam yeniden başlatıldıktan sonra CPU 0 ayarı gitti | [Bölüm 8](#cs2yi-cpu-0dan-uzak-tutmak) adımını tekrarlayın. |

---

## 14. Sınırlamalar ve test edilmeyenler

**Sınırlamalar:**
- **Tek sistem:** Tek işlemci, tek RAM kiti, tek anakart. Sonuçlar başka sistemlere doğrudan taşınmaz.
- **Oturum sapması:** Oturumlar arası sapma ±%0,6. Bundan küçük farklar ayırt edilemez.
- **BIOS karşılaştırmaları:** BIOS güncellemesi RAM ayarıyla aynı anda yapıldı. Bu yüzden FPS farkı yalnız RAM'e atfedilemez.
- **Gecikme ölçülmedi:** LDAT veya Reflex Analyzer kullanılmadı. Değerlendirme kare sürelerine dayanır.
- **Benchmark ve maç farkı:** Benchmark haritasında bot var, sunucu yükü yok. Maçta ortalama FPS benchmarktan yaklaşık %27 düşük ölçüldü. Bu yüzden benchmark sonuçları maç performansının doğrudan karşılığı değildir.

**Test edilmeyenler:**

| Konu | Neden |
|---|---|
| Secure Boot, TPM, IOMMU, HVCI, SVM, CSM | FACEIT denetliyor; dokunulmadı |
| DDR5-6000 1:1 | Bu kurulumda tercih edilmedi |
| iGPU kapatma | Bu kurulumda tercih edilmedi |
| CS2 grafik ayarları (MSAA, Reflex vb.) | Etkisi ölçülmedi |
| BCLK | PCIe saatini de değiştirir; önerilmez |
| Thermal Limit, PBO limitleri, daha derin CO | İşlemci saat tavanında ve güç sınırından uzakta; kazanç beklenmiyor |
| Turbo Game Mode, Gaming Adaptive CCD Parker | Çift CCD'li işlemciler için; 9800X3D tek CCD |
| Process Lasso, PBO2 Tuner gibi çekirdek sürücüsü yükleyen araçlar | Kullanılmadı |

**Sıradaki adaylar (ölçülmedi):**
1. **FCLK 2100 / 2167 / 2200:** Tahmini etki %0–2. Kararsızlık WHEA 19 olarak görünür.
2. **NVIDIA Low Latency Mode (On veya Ultra), yalnız `cs2.exe` profilinde:** GPU yükü p95 %96 olduğu için etkisi olabilir.
3. **tRDRDSCL ve tWRWRSCL 8 → 6, tRDWR 20 → 18:** Düşük riskli ikincil zamanlamalar. Tahmini etki %0–1,5.

---

## 15. Depo yapısı

| Klasör veya dosya | İçerik |
|---|---|
| `README.md` | Bu rehber |
| `ayarlar/hedef_ayarlar_2503.csv` | 125 hedef ayar: menü yolu, değer, NVRAM konumu, beklenen ham değer, ölçülen etki |
| `kontrol/ayar_kontrol.ps1` | Canlı BIOS'u ve Windows durumunu hedef listeyle karşılaştırır (salt okunur) |
| `bench/` | CS2 benchmark otomasyonu ve analiz betikleri |
| `nvram/` | BIOS okuma, görüntü alma, karşılaştırma ve döküm betikleri |
| `hwinfo/` | HWiNFO sensör kaydı betikleri |
| `tools/` | BIOS ayar sözlüğü çıkarma (`BiosIfr.cs`) ve EFI açıcı (`EfiDec3b.cs`) |
| `data/kosular.csv` | Tüm benchmark koşuları ve maçlar (134 satır). Sütun açıklamaları aşağıda. |
| `data/ozet.csv` | Test ve koşul başına medyan, en düşük ve en yüksek değerler |
| `data/testler.csv` | Her testin BIOS durumu, değişen ayar, affinity, öncelik ve sonucu |
| `data/bios_son_durum.csv` | Son BIOS durumunun tam dökümü (ham baytlar ayar sözlüğüyle çözüldü) |
| `data/bios_aod_alanlari.csv` | AMD Overclocking değişkeninin 226 alanı (PBO, CO vb.) |

**`kosular.csv` sütunları:**

| Sütun | Anlamı |
|---|---|
| `Oturum` | CS2 oturumu (ör. O0 = Aşama 0, O3 = PBO200_MB, O9 = öncelik ve CPU 0 testi) |
| `Tip` | `isinma` (karşılaştırmaya girmez), `kayit`, `olcum-disi`, `mac` |
| `Avg_FPS`, `P1_FPS` | Ortalama FPS ve %1 düşük FPS |
| `P99_ms` | Karelerin %99'unun altında kaldığı süre |
| `Ort_kare_ms` | Ortalama kare süresi |
| `Maks1s_P50_ms`, `Maks1s_P95_ms` | Her saniyedeki en uzun karenin medyanı ve 95. yüzdeliği (takılma göstergesi) |
| `Not` | Özel durumlar |

**Ölçülen sonuçların özeti (sayılar):** 132 benchmark koşusu (86 kayıt, 44 ısınma, 2 ölçüm dışı), 2 maç, 13 CS2 oturumu, 13 NVRAM görüntüsü. WHEA hatası ve Kernel-Power 41 olayı hiçbir açılışta görülmedi.

---

**Lisans:** Bu depoda lisans tanımlanmamıştır.
