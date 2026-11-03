# Betikler

Ölçüm, kontrol ve analiz betikleri. Tüm betikler **Windows PowerShell 5.1** ile Windows 11'de test edildi. Betik çıktıları Türkçedir.

## Başlamadan önce

- Betikleri depo kök klasöründen çalıştırın. Örnek: `.\scripts\check\Test-Configuration.ps1`.
- Gerekirse önce şu komutu çalıştırın: `Set-ExecutionPolicy -Scope Process Bypass`. Bu ayar yalnızca açık PowerShell penceresi için geçerlidir.
- Benchmark otomasyonu CS2'ye tuş gönderir. **FACEIT veya başka bir hile koruması açıkken otomasyon betiklerini çalıştırmayın.**
- Koşu sırasında klavyeye, fareye ve terminale dokunmayın. Odak değişirse koşu geçersiz sayılır.

| Klasör | Görev | Yönetici | Sistemde ne değişir |
|---|---|---|---|
| [`bench/`](#bench-cs2-ölçümü) | CS2 benchmark otomasyonu ve sonuç analizi | Hayır | CS2'nin affinity ve öncelik değeri, yalnızca oturum boyunca |
| [`bios/`](#bios-bios-okuma-yalnızca-okur) | NVRAM görüntüsü, karşılaştırma, BIOS ayar sözlüğü | Evet | Hiçbir şey. NVRAM'i yalnızca okur. |
| [`check/`](#check-ayar-kontrolü-yalnızca-okur) | BIOS ve Windows ayar kontrolü | Evet | Hiçbir şey |
| [`gpu/`](#gpu-ekran-kartı-ölçümü) | Afterburner profilleri ve ekran kartı ölçümü | Evet | Afterburner profil dosyası (önce yedeklenir). Geçici GPU saat kilidi (sonunda kaldırılır). |
| [`hwinfo/`](#hwinfo-sensör-kaydı-yalnızca-okur) | HWiNFO sensör kaydı | Hayır | Hiçbir şey |
| [`windows/`](#windows-kesme-dpc-ve-sunum-analizi) | Kesme, DPC, PresentMon ve döküm analizi | Bazıları | Hiçbir şey. Çekirdek izleme kaydı (ETW) ölçüm boyunca açılır. |

Betiklerin ürettiği dosyalar (`bench_progress.txt`, `sonuc\`, `console_log\`) depoya eklenmez ([`.gitignore`](../.gitignore)).

## bench: CS2 ölçümü

CS2, `-condebug` seçeneğiyle açık olmalıdır. Steam farklı bir klasördeyse `console.log` yolunu `-Log` parametresiyle verin (`Invoke-Cs2Benchmark.ps1`, `Get-VProfReport.ps1`, `Compare-InterleavedRun.ps1`). `Backup-ConsoleLog.ps1` betiğinde yol, betiğin başında tanımlıdır.

| Betik | Görevi |
|---|---|
| [`Invoke-Cs2Benchmark.ps1`](bench/Invoke-Cs2Benchmark.ps1) | Konsolu açar, haritayı yükler, `[VProf] FPS:` satırını bekler ve sonraki koşuya geçer. Her koşuda yalnızca komuttan sonra `console.log` dosyasına eklenen satırları okur. VProf satırını ancak yeni harita satırından sonra gelirse o koşunun sonucu sayar. Plan biçimi: `-Plan ad:maske:koşu[:öncelik];…`. Öncelik değeri N, A veya H olabilir. Plan (maske, koşu sayısı, öncelik) ve `console.log` yolu çalıştırmadan önce doğrulanır. Hata varsa betik hiçbir şeyi değiştirmeden durur. `-Warmups N`: planın ilk N koşusu ısınma sayılır. Sayaç bloklar arasında sürer, her blok için ayrı ısınma yoktur ([Ölçüm yöntemi](../docs/methodology.md#isınma-koşuları-ve-sapma)). `bench_stop.txt` dosyası oluşturulursa betik durur. Başlangıçtaki affinity ve önceliği kaydeder. Bitişte, hatada, durdurma dosyasında ve Ctrl+C ile durdurulduğunda bu değerlere döner. FACEIT çalışıyorsa CS2'ye dokunmaz ve uyarı yazar. CS2 kapanırsa veya işlem kimliği (PID) başka bir işleme geçerse o işleme dokunmaz. CS2 başta simge durumundaysa yeniden simge durumuna alır ve önceki pencereyi öne getirir. Plan adlarındaki boşluklar `_` olur. Çıktı satırları `Write-Host` ile yazılır. Başka bir betikten çağırırken satırları `6>&1` ile yakalayın. |
| [`Get-VProfReport.ps1`](bench/Get-VProfReport.ps1) | Belirli bir zaman aralığındaki koşuları okur. Avg, P1, P99, ortalama kare süresi, WHEA ve Kernel-Power 41 sayısını verir. |
| [`Compare-InterleavedRun.ps1`](bench/Compare-InterleavedRun.ps1) | Dönüşümlü koşuları eşleştirilmiş t testi ile karşılaştırır. |
| [`Backup-ConsoleLog.ps1`](bench/Backup-ConsoleLog.ps1) | `console.log` dosyasını yedekler. CS2 her açılışta bu dosyayı sıfırlar. |
| [`Protect-ConsoleLog.ps1`](bench/Protect-ConsoleLog.ps1) | `console.log` yedeklerini paylaşmadan önce anonimleştirir: oyuncu adları, Steam kimlikleri, IP adresleri, ping konumu ve günün saati. Kaynak dosyalara dokunmaz. Ayrıntı: [`data/console-logs`](../data/console-logs/README.md#anonimleştirme). |
| [`Set-Cs2Affinity.ps1`](bench/Set-Cs2Affinity.ps1) | `cs2.exe` affinity değerini okur veya ayarlar (`-Mask 0xFFFE`). Bu değer kalıcı değildir. |

```powershell
# CS2 açık olsun. FACEIT kapalı olsun. BIOS değişikliğinden sonra yeni oturumda:
.\scripts\bench\Invoke-Cs2Benchmark.ps1 -Plan AYAR:0xFFFF:12 -Warmups 6
.\scripts\bench\Get-VProfReport.ps1 -Start '10/19 12:30' -Name AYAR
```

**Notlar:**
- `Start-Process` ile `-Plan` değeri geçirirken tek tırnak kullanmayın. Tek tırnak değeri olduğu gibi iletir ve hiçbir koşu çalışmaz.
- Tarihler `console.log` biçimindedir: `MM/dd HH:mm`. `console.log` satırlarında yıl yoktur. `Invoke-Cs2Benchmark.ps1` yılı çalıştırma tarihinden alır. `Get-VProfReport.ps1` yılı 2026 varsayar.

## bios: BIOS okuma (yalnızca okur)

| Betik | Görevi |
|---|---|
| [`Save-NvramSnapshot.ps1`](bios/Save-NvramSnapshot.ps1) | Tüm NVRAM değişkenlerinin dizinini kaydeder: ad, GUID, boyut ve SHA256. Ayar değişkenlerinin ham baytlarını da kaydeder. Parola, anahtar, lisans ve TPM içeren değişkenleri kaydetmez. |
| [`Compare-NvramSnapshot.ps1`](bios/Compare-NvramSnapshot.ps1) | İki görüntüyü karşılaştırır. `-Decoded` ve `-IfrFile` ile ayar adlarını da gösterir. |
| [`Export-BiosSetting.ps1`](bios/Export-BiosSetting.ps1) | Görüntüyü ayar sözlüğüyle birleştirir ve okunur döküm oluşturur (CSV ve Markdown). |
| [`BiosIfr.cs`](bios/BiosIfr.cs), [`EfiDec3b.cs`](bios/EfiDec3b.cs) | BIOS ayar sözlüğünü oluşturur (aşağıda). |

**BIOS ayar sözlüğü:**

```powershell
Add-Type -Path .\scripts\bios\BiosIfr.cs, .\scripts\bios\EfiDec3b.cs
[Prog]::Main(@('C:\yol\BIOS.CAP', '.\sozluk'))     # sozluk\ifr_all.tsv dosyasını oluşturur
```

Bu araç AMI Aptio BIOS kapsülünü (`.CAP`) açar. BIOS 2503 için 9304 ayar çıkarır. Bunların 408'i gizlidir. Sözlük, üreticinin telifli BIOS dosyasından çıkarıldığı için depoda yoktur. Kendi BIOS dosyanızdan oluşturun.

## check: ayar kontrolü (yalnızca okur)

| Betik | Görevi |
|---|---|
| [`Test-Configuration.ps1`](check/Test-Configuration.ps1) | Canlı BIOS değerlerini [`config/bios-target-2503.csv`](../config/bios-target-2503.csv) listesiyle, Windows durumunu da beklenen değerlerle karşılaştırır. Çıkış kodu, farklı ayar sayısıdır. |

Kullanım ve örnek çıktı: [Kontrol](../docs/verification.md).

## gpu: ekran kartı ölçümü

Bu betikler yönetici PowerShell ister. MSI Afterburner ve `nvidia-smi` gerekir. Sonuçlar `scripts\gpu\sonuc\` klasörüne yazılır.

| Betik | Görevi |
|---|---|
| [`Set-AfterburnerProfile.ps1`](gpu/Set-AfterburnerProfile.ps1) | Afterburner profil yuvasını yazar ve uygular (`-Slot 5 -Core 450 -Mem 3000 -PL 116`). Önce profil dosyasının yedeğini alır. Fan değeri verilmezse fan satırı yazmaz ve fan otomatik kalır. |
| [`Compare-GpuProfile.ps1`](gpu/Compare-GpuProfile.ps1) | Afterburner profillerini ve CPU 0 ayarını aynı CS2 oturumunda karşılaştırır. Her koşuda GPU kaydı tutar ve TDR olayını kontrol eder. Kararsızlık görürse durur. |
| [`Measure-GpuClockScaling.ps1`](gpu/Measure-GpuClockScaling.ps1) | `nvidia-smi -lgc` ile GPU saatini sınırlar ve kilitsiz durumla karşılaştırır. Kilidi her durumda kaldırır. |
| [`Set-VfCurve.ps1`](gpu/Set-VfCurve.ps1) | Undervolt VF eğrisini Afterburner profil yuvasına yazar ve uygular (`-TargetMv 990 -FreqMhz 3245 -Slot 2`). Şablon olarak profil dosyasındaki stok eğriyi kullanır. Önce profil dosyasının yedeğini alır. |

```powershell
# 2x2 test: Profil 5 = stok (0/0/100), Profil 1 = günlük ayar. İkinci oturumda sırayı ters çevirin.
.\scripts\gpu\Compare-GpuProfile.ps1 -Order 'SF1:5:0xFFFF,SE1:5:0xFFFE,OF1:1:0xFFFF,OE1:1:0xFFFE' -EndProfile 1 -Tag GUN
```

## hwinfo: sensör kaydı (yalnızca okur)

Bu betikler HWiNFO'nun paylaşılan belleğini okur. HWiNFO'da **Shared Memory Support** seçeneği açık olmalıdır.

| Betik | Görevi |
|---|---|
| [`Export-HwinfoLog.ps1`](hwinfo/Export-HwinfoLog.ps1) | Tüm sensörleri 1 saniye aralıkla CSV dosyasına yazar. |
| [`Get-HwinfoSummary.ps1`](hwinfo/Get-HwinfoSummary.ps1) | CSV dosyasından bir zaman aralığının özetini çıkarır (ortalama, en düşük, yüzdelikler, en yüksek). |
| [`Get-HwinfoSensor.ps1`](hwinfo/Get-HwinfoSensor.ps1) | Anlık değerleri listeler. |

## windows: kesme, DPC ve sunum analizi

| Betik | Görevi | Yönetici |
|---|---|---|
| [`Measure-InterruptLoad.ps1`](windows/Measure-InterruptLoad.ps1) | Her saniye CPU başına kesme ve DPC sayısını ölçer. Fare hareketli ve durgun saniyeleri ayırır. Sonuçta CPU başına farkı yazar. `-OutCsv` ile ham veriyi kaydeder. | Hayır |
| [`Get-DumpSummary.ps1`](windows/Get-DumpSummary.ps1) | Minidump dosyasını (`.dmp`, `.mdmp`) okur. İstisna kodunu, hatalı modülü ve yığındaki modülleri yazar. | Hayır |
| [`Measure-DpcLatency.ps1`](windows/Measure-DpcLatency.ps1) + [`DpcEtl.cs`](windows/DpcEtl.cs) | DPC ve kesme sürelerini Windows'un çekirdek izleme kaydıyla ölçer (LatencyMon benzeri). Sürücü bazında adet, ortalama ve en uzun süreyi yazar. `-Sec 60` boşta ölçer, `-Bench` bir CS2 koşusu sırasında ölçer. | Evet |
| [`Compare-PresentMode.ps1`](windows/Compare-PresentMode.ps1) + [`PresentMonReport.cs`](windows/PresentMonReport.cs) | PresentMon ile bir CS2 oturumunu kaydeder ve `Compare-GpuProfile.ps1` koşularını çalıştırır. Her koşu için sunum kipi, kare başlangıcından ekrana gecikme, CPU ve GPU meşgul süresini yazar. `PresentMon-2.6.0-x64.exe` dosyası aynı klasörde olmalıdır (`-PresentMon` ile değiştirilebilir). PresentMon'un canlı kaydını kullanır. Bu sistemde 02.11'den beri kare kaydetmiyor (8000 Hz farede ETW olay kaybı). Yerine `Measure-FrameLatency.ps1` kullanın. | Evet |
| [`Measure-FrameLatency.ps1`](windows/Measure-FrameLatency.ps1) + [`FrameLatencyStats.cs`](windows/FrameLatencyStats.cs) + [`presentmon-light.wprp`](windows/presentmon-light.wprp) | Aynı CS2 oturumunda koşu planını (`'ad:maske:kayıt,...'`) çalıştırır. Kayıtlı koşularda WPR, PresentMon olaylarını kayıpsız olarak dosyaya yazar. Koşulardan sonra her kayıt `PresentMon --etl_file` ile işlenir. Her koşu için kare süresi p50, p99 ve p99,9, 4 ms'den uzun kare sayısı, kare başlangıcından ekrana süre ve PC gecikmesi (Reflex işaretleri) yazılır. [`FrameStabilityStats.cs`](windows/FrameStabilityStats.cs) aynı pencereden akıcılık ölçütlerini ekler: kare süresi sapması, kareden kareye fark, her saniyenin en uzun karesi, animasyon hatası ve PC gecikmesi sapması ([yöntem](../docs/methodology.md#akıcılık-ölçütleri)). Ayar değiştirmez. Yalnızca `cs2.exe` işleminin işlemci maskesini koşu boyunca ayarlar. Plan alanı `L` (`'B1:0xFFFE:1:L'`) koşu boyunca oturumdaki arka plan uygulamalarının önceliğini `-BgPriority` (varsayılan Idle) yapar. CS2, Windows kabuğu, sistem hizmetleri, Defender, NVIDIA ve ses süreçleri hariçtir. Sonra özgün öncelikler geri yüklenir. Kayıt dosyaları (~1 GB/koşu) işlendikten sonra silinir. `PresentMon-2.6.0-x64.exe` aynı klasörde olmalıdır. | Evet |
| [`Compare-LaunchOption.ps1`](windows/Compare-LaunchOption.ps1) | CS2 başlatma seçeneklerini bloklar halinde karşılaştırır. Her blokta CS2'yi kapatır, `steam -applaunch 730 <seçenekler>` ile yeniden açar, komut satırını doğrular, `Compare-GpuProfile.ps1` ile 2 ısınma ve 3 kayıt koşusu çalıştırır ve `console.log` yedeğini alır. Steam'deki kayıtlı seçenekleri değiştirmez. Boş blok (`A=`) ek seçeneksiz kontrol bloğudur. Ortaya ve sona kontrol bloğu koyun. `-Mask` verilmezse CPU 0 hariç tüm mantıksal işlemciler kullanılır. Durdurmak için `sonuc\bench_stop.txt` dosyasını oluşturun. Hatalı veya eksik bloklar günlüğün sonunda listelenir. | Evet |

| [`Compare-PowerPlan.ps1`](windows/Compare-PowerPlan.ps1) | Windows güç planlarını aynı CS2 oturumunda bloklar halinde karşılaştırır: başlangıçtaki plan (kontrol), Dengeli, Dengeli + "En iyi performans" güç modu, Yüksek performans, Atlas Power Scheme, RapidOS ve başlangıç planı + idle kapalı. Atlas, RapidOS ve idle kapalı planları geçici olarak oluşturur ve sonda siler. Başlangıç planını ve güç modunu geri yükler. Her kayıt koşusunda `Measure-FrameLatency.ps1` ile aynı kare, gecikme ve akıcılık ölçütlerini çıkarır. HWiNFO açıksa çekirdek saatlerini, efektif saati, C6/C0, paket gücünü ve sıcaklığı da koşu penceresinden özetler (HWiNFO geçici olarak SensorsOnly kipinde açılır, INI dosyası sonda geri yüklenir). `-DryRun` planları oluşturup ayarlarını yazar ve her şeyi geri alır. `PresentMon-2.6.0-x64.exe` aynı klasörde olmalıdır. | Evet |

```powershell
.\scripts\windows\Compare-LaunchOption.ps1 -Plan 'A=;B=-threads 9;C=-threads 9 -mainthreadpriority 2;D=' -Tag LAUNCH
.\scripts\windows\Compare-PowerPlan.ps1 -DryRun   # önce planları ve ayarlarını görün
.\scripts\windows\Compare-PowerPlan.ps1 -Tag GUC  # ~70 dakika, 26 koşu
```

## Katkı

Betiklerde yalnızca ASCII karakter kullanın. Windows PowerShell 5.1, BOM'suz UTF-8 dosyalardaki Türkçe karakterleri yanlış okur. Ayrıntı: [CONTRIBUTING.md](../CONTRIBUTING.md).

---

[Ana sayfa](../README.md) · [Belgeler](../docs/README.md)
