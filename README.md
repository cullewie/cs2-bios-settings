# CS2 BIOS, Windows ve ekran kartÄ± ayar rehberi

Bu rehber, ÅŸu sistem iÃ§in Ã¶lÃ§Ã¼lmÃ¼ÅŸ CS2 ayarlarÄ±nÄ± aÃ§Ä±klar:

- Ä°ÅŸlemci: Ryzen 7 9800X3D
- Anakart: ASUS ROG STRIX X870-A
- Bellek: DDR5-8000, SK Hynix M-die
- Ekran kartÄ±: RTX 5070 Ti

BIOS ayarlarÄ± 132 benchmark koÅŸusu ve 2 maÃ§ ile Ã¶lÃ§Ã¼ldÃ¼. Windows ve ekran kartÄ± ayarlarÄ± 48 benchmark koÅŸusu ile Ã¶lÃ§Ã¼ldÃ¼. Ekran kartÄ± ayarlarÄ± ayrÄ±ca Superposition, OCCT ve Kombustor ile sÄ±nandÄ±.

Bu rehberi Ã¼Ã§ durumda kullanÄ±n:

1. AynÄ± sistemi kurmak iÃ§in ayarlarÄ± sÄ±rayla uygulayÄ±n.
2. BIOS gÃ¼ncellemesinden veya CMOS sÄ±fÄ±rlamasÄ±ndan sonra ayarlarÄ± yeniden girin ve kontrol betiÄŸini Ã§alÄ±ÅŸtÄ±rÄ±n.
3. BaÅŸka bir sistemde denemek iÃ§in [bÃ¶lÃ¼m 10](#10-baÅŸka-sistemlere-uyarlama) bÃ¶lÃ¼mÃ¼nÃ¼ okuyun.

> **UYARI:** RAM hÄ±z aÅŸÄ±rtmasÄ±, ekran kartÄ± hÄ±z aÅŸÄ±rtmasÄ±, voltaj artÄ±ÅŸÄ± ve PBO garanti kapsamÄ±nÄ± etkileyebilir. Sistem kararsÄ±z Ã§alÄ±ÅŸabilir ve veri kaybÄ± olabilir. TÃ¼m sorumluluk size aittir. DeÄŸerler tek bir sistemde denendi.

---

## Ä°Ã§indekiler

1. [SonuÃ§ Ã¶zeti](#1-sonuÃ§-Ã¶zeti)
2. [Sistem](#2-sistem)
3. [BaÅŸlamadan Ã¶nce](#3-baÅŸlamadan-Ã¶nce)
4. [BIOS: RAM](#4-bios-ram)
5. [BIOS: Ä°ÅŸlemci](#5-bios-iÅŸlemci)
6. [BIOS: Auto olarak kalacak ayarlar](#6-bios-auto-olarak-kalacak-ayarlar)
7. [BIOS: FACEIT ve gÃ¼venlik](#7-bios-faceit-ve-gÃ¼venlik)
8. [Windows ve CS2 ayarlarÄ±](#8-windows-ve-cs2-ayarlarÄ±)
9. [Ekran kartÄ± hÄ±z aÅŸÄ±rtma](#9-ekran-kartÄ±-hÄ±z-aÅŸÄ±rtma)
10. [BaÅŸka sistemlere uyarlama](#10-baÅŸka-sistemlere-uyarlama)
11. [Kontrol](#11-kontrol)
12. [Ã–lÃ§Ã¼m yÃ¶ntemi](#12-Ã¶lÃ§Ã¼m-yÃ¶ntemi)
13. [AraÃ§lar](#13-araÃ§lar)
14. [Sorun giderme](#14-sorun-giderme)
15. [SÄ±nÄ±rlar](#15-sÄ±nÄ±rlar)
16. [Depo yapÄ±sÄ±](#16-depo-yapÄ±sÄ±)

---

## 1. SonuÃ§ Ã¶zeti

| AdÄ±m | Ortalama FPS | Karar |
|---|---|---|
| RAM 8000 (BIOS 2402'den 2503'e geÃ§iÅŸle birlikte) | +%1,2. SonuÃ§ kesin deÄŸil. P1 +%4,3 ve P99 âˆ’%4,0 kesin. | KullanÄ±n |
| PBO Advanced, PBO Limits Motherboard, Boost Override +200 | **+%3,5** | KullanÄ±n |
| CS2'yi CPU 0 dÄ±ÅŸÄ±nda Ã§alÄ±ÅŸtÄ±rma (Windows affinity) | **+%1,8 ile +%2,5** | KullanÄ±n |
| Curve Optimizer All Cores âˆ’10 | âˆ’%0,3. Etki yok. | AÃ§Ä±k bÄ±rakÄ±n (zararsÄ±z) |
| Core Tuning Config for Gaming Level 2 | DoÄŸrulanmadÄ± | AÃ§Ä±k bÄ±rakÄ±n (zararsÄ±z) |
| DDR5 Nitro Mode 1-3-1 | **âˆ’%1,4** | Auto bÄ±rakÄ±n |
| Latency Under Load, Medium Load Boostit, LLC 6 | Sapma iÃ§inde | Auto bÄ±rakÄ±n |
| SMT kapalÄ± | Etki yok | Auto bÄ±rakÄ±n (aÃ§Ä±k) |
| FCLK 2200 MHz (Ai Tweaker ve AMD Overclocking menÃ¼sÃ¼nde) | +%0,23. Sapma iÃ§inde. 6 koÅŸunun 5'inde yÃ¶n aynÄ±. | KullanÄ±labilir. WHEA hatasÄ± olursa 2000'e dÃ¶nÃ¼n. |
| iGPU kapalÄ±, Global C-state Enabled, Power Supply Idle Control Typical (birlikte) | Etki yok (+%0,25) | Ä°steÄŸe baÄŸlÄ± |
| YÃ¼ksek iÅŸlem Ã¶nceliÄŸi | Etki yok | Normal bÄ±rakÄ±n |
| Ekran kartÄ± hÄ±z aÅŸÄ±rtma: Ã§ekirdek +400, bellek +2750, gÃ¼Ã§ %116 | **+%2,6** | KullanÄ±n. GÃ¼nlÃ¼k deÄŸer: +450 / +3000 / %116, Ã§Ã¶kme olursa +425 ([bÃ¶lÃ¼m 9](#9-ekran-kartÄ±-hÄ±z-aÅŸÄ±rtma)) |
| Ekran kartÄ± Ã§ekirdeÄŸi +400, +425 veya +450 (3172â€“3225 MHz) | Fark yok (Â±%0,3) | +425 aynÄ± FPS'i Ã§Ã¶kme sÄ±nÄ±rÄ±na daha fazla payla verir |
| YalnÄ±zca ekran kartÄ± belleÄŸi (+200'den +2750'ye) | +%0,2 | ZararsÄ±z. KazancÄ±n neredeyse tamamÄ± Ã§ekirdekten gelir. |
| Ekran kartÄ± Core Voltage %100 (Afterburner) | Etki yok. Saat aynÄ± kalÄ±rken +8 W. | VoltajÄ± 0 bÄ±rakÄ±n |
| Ekran kartÄ± undervolt (VF eÄŸrisi) | Fayda yok | KullanmayÄ±n |
| Resizable BAR, CS2 sÃ¼rÃ¼cÃ¼ profilinde aÃ§Ä±k | Etki yok (âˆ’%0,04) | SÃ¼rÃ¼cÃ¼ varsayÄ±lanÄ± (kapalÄ±) kalsÄ±n |
| CS2'yi Vulkan ile Ã§alÄ±ÅŸtÄ±rma (`-vulkan`) | **âˆ’%6** | DX11 (varsayÄ±lan) kalsÄ±n |
| `cs2.exe` iÃ§in tam ekran iyileÅŸtirmeleri kapalÄ± (Legacy Flip) | **+%1,13** (A-B-A ile doÄŸrulandÄ±). P1 ve gecikme aynÄ±. | KullanÄ±n ([bÃ¶lÃ¼m 8](#tam-ekran-iyileÅŸtirmelerini-kapatma-legacy-flip)) |
| NVIDIA Low Latency Mode | Burada Ã¶lÃ§Ã¼lmedi. DÄ±ÅŸ veride (cs2kitchen, tÄ±klama-ekran) etkisiz. | VarsayÄ±lan (kapalÄ±) kalsÄ±n |
| Ethernet Energy Efficient Ethernet kapalÄ± | Ã–lÃ§Ã¼lmedi | Ä°steÄŸe baÄŸlÄ± |

**Toplam (BIOS ve CPU 0, 19.10):** Ortalama FPS 911'den 970'e Ã§Ä±ktÄ± (**+%6,4**). Ortalama kare sÃ¼resi 1,10 ms'den 1,03 ms'ye dÃ¼ÅŸtÃ¼. P99 deÄŸeri 2,99 ms'den 2,80 ms'ye dÃ¼ÅŸtÃ¼.

**Toplam (Windows ve ekran kartÄ±, 23.10):** AynÄ± BIOS ayarlarÄ±yla, CPU 0 dÄ±ÅŸlama ve ekran kartÄ± hÄ±z aÅŸÄ±rtmasÄ± birlikte ortalama FPS'i 926,8'den 971,4'e Ã§Ä±kardÄ± (**+%4,8**). Ekran kartÄ±nÄ±n payÄ± +%2,6, CPU 0 dÄ±ÅŸlamanÄ±n payÄ± +%2,2'dir. Ã–lÃ§Ã¼m iki ayrÄ± CS2 oturumunda ters sÄ±rayla yapÄ±ldÄ±. DÃ¶rt alt karÅŸÄ±laÅŸtÄ±rmanÄ±n hepsi aynÄ± yÃ¶nÃ¼ gÃ¶sterdi.

Ä°ki toplamÄ± birbirine eklemeyin. Ä°kisi de CPU 0 adÄ±mÄ±nÄ± iÃ§erir. AyrÄ±ca iki Ã¶lÃ§Ã¼m arasÄ±nda CS2 gÃ¼ncellendi.

Oturumlar arasÄ± sapma Â±%0,6'dÄ±r. Bu nedenle BIOS toplamÄ±nÄ± **yaklaÅŸÄ±k %6 Â± 0,6** olarak okuyun.

**DarboÄŸaz:**
- **Ä°ÅŸlemci:** CS2 sÄ±rasÄ±nda tÃ¼m Ã§ekirdekler 5425 MHz'de Ã§alÄ±ÅŸtÄ±. GÃ¼Ã§ sÄ±nÄ±rÄ±nÄ±n yalnÄ±zca %7,5'ini kullandÄ±. SÄ±caklÄ±k en fazla 60 Â°C oldu. Bu nedenle Curve Optimizer, PBO limitleri ve sÄ±caklÄ±k ayarlarÄ± ek kazanÃ§ saÄŸlamadÄ±.
- **Ekran kartÄ±:** PresentMon'a gÃ¶re kare sÃ¼resinin (~1,07 ms) ~0,98 ms'inde GPU meÅŸguldÃ¼r. CPU, kare baÅŸÄ±na ~0,37 ms GPU'yu bekler. Ama GPU sÃ¼resinin yalnÄ±zca ~%20'si Ã§ekirdek saatiyle Ã¶lÃ§eklenir: GPU saati %12 dÃ¼ÅŸÃ¼nce FPS %2,8 dÃ¼ÅŸtÃ¼, 3170 MHz'in Ã¼stÃ¼nde kazanÃ§ Ã¶lÃ§Ã¼lemez. Bellek saati, Core Voltage, Resizable BAR ve Vulkan da bu sabit kÄ±smÄ± kÃ¼Ã§Ã¼ltmedi.
- **P1:** HiÃ§bir Windows veya ekran kartÄ± ayarÄ± P1 deÄŸerini Ã¶lÃ§Ã¼lebilir ÅŸekilde deÄŸiÅŸtirmedi. P1 deÄŸerinin koÅŸudan koÅŸuya sapmasÄ± Â±%5'tir.

---

## 2. Sistem

| ParÃ§a | DeÄŸer |
|---|---|
| Ä°ÅŸlemci | AMD Ryzen 7 9800X3D (8 Ã§ekirdek, 16 thread, tek CCD, 3D V-Cache) |
| Anakart | ASUS ROG STRIX X870-A GAMING WIFI |
| BIOS | 2503 (2402 sÃ¼rÃ¼mÃ¼nden gÃ¼ncellendi) |
| Bellek | G.Skill F5-8000J4048F24GX2-TZ5RK, 2 Ã— 24 GB, SK Hynix M-die, tek rank, A2 ve B2 yuvalarÄ± |
| Ekran kartÄ± | GIGABYTE GeForce RTX 5070 Ti AERO OC 16G |
| Ekran | Alienware AW2523HF, 1920Ã—1080, 360 Hz, DisplayPort |
| SoÄŸutucu | Arctic Liquid Freezer III Pro 360 |
| Depolama | Samsung 980 PRO 500 GB |
| Ä°ÅŸletim sistemi | Windows 11 Pro, derleme 26300 |
| Ekran kartÄ± sÃ¼rÃ¼cÃ¼sÃ¼ | NVIDIA 617.42 |
| Ekran kartÄ± ayar aracÄ± | MSI Afterburner 4.6.6 |
| AÄŸ baÄŸdaÅŸtÄ±rÄ±cÄ±sÄ± | Intel I226-V, 2,5 Gbps |
| Fare | 8000 Hz yoklama hÄ±zÄ±, kablosuz alÄ±cÄ± |

---

## 3. BaÅŸlamadan Ã¶nce

### BIOS gÃ¼ncellemesinden Ã¶nce

1. Mevcut ayarlarÄ± profile kaydedin.
   - **Tool â†’ ASUS User Profile â†’ Save to Profile** seÃ§in ve bir yuva seÃ§in.
   - **Load/Save Profile from/to USB Drive** seÃ§eneÄŸiyle profili USB belleÄŸe de kaydedin.
   - Profil dosyalarÄ± genellikle baÅŸka bir BIOS sÃ¼rÃ¼mÃ¼ne yÃ¼klenemez. Bu rehberdeki adÄ±mlarÄ± da yedek olarak saklayÄ±n.
2. Ä°steÄŸe baÄŸlÄ±: YÃ¶netici PowerShell ile BIOS gÃ¶rÃ¼ntÃ¼sÃ¼ alÄ±n.

   ```powershell
   .\nvram\nvram_snap.ps1 -OutDir .\snap_guncelleme_oncesi -Label "guncelleme oncesi"
   ```

3. BitLocker kullanÄ±yorsanÄ±z kurtarma anahtarÄ±nÄ± hazÄ±r tutun. BIOS gÃ¼ncellemesi fTPM'i sÄ±fÄ±rlarsa Windows kurtarma anahtarÄ± ister.

### BIOS gÃ¼ncellemesinden veya CMOS sÄ±fÄ±rlamasÄ±ndan sonra

- AdÄ±mlarÄ± sÄ±rayla uygulayÄ±n: Ã¶nce RAM, sonra iÅŸlemci, sonra gÃ¼venlik.
- Her bÃ¼yÃ¼k adÄ±mdan sonra kaydedin ve yeniden baÅŸlatÄ±n (**F10**).
- Son olarak kontrol betiÄŸini Ã§alÄ±ÅŸtÄ±rÄ±n ([bÃ¶lÃ¼m 11](#11-kontrol)).

---

## 4. BIOS: RAM

Bu bÃ¶lÃ¼mÃ¼ ilk olarak uygulayÄ±n.

**Ai Tweaker**

| Ayar | DeÄŸer |
|---|---|
| Ai Overclock Tuner | Manual |
| Memory Frequency | DDR5-8000 |
| FCLK Frequency | 2200 MHz. AMD Overclocking menÃ¼sÃ¼ndeki deÄŸer de 2200 olmalÄ±dÄ±r (aÅŸaÄŸÄ±daki nota bakÄ±n). |
| High DRAM Voltage Mode | Enabled. 1,435 V Ã¼stÃ¼ DRAM voltajÄ± iÃ§in gerekir. |
| DRAM VDD Voltage | 1.600 |
| DRAM VDDQ Voltage | 1.600 |

> **FCLK iki menÃ¼de ayarlanÄ±r:**
> 1. **Ai Tweaker â†’ FCLK Frequency**
> 2. **Advanced â†’ AMD Overclocking â†’ DDR and Infinity Fabric Frequency/Timings â†’ Infinity Fabric Frequency and Dividers â†’ Infinity Fabric Frequency**
>
> Ä°kinci deÄŸer sabit bir sayÄ±daysa Ai Tweaker deÄŸeri uygulanmaz. Bu sistemde ikinci deÄŸer, AMD Overclocking menÃ¼sÃ¼nde PBO ayarlanÄ±rken 2000'e sabitlendi. Ai Tweaker 2200 olduÄŸu halde gerÃ§ek FCLK 2000 kaldÄ±. Ä°ki deÄŸeri aynÄ± yapÄ±n. GerÃ§ek deÄŸeri HWiNFO'da **Infinity Fabric Clock (FCLK)** satÄ±rÄ±nda kontrol edin.
>
> FCLK 2000'den 2200'e Ã§Ä±kÄ±nca ortalama FPS +%0,23 arttÄ± (aynÄ± gÃ¼n, aynÄ± diÄŸer ayarlar, 6 koÅŸu). Bu fark oturum sapmasÄ±nÄ±n iÃ§indedir. P1, CPU Busy ve GPU Busy deÄŸiÅŸmedi. WHEA hatasÄ± olmadÄ±.

**Ai Tweaker â†’ DRAM Timing Control**

| Ayar | DeÄŸer | Ayar | DeÄŸer |
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

| Ayar | DeÄŸer |
|---|---|
| Memory Context Restore | Enabled. Her aÃ§Ä±lÄ±ÅŸta bellek eÄŸitimi tekrarlanmaz. |
| Power Down Enable | Disabled |
| Gear Down Mode | Enabled |
| Bank Refresh Mode | Mixed (REFab/REFsb) |
| UCLK DIV1 MODE | Auto. 8000 MT/s deÄŸerinde UCLK = MEMCLK/2 olur. |
| DDR5 Nitro Mode | Auto. **Enabled yapmayÄ±n.** 1-3-1 ayarÄ± Avg FPS deÄŸerini %1,4 dÃ¼ÅŸÃ¼rdÃ¼. |
| DiÄŸer tÃ¼m ayarlar (RTT/ODT, sÃ¼rÃ¼cÃ¼ direnÃ§leri, VDDIO, SOC) | Auto |

**Kaydedin ve yeniden baÅŸlatÄ±n.** Ä°lk aÃ§Ä±lÄ±ÅŸta bellek eÄŸitimi birkaÃ§ dakika sÃ¼rebilir. Ekran gÃ¶rÃ¼nmeden kapatmayÄ±n.

**Bu kitin sÄ±nÄ±rlarÄ±:**
- **Twr:** BIOS, 8000 MT/s deÄŸerinde 48'in altÄ±nÄ± kabul etmez.
- **TwtrL:** 14 deÄŸerinde aÃ§Ä±lmadÄ±.
- **Trcd ve Trp:** 44 deÄŸerinde aÃ§Ä±lmadÄ±.

**Auto olarak bÄ±rakÄ±lan voltajlar** (CS2 yÃ¼kÃ¼ altÄ±nda Ã¶lÃ§Ã¼ldÃ¼):

| Hat | DeÄŸer |
|---|---|
| CPU SOC | 1,29 V |
| CPU VDDIO / MC | 1,46 V |
| CPU VDD_MISC | 1,10 V |
| DRAM VDD ve VDDQ | 1,60 V |

**Windows'ta kontrol:** GÃ¶rev YÃ¶neticisi â†’ Performans â†’ Bellek bÃ¶lÃ¼mÃ¼nde hÄ±z **8000 MT/s** olmalÄ±dÄ±r. HWiNFO'da FCLK **2200 MHz**, UCLK **2000 MHz** olmalÄ±dÄ±r. Olay GÃ¶rÃ¼ntÃ¼leyicisi'nde WHEA hatasÄ± olmamalÄ±dÄ±r.

---

## 5. BIOS: Ä°ÅŸlemci

**Advanced â†’ AMD Overclocking â†’ Precision Boost Overdrive** yolunu izleyin. MenÃ¼ye girerken Ã§Ä±kan uyarÄ±yÄ± kabul edin.

| Ayar | DeÄŸer |
|---|---|
| Precision Boost Overdrive | Advanced |
| PBO Limits | Motherboard |
| CPU Boost Clock Override | Enabled (Positive) |
| Max CPU Boost Clock Override(+) | 200. Bu deÄŸer 9800X3D iÃ§in kullanÄ±ldÄ±. Saat tavanÄ± 5,2 GHz'den 5,425 GHz'e Ã§Ä±ktÄ±. |

**Precision Boost Overdrive â†’ Curve Optimizer**

| Ayar | DeÄŸer |
|---|---|
| Curve Optimizer | All Cores |
| All Core Curve Optimizer Sign | Negative |
| All Core Curve Optimizer Magnitude | 10. Etkisi Ã¶lÃ§Ã¼lmedi. ZararsÄ±zdÄ±r. Ä°sterseniz Auto bÄ±rakÄ±n. |

**Ai Tweaker**

| Ayar | DeÄŸer |
|---|---|
| Core tunings Configuration for gaming | Level 2. Etkisi doÄŸrulanmadÄ±. ZararsÄ±zdÄ±r. Ä°sterseniz Auto bÄ±rakÄ±n. |

**Notlar:**
- AMD Overclocking menÃ¼sÃ¼, kullanÄ±lan BIOS ayar sÃ¶zlÃ¼ÄŸÃ¼nde yoktur. MenÃ¼ yolu ekran gÃ¶rÃ¼ntÃ¼lerinden ve NVRAM farkÄ±ndan Ã§Ä±karÄ±ldÄ±.
- AynÄ± PBO ayarlarÄ± **Ai Tweaker â†’ Precision Boost Overdrive** altÄ±nda da bulunur. Bu kurulumda bu ayarlar Auto olarak bÄ±rakÄ±ldÄ±.

---

## 6. BIOS: Auto olarak kalacak ayarlar

Bu ayarlar denendi. Fayda saÄŸlamadÄ±lar veya zarar verdiler. Auto olarak bÄ±rakÄ±n.

| MenÃ¼ | Ayar | DeÄŸer | Neden |
|---|---|---|---|
| AMD Overclocking / DRAM Timing Control | DDR5 Nitro Mode | Auto | 1-3-1 ayarÄ± Avg FPS'i %1,4 dÃ¼ÅŸÃ¼rdÃ¼ |
| Advanced â†’ AMD CBS â†’ CPU Common Options | Latency Under Load | Auto | Ã–lÃ§Ã¼lebilir etki yok |
| Ai Tweaker â†’ Precision Boost Overdrive | Medium Load Boostit | Auto | Ã–lÃ§Ã¼lebilir etki yok |
| Ai Tweaker â†’ DIGI + VRM | CPU Load-line Calibration | Auto | Ã–lÃ§Ã¼lebilir etki yok. LLC 6 ile sapma iÃ§inde kaldÄ±. |
| Advanced â†’ AMD CBS | SMT Control | Auto | KapatmanÄ±n etkisi yok. KapatÄ±lÄ±rsa tam kapatma ve aÃ§ma gerekir. |
| Advanced â†’ AMD CBS | Global C-state Control | Auto veya Enabled | Enabled, aÅŸaÄŸÄ±daki iki ayarla birlikte Ã¶lÃ§Ã¼ldÃ¼: etki yok. Bu sistemde Enabled. |
| Advanced â†’ AMD CBS â†’ CPU Common Options | Power Supply Idle Control | Auto veya Typical Current Idle | AynÄ± Ã¶lÃ§Ã¼m: etki yok. Bu sistemde Typical Current Idle. |
| Advanced â†’ NB Configuration | Integrated Graphics | Auto veya Disabled | AynÄ± Ã¶lÃ§Ã¼m: etki yok. Bu sistemde Disabled. |
| Ai Tweaker | AI Cache Boost | Auto | ASUS'a gÃ¶re AI araÃ§larÄ± iÃ§indir |
| Ai Tweaker | Turbo Game Mode, Gaming Adaptive CCD Parker | Disabled | Ã‡ift CCD'li iÅŸlemciler iÃ§indir. 9800X3D tek CCD'lidir. |
| Ai Tweaker â†’ Precision Boost Overdrive | Thermal Limit | VarsayÄ±lan (Level 2, 80 Â°C) | Ä°ÅŸlemci CS2'de en fazla 60 Â°C olur. |

---

## 7. BIOS: FACEIT ve gÃ¼venlik

FACEIT ÅŸu ayarlarÄ± denetler: Secure Boot, TPM 2.0, IOMMU ve Bellek BÃ¼tÃ¼nlÃ¼ÄŸÃ¼ (HVCI/VBS). BIOS gÃ¼ncellemesi bu ayarlarÄ± varsayÄ±lana dÃ¶ndÃ¼rebilir. GÃ¼ncellemeden sonra kontrol edin.

| MenÃ¼ | Ayar | DeÄŸer |
|---|---|---|
| Boot â†’ Secure Boot | OS Type | Windows UEFI mode |
| Boot â†’ Secure Boot â†’ Key Management | Install Default Secure Boot Keys | Secure Boot "Disabled" veya anahtar yok gÃ¶rÃ¼nÃ¼yorsa Ã§alÄ±ÅŸtÄ±rÄ±n |
| Boot â†’ CSM | Launch CSM | Disabled |
| Advanced â†’ AMD fTPM configuration | Firmware TPM switch | Enable Firmware TPM |
| Advanced â†’ CPU Configuration | SVM Mode | Enabled. VBS ve HVCI iÃ§in gerekir. |
| Advanced â†’ AMD CBS | IOMMU | Auto |
| Advanced â†’ PCI Subsystem Settings | Above 4G Decoding / Resize BAR | Enabled / Enabled |

---

## 8. Windows ve CS2 ayarlarÄ±

### Windows

| Ayar | DeÄŸer | Not |
|---|---|---|
| DonanÄ±m hÄ±zlandÄ±rmalÄ± GPU zamanlamasÄ± (HAGS) | AÃ§Ä±k | Ayarlar â†’ Sistem â†’ Ekran â†’ Grafik |
| CS2'yi CPU 0 dÄ±ÅŸÄ±nda Ã§alÄ±ÅŸtÄ±rma | UygulayÄ±n | AÅŸaÄŸÄ±daki adÄ±mlar. Ã–lÃ§Ã¼len kazanÃ§ +%1,8 ile +%2,5. |
| Ä°ÅŸlem Ã¶nceliÄŸi | Normal | YÃ¼ksek Ã¶ncelik denendi. Etkisi yok. |
| Bellek BÃ¼tÃ¼nlÃ¼ÄŸÃ¼ (HVCI) | AÃ§Ä±k | FACEIT iÃ§in gerekir. |
| Oyun Modu | KapalÄ± | Test edilmedi. |
| Ethernet: Energy Efficient Ethernet | KapalÄ± | AygÄ±t YÃ¶neticisi â†’ aÄŸ baÄŸdaÅŸtÄ±rÄ±cÄ±sÄ± â†’ GeliÅŸmiÅŸ. Etkisi Ã¶lÃ§Ã¼lmedi. BaÄŸlantÄ± kÄ±sa bir sÃ¼re kopar. |
| Win32PrioritySeparation | VarsayÄ±lan (2) | DeÄŸiÅŸtirmeyin. AyrÄ±ntÄ± aÅŸaÄŸÄ±da. |
| Kesme yerleÅŸimi (Interrupt Affinity) | VarsayÄ±lan | DeÄŸiÅŸtirmeyin. GPU ve USB DPC iÅŸi zaten CPU 0'da Ã§alÄ±ÅŸÄ±r. |
| Tam ekran iyileÅŸtirmeleri (yalnÄ±zca `cs2.exe`) | KapalÄ± (Legacy Flip) | AÅŸaÄŸÄ±daki adÄ±mlar. Ã–lÃ§Ã¼len kazanÃ§ +%1,13. |
| GÃ¼Ã§ planÄ± | En az iÅŸlemci durumu %100, Ã§ekirdek park etme kapalÄ± | DeÄŸiÅŸiklik Ã¶lÃ§Ã¼lmedi. |

### CS2'yi CPU 0 dÄ±ÅŸÄ±nda Ã§alÄ±ÅŸtÄ±rma

Bu adÄ±mÄ± her Steam aÃ§Ä±lÄ±ÅŸÄ±nda tekrarlayÄ±n.

1. Steam aÃ§Ä±kken GÃ¶rev YÃ¶neticisi'nde **AyrÄ±ntÄ±lar** sekmesini aÃ§Ä±n.
2. `steam.exe` satÄ±rÄ±na saÄŸ tÄ±klayÄ±n ve **BenzeÅŸimi ayarla** seÃ§in.
3. **CPU 0** kutusunun iÅŸaretini kaldÄ±rÄ±n ve **Tamam** seÃ§in.
4. CS2'yi Steam'den baÅŸlatÄ±n. CS2 bu ayarÄ± Steam'den devralÄ±r. `cs2.exe` dosyasÄ±na ayrÄ±ca dokunmanÄ±z gerekmez.

CS2'yi NVIDIA App ile baÅŸlatÄ±rsanÄ±z CS2 yine `steam.exe` altÄ±nda aÃ§Ä±lÄ±r ve ayarÄ± devralÄ±r. Bu durum denendi ve doÄŸrulandÄ±.

### CPU 0 neden Ã¶nemlidir

`windows/irq_sample.ps1` ile CPU baÅŸÄ±na kesme ve DPC sayÄ±sÄ± Ã¶lÃ§Ã¼ldÃ¼:

- CS2 benchmark sÄ±rasÄ±nda saniyede yaklaÅŸÄ±k 9700 DPC oluÅŸtu. BunlarÄ±n %99'dan fazlasÄ± CPU 0'da Ã§alÄ±ÅŸtÄ±.
- CPU 0 zamanÄ±nÄ±n yaklaÅŸÄ±k %24'Ã¼ kesme ve DPC iÅŸine gitti.
- Fare hareket edince (8000 Hz) saniyede yaklaÅŸÄ±k 4300 ek DPC oluÅŸtu. BunlarÄ±n hepsi CPU 0'da Ã§alÄ±ÅŸtÄ±.
- DiÄŸer Ã§ekirdeklerde DPC yok denecek kadar azdÄ±.

Windows, GPU ve USB iÅŸini zaten CPU 0'da Ã§alÄ±ÅŸtÄ±rÄ±r. Bu nedenle kesmeleri kayÄ±t defteriyle CPU 0'a baÄŸlamak yeni bir ÅŸey deÄŸiÅŸtirmez. CS2'yi CPU 0'dan uzak tutmak, bu iÅŸi oyundan ayÄ±rÄ±r.

**DPC ve kesme sÃ¼releri** (`windows/dpc_lat.ps1`, LatencyMon'un Ã¶lÃ§tÃ¼ÄŸÃ¼ deÄŸerler, kurulum gerekmez):

| Durum | DPC/sn | En uzun DPC | En uzun kesme | 500 Âµs Ã¼stÃ¼ | CPU 0 zamanÄ± |
|---|---|---|---|---|---|
| BoÅŸta, 60 sn | 1859 | 131 Âµs (nvlddmkm) | 72 Âµs | 0 | %2,4 |
| CS2 benchmark | 9754 | 395 Âµs (nvlddmkm, dxgkrnl) | 156 Âµs | 0 | %23,2 |

- SÃ¼rÃ¼cÃ¼ gecikmesi temizdir. En uzun DPC 500 Âµs sÄ±nÄ±rÄ±nÄ±n altÄ±ndadÄ±r.
- CS2 sÄ±rasÄ±nda CPU 0 zamanÄ±nÄ±n %23'Ã¼ ekran kartÄ± DPC ve kesmelerine gider. DiÄŸer Ã§ekirdeklerde bu oran ~%0'dÄ±r.
- Kesmeleri baÅŸka bir Ã§ekirdeÄŸe taÅŸÄ±mayÄ±n. Bu iÅŸ o zaman CS2'nin Ã§ekirdeklerine biner.

### Tam ekran iyileÅŸtirmelerini kapatma (Legacy Flip)

Windows, tam ekran oyunlarÄ± varsayÄ±lan olarak "Independent Flip" kipinde sunar. Tam ekran iyileÅŸtirmeleri (FSO) kapatÄ±lÄ±nca CS2 "Legacy Flip" kipine geÃ§er (gerÃ§ek tam ekran).

1. CS2'yi kapatÄ±n.
2. `...\Counter-Strike Global Offensive\game\bin\win64\cs2.exe` dosyasÄ±na saÄŸ tÄ±klayÄ±n. **Ã–zellikler â†’ Uyumluluk** seÃ§in.
3. **Tam ekran iyileÅŸtirmelerini devre dÄ±ÅŸÄ± bÄ±rak** kutusunu iÅŸaretleyin ve **Tamam** seÃ§in.
4. CS2'yi yeniden aÃ§Ä±n.

AynÄ± ayar kayÄ±t defterinde ÅŸu deÄŸerdir: `HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers`, ad = `cs2.exe` dosyasÄ±nÄ±n tam yolu, deÄŸer = `~ DISABLEDXMAXIMIZEDWINDOWEDMODE`. Geri almak iÃ§in kutunun iÅŸaretini kaldÄ±rÄ±n.

**Kontrol:** PresentMon'da `PresentMode` sÃ¼tunu **Hardware: Legacy Flip** gÃ¶stermelidir. VarsayÄ±lan durumda **Hardware: Independent Flip** gÃ¶sterir.

**Ã–lÃ§Ã¼m** (Ã¼Ã§ taze CS2 oturumu, A-B-A sÄ±rasÄ±yla, her biri 6 koÅŸu, GPU +425, CPU 0 hariÃ§):

| | A: Independent Flip | B: Legacy Flip (FSO kapalÄ±) | A': Independent Flip (tekrar) |
|---|---|---|---|
| Ortalama FPS (VProf, 6 koÅŸu) | 982,7 | **994,9** | 985,0 |
| P1 (VProf) | 346,5 | 348,4 | 346,6 |
| Kare baÅŸlangÄ±cÄ±ndan ekrana (PresentMon, ortalama / p99) | 1,94 / 3,66 ms | 1,95 / 3,57 ms | 1,93 / 3,63 ms |
| GPU meÅŸgul sÃ¼resi | 0,96 ms | 0,95 ms | 0,96 ms |

- AynÄ± ayarda iki oturum arasÄ±ndaki fark (A' âˆ’ A) %0,23'tÃ¼r.
- Legacy Flip, iki Independent Flip oturumunun ortalamasÄ±ndan **%1,13** yÃ¼ksektir. 6 sÄ±ra konumunun 6'sÄ±nda yÃ¼ksektir.
- P1 ve gecikme deÄŸiÅŸmez.
- Independent Flip'te CPU her karede ~0,40 ms `Present` Ã§aÄŸrÄ±sÄ±nda bekler. Legacy Flip'te bu bekleme yoktur.
- **Yan etki:** Alt-Tab sÄ±rasÄ±nda ekran kipi deÄŸiÅŸir ve ekran kÄ±sa bir sÃ¼re kararÄ±r. BazÄ± bindirmeler ve bildirimler oyunun Ã¼stÃ¼nde gÃ¶rÃ¼nmeyebilir.
- SonuÃ§ sisteme gÃ¶re deÄŸiÅŸebilir. Ä°ki kipi kendi sisteminizde deneyin.

### Win32PrioritySeparation

Bu sistemde (Windows 11, derleme 26300) varsayÄ±lan deÄŸer 2'dir. Ã–lÃ§Ã¼m ÅŸunu gÃ¶sterdi: Ã–n plandaki uygulamanÄ±n iÅŸ parÃ§acÄ±klarÄ±nÄ±n Ã¶nceliÄŸi 8'den 10'a Ã§Ä±kar. AynÄ± Ã§ekirdeÄŸi paylaÅŸan Ã¶n plan uygulamasÄ± zamanÄ±n %99'unu alÄ±r, arka plan uygulamasÄ± %1'ini alÄ±r.

Ä°nternette Ã¶nerilen 0x2A deÄŸeri sabit zaman dilimi seÃ§er. Bu deÄŸer burada Ã¶lÃ§Ã¼lmedi. AynÄ± iÅŸlemci ve ekran kartÄ±yla yapÄ±lan bir dÄ±ÅŸ veri setinde (cs2kitchen/cs2FpsBoostReal) bu ayarÄ±n etkisi Ã¶lÃ§Ã¼m sapmasÄ±nÄ±n iÃ§inde kaldÄ±. VarsayÄ±lan deÄŸeri deÄŸiÅŸtirmeyin.

**KalÄ±cÄ± yol (denenmedi):** Steam'i ÅŸu komutla baÅŸlatabilirsiniz:

```
cmd /c start "" /affinity FFFE "C:\Program Files (x86)\Steam\steam.exe"
```

FACEIT'in bu yÃ¶ntemle ilgili resmi bir aÃ§Ä±klamasÄ± yoktur.

### CS2 oyun iÃ§i ayarlarÄ±

Ã–lÃ§Ã¼mler sÄ±rasÄ±nda bu ayarlar sabit tutuldu. Kaynak: `cs2_video.txt`.

| Ayar | DeÄŸer |
|---|---|
| Ã‡Ã¶zÃ¼nÃ¼rlÃ¼k | 1280 Ã— 960 (4:3), tam ekran |
| Yenileme hÄ±zÄ± | 360 Hz |
| V-Sync | KapalÄ± |
| `fps_max` | 0 (sÄ±nÄ±rsÄ±z) |
| MSAA | 2x |
| Anizotropik filtre | 16x |
| GÃ¶lge ve doku kalitesi | DÃ¼ÅŸÃ¼k |
| Dinamik gÃ¶lgeler | TÃ¼mÃ¼ |
| ParÃ§acÄ±k ve ortam aydÄ±nlatmasÄ± | DÃ¼ÅŸÃ¼k veya kapalÄ± |
| FSR | KapalÄ± |
| NVIDIA Reflex | KapalÄ± |
| BaÅŸlatma seÃ§enekleri | `+exec crosshair.cfg -condebug` |

`-condebug` seÃ§eneÄŸi, VProf sonuÃ§larÄ±nÄ±n `console.log` dosyasÄ±na yazÄ±lmasÄ± iÃ§in gerekir.

### FACEIT nedeniyle deÄŸiÅŸtirilmeyen ayarlar

Ã–lÃ§Ã¼m sÄ±rasÄ±nda bu ayarlara dokunulmadÄ±: Secure Boot, CSM, Firmware TPM, IOMMU, SVM, DMA korumasÄ±, Pluton, VBS/HVCI ve Windows Update.

### Fan ve pompa (isteÄŸe baÄŸlÄ±)

Fan ayarlarÄ± performans Ã¶lÃ§Ã¼mÃ¼nÃ¼n parÃ§asÄ± deÄŸildir.

- **CPU ve kasa fanÄ±:** PWM Mode, Manual eÄŸri. 20, 30, 40, 50, 60, 67, 70 ve 100 Â°C noktalarÄ±nda %20, 26, 34, 45, 60, 80, 100 ve 100.
- **AIO pompa:** PWM Mode, Manual eÄŸri. 30, 40, 50, 58, 65, 70, 85 ve 100 Â°C noktalarÄ±nda %20, 20, 36, 52, 68, 84, 100 ve 100.
- **Ã–lÃ§Ã¼len pompa devri:** BoÅŸta yaklaÅŸÄ±k 1240 rpm. Tam hÄ±zda yaklaÅŸÄ±k 2780 rpm.

---

## 9. Ekran kartÄ± hÄ±z aÅŸÄ±rtma

Kart: GIGABYTE RTX 5070 Ti AERO OC 16G. Her kart farklÄ±dÄ±r. Bu deÄŸerleri doÄŸrudan kopyalamayÄ±n. Kendi sÄ±nÄ±rÄ±nÄ±zÄ± aÅŸaÄŸÄ±daki yÃ¶ntemle bulun.

### GÃ¼nlÃ¼k ayar (MSI Afterburner, Profil 1)

| Ayar | DeÄŸer |
|---|---|
| Core Voltage | 0. DeÄŸiÅŸtirmeyin. |
| Power Limit | %116 (350 W, kartÄ±n en yÃ¼ksek deÄŸeri) |
| Core Clock | +450 MHz. Bir sÃ¼rÃ¼cÃ¼ hatasÄ± daha olursa +425 yapÄ±n. |
| Memory Clock | +3000 MHz. SÃ¼rÃ¼cÃ¼nÃ¼n izin verdiÄŸi en yÃ¼ksek deÄŸerdir. |
| Fan | Otomatik (kartÄ±n kendi eÄŸrisi) |

Afterburner'da yalnÄ±zca bu profil vardÄ±r (yuva 1). DiÄŸer yuvalar boÅŸtur.

CS2 yÃ¼kÃ¼nde Ã§ekirdek yaklaÅŸÄ±k 3225 MHz'de Ã§alÄ±ÅŸÄ±r (stok 2775 MHz). Bellek 17001 MHz'de Ã§alÄ±ÅŸÄ±r (stok 14001 MHz, 28 Gbps yerine 34 Gbps). CS2'de gÃ¼Ã§ yaklaÅŸÄ±k 155 W'tÄ±r. GÃ¼Ã§ sÄ±nÄ±rÄ±na ulaÅŸÄ±lmaz.

**+450 ve +425:** +450 aÅŸaÄŸÄ±daki stres testlerinin hepsini geÃ§ti ve yaklaÅŸÄ±k 2 saat CS2'de sorun Ã§Ä±karmadÄ±. Ama 24.10'da bir CS2 benchmark koÅŸusunda bir kez sÃ¼rÃ¼cÃ¼ hatasÄ± verdi (`nvlddmkm` 153, CS2 dondu). Bu oturum, shader Ã¶nbelleÄŸi temizlendikten sonraki ilk CS2 oturumuydu. +450'de saat anlÄ±k olarak 3247â€“3255 MHz'e Ã§Ä±kar. Bu, Ã¶lÃ§Ã¼len Ã§Ã¶kme sÄ±nÄ±rÄ±na (3247â€“3250 MHz) eÅŸittir. +425'te anlÄ±k en yÃ¼ksek deÄŸer 3202â€“3225 MHz'tir. CS2, +400, +425 ve +450 ile aynÄ± FPS'i verdi. SÃ¼rÃ¼cÃ¼ hatasÄ± tekrar ederse +425'e dÃ¼ÅŸÃ¼n. FPS kaybÄ± olmaz.

**CS2'nin Ã§alÄ±ÅŸtÄ±ÄŸÄ± frekans stres testlerinden yÃ¼ksektir.** CS2 hafif bir yÃ¼ktÃ¼r. Kart V/F eÄŸrisinin en Ã¼st noktasÄ±nda Ã§alÄ±ÅŸÄ±r. +450 ile CS2'de 3225 MHz, OCCT'nin hafif fazÄ±nda 3210 MHz, Kombustor'da 3172 MHz Ã¶lÃ§Ã¼ldÃ¼. GÃ¼nlÃ¼k deÄŸeri seÃ§erken CS2'deki saati Ã§Ã¶kme sÄ±nÄ±rÄ±yla karÅŸÄ±laÅŸtÄ±rÄ±n.

### Uygulama

1. NVIDIA App â†’ **Sistem â†’ Performans** bÃ¶lÃ¼mÃ¼nde **Otomatik Ayarlama** aÃ§Ä±ksa kapatÄ±n ve **GERÄ° YÃœKLE** seÃ§in. Ä°ki araÃ§ aynÄ± anda ofset yazmamalÄ±dÄ±r.
2. MSI Afterburner'Ä± MSI'nin resmi sitesinden kurun. Kurulumda Norton seÃ§eneÄŸinin iÅŸaretini kaldÄ±rÄ±n. RivaTuner Statistics Server gerekmez.
3. Power Limit, Core Clock ve Memory Clock deÄŸerlerini girin ve **Apply** seÃ§in.
4. **Save** seÃ§in ve **1** yuvasÄ±na kaydedin. Kilit simgesiyle profilleri kilitleyin. Kilit yalnÄ±zca kaydetmeyi engeller. Profili yÃ¼klemeyi engellemez.
5. Her Windows aÃ§Ä±lÄ±ÅŸÄ±nda Afterburner'Ä± aÃ§Ä±n ve **1** seÃ§in. Afterburner'Ä±n kendi aÃ§Ä±lÄ±ÅŸta uygulama ayarÄ± bu sistemde yeniden baÅŸlatmadan sonra deÄŸerleri uygulamadÄ±. `MSIAfterburner.exe -Profile1` komutu Ã§alÄ±ÅŸÄ±r.
6. Kontrol: Afterburner'da +450, +3000 ve 116 gÃ¶rÃ¼nmelidir. `nvidia-smi` gÃ¼Ã§ sÄ±nÄ±rÄ±nÄ± 350 W gÃ¶stermelidir.

Afterburner'Ä±n RTCore64 sÃ¼rÃ¼cÃ¼sÃ¼, Bellek BÃ¼tÃ¼nlÃ¼ÄŸÃ¼ (HVCI) aÃ§Ä±kken yÃ¼klendi. Secure Boot, TPM ve HVCI ayarlarÄ± deÄŸiÅŸmedi.

### CS2 etkisi

| KarÅŸÄ±laÅŸtÄ±rma | Ortalama FPS | YÃ¶ntem |
|---|---|---|
| Stok â†’ +400 / +2750 / %116 | **+%2,6** | 2Ã—2, iki oturum, ters sÄ±ra, hÃ¼cre baÅŸÄ±na 2 koÅŸu |
| Bellek +200 â†’ +2750 (Ã§ekirdek +400) | +%0,2 | AynÄ± oturum, ABBA |
| Bellek âˆ’1000 MHz (Ã§ekirdek stok) | âˆ’%0,2 (sapma iÃ§inde) | AynÄ± oturum, MNNM |
| Ã‡ekirdek +155 â†’ +300 | +%0,7 | AynÄ± oturum, 6 koÅŸu |
| Ã‡ekirdek +155 â†’ +450 | +%1,35 | AynÄ± oturum, tek koÅŸular |
| GPU saati 2930 â†’ 2572 MHz (âˆ’%12) | âˆ’%2,8 | AynÄ± oturum, ABBA, `nvidia-smi -lgc` |
| Maksimum voltaj %100 ve gÃ¼Ã§ %116 | Sapma iÃ§inde (saat +8 MHz) | AynÄ± oturum |

P1 deÄŸeri hiÃ§bir ekran kartÄ± ayarÄ±nda Ã¶lÃ§Ã¼lebilir ÅŸekilde deÄŸiÅŸmedi.

**AynÄ± CS2 oturumunda, sÄ±ra A B C D D C B A, HWiNFO ile efektif saat Ã¶lÃ§Ã¼mÃ¼:**

| Profil | Ortalama FPS | GPU saati (bildirilen / efektif) | Voltaj | GÃ¼Ã§ |
|---|---|---|---|---|
| +450 / +3000, voltaj 0 | 989,2 | 3225 / 3225 MHz | 1,010 V | 156 W |
| +425 / +3000, voltaj 0 | 990,8 | 3195 / 3195 MHz | 1,010 V | 151 W |
| +400 / +3000, voltaj 0 | 990,1 | 3172 / 3169 MHz | 1,010 V | 152 W |
| +400 / +3000, voltaj %100 | 991,5 | 3225 / 3221 MHz | 1,025 V | 160 W |

- Fark Ã¶lÃ§Ã¼m sapmasÄ±nÄ±n iÃ§indedir (Â±3 FPS).
- CS2'de efektif saat bildirilen saate eÅŸittir. Saat kÄ±rpÄ±lmasÄ± yoktur.
- Core Voltage %100, Crossbar ve System saatlerini ~%2 artÄ±rÄ±r (2302 â†’ 2347 MHz). FPS deÄŸiÅŸmez, gÃ¼Ã§ 8 W artar.

### Voltaj kilidini aÃ§mak (Core Voltage %100)

- AynÄ± ofsette voltaj 1,010'dan 1,030 V'a Ã§Ä±kar. Saat ~45 MHz artar.
- Ã‡Ã¶kme frekansÄ± deÄŸiÅŸmez. Superposition'da voltaj 0 ile 3225 MHz geÃ§ti, ~3250 MHz Ã§Ã¶ktÃ¼. Voltaj %100 ile 3232 MHz geÃ§ti, 3247 MHz Ã§Ã¶ktÃ¼.
- Bu kartÄ±n frekans sÄ±nÄ±rÄ± ~3240 MHz'dir ve voltaja baÄŸlÄ± deÄŸildir. Voltaj yalnÄ±zca Ä±sÄ± ve gÃ¼Ã§ ekler.

### Kendi sÄ±nÄ±rÄ±nÄ±zÄ± bulma

YÃ¶ntem, fpsheaven GPU hÄ±z aÅŸÄ±rtma rehberinin akÄ±ÅŸÄ±nÄ± izler. Ã–lÃ§Ã¼m aracÄ±: Unigine Superposition 1.1, 1080p Extreme.

1. Stok puanÄ± 2 veya 3 koÅŸu ile Ã¶lÃ§Ã¼n.
2. **Ã‡ekirdek:** Bellek 0 ve Power Limit en yÃ¼ksek deÄŸerde olsun. +200'den baÅŸlayÄ±n. 25 MHz adÄ±mlarla artÄ±rÄ±n.
3. Her adÄ±mÄ± 2 koÅŸu ile Ã¶lÃ§Ã¼n. Bu kartta puanlar aynÄ± saatte iki kÃ¼mede Ã§Ä±ktÄ± (yaklaÅŸÄ±k %4,5 fark).
4. Ã‡Ã¶kme (TDR) veya puan dÃ¼ÅŸÃ¼ÅŸÃ¼ gÃ¶rÃ¼rseniz durun. Son temiz deÄŸer sÄ±nÄ±rdÄ±r.
5. **Bellek:** Ã‡ekirdeÄŸi sabit tutun. +1000'den baÅŸlayÄ±n. 250 veya 500 MHz adÄ±mlarla artÄ±rÄ±n.
6. **GÃ¼nlÃ¼k deÄŸer:** SÄ±nÄ±rdan Ã§ekirdekte 25â€“50 MHz, bellekte 100â€“250 MHz geri gelin.
7. **DoÄŸrulama:** SÄ±rayla OCCT 3D Adaptive (Switch, %30/%100, 500 ms) 1 saat, MSI Kombustor PBR-Donut (artefakt tarayÄ±cÄ± aÃ§Ä±k) 1 saat, OCCT VRAM %98 ve CS2 Ã§alÄ±ÅŸtÄ±rÄ±n.

**Bu karttaki sÄ±nÄ±rlar:**

| Test | GeÃ§en en yÃ¼ksek deÄŸer | Ã‡Ã¶ken deÄŸer |
|---|---|---|
| Superposition (sabit yÃ¼k) | +500 / +3000 | +525 / +3000 |
| Superposition, Core Voltage %100 | +450 / +3000 (3232 MHz) | +475 / +3000 (3247 MHz) |
| OCCT 3D Adaptive Switch (yÃ¼k geÃ§iÅŸi) | +450 / +3000, 1 saat | +475 / +3000, 4. dakikada |
| CS2 benchmark (kÄ±sa koÅŸu) | +450 / +200 | +500 / +200, harita yÃ¼klenirken |

YÃ¼k geÃ§iÅŸi, sabit yÃ¼kten daha zordur. Superposition'da geÃ§en deÄŸer OCCT Switch testinde Ã§Ã¶kebilir. GÃ¼nlÃ¼k deÄŸeri OCCT Switch ile doÄŸrulayÄ±n.

**+450 / +3000 doÄŸrulamasÄ±:** OCCT 3D Adaptive Switch 1 saat hatasÄ±z. Kombustor 1 saat, artefakt 0. OCCT VRAM %98 21 dakika hatasÄ±z. CS2 3 koÅŸu sorunsuz. En yÃ¼ksek sÄ±caklÄ±k 72 Â°C.

### Notlar

- **Undervolt:** VF eÄŸrisinde 3217 MHz iÃ§in 1000, 990 ve 985 mV denendi. GerÃ§ek voltaj yine yaklaÅŸÄ±k 1005 mV oldu. 970 mV'de gÃ¼Ã§ 20 W dÃ¼ÅŸtÃ¼ ama puan da dÃ¼ÅŸtÃ¼. Bu kartta undervolt fayda saÄŸlamadÄ±.
- **TDR sonrasÄ±:** SÃ¼rÃ¼cÃ¼ gÃ¼Ã§ sÄ±nÄ±rÄ±nÄ± ve ofsetleri sÄ±fÄ±rlar. Afterburner'da profili yeniden yÃ¼kleyin.
- **NVIDIA App Otomatik Ayarlama:** Bu kartta +182 / +200 buldu. YÃ¼kte saat yaklaÅŸÄ±k 2930 MHz oldu.
- **Afterburner'sÄ±z yol:** NVIDIA sÃ¼rÃ¼cÃ¼sÃ¼nÃ¼n `nvml.dll` kÃ¼tÃ¼phanesindeki `nvmlDeviceSetClockOffsets` iÅŸlevi ek sÃ¼rÃ¼cÃ¼ kurmadan ofset yazar. Bellek birimi Afterburner biriminin 2 katÄ±dÄ±r. Ayar yeniden baÅŸlatmada silinir. NVIDIA App ayarÄ±nÄ±n Ã¼zerine yazar.
- **OCCT:** AÃ§Ä±lÄ±ÅŸta HWiNFO Ã§ekirdek sÃ¼rÃ¼cÃ¼sÃ¼nÃ¼ yÃ¼kler. SÃ¼rÃ¼cÃ¼, Windows yeniden baÅŸlayana kadar yÃ¼klÃ¼ kalÄ±r.
- **Kombustor:** AkÄ±llÄ± Uygulama Denetimi aÃ§Ä±ksa sensÃ¶r DLL'si engellenir. SensÃ¶rler N/A gÃ¶rÃ¼nÃ¼r. Test ve artefakt tarayÄ±cÄ±sÄ± yine Ã§alÄ±ÅŸÄ±r.

---

## 10. BaÅŸka sistemlere uyarlama

| Durum | YapÄ±lacak iÅŸlem |
|---|---|
| AynÄ± iÅŸlemci ve anakart, farklÄ± RAM | Ã–nce Ai Overclock Tuner = EXPO veya XMP deneyin. Bu bÃ¶lÃ¼mdeki zamanlamalarÄ± yalnÄ±zca **SK Hynix 24 Gbit M-die, 2 Ã— 24 GB, tek rank** kitinde baÅŸlangÄ±Ã§ noktasÄ± olarak kullanÄ±n. PBO, Windows ve FACEIT adÄ±mlarÄ± aynen geÃ§erlidir. |
| BaÅŸka X3D iÅŸlemci | Boost Override Ã¼st sÄ±nÄ±rÄ± iÅŸlemciye gÃ¶re deÄŸiÅŸir. Ã‡ift CCD'li X3D iÅŸlemcilerde (9900X3D, 9950X3D) Turbo Game Mode, CCD Parker ve Core Flex X3D preset anlamlÄ± olabilir. Bu deÄŸerler burada test edilmedi. |
| BaÅŸka ASUS AM5 anakart | MenÃ¼ adlarÄ± bÃ¼yÃ¼k Ã¶lÃ§Ã¼de aynÄ±dÄ±r. NVRAM ofsetleri farklÄ±dÄ±r. Kendi BIOS dosyanÄ±zdan ayar sÃ¶zlÃ¼ÄŸÃ¼ Ã§Ä±karÄ±n ve `-IfrFile` ile kontrol edin. |
| BaÅŸka marka anakart | MenÃ¼ adlarÄ± farklÄ±dÄ±r. AyarlarÄ±n anlamÄ± aynÄ±dÄ±r. Kontrol betiÄŸi Ã§alÄ±ÅŸmaz. Listeyi elle uygulayÄ±n. |
| TÃ¼m durumlar | Her seferde tek ayarÄ± deÄŸiÅŸtirin. Her deÄŸiÅŸiklikten sonra Ã¶lÃ§Ã¼n ve WHEA hatasÄ± olup olmadÄ±ÄŸÄ±na bakÄ±n. |

### Kendi ayar listenizi oluÅŸturma

1. AyarlarÄ±nÄ±zÄ± BIOS'tan elle girin.
2. BIOS gÃ¶rÃ¼ntÃ¼sÃ¼ alÄ±n ve dÃ¶kÃ¼m oluÅŸturun:

   ```powershell
   .\nvram\nvram_snap.ps1 -OutDir .\snap_benim
   .\nvram\bios_dump.ps1 -SnapDir .\snap_benim -IfrFile .\sozluk\ifr_all.tsv -OutCsv .\benim.csv -OutMd .\benim.md
   ```

3. `ayarlar/hedef_ayarlar_2503.csv` dosyasÄ±nÄ±n kopyasÄ±nda `Hedef` ve `Hedef_ham` sÃ¼tunlarÄ±nÄ± kendi deÄŸerlerinizle deÄŸiÅŸtirin.
4. KontrolÃ¼ kendi listenizle Ã§alÄ±ÅŸtÄ±rÄ±n:

   ```powershell
   .\kontrol\ayar_kontrol.ps1 -Hedef .\benim_hedeflerim.csv
   ```

---

## 11. Kontrol

YÃ¶netici PowerShell'de depo klasÃ¶rÃ¼nÃ¼ aÃ§Ä±n ve ÅŸu komutlarÄ± Ã§alÄ±ÅŸtÄ±rÄ±n:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\kontrol\ayar_kontrol.ps1          # BIOS ve Windows
.\kontrol\ayar_kontrol.ps1 -Fan     # Fan ve pompa eÄŸrileriyle birlikte
```

Bu betik **yalnÄ±zca okur**. HiÃ§bir dosyaya yazmaz.

Betik ÅŸunlarÄ± yapar:
- CanlÄ± BIOS deÄŸerlerini (UEFI NVRAM) `ayarlar/hedef_ayarlar_2503.csv` listesiyle karÅŸÄ±laÅŸtÄ±rÄ±r.
- Windows'ta ÅŸunlarÄ± denetler: SMT, RAM hÄ±zÄ± (8000), Secure Boot, TPM, VBS/HVCI, HAGS, `steam.exe` ve `cs2.exe` CPU 0 durumu ve WHEA hatalarÄ±.
- Her farklÄ± ayar iÃ§in menÃ¼ yolunu yazar.
- Ã‡Ä±kÄ±ÅŸ kodu, farklÄ± ayar sayÄ±sÄ±nÄ± verir. 0 ise tÃ¼m ayarlar doÄŸrudur.

### Yeni BIOS sÃ¼rÃ¼mÃ¼ kullanÄ±yorsanÄ±z

AyarlarÄ±n NVRAM iÃ§indeki konumu deÄŸiÅŸmiÅŸ olabilir. Yeni BIOS dosyasÄ±ndan sÃ¶zlÃ¼k oluÅŸturun ve kontrolÃ¼ bu sÃ¶zlÃ¼kle yapÄ±n:

```powershell
Add-Type -Path .\tools\BiosIfr.cs, .\tools\EfiDec3b.cs
[Prog]::Main(@('C:\indirilenler\BIOS.CAP', '.\yeni_sozluk'))
.\kontrol\ayar_kontrol.ps1 -IfrFile .\yeni_sozluk\ifr_all.tsv
```

AMD Overclocking ayarlarÄ± (PBO ve Curve Optimizer) sÃ¶zlÃ¼kte yoktur. DeÄŸiÅŸkenin boyutu deÄŸiÅŸtiyse betik "DUZEN FARKLI" uyarÄ±sÄ± verir. Bu ayarlarÄ± menÃ¼den elle kontrol edin.

AyrÄ±ntÄ±lÄ± fark iÃ§in gÃ¼ncelleme Ã¶ncesi ve sonrasÄ± gÃ¶rÃ¼ntÃ¼leri karÅŸÄ±laÅŸtÄ±rÄ±n:

```powershell
.\nvram\nvram_snap.ps1 -OutDir .\snap_sonra -Label sonra
.\nvram\nvram_diff.ps1 -A .\snap_guncelleme_oncesi -B .\snap_sonra
```

---

## 12. Ã–lÃ§Ã¼m yÃ¶ntemi

### Benchmark

- **Harita:** Steam Workshop `3240880604` (de_dust2). Konsolda `map_workshop 3240880604 de_dust2` komutunu yazÄ±n.
- **KoÅŸu sÃ¼resi:** YaklaÅŸÄ±k 129 saniye. KoÅŸu sonunda CS2, VProf Ã¶zetini `console.log` dosyasÄ±na yazar.
- **Ayarlar:** TÃ¼m koÅŸularda aynÄ±ydÄ±: 1280Ã—960, tam ekran, 360 Hz, `fps_max 0` ve FACEIT kapalÄ±. HWiNFO yalnÄ±zca bir testte aÃ§Ä±ktÄ±.

### Karar kuralÄ±

- **AyrÄ± oturumlar (BIOS testleri):** Her ayar iÃ§in 6 kayÄ±t koÅŸusunun medyanÄ± ve aralÄ±ÄŸÄ± karÅŸÄ±laÅŸtÄ±rÄ±ldÄ±. AralÄ±klar Ã§akÄ±ÅŸmÄ±yorsa fark **kesin** kabul edildi. Fark %0,6'dan kÃ¼Ã§Ã¼kse oturum sapmasÄ±ndan ayÄ±rt edilemez.
- **AynÄ± oturum (Windows testleri):** KoÅŸullar dÃ¶nÃ¼ÅŸÃ¼mlÃ¼ sÄ±rayla Ã§alÄ±ÅŸtÄ±rÄ±ldÄ±. EÅŸleÅŸtirilmiÅŸ t testi uygulandÄ±. 6 turda |t| > 2,571 ve 3 turda |t| > 4,30 olduÄŸunda fark anlamlÄ± kabul edildi.

### IsÄ±nma koÅŸularÄ± ve sapma

- Her yeni CS2 oturumunda ortalama FPS, ilk yaklaÅŸÄ±k 6 koÅŸuda %1,2 ile %1,3 dÃ¼ÅŸer. Sonra deÄŸer sabitlenir.
- Bu nedenle her oturumun ilk 6 koÅŸusu **Ä±sÄ±nma koÅŸusu** sayÄ±ldÄ±. Bu koÅŸular sonuÃ§lara alÄ±nmadÄ±.
- AynÄ± BIOS ayarÄ± iki ayrÄ± oturumda Ã¶lÃ§Ã¼ldÃ¼ÄŸÃ¼nde fark %0,55 Ã§Ä±ktÄ±.

### Ekran kartÄ± ve Windows testleri

- KarÅŸÄ±laÅŸtÄ±rÄ±lan koÅŸullar aynÄ± CS2 oturumunda ABBA sÄ±rasÄ±yla Ã§alÄ±ÅŸtÄ±rÄ±ldÄ±. 2Ã—2 testte ikinci oturum ters sÄ±rayla Ã§alÄ±ÅŸtÄ±rÄ±ldÄ±. Bu yÃ¶ntem oturum iÃ§indeki doÄŸrusal kaymayÄ± dengeler.
- Her koÅŸuda `nvidia-smi` saniyede bir GPU saatini, bellek saatini, gÃ¼cÃ¼ ve sÄ±caklÄ±ÄŸÄ± kaydetti.
- Her koÅŸudan sonra System gÃ¼nlÃ¼ÄŸÃ¼nde `nvlddmkm` ve Display 4101 (TDR) olaylarÄ± kontrol edildi. CS2'nin aÃ§Ä±k olduÄŸu kontrol edildi.
- Kesme Ã¶rnekleyicisi aÃ§Ä±kken yapÄ±lan koÅŸular karÅŸÄ±laÅŸtÄ±rmaya alÄ±nmadÄ±.

### CS2 gÃ¼ncellemesi

CS2 gÃ¼ncellemesi sonuÃ§larÄ± %1 ile %2 arasÄ±nda kaydÄ±rabilir. Bir Ã¶lÃ§Ã¼mde CS2 iki oturum arasÄ±nda gÃ¼ncellendi ve aynÄ± ayarla %1â€“2 fark gÃ¶rÃ¼ldÃ¼. Bu nedenle:

- Her oturumdan Ã¶nce `steamapps\appmanifest_730.acf` dosyasÄ±ndaki `LastUpdated` deÄŸerine bakÄ±n.
- AyrÄ± oturumlardaki tek koÅŸularÄ± karÅŸÄ±laÅŸtÄ±rÄ±rken sapmayÄ± en az %1â€“2 kabul edin.

### VProf Ã§Ä±ktÄ±sÄ±

```
[VProf] Summary of 122110 frames and 129 1-second intervals.
[VProf] FPS: Avg=943.7, P1=349.1
[VProf]           FrameTotal   1.06   2.86   122110   1.06   2.86     3.18   4.06      129   3.18   4.06
```

VProf bazÄ± kareleri analizden Ã§Ä±karÄ±r. Bu nedenle P1 ve P99 deÄŸerleri, PresentMon veya CapFrameX deÄŸerleriyle birebir aynÄ± deÄŸildir.

### PresentMon

- SÃ¼rÃ¼m 2.6.0, konsol uygulamasÄ± (Intel, GitHub). Kurulum gerekmez. `windows/pm_ab.ps1` CS2 oturumu boyunca kayÄ±t alÄ±r ve her koÅŸu iÃ§in Ã¶zet Ã§Ä±karÄ±r.
- **Gecikme:** "Kare baÅŸlangÄ±cÄ±ndan ekrana" = (sunum zamanÄ± âˆ’ CPU kare baÅŸlangÄ±cÄ±) + `MsUntilDisplayed`. Fare, USB ve ekran panelinin sÃ¼resi dahil deÄŸildir. TÄ±klamadan ekrana sÃ¼re iÃ§in donanÄ±m gerekir (LDAT, OSLTT veya Ä±ÅŸÄ±k sensÃ¶rlÃ¼ Teensy).
- CS2, Reflex kapalÄ±yken PC Latency verisi gÃ¶ndermez (`MsPCLatency` = NA).
- **PresentMon'un FPS deÄŸerini kullanmayÄ±n.** Bu sistemde ETW olay kaybÄ± yÃ¼zÃ¼nden kareleri eksik saydÄ±: Independent Flip'te %3, Legacy Flip'te %10 eksik. FPS iÃ§in VProf kullanÄ±ldÄ±. Gecikme ve sunum kipi deÄŸerleri kaydedilen karelerden hesaplanÄ±r.
- `--date_time` Ã§Ä±ktÄ±sÄ±ndaki saat bu sistemde yerel saatten 3 saat ileriydi. Betik farkÄ± kendisi dÃ¼zeltir.

---

## 13. AraÃ§lar

TÃ¼m betikler **Windows PowerShell 5.1** ile test edildi. Ã‡Ä±ktÄ±lar TÃ¼rkÃ§edir. Gerekirse Ã¶nce `Set-ExecutionPolicy -Scope Process Bypass` komutunu Ã§alÄ±ÅŸtÄ±rÄ±n.

### `bench/`: CS2 Ã¶lÃ§Ã¼mÃ¼

CS2, `-condebug` seÃ§eneÄŸiyle aÃ§Ä±k olmalÄ±dÄ±r. `console.log` yolu betiklerin baÅŸÄ±nda tanÄ±mlÄ±dÄ±r. Steam farklÄ± bir klasÃ¶rdeyse yolu deÄŸiÅŸtirin.

| Betik | GÃ¶revi |
|---|---|
| `run_bench.ps1` | Konsolu aÃ§ar, haritayÄ± yÃ¼kler, `[VProf] FPS:` satÄ±rÄ±nÄ± bekler ve sonraki koÅŸuya geÃ§er. Plan biÃ§imi: `-Plan ad:maske:koÅŸu[:Ã¶ncelik];â€¦`. Ã–ncelik deÄŸeri N, A veya H olabilir. `-Warmups` Ä±sÄ±nma koÅŸusu sayÄ±sÄ±nÄ± belirler. `bench_stop.txt` dosyasÄ± oluÅŸturulursa betik durur. Bitince affinity ve Ã¶nceliÄŸi varsayÄ±lana dÃ¶ndÃ¼rÃ¼r. CS2 baÅŸta simge durumundaysa yeniden simge durumuna alÄ±r ve Ã¶nceki pencereyi Ã¶ne getirir. |
| `vprof_stage.ps1` | Belirli bir zaman aralÄ±ÄŸÄ±ndaki koÅŸularÄ± okur. Avg, P1, P99, ortalama kare sÃ¼resi, WHEA ve Kernel-Power 41 sayÄ±sÄ±nÄ± verir. |
| `interleave_report.ps1` | DÃ¶nÃ¼ÅŸÃ¼mlÃ¼ koÅŸularÄ± eÅŸleÅŸtirilmiÅŸ t testi ile karÅŸÄ±laÅŸtÄ±rÄ±r. |
| `snap_console.ps1` | `console.log` dosyasÄ±nÄ± yedekler. CS2 her aÃ§Ä±lÄ±ÅŸta bu dosyayÄ± sÄ±fÄ±rlar. |
| `cs2_affinity.ps1` | `cs2.exe` affinity deÄŸerini okur veya ayarlar (`-Mask 0xFFFE`). Bu deÄŸer kalÄ±cÄ± deÄŸildir. |

```powershell
# CS2 aÃ§Ä±k olsun. FACEIT kapalÄ± olsun. BIOS deÄŸiÅŸikliÄŸinden sonra yeni oturumda:
.\bench\run_bench.ps1 -Plan AYAR:0xFFFF:12 -Warmups 6
.\bench\vprof_stage.ps1 -Start '10/19 12:30' -Name AYAR
```

**Notlar:**
- `Start-Process` ile `-Plan` deÄŸeri geÃ§irirken tek tÄ±rnak kullanmayÄ±n. Tek tÄ±rnak deÄŸeri olduÄŸu gibi iletir ve hiÃ§bir koÅŸu Ã§alÄ±ÅŸmaz.
- Tarihler `console.log` biÃ§imindedir: `MM/dd HH:mm`. YÄ±l betiklerde 2026 olarak sabittir.

### `nvram/`: BIOS okuma (yalnÄ±zca okur)

| Betik | GÃ¶revi |
|---|---|
| `nvram_snap.ps1` | TÃ¼m NVRAM deÄŸiÅŸkenlerinin dizinini kaydeder: ad, GUID, boyut ve SHA256. Ayar deÄŸiÅŸkenlerinin ham baytlarÄ±nÄ± da kaydeder. Parola, anahtar, lisans ve TPM iÃ§eren deÄŸiÅŸkenleri kaydetmez. |
| `nvram_diff.ps1` | Ä°ki gÃ¶rÃ¼ntÃ¼yÃ¼ karÅŸÄ±laÅŸtÄ±rÄ±r. `-Decoded` ve `-IfrFile` ile ayar adlarÄ±nÄ± da gÃ¶sterir. |
| `bios_dump.ps1` | GÃ¶rÃ¼ntÃ¼yÃ¼ ayar sÃ¶zlÃ¼ÄŸÃ¼yle birleÅŸtirir ve okunur dÃ¶kÃ¼m oluÅŸturur (CSV ve Markdown). |

### `kontrol/`: ayar kontrolÃ¼

`ayar_kontrol.ps1` betiÄŸinin aÃ§Ä±klamasÄ± [bÃ¶lÃ¼m 11](#11-kontrol) bÃ¶lÃ¼mÃ¼ndedir.

### `hwinfo/`: sensÃ¶r kaydÄ±

Bu betikler HWiNFO'nun paylaÅŸÄ±lan belleÄŸini okur. HWiNFO'da **Shared Memory Support** seÃ§eneÄŸi aÃ§Ä±k olmalÄ±dÄ±r.

| Betik | GÃ¶revi |
|---|---|
| `hw_sample.ps1` | TÃ¼m sensÃ¶rleri 1 saniye aralÄ±kla CSV dosyasÄ±na yazar. |
| `hw_report.ps1` | CSV dosyasÄ±ndan Ã¶zet Ã§Ä±karÄ±r. |
| `hwinfo_sm_read.ps1` | AnlÄ±k deÄŸerleri listeler. |

### `gpu/`: ekran kartÄ± Ã¶lÃ§Ã¼mÃ¼

Bu betikler yÃ¶netici PowerShell ister. MSI Afterburner ve `nvidia-smi` gerekir. SonuÃ§lar `gpu\sonuc\` klasÃ¶rÃ¼ne yazÄ±lÄ±r.

| Betik | GÃ¶revi |
|---|---|
| `ab_profil_yaz.ps1` | Afterburner profil yuvasÄ±nÄ± yazar ve uygular (`-Slot 5 -Core 450 -Mem 3000 -PL 116`). Ã–nce profil dosyasÄ±nÄ±n yedeÄŸini alÄ±r. Fan deÄŸeri verilmezse fan satÄ±rÄ± yazmaz ve fan otomatik kalÄ±r. |
| `cs2_gpu_ab.ps1` | Afterburner profillerini ve CPU 0 ayarÄ±nÄ± aynÄ± CS2 oturumunda karÅŸÄ±laÅŸtÄ±rÄ±r. Her koÅŸuda GPU kaydÄ± tutar ve TDR olayÄ±nÄ± kontrol eder. KararsÄ±zlÄ±k gÃ¶rÃ¼rse durur. |
| `gpu_saat_kilit_ab.ps1` | `nvidia-smi -lgc` ile GPU saatini sÄ±nÄ±rlar ve kilitsiz durumla karÅŸÄ±laÅŸtÄ±rÄ±r. Kilidi her durumda kaldÄ±rÄ±r. |

```powershell
# 2x2 test: Profil 5 = stok (0/0/100), Profil 1 = gÃ¼nlÃ¼k ayar. Ä°kinci oturumda sÄ±rayÄ± ters Ã§evirin.
.\gpu\cs2_gpu_ab.ps1 -Order 'SF1:5:0xFFFF,SE1:5:0xFFFE,OF1:1:0xFFFF,OE1:1:0xFFFE' -EndProfile 1 -Tag GUN
```

### `windows/`: kesme ve Ã§Ã¶kme analizi (yalnÄ±zca okur)

| Betik | GÃ¶revi |
|---|---|
| `irq_sample.ps1` | Her saniye CPU baÅŸÄ±na kesme ve DPC sayÄ±sÄ±nÄ± Ã¶lÃ§er. Fare hareketli ve durgun saniyeleri ayÄ±rÄ±r. SonuÃ§ta CPU baÅŸÄ±na farkÄ± yazar. `-OutCsv` ile ham veriyi kaydeder. |
| `dump_ozet.ps1` | Minidump dosyasÄ±nÄ± (`.dmp`, `.mdmp`) okur. Ä°stisna kodunu, hatalÄ± modÃ¼lÃ¼ ve yÄ±ÄŸÄ±ndaki modÃ¼lleri yazar. |
| `dpc_lat.ps1` + `DpcEtl.cs` | DPC ve kesme sÃ¼relerini Windows'un Ã§ekirdek izleme kaydÄ±yla Ã¶lÃ§er (LatencyMon benzeri). SÃ¼rÃ¼cÃ¼ bazÄ±nda adet, ortalama ve en uzun sÃ¼reyi yazar. `-Sec 60` boÅŸta Ã¶lÃ§er, `-Bench` bir CS2 koÅŸusu sÄ±rasÄ±nda Ã¶lÃ§er. YÃ¶netici ister. |
| `pm_ab.ps1` + `PmRapor.cs` | PresentMon ile bir CS2 oturumunu kaydeder ve `gpu/cs2_gpu_ab.ps1` koÅŸularÄ±nÄ± Ã§alÄ±ÅŸtÄ±rÄ±r. Her koÅŸu iÃ§in sunum kipi, kare baÅŸlangÄ±cÄ±ndan ekrana gecikme, CPU ve GPU meÅŸgul sÃ¼resini yazar. `PresentMon-2.6.0-x64.exe` dosyasÄ± aynÄ± klasÃ¶rde olmalÄ±dÄ±r (`-PresentMon` ile deÄŸiÅŸtirilebilir). |

### `tools/`: BIOS ayar sÃ¶zlÃ¼ÄŸÃ¼

```powershell
Add-Type -Path .\tools\BiosIfr.cs, .\tools\EfiDec3b.cs
[Prog]::Main(@('C:\yol\BIOS.CAP', '.\sozluk'))     # sozluk\ifr_all.tsv dosyasÄ±nÄ± oluÅŸturur
```

Bu araÃ§ AMI Aptio BIOS kapsÃ¼lÃ¼nÃ¼ (`.CAP`) aÃ§ar. BIOS 2503 iÃ§in 9304 ayar Ã§Ä±karÄ±r. BunlarÄ±n 408'i gizlidir. SÃ¶zlÃ¼k, Ã¼reticinin telifli BIOS dosyasÄ±ndan Ã§Ä±karÄ±ldÄ±ÄŸÄ± iÃ§in depoda yoktur. Kendi BIOS dosyanÄ±zdan oluÅŸturun.

---

## 14. Sorun giderme

| Belirti | Ã‡Ã¶zÃ¼m |
|---|---|
| RAM ayarÄ±ndan sonra aÃ§Ä±lmÄ±yor veya bellek eÄŸitimi bitmiyor | Bekleyin. AÃ§Ä±lmazsa **Clear CMOS** yapÄ±n ve ayarlarÄ± yeniden girin. HÃ¢lÃ¢ aÃ§Ä±lmazsa bir kademe gevÅŸetin (Ã¶rneÄŸin Trcd/Trp +2, Trfc1 +32). Bu gevÅŸek deÄŸerler denenmedi. |
| Rastgele Ã§Ã¶kme veya WHEA hatasÄ± | Ã–nce RAM sÄ±caklÄ±ÄŸÄ±nÄ± kontrol edin. tREFI 65535 sÄ±caklÄ±ÄŸa duyarlÄ±dÄ±r. Sonra FCLK deÄŸerini iki menÃ¼de de 2000'e dÃ¼ÅŸÃ¼rÃ¼n (WHEA 19 genellikle FCLK kararsÄ±zlÄ±ÄŸÄ±dÄ±r). Gerekirse RAM'i EXPO veya XMP profiline alÄ±n. |
| FACEIT, Secure Boot, TPM veya VBS hatasÄ± | [BÃ¶lÃ¼m 7](#7-bios-faceit-ve-gÃ¼venlik) ayarlarÄ±nÄ± kontrol edin. Windows GÃ¼venliÄŸi â†’ Cihaz gÃ¼venliÄŸi â†’ Ã‡ekirdek yalÄ±tÄ±mÄ± â†’ Bellek bÃ¼tÃ¼nlÃ¼ÄŸÃ¼ aÃ§Ä±k olmalÄ±dÄ±r. |
| Windows 8 mantÄ±ksal iÅŸlemci gÃ¶steriyor | SMT kapalÄ± kalmÄ±ÅŸtÄ±r. Advanced â†’ AMD CBS â†’ SMT Control deÄŸerini Auto yapÄ±n ve bilgisayarÄ± tamamen kapatÄ±p aÃ§Ä±n. |
| BIOS gÃ¼ncellemesinden sonra BitLocker anahtarÄ± isteniyor | fTPM sÄ±fÄ±rlanmÄ±ÅŸtÄ±r. Kurtarma anahtarÄ±nÄ± girin. Sonra fTPM'in aÃ§Ä±k olduÄŸunu kontrol edin. |
| Steam yeniden baÅŸlatÄ±ldÄ±ktan sonra CPU 0 ayarÄ± kayboldu | [BÃ¶lÃ¼m 8](#cs2yi-cpu-0-dÄ±ÅŸÄ±nda-Ã§alÄ±ÅŸtÄ±rma) adÄ±mlarÄ±nÄ± tekrarlayÄ±n. |
| Ekran bir an kararÄ±yor, oyun kapanÄ±yor. Olay GÃ¶rÃ¼ntÃ¼leyicisi'nde `nvlddmkm` 153 veya 14 var. | Ekran kartÄ± hÄ±z aÅŸÄ±rtmasÄ± kararsÄ±zdÄ±r (TDR). Ã‡ekirdeÄŸi 25 MHz dÃ¼ÅŸÃ¼rÃ¼n. TDR sonrasÄ± sÃ¼rÃ¼cÃ¼ ofsetleri ve gÃ¼Ã§ sÄ±nÄ±rÄ±nÄ± sÄ±fÄ±rlar. Afterburner'da profili yeniden yÃ¼kleyin. |
| Yeniden baÅŸlatmadan sonra ekran kartÄ± stok saatte | Afterburner'Ä± aÃ§Ä±n ve Profil 1'i yÃ¼kleyin ([bÃ¶lÃ¼m 9](#9-ekran-kartÄ±-hÄ±z-aÅŸÄ±rtma)). |
| CS2 oyundan Ã§Ä±karken Ã§Ã¶kÃ¼yor. Olay gÃ¼nlÃ¼ÄŸÃ¼nde `tier0.dll`, eriÅŸim ihlali. | CS2'nin kendi hatasÄ±dÄ±r. KapanÄ±ÅŸ sÄ±rasÄ±nda log sistemi kapatÄ±lÄ±rken olur. HÄ±z aÅŸÄ±rtmadan Ã¶nce de vardÄ±. Oyun iÃ§inde etkisi yoktur. |
| Alt-Tab sÄ±rasÄ±nda ekran kararÄ±yor | Tam ekran iyileÅŸtirmeleri kapalÄ±yken normaldir (gerÃ§ek tam ekran). Ä°stemiyorsanÄ±z `cs2.exe` Uyumluluk sekmesindeki kutunun iÅŸaretini kaldÄ±rÄ±n. |
| CS2 aniden kapandÄ±. DÃ¶kÃ¼m `soundsystem.dll` iÃ§inde. | Kablosuz kulaklÄ±k alÄ±cÄ±sÄ± oyun aÃ§Ä±kken yeniden baÄŸlanmÄ±ÅŸtÄ±r. CS2 ses aygÄ±tÄ±nÄ± yeniden baÅŸlatÄ±rken Ã§Ã¶ker. CS2 aÃ§Ä±kken alÄ±cÄ±yÄ± Ã§Ä±karÄ±p takmayÄ±n. DÃ¶kÃ¼mÃ¼ `windows\dump_ozet.ps1` ile okuyun. |

---

## 15. SÄ±nÄ±rlar

**SÄ±nÄ±rlar:**
- **Tek sistem:** Ã–lÃ§Ã¼mler tek iÅŸlemci, tek RAM kiti ve tek anakartla yapÄ±ldÄ±. SonuÃ§larÄ± baÅŸka sistemlere doÄŸrudan uygulamayÄ±n.
- **Oturum sapmasÄ±:** Oturumlar arasÄ±nda Â±%0,6 sapma vardÄ±r. Bundan kÃ¼Ã§Ã¼k farklar ayÄ±rt edilemez.
- **BIOS karÅŸÄ±laÅŸtÄ±rmalarÄ±:** BIOS gÃ¼ncellemesi ve RAM ayarÄ± aynÄ± anda yapÄ±ldÄ±. Bu nedenle FPS farkÄ±nÄ± yalnÄ±zca RAM ayarÄ±na baÄŸlayamazsÄ±nÄ±z.
- **TÄ±klamadan ekrana gecikme Ã¶lÃ§Ã¼lmedi:** LDAT veya Reflex Analyzer kullanÄ±lmadÄ±. PresentMon ile kare baÅŸlangÄ±cÄ±ndan ekrana sÃ¼re ve Windows DPC/kesme sÃ¼releri Ã¶lÃ§Ã¼ldÃ¼.
- **Benchmark ve maÃ§ farkÄ±:** Benchmark haritasÄ±nda bot vardÄ±r, sunucu yÃ¼kÃ¼ yoktur. MaÃ§ta ortalama FPS, benchmarka gÃ¶re yaklaÅŸÄ±k %27 dÃ¼ÅŸÃ¼k Ã¶lÃ§Ã¼ldÃ¼. Benchmark sonuÃ§larÄ± maÃ§ performansÄ±nÄ±n birebir karÅŸÄ±lÄ±ÄŸÄ± deÄŸildir.
- **Ekran kartÄ± kararlÄ±lÄ±ÄŸÄ±:** GÃ¼nlÃ¼k ayar sentetik testlerle (toplam yaklaÅŸÄ±k 2 saat 20 dakika) ve kÄ±sa CS2 koÅŸularÄ±yla doÄŸrulandÄ±. Uzun oyun oturumlarÄ±nda ve sÄ±cak ortamda kararlÄ±lÄ±ÄŸÄ± ayrÄ±ca izleyin.
- **CS2 sÃ¼rÃ¼mÃ¼:** Windows ve ekran kartÄ± testleri, BIOS testlerinden sonraki bir CS2 sÃ¼rÃ¼mÃ¼nde yapÄ±ldÄ±. Ä°ki gruptaki FPS deÄŸerlerini doÄŸrudan karÅŸÄ±laÅŸtÄ±rmayÄ±n.
- **FCLK 2200 kararlÄ±lÄ±ÄŸÄ±:** YalnÄ±zca yaklaÅŸÄ±k 16 dakikalÄ±k CS2 testi ve aÃ§Ä±lÄ±ÅŸ sonrasÄ± WHEA kontrolÃ¼ yapÄ±ldÄ±. Uzun kullanÄ±mda WHEA 19 olaylarÄ±nÄ± izleyin.

**Test edilmeyen konular:**

| Konu | Neden |
|---|---|
| Secure Boot, TPM, IOMMU, HVCI, SVM, CSM | FACEIT denetler. Bu ayarlara dokunulmadÄ±. |
| DDR5-6000 1:1 | Bu kurulumda tercih edilmedi. |
| CS2 grafik ayarlarÄ± (MSAA, Reflex vb.) | Etkisi Ã¶lÃ§Ã¼lmedi. |
| BCLK | PCIe saatini de deÄŸiÅŸtirir. Ã–nerilmez. |
| Thermal Limit, PBO limitleri, daha derin Curve Optimizer | Ä°ÅŸlemci saat tavanÄ±ndadÄ±r ve gÃ¼Ã§ sÄ±nÄ±rÄ±ndan uzaktÄ±r. KazanÃ§ beklenmez. |
| Turbo Game Mode, Gaming Adaptive CCD Parker | Ã‡ift CCD'li iÅŸlemciler iÃ§indir. 9800X3D tek CCD'lidir. |
| Process Lasso, PBO2 Tuner gibi Ã§ekirdek sÃ¼rÃ¼cÃ¼sÃ¼ yÃ¼kleyen araÃ§lar | KullanÄ±lmadÄ±. |
| Ekran kartÄ± belleÄŸi +3000 Ã¼stÃ¼ | SÃ¼rÃ¼cÃ¼ sÄ±nÄ±rÄ±dÄ±r. AÅŸmak iÃ§in resmi olmayan araÃ§ gerekir (Ã¶r. mVolt+). KullanÄ±lmadÄ±. CS2'de bellek saatinin etkisi yoktur. |
| NVIDIA sÃ¼rÃ¼cÃ¼sÃ¼ gÃ¼ncelleme (617.42 â†’ 621.01) | KullanÄ±cÄ± kararÄ± bekliyor. SÃ¼rÃ¼m notlarÄ±nda CS2 maddesi yok. |
| Kesmeleri kayÄ±t defteriyle baÅŸka Ã§ekirdeÄŸe taÅŸÄ±ma | VarsayÄ±lan yerleÅŸim zaten CPU 0'dÄ±r. CS2'yi CPU 0'dan uzak tutmak daha basittir. |

**SÄ±radaki adaylar (Ã¶lÃ§Ã¼lmedi):**
1. **tRDRDSCL ve tWRWRSCL 8'den 6'ya, tRDWR 20'den 18'e:** DÃ¼ÅŸÃ¼k riskli ikincil zamanlamalardÄ±r. Tahmini etki %0 ile %1,5 arasÄ±ndadÄ±r.

---

## 16. Depo yapÄ±sÄ±

| KlasÃ¶r veya dosya | Ä°Ã§erik |
|---|---|
| `README.md` | Bu rehber |
| `ayarlar/hedef_ayarlar_2503.csv` | 126 hedef ayar. MenÃ¼ yolu, deÄŸer, NVRAM konumu, beklenen ham deÄŸer ve Ã¶lÃ§Ã¼len etki. |
| `kontrol/ayar_kontrol.ps1` | CanlÄ± BIOS ve Windows durumunu hedef listeyle karÅŸÄ±laÅŸtÄ±rÄ±r. Salt okunur Ã§alÄ±ÅŸÄ±r. |
| `bench/` | CS2 benchmark otomasyonu ve analiz betikleri |
| `nvram/` | BIOS okuma, gÃ¶rÃ¼ntÃ¼ alma, karÅŸÄ±laÅŸtÄ±rma ve dÃ¶kÃ¼m betikleri |
| `hwinfo/` | HWiNFO sensÃ¶r kaydÄ± betikleri |
| `tools/` | BIOS ayar sÃ¶zlÃ¼ÄŸÃ¼ oluÅŸturma (`BiosIfr.cs`) ve EFI aÃ§Ä±cÄ± (`EfiDec3b.cs`) |
| `gpu/` | Afterburner profil yazma ve ekran kartÄ± A/B Ã¶lÃ§Ã¼m betikleri |
| `windows/` | CPU baÅŸÄ±na kesme/DPC Ã¶lÃ§Ã¼mÃ¼, DPC/kesme sÃ¼re Ã¶lÃ§Ã¼mÃ¼, PresentMon oturum Ã¶lÃ§Ã¼mÃ¼ ve minidump Ã¶zeti |
| `data/kosular.csv` | BIOS testlerinin tÃ¼m benchmark koÅŸularÄ± ve maÃ§lar (134 satÄ±r) |
| `data/gpu_windows_kosular.csv` | Windows, ekran kartÄ±, FCLK ve sunum kipi testlerinin CS2 koÅŸularÄ± (94 satÄ±r). GPU saati, bellek saati, gÃ¼Ã§ ve (24.10'dan itibaren) efektif saat dahil. |
| `data/gpu_superposition.csv` | Superposition 1080p Extreme puanlarÄ±: stok, Ã§ekirdek ve bellek adÄ±mlarÄ±, undervolt, Ã§Ã¶kmeler |
| `data/gpu_kararlilik.csv` | KararlÄ±lÄ±k testleri: OCCT, Kombustor, Superposition ve CS2. SÃ¼re, sonuÃ§, saat, gÃ¼Ã§ ve sÄ±caklÄ±k. |
| `data/ozet.csv` | Test ve koÅŸul baÅŸÄ±na medyan, en dÃ¼ÅŸÃ¼k ve en yÃ¼ksek deÄŸerler |
| `data/testler.csv` | Her testin BIOS durumu, deÄŸiÅŸen ayar, affinity, Ã¶ncelik ve sonuÃ§ |
| `data/bios_son_durum.csv` | Son BIOS durumunun tam dÃ¶kÃ¼mÃ¼. Ham baytlar ayar sÃ¶zlÃ¼ÄŸÃ¼yle Ã§Ã¶zÃ¼ldÃ¼. |
| `data/bios_aod_alanlari.csv` | AMD Overclocking deÄŸiÅŸkeninin 226 alanÄ± (PBO, Curve Optimizer vb.) |

**`kosular.csv` sÃ¼tunlarÄ±:**

| SÃ¼tun | AnlamÄ± |
|---|---|
| `Oturum` | CS2 oturumu. Ã–rnek: O0 = AÅŸama 0, O3 = PBO200_MB, O9 = Ã¶ncelik ve CPU 0 testi. |
| `Tip` | `isinma` (karÅŸÄ±laÅŸtÄ±rmaya girmez), `kayit`, `olcum-disi` veya `mac` |
| `Avg_FPS`, `P1_FPS` | Ortalama FPS ve %1 dÃ¼ÅŸÃ¼k FPS |
| `P99_ms` | Karelerin %99'unun altÄ±nda kaldÄ±ÄŸÄ± sÃ¼re |
| `Ort_kare_ms` | Ortalama kare sÃ¼resi |
| `Maks1s_P50_ms`, `Maks1s_P95_ms` | Her saniyedeki en uzun karenin medyanÄ± ve 95. yÃ¼zdeliÄŸi. TakÄ±lmayÄ± gÃ¶sterir. |
| `Not` | Ã–zel durumlar |

**`gpu_windows_kosular.csv` sÃ¼tunlarÄ±:** `Oturum` (G1â€“G10), `Test`, `Kosul`, `GPU_ayar` (Ã§ekirdek / bellek / gÃ¼Ã§), `Benzesim` (0xFFFF tÃ¼m Ã§ekirdekler, 0xFFFE CPU 0 hariÃ§), `Tip` (`kayit`, `isinma`, `gecersiz`, `cokme`), `Avg_FPS`, `P1_FPS`, `GPU_MHz`, `Bellek_MHz` (yÃ¼k altÄ±nda medyan, nvidia-smi birimi), `GPU_W`, `Not`. BoÅŸ hÃ¼cre: deÄŸer kaydedilmedi.

**Ã–lÃ§Ã¼m sayÄ±larÄ±:**
- **BIOS testleri:** 132 benchmark koÅŸusu (86 kayÄ±t, 44 Ä±sÄ±nma, 2 Ã¶lÃ§Ã¼m dÄ±ÅŸÄ±), 2 maÃ§, 13 CS2 oturumu ve 13 NVRAM gÃ¶rÃ¼ntÃ¼sÃ¼. HiÃ§bir aÃ§Ä±lÄ±ÅŸta WHEA hatasÄ± veya Kernel-Power 41 olayÄ± gÃ¶rÃ¼lmedi.
- **Windows ve ekran kartÄ± testleri:** 10 CS2 oturumunda 67 tamamlanan koÅŸu (52 kayÄ±t, 14 Ä±sÄ±nma, 1 geÃ§ersiz) ve 2 yarÄ±da kalan koÅŸu (1 TDR, 1 ses aygÄ±tÄ± Ã§Ã¶kmesi). 37 Superposition koÅŸusu (3'Ã¼ Ã§Ã¶kme ile bitti). 12 kararlÄ±lÄ±k testi.

---

**Lisans:** Bu depoda lisans tanÄ±mlanmamÄ±ÅŸtÄ±r.
