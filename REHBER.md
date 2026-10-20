# Rehber: Ryzen 7 9800X3D + ROG STRIX X870-A + DDR5-8000 için CS2 ayarları

Bu rehber iki iş için yazıldı:

1. **Benzer sistemi olanlar için:** Hangi ayarın ne kazandırdığı ölçüldü. Ölçülmüş ve işe yarayan ayarlar, adım adım ve menü yoluyla birlikte aşağıda.
2. **BIOS güncellemesi veya CMOS sıfırlamasından sonra:** BIOS varsayılanlara döner. Bu liste ile ayarlar sırayla geri girilir, `kontrol/ayar_kontrol.ps1` ile her şeyin yerinde olduğu doğrulanır.

Ölçüm sonuçlarının ayrıntısı: [docs/SONUCLAR.md](docs/SONUCLAR.md). English version: [GUIDE_EN.md](GUIDE_EN.md).

> **Uyarı:** RAM hız aşırtması, voltaj artışı ve PBO garanti kapsamını etkileyebilir; sistem kararsızlığına ve veri kaybına yol açabilir. Her şey kendi sorumluluğundadır. Değerler tek bir sistemde denendi (bkz. [RAM uyumluluğu](docs/RAM_AYARLARI.md#7-hangi-belleklerde-uyumlu)).

## Sistem

| | |
|---|---|
| İşlemci | AMD Ryzen 7 9800X3D |
| Anakart / BIOS | ASUS ROG STRIX X870-A GAMING WIFI / 2503 |
| RAM | G.Skill F5-8000J4048F24GX2-TZ5RK, 2 × 24 GB, SK Hynix M-die, tek rank, A2 + B2 yuvaları |
| Ekran kartı | RTX 5070 Ti |
| İşletim sistemi / oyun | Windows 11 Pro, CS2 (FACEIT) |

## Ne kazandırıyor (kısaca)

| Adım | Etki (ortalama FPS) |
|---|---|
| RAM 8000 ayarı | Ortalama değişmedi; %1 düşük +%4,3, P99 −%4,0 |
| PBO + Boost Override +200 | **+%3,5** |
| CS2'yi CPU 0'dan uzak tutmak (Windows) | **+%1,8 ile +%2,5** |
| DDR5 Nitro Mode 1-3-1 | **−%1,4**, bu yüzden Auto kalmalı |
| Toplam | 911 → 970 FPS (**+%6,4**) |

## 0. Başlamadan önce

**BIOS güncellemesinden ÖNCE:**

1. Mevcut ayarları kaydet:
   - **Tool → ASUS User Profile → Save to Profile** ile bir yuvaya kaydet.
   - **Load/Save Profile from/to USB Drive** ile USB'ye de kaydet.
   - Not: Profil dosyaları genellikle başka bir BIOS sürümünde yüklenemez. Bu rehber bunun için var.
2. İsteğe bağlı: Yönetici PowerShell'de BIOS'un tam görüntüsünü al:

   ```powershell
   .\nvram\nvram_snap.ps1 -OutDir .\snap_guncelleme_oncesi -Label "guncelleme oncesi"
   ```

3. BitLocker kullanıyorsan kurtarma anahtarını hazır tut. BIOS güncellemesi fTPM'i sıfırlarsa Windows kurtarma anahtarı isteyebilir.

**BIOS güncellemesinden veya CMOS sıfırlamasından SONRA:**

- Aşağıdaki adımları sırayla uygula: önce RAM, sonra işlemci, sonra güvenlik kontrolü.
- Her büyük adımdan sonra kaydet ve aç (F10).
- En sonda Windows'ta `kontrol/ayar_kontrol.ps1` çalıştır (bölüm 4).

## 1. BIOS: RAM (önce bu)

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
| Memory Context Restore | Enabled (her açılışta bellek eğitimi tekrarlanmaz, açılış hızlanır) |
| Power Down Enable | Disabled |
| Gear Down Mode | Enabled |
| Bank Refresh Mode | Mixed(REFab/REFsb) Mode |
| UCLK DIV1 MODE | Auto (8000 MT/s'de otomatik olarak UCLK = MEMCLK/2) |
| DDR5 Nitro Mode | Auto (**açma**, ölçülen −%1,4) |
| Diğer her şey (RTT/ODT, sürücü dirençleri, VDDIO, SOC) | Auto |

**Kaydet ve aç.** İlk açılışta bellek eğitimi birkaç dakika sürebilir; ekran gelmeden kapatma.

Bu kitin sınırları:
- **Twr:** BIOS 8000 MT/s'de 48'in altını kabul etmiyor.
- **TwtrL:** 14 ile açılmıyor.
- **Trcd ve Trp:** 44 ile açılmıyor.

Bu durumda Auto bırakılan voltajlar ölçüldüğünde:
- SOC 1,29 V
- VDDIO 1,46 V
- VDD_MISC 1,10 V
- PMIC VDD/VDDQ 1,60 V

Windows'ta kontrol: Görev Yöneticisi → Performans → Bellek → Hız **8000 MT/s**. Olay Görüntüleyicisi'nde WHEA hatası olmamalı.

## 2. BIOS: İşlemci

**Advanced → AMD Overclocking → Precision Boost Overdrive** (menüye girerken çıkan uyarıyı kabul et)

| Ayar | Değer |
|---|---|
| Precision Boost Overdrive | Advanced |
| PBO Limits | Motherboard |
| CPU Boost Clock Override | Enabled (Positive) |
| Max CPU Boost Clock Override(+) | 200 (9800X3D için üst sınır; saat tavanı 5,2 → 5,425 GHz) |

**… → Precision Boost Overdrive → Curve Optimizer**

| Ayar | Değer |
|---|---|
| Curve Optimizer | All Cores |
| All Core Curve Optimizer Sign | Negative |
| All Core Curve Optimizer Magnitude | 10 (ölçülebilir etkisi yok, zararsız; istersen Auto bırak) |

**Ai Tweaker**

| Ayar | Değer |
|---|---|
| Core tunings Configuration for gaming | Level 2 (etkisi doğrulanmadı, zararsız; istersen Auto bırak) |

Notlar:
- **Menü yolu kaynağı:** AMD Overclocking menüsü BIOS'tan çıkarılan sözlükte yer almıyor. Yol, ayar sırasında alınan ekran görüntülerine ve NVRAM farkına göre yazıldı.
- **İki yere farklı değer yazma:** Aynı PBO / Boost Override / Curve Optimizer ayarları **Ai Tweaker → Precision Boost Overdrive** altında da var. Bu kurulumda onlar **Auto** bırakıldı.
- **İsteğe bağlı aynı değerler:** AMD Overclocking'in DDR / Infinity Fabric bölümünde de FCLK 2000, UCLK DIV1 MODE = UCLK=MEMCLK/2 ve Power Down Disabled yazılıydı. Bunlar Ai Tweaker'daki değerlerle aynı; Auto da bırakılabilir.

## 3. BIOS: Auto kalması gerekenler (denendi, fayda yok ya da zararlı)

| Menü | Ayar | Değer | Neden |
|---|---|---|---|
| AMD Overclocking (DDR) / DRAM Timing Control | DDR5 Nitro Mode | Auto | 1-3-1 Avg'yi %1,4 düşürdü |
| Advanced → AMD CBS → CPU Common Options | Latency Under Load (LUL) | Auto | Ölçülebilir etki yok |
| Ai Tweaker → Precision Boost Overdrive | Medium Load Boostit | Auto | Ölçülebilir etki yok |
| Ai Tweaker → DIGI + VRM | CPU Load-line Calibration | Auto | Ölçülebilir etki yok |
| Advanced → AMD CBS | SMT Control | Auto | Kapatmanın etkisi yok. Kapatıldıysa geri açmak için tam kapat-aç (power cycle) gerekir. |
| Advanced → AMD CBS | Global C-state Control | Auto | Kanıt yok |
| Ai Tweaker | AI Cache Boost | Auto | ASUS'a göre AI araçları için |
| Ai Tweaker | Turbo Game Mode / Gaming Adaptive CCD Parker | Disabled | Çift CCD'li işlemciler için; 9800X3D tek CCD |
| Ai Tweaker → Precision Boost Overdrive | Thermal Limit | Level 2 (80 °C), varsayılan | İşlemci CS2'de en fazla 60 °C |

## 4. BIOS: FACEIT ve güvenlik (güncellemeden sonra mutlaka kontrol et)

FACEIT; Secure Boot, TPM 2.0, IOMMU ve Bellek Bütünlüğü'nü (HVCI/VBS) denetliyor. BIOS güncellemesi bunları varsayılana döndürebilir.

| Menü | Ayar | Değer |
|---|---|---|
| Boot → Secure Boot | OS Type | Windows UEFI mode |
| Boot → Secure Boot → Key Management | Install Default Secure Boot Keys | Secure Boot "Disabled / anahtar yok" görünüyorsa çalıştır |
| Boot → CSM (Compatibility Support Module) | Launch CSM | Disabled |
| Advanced → AMD fTPM configuration | Firmware TPM switch | Enable Firmware TPM |
| Advanced → CPU Configuration | SVM Mode | Enabled (VBS/HVCI için gerekli) |
| Advanced → AMD CBS | IOMMU | Auto |
| Advanced → PCI Subsystem Settings | Above 4G Decoding / Resize BAR Support | Enabled / Enabled |
| Advanced → NB Configuration | Integrated Graphics | Auto (bu kurulumda iGPU açık) |

## 5. BIOS: Kişisel / isteğe bağlı

| Menü | Ayar | Değer |
|---|---|---|
| Tool → Auto Install ASUS Utilities | Download and Install ASUS DriverHub | Disabled |

**Monitor → Q-Fan Configuration** (Arctic Liquid Freezer III Pro 360). Tüm kanallarda Q-Fan Control = PWM Mode, Profile = Manual, kaynak CPU.

| Nokta | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| CPU Fan ve Chassis Fan 1: sıcaklık °C | 20 | 30 | 40 | 50 | 60 | 67 | 70 | 100 |
| CPU Fan ve Chassis Fan 1: duty % | 20 | 26 | 34 | 45 | 60 | 80 | 100 | 100 |
| AIO Pump: sıcaklık °C | 30 | 40 | 50 | 58 | 65 | 70 | 85 | 100 |
| AIO Pump: duty % | 20 | 20 | 36 | 52 | 68 | 84 | 100 | 100 |

Diğer fan ayarları:
- **Speed Low Limit:** CPU ve kasa fanı 200 RPM, pompa Ignore.
- **Step Up / Step Down:** Level 0.
- **Pompa devri:** Boşta ~1240 rpm, Full Speed'de ~2780 rpm.

**Son adım:**
- **Tool → ASUS User Profile → Save to Profile** ile kaydet, USB'ye de kaydet.
- F10 ile kaydedip çık.
- İpucu: BIOS'ta F12 ekran görüntüsünü USB'ye kaydeder.

## 6. Windows

| Ayar | Değer | Not |
|---|---|---|
| Donanım hızlandırmalı GPU zamanlaması (HAGS) | Açık | Ayarlar → Sistem → Ekran → Grafik → Varsayılan grafik ayarları |
| CS2'yi CPU 0'dan uzak tutmak | Uygulanıyor | Aşağıda; ölçülen +%1,8–2,5 |
| İşlem önceliği | Normal | High denendi, fayda yok |
| Bellek Bütünlüğü (HVCI) | Açık | FACEIT için |
| Oyun Modu | Kapalı | Test edilmedi |
| NVIDIA sürücüsü | 617.42 | Ölçümlerdeki sürüm |

**CS2'yi CPU 0'dan uzak tutmak** (her Steam açılışında):

1. Steam açıkken Görev Yöneticisi → Ayrıntılar → `steam.exe` → sağ tık → **Benzeşimi ayarla** → **CPU 0'ın işaretini kaldır** → Tamam.
2. CS2'yi Steam'den başlat. CS2 bu ayarı Steam'den devralır; `cs2.exe`'ye dokunulmaz.

İsteğe bağlı, kalıcı yol (bu projede **denenmedi**, aynı mekanizma): Steam'i bir kısayolla CPU 0 hariç başlatmak.

```
cmd /c start "" /affinity FFFE "C:\Program Files (x86)\Steam\steam.exe"
```

FACEIT'in bu yöntemler hakkında resmi bir açıklaması bulunamadı.

**CS2 oyun içi ayarları** (değiştirilmedi, ölçümlerde hep aynı):
- Görüntü: 1280×960 (4:3) tam ekran, 360 Hz, V-Sync kapalı, `fps_max 0`.
- Kalite: MSAA 2x, anizotropik 16x, gölge/doku/parçacık/gölgelendirici düşük, dinamik gölgeler Tümü, ortam aydınlatması ve FSR kapalı.
- NVIDIA Reflex kapalı.
- Tam liste: [docs/SISTEM_VE_OYUN.md](docs/SISTEM_VE_OYUN.md).

## 7. Kontrol: her şey yerinde mi?

Yönetici PowerShell'de, depo klasöründe:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\kontrol\ayar_kontrol.ps1          # BIOS + Windows
.\kontrol\ayar_kontrol.ps1 -Fan     # fan/pompa eğrileri dahil
```

Betik salt okunurdur; hiçbir yere yazmaz. Ne yaptığı:
- Canlı BIOS'u (UEFI NVRAM) `ayarlar/hedef_ayarlar_2503.csv` listesiyle karşılaştırır.
- Windows'ta şunları kontrol eder:
  - SMT (16 mantıksal işlemci)
  - RAM hızı (8000)
  - Secure Boot
  - TPM
  - VBS/HVCI
  - HAGS
  - `steam.exe` / `cs2.exe` CPU 0 durumu
  - WHEA hataları
- Farklı olan her ayar için menü yolunu yazar.
- Çıkış kodu farklı ayar sayısıdır (0 = hepsi tamam).

**Yeni BIOS sürümüne geçtiysen** ayarların NVRAM'deki yeri değişmiş olabilir. Ayar sözlüğünü yeni BIOS dosyasından çıkar, kontrolü onunla yap:

```powershell
# ASUS'tan indirdiğin BIOS dosyası (.CAP)
Add-Type -Path .\tools\BiosIfr.cs, .\tools\EfiDec3b.cs
[Prog]::Main(@('C:\indirilenler\BIOS.CAP', '.\yeni_sozluk'))     # ~1 sn, yeni_sozluk\ifr_all.tsv
.\kontrol\ayar_kontrol.ps1 -IfrFile .\yeni_sozluk\ifr_all.tsv
```

Bu durumda ayarlar adlarıyla bulunur. AMD Overclocking (PBO/CO) ayarları sözlükte olmadığı için, değişken boyutu değiştiyse "DUZEN FARKLI" çıkar; onları menüden elle kontrol et.

Ayrıntılı karşılaştırma için güncelleme öncesi ve sonrası iki görüntü al:

```powershell
.\nvram\nvram_snap.ps1 -OutDir .\snap_sonra -Label sonra
.\nvram\nvram_diff.ps1 -A .\snap_guncelleme_oncesi -B .\snap_sonra
```

## 8. Benzer sistemlere uyarlama

| Durum | Ne yapmalı |
|---|---|
| Aynı işlemci ve anakart, farklı RAM | RAM için önce Ai Overclock Tuner = EXPO/XMP. Buradaki zamanlamaları yalnız SK Hynix 24 Gbit M-die, 2 × 24 GB tek rank kitte başlangıç noktası olarak kullan ([uyumluluk tablosu](docs/RAM_AYARLARI.md#7-hangi-belleklerde-uyumlu)). PBO, Windows ve FACEIT adımları aynen geçerli. |
| Başka X3D işlemci | Boost Override üst sınırı işlemciye göre değişir (9800X3D'de 200 MHz). Çift CCD'li X3D'lerde (9900X3D/9950X3D) Turbo Game Mode, CCD Parker ve Core Flex X3D preset anlamlı olabilir; burada test edilmedi. |
| Başka ASUS AM5 anakart | Menü adları büyük ölçüde aynı, NVRAM ofsetleri farklı. Kontrol için kendi BIOS dosyandan sözlük çıkar (`-IfrFile`). |
| Başka marka anakart | Menü adları farklı, ayarların anlamı aynı. Kontrol betiği çalışmaz; listeyi elle uygula. |
| Her durumda | Tek seferde tek ayar değiştir. Ölç (`bench/`), WHEA hatası olup olmadığına bak. |

## 9. Sorun giderme

| Belirti | Çözüm |
|---|---|
| RAM ayarından sonra açılmıyor / bellek eğitimi bitmiyor | Bekle (ilk eğitim uzun sürebilir). Olmazsa Clear CMOS, sonra ayarları tekrar gir. Yine olmazsa bir kademe gevşet (ör. Trcd/Trp +2, Trfc1 +32); bu gevşek değerler burada denenmedi. |
| Rastgele çökme / WHEA hatası | Önce RAM (tREFI 65535 sıcaklığa duyarlı; RAM sıcaklığına bak), sonra FCLK. Gerekirse RAM'i EXPO/XMP'ye al. |
| FACEIT Secure Boot / TPM / VBS hatası | Bölüm 4'teki BIOS ayarlarını kontrol et. Windows Güvenliği → Cihaz güvenliği → Çekirdek yalıtımı → Bellek bütünlüğü açık olmalı. |
| Windows'ta 8 mantıksal işlemci görünüyor | SMT kapalı kalmış: Advanced → AMD CBS → SMT Control = Auto, sonra tam kapat-aç. |
| BIOS güncellemesinden sonra BitLocker anahtarı istiyor | fTPM sıfırlanmış. Kurtarma anahtarını gir; sonra fTPM'in açık olduğunu kontrol et. |
