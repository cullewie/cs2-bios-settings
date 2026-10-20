# RAM ayarları: DDR5-8000, SK Hynix M-die, 2×24 GB

## 1. Modüller

| | |
|---|---|
| Kit | G.Skill F5-8000J4048F24GX2-TZ5RK (2 × 24 GB) |
| Bellek yongası | SK Hynix, 24 Gbit (M-die), modül başına 8 yonga, x8 |
| Rank | 1 (tek rank, SR) |
| Yuvalar | A2 ve B2 (kanal başına 1 modül) |
| PMIC / SPD hub | Richtek (PMIC5100) / Montage (SPD5118) |
| Üretim | 2024, 31. hafta |
| SPD JEDEC | 5600 MT/s 46-45-45-90, 1,10 V; tRFC1min 410 ns, tRFC2min 220 ns, tRFCsbmin 190 ns |
| SPD XMP 3.0 profili | "Lv1-8000C40": 8000 MT/s 40-48-48-128, VDD/VDDQ 1,35 V, VPP 1,80 V, bellek denetleyicisi 1,10 V |
| SPD EXPO profili | Yok (SPD raporunda "EXPO" geçmiyor) |

## 2. Ayarların dayanağı

RAM zamanlamaları bu projeden önce yapılmış ayrı bir ayar oturumunun referans raporundan alındı. Raporun adı "DDR5 Tuning Oturumu — Referans Raporu v1.0" (Ryzen 9800X3D / Hynix M-Die / 8000 MT/s, ROG X870-A, 2×24 GB SR, Gear 2, CL34). Rapordaki en sıkı çalışan profilin adı **PD**. Bu projede PD profili olduğu gibi uygulandı (Aşama 1). Değerler hem NVRAM'den hem HWiNFO'dan geri okunup doğrulandı.

### Deneme kronolojisi (referans rapordan)

| Profil | Değişen | Sonuç | Not |
|---|---|---|---|
| AG-15 | Taban profil | Açıldı | tCL 34, tRCDRD 46, tWR 48, tRRDL 12, tFAW 24, tWTRL 16 |
| P1 | tRAS 50, tRC 96 | Açıldı | |
| P2 | tWR 44 | BIOS reddetti | BIOS 48'e geri çekti |
| P3 | tRFC1 664, tRFC2 852, tRFCsb 730 | Açıldı | |
| P4 | tRTP 14 | Kararlı | "Uzun seans testi geçti" |
| PA | tWTRL 14 | Açılmadı | Eğitimde uzun bekledi |
| PB | tRRDL 10 | Açıldı | |
| PC | tFAW 20 | Açıldı | |
| **PD** | tRRDL 10 + tFAW 20 | **Açıldı, etkin** | Raporda "stabilite testi devam ediyor" |
| PE | tRCDRD 44 + tRCDWR 44 | Açılmadı | |
| PF | tRP 44 | Açılmadı | |

### Bulunan sınırlar

| Zamanlama | Alt sınır | Neden |
|---|---|---|
| tWR | ≥ 48 | ASUS X870-A BIOS'u 8000 MT/s'de 48'in altını kabul etmiyor (44/46 girilse de 48'e çekiyor) |
| tWTRL | ≥ 16 | 14 ile açılmadı (bellek denetleyicisi sınırı) |
| tRCDRD / tRCDWR | ≥ 46 | 44 ile açılmadı (bu kit + 8000 MT/s) |
| tRP | ≥ 46 | 44 ile açılmadı |

## 3. Uygulanan değerler (PD profili)

### Saatler

| | Değer |
|---|---|
| Bellek hızı | 8000 MT/s (MCLK 4000 MHz) |
| UCLK | 2000 MHz (Gear 2, UCLK = MCLK/2) |
| FCLK | 2000 MHz |
| Komut hızı | 1T |
| Gear Down Mode | Enabled |

### Zamanlamalar

ns değerleri MCLK 4000 MHz (1 tık = 0,25 ns) ile hesaplandı. Karşılaştırma için Aşama 0 (JEDEC 5600, MCLK 2800 MHz) değerleri de verildi.

| Zamanlama | PD (tık) | PD (ns) | Aşama 0 JEDEC 5600 (tık) | Aşama 0 (ns) |
|---|---|---|---|---|
| tCL | 34 | 8,5 | 46 | 16,4 |
| tRCDRD | 46 | 11,5 | 45 | 16,1 |
| tRCDWR | 46 | 11,5 | 45 | 16,1 |
| tRP | 46 | 11,5 | 45 | 16,1 |
| tRAS | 50 | 12,5 | 90 | 32,1 |
| tRC | 96 | 24,0 | 135 | 48,2 |
| tWR | 48 | 12,0 | 84 | 30,0 |
| tREFI | 65535 | 16 384 | 10892 | 3 890 |
| tRFC1 | 664 | 166 | 1146 | 409 |
| tRFC2 | 852 | 213 | 615 | 220 |
| tRFCsb | 730 | 182,5 | 531 | 190 |
| tRTP | 14 | 3,5 | 21 | 7,5 |
| tRRD_L | 10 | 2,5 | 14 | 5,0 |
| tRRD_S | 8 | 2,0 | 8 | 2,9 |
| tFAW | 20 | 5,0 | 32 | 11,4 |
| tWTR_L | 16 | 4,0 | 28 | 10,0 |
| tWTR_S | 6 | 1,5 | 7 | 2,5 |
| tCWL | 32 | 8,0 | 44 | 15,7 |
| tRDRD_SCL / SC / SD / DD | 8 / 1 / 1 / 1 | | 7 / 1 / – / 7 | |
| tWRWR_SCL / SC / SD / DD | 8 / 1 / 1 / 1 | | 21 / 1 / – / 15 | |
| tWRRD | 6 | | 8 | |
| tRDWR | 20 | | 20 | |
| tWTP / tCPDED / tXP (HWiNFO) | 59 / 20 / 30 | | 95 / 14 / 21 | |

### Diğer DRAM ayarları (canlı BIOS)

| Ayar | Değer |
|---|---|
| Memory Context Restore | Enabled (her açılışta yeniden eğitim yapılmaz) |
| Power Down Enable | Disabled |
| Gear Down Mode | Enabled |
| Bank Refresh Mode | Mixed (REFab/REFsb) |
| Bank Swap Mode | Auto |
| UCLK DIV1 MODE | Ai Tweaker'da Auto; AMD Overclocking'de elle UCLK=MEMCLK/2 |
| Memory P-state | Auto |
| DDR5 Nitro Mode | Auto (1-3-1 denendi, zararlı; bkz. bölüm 6) |
| Rtt Nom Wr / Nom Rd / Wr / Park / Park Dqs | Auto |
| İşlemci ODT ve sürücü dirençleri, faz kaydırmaları, DFE ayarları | Auto |

### Voltajlar

| Hat | BIOS | Ölçülen (CS2 yükü) |
|---|---|---|
| DRAM VDD | 1,60 V (kod 81, High DRAM Voltage Mode Enabled) | 1,590–1,605 V (ort. 1,602) |
| DRAM VDDQ | 1,60 V (kod 81) | 1,605–1,620 V (ort. 1,613–1,615) |
| DRAM VPP | Auto | 1,815 V |
| CPU VDDIO / MC | Auto | 1,447–1,465 V (ort. 1,457) |
| CPU SOC | Auto | 1,288–1,296 V (ort. 1,292); JEDEC 5600'de 0,898 V idi |
| CPU VDD_MISC | Auto | 1,100 V |
| VDDG CCD / IOD, VDDP | Auto | okunmadı |

Referans raporda voltajlar belgelenmemiş ("kullanıcı ayarlar"). Buradaki değerler bu sistemde NVRAM'den ve HWiNFO'dan okunan gerçek değerlerdir.

### Referans rapordaki "sabit ayarlar" ile canlı BIOS farkı

| Referans rapor | Canlı BIOS | Durum |
|---|---|---|
| GDM ON | Gear Down Mode Enabled | Aynı |
| Cmd2T 1T | Komut hızı 1T (HWiNFO CR 1) | Aynı |
| Power Down Mode OFF | Disabled | Aynı |
| tREFI 65535 | 65535 | Aynı |
| BGS ON / BGS Alt OFF | Bu BIOS'ta ayrı BGS alanı yok; Bank Swap Mode Auto | Doğrulanamadı |
| tCKE 0 | Alan bulunamadı; HWiNFO'da boş | Doğrulanamadı |
| RttNomWr / RttNomRd OFF | Auto | **Farklı** (uygulanmamış) |
| RttWr RZQ/5 | Auto | **Farklı** (uygulanmamış) |
| RttPark | Auto | Raporda değer yok |

Yani bu sistemde RTT/ODT değerlerini BIOS kendisi seçiyor. Bu değerlerle 8000 MT/s açılıyor ve WHEA hatası yok.

## 4. Ölçülen etki

| | Aşama 0 (JEDEC 5600, BIOS 2402) | Aşama 1 (PD 8000, BIOS 2503) | Fark |
|---|---|---|---|
| Avg FPS | 857,3 (854,3–869,9) | 867,3 (863,7–873,4) | +%1,17, sonuçsuz |
| P1 FPS | 308,5 (295,8–311,1) | 321,8 (316,8–338,5) | **+%4,31, gerçek** |
| P99 kare | 3,24 ms (3,21–3,38) | 3,11 ms (2,95–3,16) | **−%4,01, gerçek** |
| Ortalama kare | 1,17 ms | 1,15 ms | −%1,7, sonuçsuz |

- Ölçüm elle yapıldı, her aşamada 5 koşu.
- BIOS güncellemesi RAM ayarıyla aynı anda yapıldığı için fark yalnız RAM'e atfedilemez.
- 9800X3D'nin büyük L3 önbelleği (3D V-Cache) yüzünden bellek hızı ortalama FPS'i az etkiliyor; etki en kötü kareler tarafında görüldü.

## 5. Kararlılık

- **Bu projede tutulan kayıt:**
  - En az 10 açılış.
  - 132 benchmark koşusu (~5,5 saat CS2 yükü) ve 2 gerçek maç.
  - Tüm açılışlarda WHEA-Logger 0, Kernel-Power 41 0.
  - Çökme ya da donma yok.
- **Bu projede yapılmayan:** TM5, OCCT veya y-cruncher gibi bir bellek testi yapılmadı. Referans rapordaki protokol: her yeni profil için 30 dk CS2 maçı + TM5 (icicle) 1 döngü; ek doğrulama OCCT Memory veya y-cruncher. Rapor PD profili için "stabilite testi devam ediyor" diyor.
- **Sıcaklık:**
  - CS2 sırasında DIMM SPD hub sıcaklığı 38–42 °C.
  - tREFI 65535 sıcaklığa duyarlıdır: sıcak modülde hata olasılığı artar.
  - 1,60 V, XMP'nin 1,35 V'undan yüksek. Daha ağır yükte (bellek testi, render) sıcaklık izlenmeli.

## 6. Nitro deneyi (RAM ile ilgili BIOS ayarı)

- **Ayar:** DDR5 Nitro Mode Enabled, RX Data 1 / TX Data 3 / Control Line 1, Rx/Tx Burst 8x.
- **Neden 1-3-1:** Kullanıcının önceki deneyiminde Nitro 1-2-1 bu ayarda açılmamıştı.
- **ASUS açıklaması:**
  - Nitro "6000 MT/s üzeri bellek desteğini iyileştirebilir, açılış süresi ve/veya gecikme ödünleşimi olabilir".
  - RX/TX/Control Line değeri yükseldikçe frekans payı artar, gecikme de artar.
  - Burst yalnız eğitim deseni uzunluğudur.
- **Sonuç:** Nitro 1-3-1 Avg FPS'i **%1,44 düşürdü** (gerçek). Nitro Auto'ya döndürüldü.

## 7. Hangi belleklerde uyumlu?

Bu değerler yalnız şu birleşimde denendi: bu kit (SK Hynix 24 Gbit M-die, 2 × 24 GB, tek rank), bu işlemci örneği (9800X3D bellek denetleyicisi), bu anakart ve BIOS (ROG STRIX X870-A, 2503). Başka sistemde garanti değildir, en fazla başlangıç noktası olabilir.

| Bellek / sistem | Doğrudan uygulanır mı? | Not |
|---|---|---|
| SK Hynix 24 Gbit M-die, 2 × 24 GB, tek rank (8000 sınıfı kitler) | Başlangıç noktası olarak | En yakın eşleşme. Açılmazsa önce tRCD/tRP, tRFC ve tWTR gevşetilir. Bellek denetleyicisi örnekten örneğe değişir. |
| SK Hynix 16 Gbit A-die, 2 × 16 GB, tek rank | Kısmen | Ana zamanlamalar benzer olabilir. tRFC yoğunluğa bağlıdır: JEDEC tRFC1 16 Gbit için 295 ns, 24 Gbit için 410 ns. Aynı tık sayısı aynı anlama gelmez. |
| 2 × 48 GB, çift rank (2R) | Hayır | Çift rank kitler AM5'te genellikle 8000'e çıkmaz. Rank arası zamanlamalar (tRDRD_DD, tWRWR_DD = 1) tek rank içindir. |
| 4 modül | Hayır | |
| Samsung veya Micron DDR5 | Hayır | Farklı yonga karakteristiği; kendi değerleri bulunmalı |
| Başka AM5 anakart | Kısmen | tWR ≥ 48 bu ASUS BIOS'unun sınırı. 8000 MT/s için bellek denetleyicisi ve kartın yuva düzeni belirleyici. |
| Intel | Hayır | Gear 2/UCLK, FCLK, Nitro ve AMD Overclocking alanları AMD'ye özel |

## 8. Sıradaki RAM adayları (ölçülmedi)

1. **FCLK 2100 / 2167 / 2200** (8000 Gear 2'de, RAM aynı kalır): Kontrollü oyun testi yok, tahmini etki %0–2. Kararsızlık WHEA 19 olarak görünür.
2. **tRDRDSCL / tWRWRSCL 8 → 6:** Referans rapora göre düşük riskli ilk hedef.
3. **tRDWR 20 → 18.**
4. **CL32:** tRCD 46 sabit kalarak; tCWL de birlikte düşürülmeli.
5. **tRFC1 664'ün altı:** Etkisi birkaç ns gecikme; sıcaklık ve kararlılık izlenmeli.
6. **tWTRL:** 16'da kalmalı (14 açılmadı).
