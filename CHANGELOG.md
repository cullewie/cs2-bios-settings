# Değişiklik günlüğü

Bu dosya, depodaki önemli değişiklikleri listeler. Biçim [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) kurallarına uyar. Bu depo sürüm numarası yerine yayın tarihini kullanır (`YYYY-AA-GG`).

## 2026-10-26

### Eklendi

- Belgeler `docs/` klasöründe ayrı sayfalara bölündü: [BIOS](docs/bios.md), [Windows ve CS2](docs/windows.md), [ekran kartı](docs/gpu.md), [kontrol](docs/verification.md), [uyarlama](docs/adapting.md), [sonuçlar](docs/results.md), [ölçüm yöntemi](docs/methodology.md), [sorun giderme](docs/troubleshooting.md) ve [sınırlar](docs/limitations.md).
- İngilizce giriş sayfası: [README.en.md](README.en.md).
- [Veri sözlüğü](data/README.md), [betik başvurusu](scripts/README.md) ve [hedef ayar listesi açıklaması](config/README.md).
- [LICENSE](LICENSE) (MIT), [CITATION.cff](CITATION.cff), [CONTRIBUTING.md](CONTRIBUTING.md), sorun şablonları, `.gitattributes`, `.editorconfig` ve `.gitignore`.
- Gölge kalitesi Yüksek ile profil karşılaştırması: +425 stoğa göre +%3,3, undervolt −%0,2 (sapma içinde). Gölge Yüksek'in maliyeti −%5,8.
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
