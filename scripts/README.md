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

CS2, `-condebug` seçeneğiyle açık olmalıdır. `console.log` yolu betiklerin başında tanımlıdır. Steam farklı bir klasördeyse yolu değiştirin.

| Betik | Görevi |
|---|---|
| [`Invoke-Cs2Benchmark.ps1`](bench/Invoke-Cs2Benchmark.ps1) | Konsolu açar, haritayı yükler, `[VProf] FPS:` satırını bekler ve sonraki koşuya geçer. Plan biçimi: `-Plan ad:maske:koşu[:öncelik];…`. Öncelik değeri N, A veya H olabilir. `-Warmups` ısınma koşusu sayısını belirler. `bench_stop.txt` dosyası oluşturulursa betik durur. Bitince affinity ve önceliği varsayılana döndürür. CS2 başta simge durumundaysa yeniden simge durumuna alır ve önceki pencereyi öne getirir. |
| [`Get-VProfReport.ps1`](bench/Get-VProfReport.ps1) | Belirli bir zaman aralığındaki koşuları okur. Avg, P1, P99, ortalama kare süresi, WHEA ve Kernel-Power 41 sayısını verir. |
| [`Compare-InterleavedRun.ps1`](bench/Compare-InterleavedRun.ps1) | Dönüşümlü koşuları eşleştirilmiş t testi ile karşılaştırır. |
| [`Backup-ConsoleLog.ps1`](bench/Backup-ConsoleLog.ps1) | `console.log` dosyasını yedekler. CS2 her açılışta bu dosyayı sıfırlar. |
| [`Set-Cs2Affinity.ps1`](bench/Set-Cs2Affinity.ps1) | `cs2.exe` affinity değerini okur veya ayarlar (`-Mask 0xFFFE`). Bu değer kalıcı değildir. |

```powershell
# CS2 açık olsun. FACEIT kapalı olsun. BIOS değişikliğinden sonra yeni oturumda:
.\scripts\bench\Invoke-Cs2Benchmark.ps1 -Plan AYAR:0xFFFF:12 -Warmups 6
.\scripts\bench\Get-VProfReport.ps1 -Start '10/19 12:30' -Name AYAR
```

**Notlar:**
- `Start-Process` ile `-Plan` değeri geçirirken tek tırnak kullanmayın. Tek tırnak değeri olduğu gibi iletir ve hiçbir koşu çalışmaz.
- Tarihler `console.log` biçimindedir: `MM/dd HH:mm`. Yıl betiklerde 2026 olarak sabittir.

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
| [`Compare-PresentMode.ps1`](windows/Compare-PresentMode.ps1) + [`PresentMonReport.cs`](windows/PresentMonReport.cs) | PresentMon ile bir CS2 oturumunu kaydeder ve `Compare-GpuProfile.ps1` koşularını çalıştırır. Her koşu için sunum kipi, kare başlangıcından ekrana gecikme, CPU ve GPU meşgul süresini yazar. `PresentMon-2.6.0-x64.exe` dosyası aynı klasörde olmalıdır (`-PresentMon` ile değiştirilebilir). | Evet |

## Katkı

Betiklerde yalnızca ASCII karakter kullanın. Windows PowerShell 5.1, BOM'suz UTF-8 dosyalardaki Türkçe karakterleri yanlış okur. Ayrıntı: [CONTRIBUTING.md](../CONTRIBUTING.md).

---

[Ana sayfa](../README.md) · [Belgeler](../docs/README.md)
