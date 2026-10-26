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

### DDR5-6000 1:1 alternatifi

8000 MT/s (Gear 2) yerine DDR5-6000, UCLK = MEMCLK (1:1) ölçüldü. Ortalama FPS farkı ölçüm sapmasının içindedir. İkisini de kullanabilirsiniz. 6000, daha düşük DRAM voltajıyla çalışır.

| Ayar | UCLK | Ortalama FPS (8000'e göre) | P1 ve P99 | Karar |
|---|---|---|---|---|
| DDR5-8000 CL34, Gear 2 | 2000 MHz | — | — | Kullanın |
| DDR5-6000 CL28, 1:1 | 3000 MHz | +%0,2 ile +%0,4 (sapma içinde) | Aynı | Kullanılabilir |
| DDR5-6200 CL28, 1:1 | 3100 MHz | 6000 ile aynı | Aynı | Kazanç yok |
| DDR5-6400 CL28, 1:1 | 3200 MHz | Ölçülmedi | — | Kullanmayın: iki açılışta iki mavi ekran (`0xA`) |

**6000 ayarları:** Ai Tweaker → Memory Frequency: DDR5-6000. DRAM Timing Control: Tcl 28, Trcd Rd 35, Trcd Wr 36, Trp 35, Tras 49, Trc 84, Trfc1 510, Trfc2 ve Trfcsb Auto, TrrdL 12, Tfaw 32, TrdrdScl 4, TwrwrScl 4, Twrrd 2, Trdwr 16. Diğer zamanlamalar yukarıdaki tabloyla aynıdır. DRAM VDD 1.450, DRAM VDDQ 1.350. FCLK 2200.

> [!IMPORTANT]
> **UCLK DIV1 MODE da iki menüde ayarlanır** (FCLK gibi):
> 1. **Ai Tweaker → UCLK DIV1 MODE**
> 2. **Advanced → AMD Overclocking → DDR and Infinity Fabric Frequency/Timings → Infinity Fabric Frequency and Dividers → UCLK DIV1 MODE**
>
> İkinci değer sabitse Ai Tweaker değeri uygulanmaz. Bu sistemde ikinci değer UCLK=MEMCLK/2 olarak kalmıştı ve 6000'de UCLK 1500 MHz oldu. 1:1 için ikisini de **UCLK=MEMCLK** yapın. 8000'e dönerken ikinci değeri **UCLK=MEMCLK/2** yapın. HWiNFO'da **Memory Controller Clock (UCLK)** değerini kontrol edin.

**Ölçüm (26.10):** Gölge Yüksek, ekran kartı +425, CPU 0 hariç. Her ayar ayrı bir CS2 oturumunda 2 ısınma ve 3 kayıt koşusuyla ölçüldü. 6000 ve 8000 ikişer kez ölçüldü (A-B-A).

| Oturum | Ortalama FPS (3 kayıt koşusu) | P1 |
|---|---|---|
| 8000 Gear 2 (gece) | 934,8 | 331,5 |
| 6000 1:1 | 948,1 | 347,6 |
| 6200 1:1 | 946,6 | 350,1 |
| 6000 1:1 (tekrar) | 948,7 | 350,0 |
| 8000 Gear 2 (tekrar) | 946,2 | 354,0 |

- İlk 8000 oturumu, aynı BIOS ayarlarının tekrar ölçümünden %1,2 düşük çıktı. Bu nedenle ilk karşılaştırmada görülen +%1,5 fark, ayarın değil oturumun etkisidir.
- Aynı öğleden sonra ölçülen 6000 ile 8000 arasındaki fark %0,2 ile %0,4'tür. Beş koşu sırasının beşinde de 6000 öndedir. Ama aynı gün, aynı ayarın iki oturumu arasında %0,05 ile %1,2 fark görüldü. Bu nedenle bu fark kesin değildir.
- P1, P99 ve ortalama kare süresi değişmedi.

**Kararlılık:** 6000 ve 6200, OCCT Memory testini (yaklaşık 16 dakika) hatasız geçti. WHEA hatası olmadı. 6400 aynı zamanlamalarla iki açılışta da mavi ekran verdi (`0xA`, açılıştan 20 saniye ve 13 dakika sonra). Aynı döngü sayısı 6400'de nanosaniye olarak daha sıkıdır (örneğin CL28 = 8,75 ns). 6400 için gevşek zamanlamalar veya yüksek SOC voltajı denenmedi.

### BCLK

Bu anakartta BCLK, işlemci saatiyle birlikte PCIe saatini de değiştirir. Ayrı bir saat üreteci yoktur.

| BCLK | Sonuç |
|---|---|
| 101 MHz | Ortalama FPS +%0,4. A-B-A ile doğrulandı: aynı ayarın iki oturumu arasındaki fark %0,03'tür. P1 ve P99 değişmedi. Saat tavanı 5479 MHz, FCLK 2222 MHz, MCLK 3030 MHz oldu. OCCT CPU + RAM 18 dakika hatasız. |
| 102 MHz | Açılmadı. BIOS varsayılan ayarlara döndü. |

**Karar:** 100 MHz bırakın. Kazanç küçüktür ve P1 değişmez. 101 MHz, PCIe 5.0 ekran kartını ve NVMe diski spesifikasyon dışında çalıştırır.

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
