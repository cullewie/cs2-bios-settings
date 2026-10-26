# BIOS ayarları

Anakart: ASUS ROG STRIX X870-A GAMING WIFI, BIOS 2503. Ayarları bu sırayla uygulayın: RAM, işlemci, Auto kalacak ayarlar, FACEIT ve güvenlik.

> [!WARNING]
> RAM hız aşırtması, voltaj artışı ve PBO garanti kapsamını etkileyebilir. Sistem kararsız çalışabilir ve veri kaybı olabilir. Tüm sorumluluk size aittir.

## Başlamadan önce

### BIOS güncellemesinden önce

1. Mevcut ayarları profile kaydedin.
   - **Tool → ASUS User Profile → Save to Profile** seçin ve bir yuva seçin.
   - **Load/Save Profile from/to USB Drive** seçeneğiyle profili USB belleğe de kaydedin.
   - Profil dosyaları genellikle başka bir BIOS sürümüne yüklenemez. Bu rehberdeki adımları da yedek olarak saklayın.
2. İsteğe bağlı: Yönetici PowerShell ile BIOS görüntüsü alın.

   ```powershell
   .\scripts\bios\Save-NvramSnapshot.ps1 -OutDir .\snap_guncelleme_oncesi -Label "guncelleme oncesi"
   ```

3. BitLocker kullanıyorsanız kurtarma anahtarını hazır tutun. BIOS güncellemesi fTPM'i sıfırlarsa Windows kurtarma anahtarı ister.

### BIOS güncellemesinden veya CMOS sıfırlamasından sonra

- Adımları sırayla uygulayın: önce RAM, sonra işlemci, sonra güvenlik.
- Her büyük adımdan sonra kaydedin ve yeniden başlatın (**F10**).
- Son olarak kontrol betiğini çalıştırın ([Kontrol](verification.md)).

## RAM

Bu bölümü ilk olarak uygulayın.

**Ai Tweaker**

| Ayar | Değer |
|---|---|
| Ai Overclock Tuner | Manual |
| Memory Frequency | DDR5-8000 |
| FCLK Frequency | 2200 MHz. AMD Overclocking menüsündeki değer de 2200 olmalıdır (aşağıdaki nota bakın). |
| High DRAM Voltage Mode | Enabled. 1,435 V üstü DRAM voltajı için gerekir. |
| DRAM VDD Voltage | 1.600 |
| DRAM VDDQ Voltage | 1.600 |

> [!IMPORTANT]
> **FCLK iki menüde ayarlanır:**
> 1. **Ai Tweaker → FCLK Frequency**
> 2. **Advanced → AMD Overclocking → DDR and Infinity Fabric Frequency/Timings → Infinity Fabric Frequency and Dividers → Infinity Fabric Frequency**
>
> İkinci değer sabit bir sayıdaysa Ai Tweaker değeri uygulanmaz. Bu sistemde ikinci değer, AMD Overclocking menüsünde PBO ayarlanırken 2000'e sabitlendi. Ai Tweaker 2200 olduğu halde gerçek FCLK 2000 kaldı. İki değeri aynı yapın. Gerçek değeri HWiNFO'da **Infinity Fabric Clock (FCLK)** satırında kontrol edin.

FCLK 2000'den 2200'e çıkınca ortalama FPS +%0,23 arttı (aynı gün, aynı diğer ayarlar, 6 koşu). Bu fark oturum sapmasının içindedir. P1, CPU Busy ve GPU Busy değişmedi. WHEA hatası olmadı.

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
| DDR5 Nitro Mode | Auto. **Enabled yapmayın.** 1-3-1 ayarı ortalama FPS'i %1,4 düşürdü. |
| Diğer tüm ayarlar (RTT/ODT, sürücü dirençleri, VDDIO, SOC) | Auto |

**Kaydedin ve yeniden başlatın.** İlk açılışta bellek eğitimi birkaç dakika sürebilir. Ekran görünmeden bilgisayarı kapatmayın.

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

**Windows'ta kontrol:** Görev Yöneticisi → Performans → Bellek bölümünde hız **8000 MT/s** olmalıdır. HWiNFO'da FCLK **2200 MHz**, UCLK **2000 MHz** olmalıdır. Olay Görüntüleyicisi'nde WHEA hatası olmamalıdır.

## İşlemci

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

## Auto olarak kalacak ayarlar

Bu ayarlar denendi. Fayda sağlamadılar veya zarar verdiler. Auto olarak bırakın.

| Menü | Ayar | Değer | Neden |
|---|---|---|---|
| AMD Overclocking / DRAM Timing Control | DDR5 Nitro Mode | Auto | 1-3-1 ayarı ortalama FPS'i %1,4 düşürdü |
| Advanced → AMD CBS → CPU Common Options | Latency Under Load | Auto | Ölçülebilir etki yok |
| Ai Tweaker → Precision Boost Overdrive | Medium Load Boostit | Auto | Ölçülebilir etki yok |
| Ai Tweaker → DIGI + VRM | CPU Load-line Calibration | Auto | Ölçülebilir etki yok. LLC 6 ile sapma içinde kaldı. |
| Advanced → AMD CBS | SMT Control | Auto | Kapatmanın etkisi yok. Kapatılırsa tam kapatma ve açma gerekir. |
| Advanced → AMD CBS | Global C-state Control | Auto veya Enabled | Enabled, aşağıdaki iki ayarla birlikte ölçüldü: etki yok. Bu sistemde Enabled. |
| Advanced → AMD CBS → CPU Common Options | Power Supply Idle Control | Auto veya Typical Current Idle | Aynı ölçüm: etki yok. Bu sistemde Typical Current Idle. |
| Advanced → NB Configuration | Integrated Graphics | Auto veya Disabled | Aynı ölçüm: etki yok. Bu sistemde Disabled. |
| Ai Tweaker | AI Cache Boost | Auto | ASUS'a göre yapay zekâ araçları içindir |
| Ai Tweaker | Turbo Game Mode, Gaming Adaptive CCD Parker | Disabled | Çift CCD'li işlemciler içindir. 9800X3D tek CCD'lidir. |
| Ai Tweaker → Precision Boost Overdrive | Thermal Limit | Varsayılan (Level 2, 80 °C) | İşlemci CS2'de en fazla 60 °C olur. |

## FACEIT ve güvenlik

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

**Sonraki adım:** [Windows ve CS2 ayarları](windows.md) · [Belgeler dizini](README.md)
