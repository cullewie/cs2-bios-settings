# Değişiklik günlüğü

Bu dosya, depodaki önemli değişiklikleri listeler. Biçim [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) kurallarına uyar. Bu depo sürüm numarası yerine yayın tarihini kullanır (`YYYY-AA-GG`).

## 2026-11-02

### Eklendi

- [Curve Optimizer −10 ile Auto](docs/bios.md) karşılaştırması: CS2'de fark %0,33, aynı günkü oturum sapması (%0,32) kadar. Ağır tüm çekirdek yükte Auto ile saat %2,6 düşük. Bu sistem artık Curve Optimizer Auto kullanır.
- [CS2 başlatma seçenekleri](docs/windows.md#cs2-başlatma-seçenekleri): `-threads 9`, `-mainthreadpriority 2` ve `-nojoy +violence_hblood 0 +engine_low_latency_sleep_after_client_tick true` aynı Windows oturumunda üç kontrol bloğuyla ölçüldü. Hiçbiri ölçülebilir kazanç vermedi.
- [NVIDIA sürücüsü ve sürücü ayarları](docs/windows.md#nvidia-sürücüsü-ve-sürücü-ayarları): 621.01 ve 621.12 oturumları (617.42'ye göre −%0,8 ile −%1,3; CS2 ve Windows da güncellendi, sürücüye atfedilemez), NVIDIA App genel 3D ayarları (etki yok) ve doku süzme Kalite/Performans (fark sapma içinde).
- Veri: [`windows-gpu-runs.csv`](data/windows-gpu-runs.csv) dosyasına `G26` … `G38` oturumları eklendi (65 koşu, toplam 222).
- Betik: [`Compare-LaunchOption.ps1`](scripts/windows/Compare-LaunchOption.ps1). CS2 başlatma seçeneklerini kontrol bloklarıyla karşılaştırır.
- [Sapma kaynakları](docs/methodology.md#sapma-kaynakları): Windows oturumunun ilk ~40 dakikasında %1'e varan düşüş ve sürücü/CS2/Windows güncellemesi satırları.

### Değişti

- Kontrol listesi ([`bios-target-2503.csv`](config/bios-target-2503.csv)): Curve Optimizer hedefi Disabled (Auto) oldu. All Cores işaret ve büyüklük satırları kaldırıldı. Satır sayısı 126'dan 124'e indi (70 ayar ve 54 fan noktası). Core Tuning satırındaki "zararsız" notu kaldırıldı.
- Test sistemi bilgisi: NVIDIA sürücüsü 621.12.
- [Sınırlar](docs/limitations.md): Bloklu ölçümde kontrol bloğu uyarısı, sürücü güncellemesi ve gecikme ölçümü satırları güncellendi.

## 2026-10-27

### Değişti

- RAM için varsayılan öneri artık kitin kendi EXPO veya XMP profilidir ([BIOS](docs/bios.md#ram)). Bu profil bu depoda ölçülmedi.
- Elle DDR5-6000 1:1 bir alternatif oldu. Elle DDR5-8000 CL34 profili (1,60 V, tREFI 65535) varsayılan öneriden çıkarıldı. Bu profil ileri düzey bir seçenek olarak kaldı ve bellek kararlılık testi gerektirir. Ölçüm sonuçları değişmedi.
- Curve Optimizer ve Core Tuning Config for Gaming için öneri Auto oldu. Bu ayarların ölçülebilir FPS kazancı doğrulanmadı. Çekirdek bazında kararlılıkları test edilmedi.
- PBO ve Boost Override +200 sonucuna not eklendi: tek sistemde ölçüldü, üç ayar birlikte değişti, depoda çekirdek bazında CPU kararlılık testi yok. Karar "Kullanın" yerine "Kullanılabilir, CPU kararlılığını test edin" oldu.
- [Başka sistemlere uyarlama](docs/adapting.md): PBO ve Curve Optimizer değerlerinin başka işlemcilere kopyalanmaması gerektiği yazıldı.
- [Grafik](docs/img/fps-gains.svg): Alt satırdaki RAM 8000 notu ve toplam tahmini kaldırıldı. Yerine ölçümün sınırları yazıldı.
- DDR5-6000 ile DDR5-8000 karşılaştırmasındaki "aynı ortalama FPS" ve "fark yok" gibi kesin ifadeler kaldırıldı ([BIOS](docs/bios.md#ddr5-6000-11-alternatifi), [sonuçlar](docs/results.md), [sınırlar](docs/limitations.md), README). Yeni ifade: karşılaştırmada 6000 için iki oturum, 8000 için yalnızca bir oturum kullanıldı. İlk 8000 oturumu %1,2 düşük çıktığı için karşılaştırmaya alınmadı. Mevcut ölçümler güvenilir bir performans farkı ortaya koymuyor. Veriler bir üstünlüğü veya eşdeğerliği göstermek için yetersizdir. Ölçüm değerleri değişmedi.
- README'deki "RAM ve BCLK testleri A-B-A sırasıyla doğrulandı" ifadesi düzeltildi. Bu testler 2 ısınma ve 3 kayıt koşusuyla ölçüldü. A-B-A kontrolü DDR5-6000 ve BCLK için tuttu, DDR5-8000 için tutmadı.
- [Ölçüm yöntemi](docs/methodology.md#karar-kuralı): Aynı düzeltme "sonuçlar A-B-A sırasıyla doğrulandı" ifadesinde yapıldı. Test kuralı (2 ısınma, 3 kayıt, 5 sıra eşleştirilmiş t testi) değişmedi.
- [BIOS: RAM](docs/bios.md#ddr5-6000-11-alternatifi) ve [BCLK](docs/bios.md#bclk): Oturumlar arası yüzdeler hesaplama yöntemiyle birlikte verildi (3 kayıt koşusu veya ısınma dahil 5 koşu). Hiçbir yöntemle elde edilemeyen "%0,05" değeri kaldırıldı. "Beş koşu sırasının beşinde de 6000 önde" ifadesi düzeltildi: ilk 6000 oturumu beş sıranın dördünde öndedir. İlk 8000 oturumundan önceki sürücü hatası (TDR) artık %1,2 farkın nedeni gibi yazılmıyor; neden bulunamadı. Ölçüm değerleri değişmedi.
- [Betikler](scripts/README.md): `-Warmups` açıklaması netleştirildi. Planın ilk N koşusu ısınma sayılır, her blok için ayrı ısınma yoktur. Betiğin bu davranışı değişmedi.
- Not: Kontrol betiği ([`Test-Configuration.ps1`](scripts/check/Test-Configuration.ps1)) ve hedef liste ([`bios-target-2503.csv`](config/bios-target-2503.csv)) bu sürümde değişmedi. İkisi hâlâ elle DDR5-8000, Curve Optimizer −10 ve Core Tuning Level 2 değerlerini hedefler. Yeni varsayılanları kullanan sistemlerde bu satırlar FARKLI görünür.

### Eklendi

- [BIOS: Bellek kararlılık testi](docs/bios.md#bellek-kararlılık-testi) bölümü ve WHEA uyarısı: WHEA hatası olmaması bellek kararlılığını kanıtlamaz.
- [Sınırlar](docs/limitations.md): Bellek ve işlemci kararlılığı, WHEA ve PBO ölçümü maddeleri. Test edilmeyen konulara EXPO/XMP profili, uzun bellek testi ve çekirdek bazında CPU kararlılık testi eklendi.

### Kaldırıldı

- Curve Optimizer −10 ve Core Tuning Level 2 için "zararsız" ifadeleri.

### Düzeltildi

- [`Invoke-Cs2Benchmark.ps1`](scripts/bench/Invoke-Cs2Benchmark.ps1): CS2'nin affinity ve önceliği artık başlangıçtaki değerlere döner. Önceden tüm çekirdeklere ve Normal önceliğe dönüyordu. Durdurma dosyası, odak hatası, CS2'nin kapanması, Ctrl+C ve diğer hatalarda hiç geri yükleme yapılmıyordu. Geri yükleme artık her çıkışta `finally` içinde yapılır. Güvenlik kontrolü (FACEIT, `bench_stop.txt`) geri yüklemeyi engellemez.
- Aynı betik: CS2 işlemi PID ve başlangıç zamanıyla izlenir. CS2 kapanırsa veya PID başka bir işleme geçerse betik o işleme dokunmaz. Birden fazla `cs2.exe` varsa betik başlamaz.
- Aynı betik: Plan (maske, koşu sayısı, öncelik) ve `console.log` yolu çalıştırmadan önce doğrulanır. Hata varsa betik hiçbir şeyi değiştirmez. `console.log` yolu için `-Log` parametresi eklendi.
- Aynı betik: `console.log` saatlerinin yılı sabit 2026 yerine çalıştırma tarihinden alınır. Yıl dönümündeki ve geçersiz tarihli satırlar betiği durdurmaz.
- Aynı betik: Her koşuda yalnızca komuttan önce kaydedilen konumdan sonra `console.log` dosyasına eklenen satırlar okunur. VProf satırı ancak yeni harita satırından sonra gelirse kabul edilir. Önceden dosyanın tamamı yalnızca saat süzgeciyle taranıyordu. Bu yüzden harita yüklenmeden gelen bir VProf satırı (örneğin yarıda kesilen önceki çalıştırmanın raporu) veya saati ileri görünen eski bir satır yeni koşunun sonucu sayılabiliyordu (sentetik testle gösterildi). Dosya kısalırsa veya yeniden oluşturulursa koşunun geri kalanında dosya baştan okunur ve uyarı yazılır. Satır sonu henüz yazılmamış son satır okunmaz; yarım yazılmış bir VProf satırından kesik değer alınmaz.

## 2026-10-26

### Eklendi

- Belgeler `docs/` klasöründe ayrı sayfalara bölündü: [BIOS](docs/bios.md), [Windows ve CS2](docs/windows.md), [ekran kartı](docs/gpu.md), [kontrol](docs/verification.md), [uyarlama](docs/adapting.md), [sonuçlar](docs/results.md), [ölçüm yöntemi](docs/methodology.md), [sorun giderme](docs/troubleshooting.md) ve [sınırlar](docs/limitations.md).
- İngilizce giriş sayfası: [README.en.md](README.en.md).
- [Veri sözlüğü](data/README.md), [betik başvurusu](scripts/README.md) ve [hedef ayar listesi açıklaması](config/README.md).
- [LICENSE](LICENSE) (MIT), [CITATION.cff](CITATION.cff), [CONTRIBUTING.md](CONTRIBUTING.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), [SECURITY.md](SECURITY.md), sorun ve pull request şablonları, `.gitattributes`, `.editorconfig` ve `.gitignore`.
- RAM ve BCLK ölçümleri ([BIOS](docs/bios.md#ddr5-6000-11-alternatifi)): DDR5-6000 CL28 1:1 ile DDR5-8000 Gear 2 arasında ölçülebilir fark yok (+%0,2 ile +%0,4, A-B-A). 6200 1:1, 6000 ile aynı. 6400 1:1 iki açılışta mavi ekran verdi. BCLK 101 +%0,4 verdi, önerilmez. BCLK 102 açılmadı. Veri: [`data/windows-gpu-runs.csv`](data/windows-gpu-runs.csv) `G21`–`G25`.
- Sorun giderme: RAM frekansından sonra mavi ekran ve BCLK sonrası açılmama.
- Gölge kalitesi Yüksek ile profil karşılaştırması: +425 stoğa göre +%3,3, undervolt −%0,2 (sapma içinde). Gölge Yüksek'in maliyeti −%4,7.
- Undervolt (VF eğrisi) ölçümleri: çökme sınırı, uzun doğrulama ve uzun CS2 oturumundaki sürücü hatası. Karar: kullanmayın.
- Günler arasındaki FPS farklarının ölçülmüş nedenleri ([Sapma kaynakları](docs/methodology.md#sapma-kaynakları)).

### Değişti

- Günlük ekran kartı değeri +450'den **+425**'e indi. +450, soğuk kartta 3255–3262 MHz'e çıkarak CS2'de ikinci kez sürücü hatası verdi. FPS değişmez.
- README kısa bir giriş sayfası oldu.
- Klasör ve dosya adları İngilizceye çevrildi. PowerShell betikleri Fiil-İsim düzeninde adlandırıldı (aşağıdaki tablo). Belgelerin dili Türkçe kaldı.
- [`data/bios-final-state.csv`](data/bios-final-state.csv) ve [`data/bios-aod-fields.csv`](data/bios-aod-fields.csv) güncel BIOS durumuna getirildi: FCLK 2200, Global C-state Enabled, Power Supply Idle Control Typical Current Idle, Integrated Graphics Disabled.
- Tüm metin dosyalarının satır sonu LF oldu.

### Düzeltildi

- Depoda lisans yoktu. MIT lisansı eklendi.
- Güncelliğini yitirmiş notlar düzeltildi: sıradaki ölçüm, test edilmeyen konular, ekran kartı kararlılığı.
- Gölge Yüksek'in maliyeti −%5,8 değil, **−%4,7**. İlk ölçümün yapıldığı oturum, aynı BIOS ve profilin tekrar ölçümünden %1,2 düşük çıktı. Oturumlar arası sapma notları buna göre güncellendi.
- "Steam'i kalıcı olarak CPU 0 dışında başlatma" notu doğru bölüme (CPU 0) taşındı.

### Eski ve yeni yollar

| Eski | Yeni |
|---|---|
| `bench/run_bench.ps1` | `scripts/bench/Invoke-Cs2Benchmark.ps1` |
| `bench/vprof_stage.ps1` | `scripts/bench/Get-VProfReport.ps1` |
| `bench/interleave_report.ps1` | `scripts/bench/Compare-InterleavedRun.ps1` |
| `bench/snap_console.ps1` | `scripts/bench/Backup-ConsoleLog.ps1` |
| `bench/cs2_affinity.ps1` | `scripts/bench/Set-Cs2Affinity.ps1` |
| `nvram/nvram_snap.ps1` | `scripts/bios/Save-NvramSnapshot.ps1` |
| `nvram/nvram_diff.ps1` | `scripts/bios/Compare-NvramSnapshot.ps1` |
| `nvram/bios_dump.ps1` | `scripts/bios/Export-BiosSetting.ps1` |
| `tools/BiosIfr.cs`, `tools/EfiDec3b.cs` | `scripts/bios/BiosIfr.cs`, `scripts/bios/EfiDec3b.cs` |
| `kontrol/ayar_kontrol.ps1` | `scripts/check/Test-Configuration.ps1` |
| `gpu/ab_profil_yaz.ps1` | `scripts/gpu/Set-AfterburnerProfile.ps1` |
| `gpu/cs2_gpu_ab.ps1` | `scripts/gpu/Compare-GpuProfile.ps1` |
| `gpu/gpu_saat_kilit_ab.ps1` | `scripts/gpu/Measure-GpuClockScaling.ps1` |
| `gpu/vf_egri_yaz.ps1` | `scripts/gpu/Set-VfCurve.ps1` |
| `hwinfo/hw_sample.ps1` | `scripts/hwinfo/Export-HwinfoLog.ps1` |
| `hwinfo/hw_report.ps1` | `scripts/hwinfo/Get-HwinfoSummary.ps1` |
| `hwinfo/hwinfo_sm_read.ps1` | `scripts/hwinfo/Get-HwinfoSensor.ps1` |
| `windows/irq_sample.ps1` | `scripts/windows/Measure-InterruptLoad.ps1` |
| `windows/dump_ozet.ps1` | `scripts/windows/Get-DumpSummary.ps1` |
| `windows/dpc_lat.ps1`, `windows/DpcEtl.cs` | `scripts/windows/Measure-DpcLatency.ps1`, `scripts/windows/DpcEtl.cs` |
| `windows/pm_ab.ps1`, `windows/PmRapor.cs` | `scripts/windows/Compare-PresentMode.ps1`, `scripts/windows/PresentMonReport.cs` |
| `ayarlar/hedef_ayarlar_2503.csv` | `config/bios-target-2503.csv` |
| `data/kosular.csv` | `data/bios-runs.csv` |
| `data/ozet.csv` | `data/bios-summary.csv` |
| `data/testler.csv` | `data/bios-tests.csv` |
| `data/bios_son_durum.csv` | `data/bios-final-state.csv` |
| `data/bios_aod_alanlari.csv` | `data/bios-aod-fields.csv` |
| `data/gpu_windows_kosular.csv` | `data/windows-gpu-runs.csv` |
| `data/gpu_superposition.csv` | `data/gpu-superposition.csv` |
| `data/gpu_kararlilik.csv` | `data/gpu-stability.csv` |
| `docs/kazanc.svg` | `docs/img/fps-gains.svg` |

## 2026-10-24

### Eklendi

- Windows ve ekran kartı sonuçları: CPU 0 dışlama, MSI Afterburner ile hız aşırtma (+%2,6), Core Voltage, bellek saati, Resizable BAR ve Vulkan (−%6).
- Tam ekran iyileştirmeleri kapalı (Legacy Flip): +%1,13, A-B-A ile doğrulandı.
- FCLK 2200 sonucu ve AMD Overclocking menüsündeki ikinci FCLK ayarı notu. Global C-state, Power Supply Idle Control ve iGPU ölçümü.
- DPC ve kesme süresi ölçümü, PresentMon oturum ölçümü, CPU başına kesme örnekleme ve minidump özeti betikleri.
- Ekran kartı ölçüm betikleri ve Windows ve ekran kartı ölçüm verileri.
- Ölçülen FPS kazancı grafiği (açık ve koyu tema).

### Değişti

- Benchmark betiği bitince CS2 penceresini ve terminali önceki düzenine döndürür.

### Düzeltildi

- README'deki Türkçe karakter bozulması.

## 2026-10-20

### Eklendi

- İlk yayın: CS2 BIOS ayar rehberi, 132 benchmark koşusunun verisi, NVRAM okuma ve ayar kontrol betikleri.

### Değişti

- README tek rehber olarak yeniden yazıldı. Dil, ASD-STE100 kurallarına göre sadeleştirildi.
