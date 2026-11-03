# CS2 console.log kayıtları

Bu klasör, ölçüm oturumlarında alınan CS2 `console.log` yedeklerini içerir. Her dosya bir CS2 oturumudur. Her benchmark koşusunun VProf raporu (`[VProf] FPS: Avg=…` ve kare süresi tablosu) dosyanın içindedir. CSV dosyalarındaki FPS değerleri bu satırlardan alındı.

Kayıtlar yayımlanmadan önce [`Protect-ConsoleLog.ps1`](../../scripts/bench/Protect-ConsoleLog.ps1) ile anonimleştirildi. Ölçüm satırları değişmedi.

## Anonimleştirme

| Bilgi | Değiştirilen biçim |
|---|---|
| Oyuncu adı | `player1`. Bot adları (`<BOT>`) değişmedi. |
| Steam hesap numarası, SteamID64, `[U:1:…]` | `***`, `[U:1:***]` |
| IP adresleri | Belgeleme için ayrılmış sahte adresler (RFC 5737: `192.0.2.x`, `198.51.100.x`, `203.0.113.x`). Aynı gerçek adres her dosyada aynı sahte adresi alır. Port numaraları ve `127.0.0.1`, `0.0.0.0` değişmedi. |
| `Ping location:` satırı | `***`. Bu satırdaki veri merkezi ping'leri yaklaşık konumu verir. |
| Satır başındaki saat | Logun başından geçen süre. Tarih korundu. Örnek: `11/02 00:03:01` = oturum başladıktan 3 dakika 1 saniye sonra. |
| Dosya adı | `YYYY-AA-GG_<etiket>.log`. Saat kaldırıldı. |

Satır sonları LF, kodlama UTF-8'dir. Birebir aynı yedekler ve başka bir yedeğin baş kısmı olan ara yedekler yazılmadı (43 yedekten 36 dosya). CS2 her açılışta `console.log` dosyasını sıfırlar. Bu yüzden aynı oturumun ara yedekleri, son yedeğin baş kısmıdır.

## Dosyalar

| Dosya | Oturum | Test | Veri |
|---|---|---|---|
| `2026-10-19_console_CS2_acik.log` | `O2` | CPU 0 dışlama, dönüşümlü affinity | [`bios-runs.csv`](../bios-runs.csv) |
| `2026-10-19_PBO200_MB.log` | `O3` | PBO, Motherboard limitleri, Boost Override +200 | `bios-runs.csv` |
| `2026-10-19_CO-10.log` | `O4` | Curve Optimizer −10 | `bios-runs.csv` |
| `2026-10-19_CoreL2.log` | `O5` | Core Tuning Config for Gaming Level 2 | `bios-runs.csv` |
| `2026-10-19_snap.log` | `O6` | DDR5 Nitro 1-3-1, Latency Under Load, Medium Load Boostit ve LLC 6 birlikte | `bios-runs.csv` |
| `2026-10-19_snap_2.log` | `O7` | Nitro Auto | `bios-runs.csv` |
| `2026-10-19_L2Tekrar.log` | `O8` | Core Tuning Level 2 (tekrar) | `bios-runs.csv` |
| `2026-10-19_PRI2x2.log` | `O9` | CS2 affinity × öncelik | `bios-runs.csv` |
| `2026-10-19_SMToff.log` | `O10` | SMT kapalı | `bios-runs.csv` |
| `2026-10-26_snap.log` | `G21` | RAM 6000 1:1 | [`windows-gpu-runs.csv`](../windows-gpu-runs.csv) |
| `2026-10-26_RAM6200.log` | `G22` | RAM 6200 1:1 | `windows-gpu-runs.csv` |
| `2026-10-26_BCLK101.log` | `G23` | BCLK 101 | `windows-gpu-runs.csv` |
| `2026-10-26_BCLK100b.log` | `G24` | RAM 6000 1:1 (tekrar, BCLK 100) | `windows-gpu-runs.csv` |
| `2026-10-26_RAM8000b.log` | `G25` | RAM 8000 (tekrar) | `windows-gpu-runs.csv` |
| `2026-10-26_DRV621.log` | `G26` | Sürücü 621.01 | `windows-gpu-runs.csv` |
| `2026-10-26_NVPERF.log` | `G27` | NVIDIA 3D ayarları | `windows-gpu-runs.csv` |
| `2026-11-02_DRV62112.log` | `G28` | Sürücü 621.12 (taban) | `windows-gpu-runs.csv` |
| `2026-11-02_TEXQ.log` | `G29` | Doku süzme Kalite | `windows-gpu-runs.csv` |
| `2026-11-02_TEXP.log` | `G30` | Doku süzme Performans | `windows-gpu-runs.csv` |
| `2026-11-02_CO_CO10.log` | `G31` | Curve Optimizer −10 | `windows-gpu-runs.csv` |
| `2026-11-02_CO_COAuto.log` | `G32` | Curve Optimizer Auto | `windows-gpu-runs.csv` |
| `2026-11-02_LA_LAUNCH_A.log` … `_D.log` | `G33`–`G36` | Başlatma seçenekleri | `windows-gpu-runs.csv` |
| `2026-11-02_LA_LAUNCH2_E.log`, `_F.log` | `G37`, `G38` | Başlatma seçenekleri | `windows-gpu-runs.csv` |
| `2026-11-02_CO_A1.log`, `_B2.log`, `_A3.log` | `G40`, `G41`, `G42` | Custom OS paketi | `windows-gpu-runs.csv` |
| `2026-11-02_WAB_A1.log`, `_G2.log`, `_B3.log`, `_A4.log` | `G43`, `G44`, `G45`, `G46` | Oyun Modu, custom OS paketi (2. ölçüm) | `windows-gpu-runs.csv` |
| `2026-11-02_LAT_ONCELIK.log` | `G47`, `G48` | Gecikme (CPU 0 dışlama), arka plan önceliği | `windows-gpu-runs.csv`, [`latency-runs.csv`](../latency-runs.csv) |
| `2026-11-03_LAT_GUC.log` | `G49` | Güç planı | `windows-gpu-runs.csv`, `latency-runs.csv` |

Oturum ve test ayrıntıları: [Veri sözlüğü](../README.md). Diğer oturumların (`O0`, `O1`, maçlar, `G1`–`G20`, `G39`) `console.log` yedeği yoktur.

## Okuma

```powershell
.\scripts\bench\Get-VProfReport.ps1 -Log .\data\console-logs\2026-11-02_TEXQ.log -Start '11/02 00:00' -Name TEXQ
```

Betik her koşunun Avg, P1, P99 ve kare süresi değerlerini yazar. Son satırdaki WHEA ve Kernel-Power sayıları sizin bilgisayarınızın olay günlüğünden okunur. Bu kayıtlar için anlamsızdır.

---

[Veri sözlüğü](../README.md) · [Ana sayfa](../../README.md)
