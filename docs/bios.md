# BIOS ayarları

Anakart: ASUS ROG STRIX X870-A GAMING WIFI, BIOS 2503. Ayarları bu sırayla uygulayın: RAM, işlemci, Auto kalacak ayarlar, FACEIT ve güvenlik.

> [!WARNING]
> RAM hız aşırtması, voltaj artışı ve PBO garanti kapsamını etkileyebilir. Sistem kararsız çalışabilir ve veri kaybı olabilir. Tüm sorumluluk size aittir. Bu depoda uzun bellek testi ve çekirdek bazında CPU kararlılık testi sonucu yoktur.

## Başlamadan önce

### İlk değişiklikten önce

- Taban ölçümünü yapın ve araçları hazırlayın ([Başlamadan önce](preparation.md)).
- Mevcut ayarları profile kaydedin: **Tool → ASUS User Profile → Save to Profile**. Bir ayardan sonra sistem açılmazsa bu profile dönersiniz.
- Her seferde tek grubu değiştirin (önce RAM, sonra işlemci). Her gruptan sonra kararlılık testi yapın ve ölçün.

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

> [!NOTE]
> Kontrol betiğinin hedef listesi bu sistemin güncel ayarlarını hedefler: ileri düzey DDR5-8000 profili ve Core Tuning Level 2. Curve Optimizer 02.11'den beri Disabled (Auto) olarak hedeflenir. Bu sayfadaki varsayılanları (EXPO/XMP, Auto) kullanıyorsanız RAM ve Core Tuning satırları **FARKLI** görünür. Bu satırları listeye uymak için değiştirmeyin.

## RAM

Bu bölümü ilk olarak uygulayın. Bir seçenek seçin:

| Seçenek | Ayar | Durum |
|---|---|---|
| **Varsayılan** | [Kitin kendi EXPO veya XMP profili](#varsayılan-kitin-expo-veya-xmp-profili) | Bu depoda ölçülmedi. Profili açtıktan sonra bellek testi yapın. |
| Alternatif | [Elle DDR5-6000 CL28 1:1](#ddr5-6000-11-alternatifi) | Mevcut ölçümler 8000 profiliyle güvenilir bir performans farkı ortaya koymuyor. DRAM VDD 1,45 V. Bellek testi gerektirir. |
| İleri düzey | [Elle DDR5-8000 CL34, 1,60 V, tREFI 65535](#ddr5-8000-ileri-düzey) | Varsayılan değildir. Bu depoda bellek kararlılık testi sonucu yoktur. Yalnızca bellek testini geçtikten sonra kullanın. |

> [!WARNING]
> **WHEA hatası görülmemesi, bellek kararlılığını kanıtlamaz.** RAM kararlılığı uygun bellek testleriyle doğrulanmalıdır ([Bellek kararlılık testi](#bellek-kararlılık-testi)). Kararsız bellek, hata mesajı vermeden veriyi bozabilir. Görev Yöneticisi'ndeki hız ve HWiNFO'daki saatler yalnızca ayarın uygulandığını gösterir.

### Varsayılan: kitin EXPO veya XMP profili

1. **Ai Tweaker → Ai Overclock Tuner** değerini kitin desteklediği **EXPO** veya **XMP** profiline alın.
2. Diğer RAM ayarlarını Auto bırakın.
3. Kaydedin ve yeniden başlatın (**F10**). İlk açılışta bellek eğitimi birkaç dakika sürebilir.
4. [Bellek kararlılık testi](#bellek-kararlılık-testi) yapın.

- **FCLK:** Auto bırakabilirsiniz. Bu sistemde 2000'den 2200 MHz'e çıkmak +%0,23 verdi (sapma içinde). 2200 kullanacaksanız değeri iki menüde de ayarlayın ([FCLK notu](#ddr5-8000-ileri-düzey)) ve WHEA 19 olaylarını izleyin.
- **Kontrol betiği:** Hedef liste DDR5-8000 profilini hedefler. EXPO/XMP ile RAM satırları **FARKLI** görünür. Windows RAM hızı kontrolü için kitin hızını verin: `.\scripts\check\Test-Configuration.ps1 -RamMts 6000`.
- Profilin hızı, zamanlamaları ve voltajı kitin etiketinde ve üreticinin sayfasında yazar.
- EXPO/XMP de belleği varsayılan (JEDEC) hızının üstünde çalıştırır. Bu sistemde kitin JEDEC hızı 5600 MT/s'dir. Kararlılık işlemciye ve anakarta göre değişir.
- Bu profil bu depoda ölçülmedi. FPS ve kararlılık sonucu yoktur.

### DDR5-8000 (ileri düzey)

> [!CAUTION]
> Bu profil varsayılan öneri değildir. Zamanlamalar elle ayarlanır. DRAM VDD ve VDDQ voltajı 1,60 V'tur. tREFI en yüksek değerdedir (65535). Bu depoda bu profil için bellek kararlılık testi sonucu yoktur. Mevcut ölçümler bu profil ile elle DDR5-6000 1:1 arasında güvenilir bir performans farkı ortaya koymuyor. Profili yalnızca [bellek kararlılık testini](#bellek-kararlılık-testi) geçtikten sonra kullanın. Zamanlamalar yalnızca bu kit için bir başlangıç noktasıdır (SK Hynix 24 Gbit M-die, 2 × 24 GB, tek rank).

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

**Windows'ta kontrol:** Görev Yöneticisi → Performans → Bellek bölümünde hız **8000 MT/s** olmalıdır. HWiNFO'da FCLK **2200 MHz**, UCLK **2000 MHz** olmalıdır. Olay Görüntüleyicisi'nde WHEA hatası olmamalıdır. Bu kontroller yalnızca ayarın uygulandığını gösterir. Bellek kararlılığını göstermez.

### DDR5-6000 1:1 alternatifi

Elle DDR5-8000 (Gear 2) yerine elle DDR5-6000, UCLK = MEMCLK (1:1) ölçüldü. Mevcut ölçümler güvenilir bir performans farkı ortaya koymuyor. Veriler bir üstünlüğü veya eşdeğerliği göstermek için yetersizdir (ayrıntı aşağıda). 6000, daha düşük DRAM voltajıyla çalışır. Bu profil de elle yapılan bir hız aşırtmadır. Kararlılığını kendi sisteminizde [bellek kararlılık testi](#bellek-kararlılık-testi) ile doğrulayın.

| Ayar | UCLK | Ortalama FPS (8000'e göre) | P1 ve P99 | Karar |
|---|---|---|---|---|
| DDR5-8000 CL34, Gear 2 | 2000 MHz | — | — | İleri düzey ([yukarıda](#ddr5-8000-ileri-düzey)) |
| DDR5-6000 CL28, 1:1 | 3000 MHz | +%0,2 ile +%0,4 (yönteme ve oturuma göre, sapma içinde) | Güvenilir fark görülmedi | Alternatif. Bellek testi gerektirir. |
| DDR5-6200 CL28, 1:1 | 3100 MHz | 6000'e göre −%0,2 (tek oturum, sapma içinde) | Güvenilir fark görülmedi | Kazanç gösterilmedi |
| DDR5-6400 CL28, 1:1 | 3200 MHz | Ölçülmedi | — | Kullanmayın: iki açılışta iki mavi ekran (`0xA`) |

**6000 ayarları:** Ai Tweaker → Memory Frequency: DDR5-6000. DRAM Timing Control: Tcl 28, Trcd Rd 35, Trcd Wr 36, Trp 35, Tras 49, Trc 84, Trfc1 510, Trfc2 ve Trfcsb Auto, TrrdL 12, Tfaw 32, TrdrdScl 4, TwrwrScl 4, Twrrd 2, Trdwr 16. Diğer zamanlamalar yukarıdaki tabloyla aynıdır. DRAM VDD 1.450, DRAM VDDQ 1.350. FCLK 2200.

> [!IMPORTANT]
> **UCLK DIV1 MODE da iki menüde ayarlanır** (FCLK gibi):
> 1. **Ai Tweaker → UCLK DIV1 MODE**
> 2. **Advanced → AMD Overclocking → DDR and Infinity Fabric Frequency/Timings → Infinity Fabric Frequency and Dividers → UCLK DIV1 MODE**
>
> İkinci değer sabitse Ai Tweaker değeri uygulanmaz. Bu sistemde ikinci değer UCLK=MEMCLK/2 olarak kalmıştı ve 6000'de UCLK 1500 MHz oldu. 1:1 için ikisini de **UCLK=MEMCLK** yapın. 8000'e dönerken ikinci değeri **UCLK=MEMCLK/2** yapın. HWiNFO'da **Memory Controller Clock (UCLK)** değerini kontrol edin.

**Ölçüm (26.10):** Gölge Yüksek, ekran kartı +425, CPU 0 hariç. Her ayar ayrı bir CS2 oturumunda 2 ısınma ve 3 kayıt koşusuyla ölçüldü. 6000 ve 8000 ikişer oturumda, A-B-A sırasıyla ölçüldü. Karşılaştırmada 8000'in yalnızca tekrar oturumu kullanıldı (aşağıda). İlk 8000 ölçümü, gölge ve ekran kartı profili karşılaştırması için açılan gece oturumunun ilk bloğudur.

| Oturum | Ortalama FPS (3 kayıt koşusu) | P1 |
|---|---|---|
| 8000 Gear 2 (gece, karşılaştırmaya alınmadı) | 934,8 | 331,5 |
| 6000 1:1 | 948,1 | 347,6 |
| 6200 1:1 | 946,6 | 350,1 |
| 6000 1:1 (tekrar) | 948,7 | 350,0 |
| 8000 Gear 2 (tekrar) | 946,2 | 354,0 |

**Hesaplama:** Yüzdeler oturum ortalamalarından iki yöntemle hesaplandı: 3 kayıt koşusu (tablodaki değerler) ve ısınma dahil 5 koşu ([karar kuralındaki](methodology.md#karar-kuralı) 5 sıra). Yöntem sonucu değiştirdiğinde iki değer de verildi. Ham veri: [`data/windows-gpu-runs.csv`](../data/windows-gpu-runs.csv), `G20`–`G25`.

- İlk 8000 oturumu, aynı BIOS ayarlarının tekrar ölçümünden %1,2 düşük çıktı (3 kayıt koşusuyla %1,22, 5 koşuyla %1,17). Bu nedenle ilk karşılaştırmada görülen fark (3 kayıt koşusuyla +%1,4, 5 koşuyla +%1,5), RAM ayarının etkisi olarak okunamaz.
- Aynı öğleden sonra ölçülen 6000 ile 8000 arasındaki fark, 8000'in tekrar oturumuna göre 3 kayıt koşusuyla +%0,19 ve +%0,26, 5 koşuyla +%0,36 ve +%0,39'dur (6000'in iki oturumu). Sıra sıra bakıldığında (ısınma dahil 5 sıra) 6000'in tekrar oturumu beş sıranın beşinde, ilk oturumu dördünde öndedir. Ama aynı gün, aynı ayarın iki oturumu arasında 3 kayıt koşusuyla %0,06 (6000) ve %1,22 (8000), 5 koşuyla %0,03 ve %1,17 fark görüldü. Bu aralık, iki profil arasındaki farkı kapsar.
- Oturum sayısı: 6000 iki, 8000 iki, 6200 bir. Karşılaştırmada 6000'in iki oturumu ve 8000'in yalnızca tekrar oturumu kullanıldı. İlk 8000 oturumu karşılaştırmaya alınmadı: aynı ayarların tekrarından %1,2 düşük çıktı, yani 8000 için A-B-A kontrolü tutmadı. Farkın nedeni bulunamadı. Bu oturum, bir sürücü hatasından (TDR) 3 dakika sonra yeniden başlatma yapılmadan başlamıştı.
- Tek bir 8000 oturumuyla yapılan karşılaştırma, oturum etkisini RAM ayarının etkisinden ayıramaz. Bu nedenle mevcut ölçümler güvenilir bir performans farkı ortaya koymuyor. Veriler bir üstünlüğü veya eşdeğerliği göstermek için yetersizdir.
- P1, P99 ve ortalama kare süresinde de güvenilir bir fark görülmedi.

**Kararlılık:** 6000 ve 6200, OCCT Memory testini (yaklaşık 16 dakika) hatasız geçti. WHEA hatası olmadı. Bu kısa bir kontroldür. Uzun bellek testi yapılmadı. 6400 aynı zamanlamalarla iki açılışta da mavi ekran verdi (`0xA`, açılıştan 20 saniye ve 13 dakika sonra). Aynı döngü sayısı 6400'de nanosaniye olarak daha sıkıdır (örneğin CL28 = 8,75 ns). 6400 için gevşek zamanlamalar veya yüksek SOC voltajı denenmedi.

### Bellek kararlılık testi

Bu adımları her bellek profilinden sonra izleyin. Elle profillerde (DDR5-6000, DDR5-8000) zorunludur. EXPO/XMP profilinde de önerilir.

1. Uzun bir bellek testi çalıştırın. Araçlar ve bağlantılar: [Başlamadan önce](preparation.md#2-araçlar). Topluluğun yaygın kullandığı ölçütler aşağıdadır. Bu ölçütler bu depoda doğrulanmadı. Aracın kendi belgesi önceliklidir.

   | Araç | Yaygın ölçüt |
   |---|---|
   | TestMem5 | anta777 "Extreme" yapılandırması, en az 3 döngü, hatasız |
   | Karhu RAM Test | En az %10.000 kapsama, hatasız |
   | y-cruncher | Stres testi, VT3 bileşeni, en az 1 saat |
   | MemTest86 | En az 4 geçiş, hatasız (Windows dışında, USB bellekten açılır) |

2. Test sırasında bellek sıcaklığını izleyin (HWiNFO, SPD Hub sıcaklığı). tREFI yüksekse bellek sıcaklığa daha duyarlıdır.
3. Testi soğuk açılıştan sonra da tekrarlayın.
4. Hata görürseniz zamanlamaları gevşetin veya kitin EXPO/XMP profiline dönün ([Sorun giderme](troubleshooting.md)).

**Bu testin yerini tutmayanlar:** Görev Yöneticisi'nde doğru hız, HWiNFO'da doğru FCLK ve UCLK, WHEA hatası olmaması ve CS2 benchmarkı. Bunlar yalnızca ayarın uygulandığını ve sistemin çalıştığını gösterir.

Bu depoda bu testlerin sonuçları yoktur. DDR5-6000 ve 6200 için yalnızca yaklaşık 16 dakikalık OCCT Memory testi yapıldı. DDR5-8000 için bellek testi yapılmadı.

### BCLK

Bu anakartta BCLK, işlemci saatiyle birlikte PCIe saatini de değiştirir. Ayrı bir saat üreteci yoktur.

| BCLK | Sonuç |
|---|---|
| 101 MHz | Ortalama FPS, iki BCLK 100 oturumuna göre ısınma dahil 5 koşuyla +%0,37 ve +%0,40, 3 kayıt koşusuyla +%0,50 ve +%0,57 yüksek. A-B-A kontrolü tuttu: BCLK 100 ile ölçülen iki oturum arasındaki fark %0,03'tür (5 koşu; 3 kayıt koşusuyla %0,06). P1 ve P99 değişmedi. Saat tavanı 5479 MHz, FCLK 2222 MHz, MCLK 3030 MHz oldu. OCCT CPU + RAM 18 dakika hatasız. |
| 102 MHz | Açılmadı. BIOS varsayılan ayarlara döndü. |

**Karar:** 100 MHz bırakın. Kazanç küçüktür ve P1 değişmez. 101 MHz, PCIe 5.0 ekran kartını ve NVMe diski spesifikasyon dışında çalıştırır.

## İşlemci

> [!IMPORTANT]
> - Bu bölümdeki değerler tek bir Ryzen 7 9800X3D ile ölçüldü. Her işlemci örneği farklıdır. Değerleri başka bir işlemciye doğrudan kopyalamayın.
> - PBO ölçümünde üç ayar birlikte değişti: Precision Boost Overdrive Advanced, PBO Limits Motherboard ve Boost Override +200. Ortalama FPS +%3,5 arttı. Her ayarın payı ayrı ölçülmedi.
> - Bu depoda çekirdek bazında veya düşük yükte CPU kararlılık testi sonucu yoktur. Tek CPU testi, BCLK 101 MHz ve DDR5-6000 ile yapılan 18 dakikalık OCCT CPU + RAM testidir ([BCLK](#bclk)).
> - Ayarları uyguladıktan sonra kendi sisteminizde CPU kararlılık testi yapın. WHEA hatası olmaması tek başına kararlılık kanıtı değildir. Yaygın kullanılan testler (bu depoda doğrulanmadı): OCCT CPU testi (büyük veri seti, değişken yük) ve y-cruncher stres testi, en az 1'er saat. Curve Optimizer değiştirirseniz çekirdek bazında test için CoreCycler kullanın. Düşük yükte ve boşta oluşan çökmeleri de izleyin. Araçlar: [Başlamadan önce](preparation.md#2-araçlar).

**Advanced → AMD Overclocking → Precision Boost Overdrive** yolunu izleyin. Menüye girerken çıkan uyarıyı kabul edin.

| Ayar | Değer |
|---|---|
| Precision Boost Overdrive | Advanced |
| PBO Limits | Motherboard. Bu ayarın ayrı etkisi ölçülmedi. |
| CPU Boost Clock Override | Enabled (Positive) |
| Max CPU Boost Clock Override(+) | 200. Bu değer 9800X3D için kullanıldı. Saat tavanı 5,2 GHz'den 5,425 GHz'e çıktı. |

**Curve Optimizer ve Core Tuning**

Bu iki ayarı Auto (BIOS varsayılanı) bırakın. Bu sistemde ölçülebilir FPS kazancı doğrulanmadı. Çekirdek bazında kararlılıkları test edilmedi. Değiştirmek isterseniz kararlılığı kendi sisteminizde doğrulayın.

| Menü | Ayar | Önerilen | Bu sistemde ölçülen değer ve sonuç |
|---|---|---|---|
| Precision Boost Overdrive → Curve Optimizer | Curve Optimizer | Auto (BIOS varsayılanı) | All Cores, Negative, 10. Ortalama FPS −%0,3 (19.10), etki yok. 02.11'de Auto ile yeniden karşılaştırıldı (aşağıda). Bu sistem artık Auto kullanır. |
| Ai Tweaker | Core tunings Configuration for gaming | Auto (BIOS varsayılanı) | Level 2. İlk ölçümde +%0,7, tekrar ölçümde doğrulanmadı. |

**Curve Optimizer −10 ile Auto (02.11):** Yalnızca Curve Optimizer değişti (AMD Overclocking, `AodSetupRpl` @00B6: 1 → 0). Diğer ayarlar aynı kaldı.

| Ölçüt | All Cores −10 | Auto (Disabled) | Fark |
|---|---|---|---|
| CS2, 3 kayıt koşusu (iki taze oturum) | 938,70 | 934,70 | −%0,43 |
| CS2, sıra eşleştirmeli (5 koşu) | | | −%0,33 (5 sıranın 5'inde düşük) |
| CS2 P1 / P99 (kayıt medyanı) | 340,1 / 2,94 ms | 353,8 / 2,83 ms | Fark yok |
| Tüm çekirdek yükte saat (y-cruncher stres) | 4835 MHz | 4711 MHz | −%2,6. Bildirilen ve efektif saat aynı (saat esnemesi yok). |
| y-cruncher bench 1b | 17,29 sn | 17,52 sn | %1,3 yavaş |

- Aynı gün, aynı ayarla iki oturum arasındaki fark %0,32'dir. CS2 farkı bu sapma kadardır.
- CS2 sırasında çekirdekler zaten 5425 MHz tavanında çalışır. Curve Optimizer yalnızca ağır tüm çekirdek yükte saati değiştirir.
- Bu işlemci örneği, önceki bir Windows kurulumunda −15'te CS2 sırasında çöktü (kullanıcı beyanı, kayıt yok). Bu nedenle daha derin değerler denenmedi.
- −10 için stres ve bench değerleri taze olmayan bir oturumda ölçüldü.
- Ham veri: [`windows-gpu-runs.csv`](../data/windows-gpu-runs.csv), `G28` (−10, taze), `G31` (−10) ve `G32` (Auto).

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
