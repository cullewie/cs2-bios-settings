# Sistem, Windows ve oyun ayarları

## 1. Donanım

| Parça | Model |
|---|---|
| İşlemci | AMD Ryzen 7 9800X3D (8 çekirdek / 16 thread, tek CCD, 3D V-Cache) |
| Anakart | ASUS ROG STRIX X870-A GAMING WIFI |
| BIOS | 2503 (18.10.2026'da 2402'den güncellendi) |
| Bellek | G.Skill F5-8000J4048F24GX2-TZ5RK, 2 × 24 GB, SK Hynix M-die, tek rank ([RAM_AYARLARI.md](RAM_AYARLARI.md)) |
| Ekran kartı | GIGABYTE GeForce RTX 5070 Ti AERO OC 16G (güç sınırı 300 W, en fazla 350 W) |
| Ekran | Alienware AW2523HF, 1920×1080 360 Hz, DisplayPort |
| İşlemci soğutucu | Arctic Liquid Freezer III Pro 360 (AIO) |
| Depolama | Samsung 980 PRO 500 GB (NVMe) |

## 2. Windows

| Ayar | Değer |
|---|---|
| Sürüm | Windows 11 Pro 26H2, derleme 26300 (Insider değil) |
| Bellek Bütünlüğü (HVCI) / VBS | Açık / çalışıyor (FACEIT gerektiriyor) |
| Donanım hızlandırmalı GPU zamanlaması (HAGS) | Açık |
| Oyun Modu | Kapalı (AutoGameModeEnabled 0) |
| Game DVR (AppCaptureEnabled) | 1 |
| Win32PrioritySeparation | 2 (varsayılan) |
| Fare hızlandırma | Kapalı (MouseSpeed 0, eşikler 0) |
| CS2 için uyumluluk (tam ekran iyileştirmeleri) kaydı | Yok (değiştirilmedi) |
| MPO (OverlayTestMode), GlobalTimerResolutionRequests | Kayıt yok (varsayılan) |
| NVIDIA sürücüsü | 617.42, WDDM 3.2 |
| GPU bağlantısı | PCIe 5.0 x16 |
| Resizable BAR | Açık (BAR1 16384 MiB) |

### Güç planı

Özel plan ("FPSHEAVEN2026"), AC değerleri:

| Ayar | Değer |
|---|---|
| En düşük / en yüksek işlemci durumu | %100 / %100 |
| Enerji performansı tercihi (EPP) | 0 |
| Performans artırma (boost) modu | 5 (Aggressive At Guaranteed) |
| Otonom mod | 1 |
| Çekirdek park etme (en az / en çok çekirdek) | %100 / %100 (park yok) |
| Boşta kalmayı devre dışı bırak | 0 |
| Gecikme duyarlılığı ipucu (performans / EPP) | 100 / 100 |
| En yüksek işlemci frekansı | 0 (sınırsız) |
| PCI Express bağlantı durumu güç yönetimi | Kapalı |
| USB seçmeli askıya alma | Kapalı |
| Kablosuz bağdaştırıcı güç tasarrufu | 0 |

Güç planı bu projede test edilmedi. İşlemci CS2'de zaten saat tavanında olduğu için güç planından beklenen etki küçük.

### CS2'yi CPU 0'dan uzak tutmak (uygulanan tek Windows değişikliği)

1. Steam açıkken Görev Yöneticisi → Ayrıntılar → `steam.exe` → sağ tık → Benzeşimi ayarla → **CPU 0'ın işaretini kaldır**.
2. CS2'yi Steam'den başlat. Alt işlemler benzeşimi üst işlemden devralır, bu yüzden `cs2.exe` de CPU 0'sız açılır. `cs2.exe`'ye doğrudan dokunulmaz.
3. Steam her yeniden başladığında bu adım tekrarlanmalı.

Ölçülen etki: Avg +%1,8 ile +%2,5 arası, P1/P99 değişmedi ([SONUCLAR.md](SONUCLAR.md)). FACEIT'in bu yöntem hakkında resmi bir açıklaması bulunamadı.

## 3. CS2 oyun içi ayarları

Kaynak: `cs2_video.txt` (değiştirilmedi). Tüm ölçümlerde aynıydı.

| Ayar (dosyadaki ad) | Değer | Anlamı |
|---|---|---|
| Çözünürlük (`defaultres` × `defaultresheight`) | 1280 × 960 | 4:3 |
| `aspectratiomode` | 0 | 4:3 |
| Yenileme hızı | 360 Hz | |
| `fullscreen` | 1 | Tam ekran |
| `nowindowborder` | 1 | |
| `fullscreen_min_on_focus_loss` | 1 | Odak kaybında simge durumuna küçült |
| `mat_vsync` | 0 | V-Sync kapalı |
| `high_dpi` | 0 | |
| `r_low_latency` | 0 | NVIDIA Reflex kapalı |
| `msaa_samples` | 2 | MSAA 2x |
| `r_csgo_cmaa_enable` | 0 | CMAA kapalı |
| `r_texturefilteringquality` | 5 | Anizotropik 16x |
| `shaderquality` | 0 | Düşük |
| `videocfg_shadow_quality` | 0 | Düşük |
| `videocfg_dynamic_shadows` | 1 | Tümü |
| `videocfg_texture_detail` | 0 | Düşük |
| `videocfg_particle_detail` | 0 | Düşük |
| `videocfg_ao_detail` | 0 | Ortam aydınlatması kapalı |
| `videocfg_hdr_detail` | -1 | Performans |
| `videocfg_fsr_detail` | 0 | FSR kapalı |
| `cpu_level` / `gpu_level` / `gpu_mem_level` | 3 / 3 / 3 | Otomatik yapılandırma seviyeleri |

| Diğer | Değer |
|---|---|
| `fps_max` | 0 (sınırsız). Benchmark haritası workshop haritası olduğu için `fps_max` gibi cvar'ları değiştirmeye izin vermiyor ("DISALLOWED WORKSHOP CONVAR"). |
| Başlatma seçenekleri | `+exec crosshair.cfg -condebug` (`-steam` parametresini Steam kendisi ekler). `-condebug`, VProf sonuçlarının `console.log`'a yazılması için gerekli. Performans etkisi ölçülmedi. |
| İşlem önceliği | Normal (High denendi, etkisiz) |

Grafik ayarlarının (MSAA, Reflex vb.) etkisi bu projede test edilmedi; ayarlar olduğu gibi bırakıldı.

## 4. FACEIT nedeniyle dokunulmayanlar

FACEIT Anti-Cheat Secure Boot, IOMMU, TPM 2.0, TPM Attestation, HVCI (Bellek Bütünlüğü) ve Windows güvenlik güncellemelerini denetliyor. Bu yüzden bunlara ve bağlı BIOS alanlarına hiç dokunulmadı:
- Secure Boot ve CSM (Launch CSM Disabled).
- Firmware TPM.
- IOMMU (Auto).
- SVM.
- DMA koruması (BME DMA Mitigation).
- Pluton.
- VBS/HVCI.
- Windows Update.

Ölçüm sırasında FACEIT kapalıydı; `run_bench.ps1` FACEIT işlemi görürse durur.

## 5. Fan ve pompa

Fan ve pompa ayarları performans ölçümünün parçası değildi.

- **CPU fanı ve kasa fanı 1:** BIOS Q-Fan'da PWM Mode, Manual eğri.
- **AIO pompa:** PWM Mode, Manual eğri. Noktalar:

  | Sıcaklık | 30 °C | 40 °C | 50 °C | 58 °C | 65 °C | 70 °C | 85 °C | 100 °C |
  |---|---|---|---|---|---|---|---|---|
  | Duty | %20 | %20 | %36 | %52 | %68 | %84 | %100 | %100 |

- **CPU fanı ve kasa fanı 1 eğrisi:** 20/30/40/50/60/67/70/100 °C → %20/26/34/45/60/80/100/100.

- **Ölçülen pompa devri:** Boşta 1235–1241 rpm. Önceki "Full Speed" ayarında 2766–2800 rpm idi.
- **Neden düşük eğri sorun değil:** Arctic'in pompası PWM kontrollü, 800–2800 rpm aralığında çalışmak üzere tasarlanmış. CS2'de işlemci ~75 W çekiyor ve en fazla 60 °C oluyor.
