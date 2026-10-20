# cs2-bios-bench

**Ryzen 7 9800X3D + ASUS ROG STRIX X870-A + DDR5-8000 (SK Hynix M-die) + RTX 5070 Ti** için ölçülmüş CS2 ayar rehberi ve ayar kontrol aracı.

- **Rehber:** Hangi BIOS ve Windows ayarının ne kazandırdığı ölçüldü (132 benchmark koşusu). İşe yarayanlar menü yolu ve değeriyle, uygulama sırasıyla yazıldı.
- **Hatırlatıcı ve kontrol:** BIOS güncellemesi veya CMOS sıfırlamasından sonra ayarlar listeden geri girilir. `kontrol/ayar_kontrol.ps1` canlı BIOS'u okuyup neyin eksik veya farklı olduğunu söyler.
- **Ham veri ve araçlar:** Tüm ölçümler, BIOS dökümü ve ölçümde kullanılan PowerShell araçları.

*English: [GUIDE_EN.md](GUIDE_EN.md)*

## Hızlı başlangıç

| Ne yapmak istiyorsun | Nereye bak |
|---|---|
| Ayarları uygulamak (ilk kez ya da BIOS güncellemesinden sonra) | **[REHBER.md](REHBER.md)** |
| Ayarlar yerinde mi kontrol etmek | Yönetici PowerShell: `.\kontrol\ayar_kontrol.ps1` ([REHBER.md bölüm 7](REHBER.md#7-kontrol-her-şey-yerinde-mi)) |
| Kendi ayarlarını kontrol listesine çevirmek | [ayarlar/README.md](ayarlar/README.md) |
| Neyin ne kadar kazandırdığını, yöntemi ve istatistiği görmek | [docs/SONUCLAR.md](docs/SONUCLAR.md) |
| RAM zamanlamaları, voltajlar, hangi belleklerde uyumlu olduğu | [docs/RAM_AYARLARI.md](docs/RAM_AYARLARI.md) |
| BIOS'taki her verinin anlamı, ofsetler, voltaj/sıcaklık okumaları | [docs/BIOS_VERILERI.md](docs/BIOS_VERILERI.md) |
| Donanım, Windows ve CS2 oyun içi ayarları | [docs/SISTEM_VE_OYUN.md](docs/SISTEM_VE_OYUN.md) |

## Sonuç özeti

| Ayar | Avg FPS | P1 / P99 | Karar |
|---|---|---|---|
| RAM JEDEC 5600 → ayarlı 8000 (+ BIOS 2402 → 2503) | +%1,2 (sonuçsuz) | **P1 +%4,3, P99 −%4,0** | Kullanılıyor |
| PBO Advanced + Limits Motherboard + Boost Override +200 | **+%3,5** | sonuçsuz | Kullanılıyor |
| Curve Optimizer All Cores −10 | −%0,3 (etki yok) | sonuçsuz | Açık (zararsız) |
| Core Tuning Config for Gaming Level 2 | doğrulanmadı | sonuçsuz | Açık (zararsız) |
| DDR5 Nitro Mode 1-3-1 | **−%1,4** | sonuçsuz | Auto (kapalı) |
| Latency Under Load + Medium Load Boostit + LLC 6 | sapma içinde | sonuçsuz | Auto |
| SMT kapalı | etki yok | sonuçsuz | Auto (açık) |
| CS2'yi CPU 0'dan uzak tutmak (Windows affinity) | **+%1,8 / +%2,5** (iki ayrı test) | sonuçsuz | Kullanılıyor |
| High işlem önceliği | etki yok | sonuçsuz | Kullanılmıyor |

**Toplam:** Avg FPS 911 → 970 (**+%6,4**), ortalama kare süresi 1,10 → 1,03 ms, P99 2,99 → 2,80 ms. Oturumlar arası sapma ±%0,6.

**Darboğaz durumu:**
- **İşlemci:** CS2'de tüm çekirdekler 5425 MHz'de (boost tavanı), güç sınırının %7,5'inde, en fazla 60 °C. Bu yüzden CO, PBO limitleri ve sıcaklık ayarları ek saat kazandıramıyor.
- **GPU:** Yük p95 %96, yani darboğaz kısmen GPU'da.

## Depo yapısı

| Klasör / dosya | İçerik |
|---|---|
| `REHBER.md`, `GUIDE_EN.md` | Adım adım ayar rehberi (Türkçe / İngilizce) |
| `ayarlar/hedef_ayarlar_2503.csv` | 125 hedef ayar: menü yolu, değer, NVRAM konumu, beklenen ham değer, ölçülen etki |
| `kontrol/ayar_kontrol.ps1` | Canlı BIOS'u ve Windows durumunu hedef listeyle karşılaştırır (salt okunur) |
| `docs/` | Sonuçlar, BIOS verileri, RAM ayarları, sistem ve oyun ayarları |
| `data/` | Tüm koşular (`kosular.csv`), özetler, test tanımları, tam BIOS dökümü ([sütun açıklamaları](data/README.md)) |
| `bench/` | CS2 benchmark otomasyonu ve analiz betikleri |
| `nvram/` | BIOS ayarlarını Windows'tan okuma, görüntü alma, karşılaştırma, döküm |
| `hwinfo/` | HWiNFO paylaşılan belleğinden sensör kaydı |
| `tools/` | BIOS dosyasından ayar sözlüğü çıkarma (`BiosIfr.cs`) ve EFI sıkıştırma açıcı (`EfiDec3b.cs`) |

## Araçlar

Windows PowerShell 5.1 ile yazıldı ve test edildi. Betik çıktıları Türkçedir. Betikleri çalıştırmak için gerekirse önce şunu çalıştır: `Set-ExecutionPolicy -Scope Process Bypass`.

### `kontrol/`: ayar kontrolü

```powershell
# Yönetici PowerShell, depo klasöründe
.\kontrol\ayar_kontrol.ps1                                        # BIOS + Windows
.\kontrol\ayar_kontrol.ps1 -Fan                                   # fan/pompa eğrileri dahil
.\kontrol\ayar_kontrol.ps1 -IfrFile .\yeni_sozluk\ifr_all.tsv     # yeni BIOS sürümünde, ayarları adıyla bulur
.\kontrol\ayar_kontrol.ps1 -Hedef .\benim_hedeflerim.csv          # kendi listen
```

### `bench/`: CS2 ölçümü

CS2 `-condebug` ile açık olmalı (`console.log` oluşması için). `console.log` yolu betiklerin başında tanımlı; Steam başka bir yerdeyse değiştir. Benchmark haritası: Workshop `3240880604` (de_dust2).

| Betik | Ne yapar |
|---|---|
| `run_bench.ps1` | Konsolu açar, `map_workshop 3240880604 de_dust2` yazar, `console.log`'daki `[VProf] FPS:` satırını bekler, sonraki koşuya geçer. Plan biçimi: `-Plan ad:maske:koşu[:öncelik];ad2:…` (öncelik N/A/H). `-Warmups` ilk kaç koşunun ısınma sayılacağını belirler. `bench_stop.txt` oluşturulursa durur. Bitince affinity'yi tüm mantıksal işlemcilere, önceliği Normal'e döndürür. Konsol tuşu Türkçe klavyede `"` (tarama kodu 0x29); başka klavye düzeninde değiştir. |
| `vprof_stage.ps1` | Belirli bir zaman aralığındaki benchmark koşularını okur: Avg/P1/P99, ortalama kare, medyan/aralık, WHEA ve Kernel-Power 41 sayısı, önceki aşamayla karşılaştırma |
| `interleave_report.ps1` | Dönüşümlü koşuları eşleştirilmiş t testi ve aralık çakışmasıyla karşılaştırır |
| `snap_console.ps1` | CS2 her açılışta `console.log`'u sıfırladığı için dosyayı yedekler |
| `cs2_affinity.ps1` | `cs2.exe` affinity değerini okur/ayarlar (`-Mask 0xFFFE`); kalıcı değildir |

```powershell
# CS2 açık, FACEIT kapalı. BIOS değişikliğinden sonra yeni oturumda:
.\bench\run_bench.ps1 -Plan AYAR:0xFFFF:12 -Warmups 6
.\bench\vprof_stage.ps1 -Start '10/19 12:30' -Name AYAR
```

- Plan değerini `Start-Process` ile başka bir PowerShell'e geçirirken tırnak kullanma; tek tırnak betiğe aynen geçer ve hiç koşu yapılmaz.
- Tarihler `console.log` biçimindedir (`MM/dd HH:mm`); yıl betiklerde 2026 olarak sabit.

### `nvram/`: BIOS ayarlarını Windows'tan okuma (yalnız okur)

| Betik | Ne yapar |
|---|---|
| `nvram_snap.ps1` | Tüm NVRAM değişkenlerinin dizinini (ad, GUID, boyut, SHA256) ve ayar değişkenlerinin ham baytını kaydeder. Parola/anahtar/lisans/TPM adlı değişkenler kaydedilmez. `-OutDir` olarak görüntü klasörünün kendisini ver. |
| `nvram_diff.ps1` | İki görüntüyü karşılaştırır. `-Decoded` / `-IfrFile` verilirse ayar adı ve seçenek metniyle yazar. |
| `bios_dump.ps1` | Bir görüntüyü ayar sözlüğüyle birleştirip okunur döküm (CSV + Markdown) üretir |

### `hwinfo/`: sensör kaydı

`hw_sample.ps1`, HWiNFO'nun paylaşılan belleğinden (`Global\HWiNFO_SENS_SM2`; HWiNFO'da "Shared Memory Support" açık olmalı) tüm sensörleri 1 sn aralıkla CSV'ye yazar. `hw_report.ps1` bu CSV'den özet çıkarır. `hwinfo_sm_read.ps1` anlık değerleri listeler.

### `tools/`: BIOS ayar sözlüğü

```powershell
Add-Type -Path .\tools\BiosIfr.cs, .\tools\EfiDec3b.cs
[Prog]::Main(@('C:\yol\BIOS.CAP', '.\sozluk'))     # sozluk\ifr_all.tsv: menü, ad, değişken, ofset, seçenekler, varsayılan
```

AMI Aptio BIOS kapsülünü (`.CAP`) açar: FV → FFS → LZMA/Tiano → PE32 → HII → IFR. BIOS 2503'te 9304 ayar çıkıyor (408'i gizli). Sözlük, üreticinin telifli BIOS dosyasından türediği için depoda yok; kendi indirdiğin BIOS dosyasından çıkarılır.

## Uyarılar

- **Risk:** RAM hız aşırtması, voltaj artışı ve PBO garanti kapsamını etkileyebilir, kararsızlığa yol açabilir. Kendi sorumluluğunda kullan. Değerler tek bir sistemde denendi.
- **Anti-cheat:** `run_bench.ps1` CS2 penceresine SendInput ile klavye girdisi gönderir. Bu FACEIT, VAC vb. ile çakışabilir. Yalnız anti-cheat **kapalıyken** kullan. Betik FACEIT işlemini görürse durur, ama bu bir garanti değildir.
- **Sistem değişikliği:** `kontrol/` ve `nvram/` betikleri NVRAM'e hiçbir şey yazmaz. Hiçbir betik oyun dosyalarını, kayıt defterini, servisleri veya sürücüleri değiştirmez. Yalnız `bench/` betikleri çalışan `cs2.exe`'nin affinity ve önceliğini değiştirir; CS2 kapanınca sıfırlanır.
- **Lisans:** MIT, bkz. `LICENSE`.
