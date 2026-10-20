# BIOS verileri: nerede durur, ne anlama gelir, ne ölçüldü

Bu belge ASUS ROG STRIX X870-A GAMING WIFI, BIOS 2503 içindir. Ofsetler, değişken adları ve kodlar BIOS sürümüne ve karta özeldir; başka kartta veya sürümde aynı olmayabilir.

## 1. BIOS ayarlarını Windows'tan okuma

- **Okuma yöntemi:** BIOS ayarları UEFI NVRAM değişkenlerinde saklanır. Windows'ta yönetici PowerShell ve `SeSystemEnvironmentPrivilege` yetkisiyle `GetFirmwareEnvironmentVariableExW` çağrılarak **yalnızca okundu**. Değişken listesi `NtEnumerateSystemEnvironmentValuesEx` ile alındı.
- **Kullanılmayanlar:** Sürücü kurulmadı, SCEWIN/AMISCE kullanılmadı, NVRAM'e hiçbir şey yazılmadı.
- **Araçlar:**
  - `nvram/nvram_snap.ps1`: tüm NVRAM dizinini ve ayar değişkenlerinin ham baytını kaydeder. Parola/anahtar/TPM adlı değişkenleri kaydetmez.
  - `nvram/nvram_diff.ps1`: iki görüntüyü karşılaştırır.
  - `nvram/bios_dump.ps1`: okunur döküm üretir.
- **Gürültü kontrolü:** Aynı BIOS durumunda alınan iki görüntü arasında fark 0 çıktı. Değişen baytlar yalnızca BIOS'ta yapılan değişikliği gösteriyor; sayaç ve log değişkenleri (MonotonicCounter, BiosEventLog) hariç.

### Ayar adları nereden geldi

1. **Ayar sözlüğü (IFR):** ASUS'un 2503 BIOS dosyası (`.CAP`, 33.558.528 bayt, imzalı AMI kapsülü) `tools/BiosIfr.cs` ile açıldı.
   - Çıkarma zinciri: FV → FFS → LZMA → PE32 → HII paketleri → IFR.
   - Sonuç: **9304 ayar**. 408'i `suppressif TRUE` ile **gizli** (BIOS menüsünde görünmez), 3654'ü koşullu.
   - Her ayarın menü yolu, adı, değişkeni, ofseti, boyutu, seçenekleri ve varsayılanı çıkarıldı.
   - Sözlük üreticinin telifli dosyasından türediği için depoda yok; kendi BIOS'undan `BiosIfr.cs` ile çıkarılabilir. `data/bios_son_durum.csv` bu sözlükle çözülmüş son durumdur.
2. **AMD Overclocking (AOD) alan adları:** AOD bloğu IFR sözlüğünde yer almıyor. Alan adları, ASUS'un BIOS profil dosyasındaki (`.CMO`) C yapı tanımlarından alındı.
   - Profil dosyası EFI/Tiano sıkıştırmalıdır; `tools/EfiDec3b.cs` ile açılır (`[EfiDec3]::Run(bytes, 0, 4)`).
   - Açılan metin, C yapı tanımları ve `$ProfileData(<YAPI>) … $End` arasında hex değerler içerir.
3. **Doğrulama:**
   - Değişkenlerin canlı boyutları yapı tanımlarıyla birebir aynı: OCMR 10398, AOD 800, CBS 2016, PBS 256, Setup 359 bayt.
   - Bilinen canlı değerler (RAM zamanlamaları) HWiNFO ile aynı.

## 2. Değişkenler

| Kısa ad | NVRAM adı | GUID | Boyut | İçerik |
|---|---|---|---|---|
| OCMR | `VARSTORE_OCMR_SETTINGS_NAME` | {A3A3B874-7636-4182-BA1E-F52C584494E3} | 10398 | ASUS Ai Tweaker: bellek frekansı, FCLK, RAM zamanlamaları, voltajlar, Core Tuning, LLC, Ai Tweaker PBO |
| HOB | `VARSTORE_OCMR_OUTPUT_HOB` | {A3A3B874-7636-4182-BA1E-F52C584494E3} | 3135 | BIOS'un açılışta uyguladığı değerlerin çıktısı (salt bilgi) |
| AOD | `AodSetupRpl` | {5ED15DC0-EDEF-4161-9151-6014C4CC630C} | 800 | AMD Overclocking menüsü: PBO, Curve Optimizer, Boost Override, FCLK/UCLK, Nitro, SMT kopyası |
| AODL | `AodSetupRplLast` | {5ED15DC0-EDEF-4161-9151-6014C4CC630C} | 800 | AOD'un son uygulanan kopyası (AOD ile aynı değişir) |
| CBS | `AmdSetupRPL` | {3A997502-647A-4C82-998E-52EF9486A247} | 2016 | AMD CBS (SMT, C-state, LUL, prefetcher, IOMMU…). `AmdSetupPHX` / `AmdSetupSTXKRK` başka işlemci aileleri için, etkin değil |
| PBS | `AMD_PBS_SETUP` | {A339D746-F678-49B3-9FC7-54CE0F9DF226} | 256 | AMD PBS |
| SETUP | `Setup` | {EC87D643-EBA4-4BB5-A1E5-3F3E36B20DA9} | 359 | Genel ayarlar (iGPU, SVM, Above 4G, DriverHub…) |
| QFAN | `AsusQFanSetupData` | {EC87D643-EBA4-4BB5-A1E5-3F3E36B20DA9} | 343 | Q-Fan fan/pompa eğrileri |

**Önemli:** Bazı ayarlar iki yerde durur. Örneğin PBO hem Ai Tweaker'da (OCMR @046C) hem AMD Overclocking'de (AOD @009A) var. Bu projede PBO, CO ve Boost Override AMD Overclocking menüsünden ayarlandı. OCMR'deki Ai Tweaker PBO alanları **Auto** kaldı; bu normaldir. İki yere farklı değer yazılmamalı.

## 3. Ofset ve kod sözlüğü (bu projede kullanılan ayarlar)

`*` = BIOS varsayılanı. "Gizli" = menüde görünmez, yalnız NVRAM'de var. "Son" = projenin sonundaki değer.

### Ai Tweaker / DRAM (OCMR)

| Ayar | Ofset | Kodlar | Son |
|---|---|---|---|
| Ai Overclock Tuner | @0000 | 0 Auto, 1 Manual, 5/6/11 DOCP I/II/Tweaked, 7/8/12/13 EXPO I/II/Tweaked/on the fly, 9 AEMP, 10 ROG Certified | 1 Manual |
| Memory Frequency | @085E (4 B) | MHz | 8000 |
| FCLK Frequency | @0862 (4 B) | MHz | 2000 |
| UCLK DIV1 MODE | @08C4 | 255 Auto* | 255 Auto (AOD'da elle UCLK=MEMCLK/2) |
| Core tunings Configuration for gaming | @08F7 | 255 Auto*, 0 Legacy, 1 Level 1, 2 Level 2 | **2 Level 2** |
| Turbo Game Mode | @0417 | 0*, 1 (ASUS: ikinci CCD ve SMT kapatılır) | 0 |
| Gaming Adaptive CCD Parker | @0418 | 0*, 1 (çift CCD için) | 0 |
| AI Cache Boost | @0419 | 255*, 0, 1 (ASUS: AI araçları için) | 255 |
| Core Performance Boost | @0414 | 0 Auto*, 1 Enabled, 2 Disabled | 0 |
| Medium Load Boostit | @0467 | 255*, 0, 1 | 255 (1 denendi) |
| Ai Tweaker PBO | @046C | 255 Auto*, 0 Disabled, 1 Enabled, 2 Manual, 3 Enhancement, 4 ECO | 255 |
| Thermal Limit | @046D | 1 Level 1 (90 °C), 2 Level 2 (80 °C)*, 3 Level 3 (70 °C) | 2 |
| CPU Boost Clock Override (Ai Tweaker) | @048A | 255*, 0, 1 Pozitif, 2 Negatif; Max(+) @048B gizli | 255 |
| Curve Optimizer (Ai Tweaker) | @06BC | 0 Auto*, 1 All Cores, 2 Per Core, 3 Per CCD; işaret @06BD, büyüklük @06BE; çekirdek n: @06C0+n, @0700+2n | 0 |
| CPU Load-line Calibration | @093A | 0 Auto*, 1–8 Level | 0 (6 denendi) |
| Power Down Enable | @08C2 | 0 Disabled, 1 Enabled, 255 Auto* | **0 Disabled** |
| Memory Context Restore | @08C3 | 255*, 1 Enabled, 0 Disabled | **1 Enabled** |
| Gear Down Mode | @08CB | 255*, 1 Disabled, 2 Enabled | **2 Enabled** |
| Bank Refresh Mode | @08CD | 255 Auto*, 0 Normal, 1 Fine Granularity Refresh, 2 Mixed (REFab/REFsb) | **2 Mixed** |
| Bank Swap Mode | @08C9 | 255 Auto* | 255 |
| Memory P-state | @08A6 | 255*, 0, 1 | 255 |
| High DRAM Voltage Mode | @080D | 0 Auto*, 1 Disabled, 2 Enabled | **2 Enabled** |
| DRAM VDD / VDDQ Voltage (gizli) | @080E / @0810 | volt = 0,79 + 0,01 × kod | **81 = 1,60 V** |
| Memory VDD / VDDQ (Sync All, gizli) | @0817 / @0819 | aynı formül | 81 |
| PMIC0–3 Memory VDD (gizli) | @0831 / @0833 / @0835 / @0837 | aynı formül | 81 |
| PMIC0–3 Memory VDDQ (gizli) | @0839 / @083B / @083D / @083F | aynı formül | 81 |
| CPU SOC Voltage | @07C6 | 0 Auto* | Auto |
| CPU VDDIO / MC Voltage (gizli) | @07C1 | 3 Auto | Auto |
| Misc Voltage | @07F5 | 0 Auto* | Auto |
| VDDG CCD / IOD | @085A / @085C | 0 Auto* | Auto |
| DDR5 Nitro Mode (gizli) | @08D7 | 255*, 1 Enabled, 0 Disabled | 255 |
| Nitro RX / TX / Control Line / Rx Burst / Tx Burst (gizli) | @08D9 / @08DA / @08DB / @08DC / @08DD | 255*; RX 1–2, TX 0–3, CTL 1–2; Burst 0=1x, 1=2x, 2=4x, 3=8x | 255 |
| Rtt Nom Wr / Nom Rd / Wr / Park / Park Dqs | @08AB–@08AF | 255 Auto* | Auto |

**RAM zamanlamaları (OCMR, hepsi 2 bayt, menüde gizli alanlar):**

| Alan | Ofset | Değer |
|---|---|---|
| Tcl | @086A | 34 |
| TrcdWr | @086C | 46 |
| Trcd (Rd) | @086E | 46 |
| Trp | @0870 | 46 |
| Tras | @0872 | 50 |
| Trc | @0874 | 96 |
| Twr | @0876 | 48 |
| tREFI (Refresh Interval) | @0878 | 65535 |
| Trfc1 | @087A | 664 |
| Trfc2 | @087C | 852 |
| Trfcsb | @087E | 730 |
| Trtp | @0880 | 14 |
| TrrdL | @0882 | 10 |
| TrrdS | @0884 | 8 |
| Tfaw | @0886 | 20 |
| TwtrL | @0888 | 16 |
| TwtrS | @088A | 6 |
| TrdrdScl / Sc / Sd / Dd | @0892 / @0894 / @0896 / @0898 | 8 / 1 / 1 / 1 |
| TwrwrScl / Sc / Sd / Dd | @089A / @089C / @089E / @08A0 | 8 / 1 / 1 / 1 |
| Twrrd | @08A2 | 6 |
| Trdwr | @08A4 | 20 |

### AMD Overclocking (AOD)

Alanların tam listesi (226 alan, son durum / Aşama 1 başlangıcı / eski profil): `data/bios_aod_alanlari.csv`.

| Alan | Ofset | Kodlar | Aşama 1 | Son |
|---|---|---|---|---|
| AodCpuSmtCtrl | @0032 | 1 açık, 0 kapalı (CBS SMT Control'ün kopyası) | 1 | 1 |
| AodMemCtrllerPowerDownEnDdr | @0093 | 255 Auto, 0 Disabled | 255 | 0 |
| AodFclkFrequency | @0094 (2 B) | 65535 Auto, MHz | 65535 | 2000 |
| AodUclkDiv1Mode | @0096 | 255 Auto, 0 UCLK=MEMCLK/2 | 255 | 0 |
| AodNbioPBOCtl | @009A | 255 Auto; 2 (PBO Advanced ile birlikte yazıldı) | 255 | **2** |
| AodNbioPBOAdvancedCtrl | @009B | 255 Auto; 1 (PBO Limits Motherboard ile birlikte yazıldı) | 255 | **1** |
| AodNbioSocketPPTLimit / TDCVDDLimit / EDCVDDLimit | @009C / @00A0 / @00A4 (4 B) | 0 = limit değeri girilmedi | 0 | 0 |
| AodNbioPBOScalarCtl / PBOScalar | @00A8 / @00A9 | 255 Auto / 100 = 1x | 255 / 100 | 255 / 100 |
| AodCpuBoostClock (yön) | @00AD | 0 Disabled, 1 Positive, 2 Negative | 0 | **1** |
| AodCpuBoostClock (MHz) | @00AE | MHz | 25 | **200** |
| AodNbiocHTCCtl / cHTC | @00B1 / @00B2 | 0 Auto | 0 | 0 |
| AodCurveOptimizer | @00B6 | 0 Auto, 1 All Cores, 2 Per Core | 0 | **1** |
| AodAllCoreCurveOptimizerSign | @00B7 | 0 Positive, 1 Negative | 0 | **1** |
| AodAllCoreCurveOptimizerMagnitude | @00B8 (2 B) | sayım | 0 | **10** |
| AodVddgCtrl / AodVddpVoltageCtrl | @017A / @0187 | 0 / 255 Auto | Auto | Auto |
| AodNitroModeDdr | @01B2 | 255 Auto, 1 Enabled | 255 | 255 (1 denendi) |
| AodNitroRXData / TXData / ControlLine | @01B4 / @01B5 / @01B6 | denenen 1 / 3 / 1 | 255 | 1 / 3 / 1 (Nitro Auto olduğu için etkisiz artık bayt) |
| AodNitroRx/TxBurstLength | @01B7 / @01B8 | 3 = 8x | 255 | 3 / 3 (etkisiz artık bayt) |
| Curve Shaper (15 bölge) | @01D9–@0205 | 255 Auto | Auto | Auto |

Notlar:
- AodNbioPBOCtl ve AodNbioPBOAdvancedCtrl aynı adımda değişti (PBO = Advanced ve PBO Limits = Motherboard). Hangi menü satırının hangi alana yazdığı tek tek ayrılmadı.
- Nitro RX/TX/CTL/Burst baytları, Nitro Auto'ya alındıktan sonra eski değerde kaldı. Nitro Mode Auto olduğu için etkisiz sayılıyor; bu doğrulanmadı.

### AMD CBS (CBS) ve Setup (SETUP)

| Ayar | Değişken@ofset | Kodlar | Son |
|---|---|---|---|
| SMT Control | CBS @0035 | 1 Auto*, 0 Disable (geri açmak için power cycle) | 1 Auto |
| Global C-state Control | CBS @0029 | 0 Disabled, 1 Enabled, 3 Auto* | 3 Auto |
| DF Cstates | CBS @003C | 0, 1, 255 Auto* | Auto |
| Latency Under Load (LUL) | CBS @03DE | 255*, 0 Enabled, 1 Disabled (koşullu görünür) | Auto (0 denendi) |
| Power Supply Idle Control | CBS @02DE | 255*, 0 Typical, 1 Low | Auto |
| CPPC Dynamic Preferred Cores | CBS @02D9 | 255* | Auto |
| Prefetcher'lar (L1 Stream, L2 Stream, L1 Stride, L1 Region, L1 Burst, L2 Up/Down) | CBS @0021, @0022, @00AF, @00B0, @0369, @00B1 | 0, 1, 3 Auto* | Auto |
| FCH Spread Spectrum / Clock Spread Spectrum | CBS @0063 / OCMR @0466 | Auto | Auto |
| IOMMU | CBS @003D | 0, 1, 15 Auto* | 15 Auto (FACEIT, dokunulmadı) |
| SVM Enable | CBS @0378 | 255*, 1, 0 | Auto (FACEIT, dokunulmadı) |
| Pluton Attribute Control | CBS @0485 | … 0 Disabled | 0 (varsayılandan farklı, proje öncesinden; dokunulmadı) |
| Integrated Graphics | SETUP @00EC | 0 Disabled, 2 Force, 255 Auto* | 255 Auto (iGPU açık) |
| SVM Mode | SETUP @00F1 | 0, 1* | 1 (FACEIT, dokunulmadı) |
| Above 4G Decoding / Resizable BAR | SETUP | Enabled | Enabled |
| Download and Install ASUS DriverHub | SETUP @00CF | 0 Disabled, 1 Enabled | 0 |

**Bulunamayanlar:** APBDIS ve Fixed SOC P-state bu BIOS'ta yok. PDF'teki "BGS / BGS Alt" için ayrı bir alan yok; en yakını Bank Swap Mode (Auto). Cmd2T için ayrı bir alan yok; HWiNFO'ya göre komut hızı 1T.

## 4. Son BIOS durumu

Varsayılandan farklı ayarların hepsi. Tam liste (2336 ayar, menü yolu, değer, seçenek): `data/bios_son_durum.csv`.

- **Ai Tweaker:**
  - Ai Overclock Tuner Manual.
  - Memory Frequency 8000.
  - FCLK 2000.
  - Core Tuning Config Level 2.
  - High DRAM Voltage Mode Enabled.
  - DRAM VDD/VDDQ 1,60 V; tüm PMIC VDD/VDDQ alanları 81.
- **DRAM Timing Control:**
  - Bölüm 3'teki tüm zamanlamalar.
  - Memory Context Restore Enabled.
  - Power Down Disabled.
  - Gear Down Mode Enabled.
  - Bank Refresh Mode Mixed.
- **AMD Overclocking:**
  - PBO Advanced + Limits Motherboard (AOD @009A=2, @009B=1).
  - CPU Boost Clock Override Positive +200 MHz.
  - Curve Optimizer All Cores Negative 10.
  - FCLK 2000, UCLK=MEMCLK/2, Power Down Disabled (elle yazılmış ama Ai Tweaker'daki değerlerle aynı).
- **Setup:** DriverHub Disabled. Arka plan teması "Se7en" (kozmetik).
- **Q-Fan:**
  - CPU Fan ve Chassis Fan 1: PWM Mode, Manual eğri.
  - AIO Pump: PWM Mode, Manual eğri. Noktalar 30/40/50/58/65/70/85/100 °C → %20/20/36/52/68/84/100/100.
  - CPU Fan ve Chassis Fan 1 noktaları: 20/30/40/50/60/67/70/100 °C → %20/26/34/45/60/80/100/100.
- **Proje öncesinden farklı olan, dokunulmayan:** Pluton Attribute Control Disabled.
- **Auto bırakılan önemli ayarlar:**
  - Nitro, LUL, Medium Load Boostit, LLC.
  - SMT, Global C-state, DF C-state.
  - AI Cache Boost, Core Flex (3 algoritma), Thermal Limit (Level 2, 80 °C).
  - Tüm CPU voltajları (Vcore, SOC, VDDIO, MISC, VDDG, VDDP).
  - RTT/ODT/sürücü dirençleri.
  - iGPU.

FACEIT'in denetlediği ayarların durumu (değişmedi):
- IOMMU Auto.
- SVM Mode Enabled.
- Launch CSM Disabled.
- Firmware TPM açık.
- BME DMA Mitigation Disabled.
- Resize BAR ve Above 4G Decoding Enabled.

### Her testte NVRAM'de ne değişti

Her BIOS değişikliğinden önce ve sonra görüntü alınıp karşılaştırıldı. Sayaç/log değişkenleri yazılmadı.

| Adım | Değişen baytlar |
|---|---|
| Aşama 1 → PBO200_MB | AOD: @0093 255→0 (Power Down Disabled), @0094 65535→2000 (FCLK), @0096 255→0 (UCLK DIV1), @009A 255→2, @009B 255→1, @00AD 0→1 (Positive), @00AE 25→200. AODL'de aynı 8 bayt. SETUP @012F 0→1 (tema). OCMR'de fark yok. |
| → CO-10 | AOD @00B6 0→1 (All Cores), @00B7 0→1 (Negative), @00B8 0→10 (+ AODL) |
| → CoreL2 | OCMR @08F7 255→2; HOB @0BD8 255→2 (uygulanan değer çıktısı) |
| → NitroCombo | AOD @01B2 255→1 (Nitro), @01B4 RX 1, @01B5 TX 3, @01B6 CTL 1, @01B7 3 (8x), @01B8 3 (8x); CBS @03DE 255→0 (LUL Enabled); OCMR @0467 255→1 (Medium Load Boostit); OCMR @093A →6 (LLC Level 6); SETUP @00CF 1→0 (DriverHub); HOB @0748 255→1, @0C1B 0→6 |
| → NitroAuto | AOD @01B2 1→255 (yalnız bu) |
| → L2Tekrar | CBS @03DE →255; OCMR @0467 →255; OCMR @093A →0 (Auto); HOB @0748 →255, @0C1B →0 |
| → SMToff | CBS @0035 1→0; AOD @0032 1→0 (+ AODL); HOB @006A 2→1 (çekirdek başına thread) |
| → SMT geri açık | SMToff öncesine göre CPU/RAM farkı 0; QFAN'da 19 bayt (fan ve pompa eğrileri) |

## 5. Okumalar ve anlamları (HWiNFO)

Kaynak: HWiNFO 8.54 paylaşılan belleği, 1 sn örnekleme (`hwinfo/hw_sample.ps1`). İki CS2 benchmark koşusu, son BIOS durumu (CoreL2) ile. Aşama 0 ve Aşama 1 değerleri 18.10 HWiNFO kayıtlarından.

### Voltajlar: BIOS ayarı ve ölçülen değer

| Hat | BIOS ayarı | CS2 yükünde (min / ort / maks) | Aşama 1 boşta | Aşama 0 | Anlamı |
|---|---|---|---|---|---|
| Vcore (Nuvoton) | Auto (PBO + CO −10) | 1,252 / 1,280 / 1,323 V | 1,199 V | – | Çekirdek voltajı |
| VDDCR_VDD (SVI3) | Auto | 1,259 / 1,283 / 1,290 V | 1,204 V | – | İşlemcinin bildirdiği çekirdek hattı |
| Core VID (çekirdek başına) | – | 1,255 / 1,28 / 1,32 V | – | – | İşlemcinin istediği voltaj |
| VDDCR_SOC (SVI3) | CPU SOC Auto | 1,283 / 1,284 / 1,285 V | 1,285 V | – | SoC / bellek denetleyicisi |
| CPU SOC (Nuvoton) | Auto | 1,288 / 1,292 / 1,296 V | 1,288 V | **0,898 V** | ASUS Auto, 8000 MT/s için SOC'u 0,90'dan 1,29 V'a çıkarıyor |
| CPU VDDIO / MC | Auto | 1,447 / 1,457 / 1,465 V | 1,464 V | – | Bellek denetleyicisi G/Ç |
| VDD_MISC (SVI3) / VMISC | Auto | 1,100 / 1,101 V | 1,100 V | – | |
| DRAM VDD (PMIC SWA, iki modül) | 1,60 V (kod 81) | 1,590 / 1,602 / 1,605 V | 1,602 V | 1,1 V (JEDEC) | Bellek çekirdek voltajı |
| DRAM VDDQ (PMIC SWB) | 1,60 V (kod 81) | 1,605 / 1,613–1,615 / 1,620 V | 1,607 V | 1,1 V | Bellek G/Ç voltajı |
| DRAM VPP (PMIC SWC) | Auto | 1,815 V | 1,815 V | 1,8 V | |
| PMIC 1,8 V / 1,0 V çıkışı, VIN | – | 1,809 / 1,004 / 5,10 V | – | – | Modül üstü regülatör |
| Chipset0 VDD | Auto | 1,056 / 1,057 / 1,072 V | – | – | |
| 1,8 V PLL | Auto | 1,826 V | – | – | |
| +12 V / +5 V / 3VSB / VBAT | – | 12,096 / 5,04 / 3,392 / 3,264 V | – | – | Güç kaynağı ve pil |
| GPU çekirdek | – | 0,945 / 1,007 / 1,015 V | – | – | |
| GPU 12VHPWR | – | 12,081 / 12,098 / 12,131 V | – | – | |

Not:
- Windows'taki `Win32_PhysicalMemory.ConfiguredVoltage` her zaman 1100 mV gösteriyor. Bu SPD'deki nominal değerdir, gerçek voltaj değildir; gerçek değer PMIC'ten okunur.
- DRAM VDD/VDDQ'nun Auto olduğu sanılıyordu, ama NVRAM'de bu alanlar 81 (= "1.600") yazıyor. PMIC ölçümü (1,60 V) NVRAM ile uyumlu; yani voltaj elle 1,60 V'a ayarlanmış.

### Saatler

| Ölçüm | Değer | Anlamı |
|---|---|---|
| Çekirdek saati | 5425 MHz (tüm çekirdekler, sabit) | Boost tavanı. Frequency Limit Global 5450 MHz |
| L3 saati | ort. 5436 MHz | |
| BCLK | 100,0 MHz | |
| MCLK / UCLK / FCLK | 4000 / 2000 / 2000 MHz | DDR5-8000, Gear 2 (UCLK = MCLK/2), FCLK 2000 |
| GPU çekirdek / bellek | ort. 2773 MHz / 1750 MHz | |

### Sıcaklıklar (CS2 yükü; min / ort / maks)

| Sensör | Değer |
|---|---|
| CPU Tctl/Tdie | 47,9 / 57,1 / 60,1 °C |
| CPU die ortalaması | 47,5 / 53,0 / 57,7 °C |
| CCD1 Tdie | 35,5 / 52,1 / 66,6 °C |
| L3 (CCD1) | maks. 44,1 °C |
| IOD hotspot | maks. 51 °C |
| VRM (VDD / SOC / MISC, SVI3) | 54–56 °C |
| Chipset (xHCI) | 44 °C |
| Anakart | 31 °C |
| DIMM SPD hub (A / B) | ort. 41,0 / 40,1 °C, maks. 42,0 / 41,3 °C |
| GPU / hotspot / bellek bağlantı | maks. 59,2 / 67,4 / 64 °C |
| SSD | 49–52 °C |

### Güç, akım ve sınırlar

| Ölçüm | Değer | Sınırın yüzdesi |
|---|---|---|
| CPU PPT | koşu sırasında ort. 75–76 W, maks. 85,8 W | %7,2–7,5 (maks. %8,6) |
| CPU çekirdek / SoC gücü | ort. 38 W / 17 W | |
| TDC | koşu sırasında ort. 32 A, maks. 40 A | %3,2 (maks. %4) |
| EDC | ort. 57 A, maks. 87 A | %5,8 (maks. %8,7) |
| Thermal Limit | | ort. %56, maks. %61 |
| DIMM gücü (modül başına) | ort. 1,5–1,6 W, maks. 3 W | |
| GPU gücü | ort. 131 W, maks. 165 W | TDP'nin %44'ü (sınır 300 W, en fazla 350 W) |
| HTC / PROCHOT kısma | 0 | |

### Fan ve pompa

- AIO pompa (Arctic Liquid Freezer III Pro 360, PWM, 800–2800 rpm):
  - Full Speed'de 2766–2800 rpm.
  - Manual eğride boşta 1235–1241 rpm (Tctl ~44 °C).
- CPU fanı boşta 1172–1296 rpm.
- Kasa fanı 1 boşta 639–722 rpm.

### Diğer Windows okumaları

| Okuma | Değer |
|---|---|
| GPU PCIe bağlantısı | 5.0 x16 (tam) |
| Resizable BAR | Açık (BAR1 16384 MiB) |
| HAGS | Açık (dxdiag: Hardware Scheduling Enabled) |
| WHEA-Logger / Kernel-Power 41 | Tüm açılışlarda 0 / 0 |

## 6. Eski BIOS profili (13.09, BIOS 2402)

Projeden önce kaydedilmiş bir ASUS profil dosyası da açıldı (EFI sıkıştırma; içinde 11 ayar yapısı var). **Bu profil yüklenmedi**, yalnız karşılaştırma için okundu. İçinde:

- **RAM:** 6000 MT/s, FCLK 2133, UCLK=MCLK (1:1); VDD 1,45 V / VDDQ 1,35 V, SOC 1,25 V.
- **Zamanlamalar:** CL28-36-35-35-49-84, tWR 48, tRFC 500/400/300, tRTP 12, tRRD 8/6, tFAW 20, tWTR 16/6.
- **CPU:** PBO (AodNbioPBOCtl 2, Scalar 2x), Curve Optimizer Per Core −10 (ilk 8 çekirdek), Core Tuning Level 2.
- **Diğer:** iGPU Disabled. Q-Fan'da AIO pompa Full Speed; CPU ve kasa fanları Manual düşük eğri.
