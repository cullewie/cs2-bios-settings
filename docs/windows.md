# Windows ve CS2 ayarları

Windows 11 Pro (derleme 26300) ve CS2 için uygulanan ayarlar. BIOS ayarlarından sonra uygulayın.

## Windows

| Ayar | Değer | Not |
|---|---|---|
| Donanım hızlandırmalı GPU zamanlaması (HAGS) | Açık | Ayarlar → Sistem → Ekran → Grafik |
| CS2'yi CPU 0 dışında çalıştırma | Uygulayın | Aşağıdaki adımlar. Ölçülen kazanç +%1,8 ile +%2,5. Akıcılık da iyileşir: kareden kareye fark −%11. |
| İşlem önceliği | Normal | Yüksek öncelik denendi. Etkisi yok. |
| Bellek Bütünlüğü (HVCI) | Açık | FACEIT için gerekir. |
| Oyun Modu | Kapalı | Açıkken −%0,21 ölçüldü, sapma içinde ([Oyun Modu](#oyun-modu)). |
| Ethernet: Energy Efficient Ethernet | Kapalı | Aygıt Yöneticisi → ağ bağdaştırıcısı → Gelişmiş. Etkisi ölçülmedi. Bağlantı kısa bir süre kopar. |
| Win32PrioritySeparation | Varsayılan (2) | Değiştirmeyin. Ayrıntı aşağıda. |
| Kesme yerleşimi (Interrupt Affinity) | Varsayılan | Değiştirmeyin. GPU ve USB DPC işi zaten CPU 0'da çalışır. |
| Tam ekran iyileştirmeleri (yalnızca `cs2.exe`) | Kapalı (Legacy Flip) | Aşağıdaki adımlar. Ölçülen kazanç +%1,13. |
| Güç planı | Dengeli (Windows varsayılanı) yeterli. Çekirdek park etme kapalı, işlemci boşta kalma açık. | 7 plan ölçüldü: FPS, akıcılık ve saat farkı yok. Çekirdek park eden ve idle'ı kapatan planlar −%4,9 ve −%7,4 ([Güç planı](#güç-planı)). |

## CS2'yi CPU 0 dışında çalıştırma

Bu adımı her Steam açılışında tekrarlayın.

1. Steam açıkken Görev Yöneticisi'nde **Ayrıntılar** sekmesini açın.
2. `steam.exe` satırına sağ tıklayın ve **Benzeşimi ayarla** seçin.
3. **CPU 0** kutusunun işaretini kaldırın ve **Tamam** seçin.
4. CS2'yi Steam'den başlatın. CS2 bu ayarı Steam'den devralır. `cs2.exe` dosyasına ayrıca dokunmanız gerekmez.

CS2'yi NVIDIA App ile başlatırsanız CS2 yine `steam.exe` altında açılır ve ayarı devralır. Bu durum denendi ve doğrulandı.

**PowerShell ile (Görev Yöneticisi yerine):** Steam açıkken şu komut CPU 0'ı kaldırır. Mantıksal işlemci sayısına göre maskeyi kendisi hesaplar. Yönetici gerekmez.

```powershell
Get-Process steam | ForEach-Object { $_.ProcessorAffinity = [IntPtr]((1 -shl [Environment]::ProcessorCount) - 2) }
```

CS2 zaten açıksa aynı komutu `steam` yerine `cs2` ile çalıştırın veya [`Set-Cs2Affinity.ps1`](../scripts/bench/Set-Cs2Affinity.ps1) kullanın (`-Mask 0xFFFE`, 16 mantıksal işlemci için). Bu ayar CS2 kapanınca sıfırlanır.

> [!NOTE]
> Steam, Windows açılışında kendiliğinden başlarsa CPU 0 ayarı uygulanmamış olur. Ayarı her Steam açılışında kontrol edin. Kontrol betiği `steam.exe` ve `cs2.exe` durumunu gösterir ([Kontrol](verification.md)).

> [!IMPORTANT]
> **FACEIT:** Ölçümler FACEIT kapalıyken yapıldı. FACEIT açıkken `cs2.exe` benzeşimini değiştirmek ve FACEIT istemcisinden açılan CS2'nin Steam ayarını devralması denenmedi. Ayarı Steam'de, CS2'yi açmadan önce yapın. Maçta `cs2.exe` satırını Görev Yöneticisi'nde kontrol edin.

**Kalıcı yol (denenmedi):** Steam'i şu komutla başlatabilirsiniz:

```bat
cmd /c start "" /affinity FFFE "C:\Program Files (x86)\Steam\steam.exe"
```

FACEIT'in bu yöntemle ilgili resmi bir açıklaması yoktur.

### CPU 0 neden önemlidir

[`Measure-InterruptLoad.ps1`](../scripts/windows/Measure-InterruptLoad.ps1) ile CPU başına kesme ve DPC sayısı ölçüldü:

- CS2 benchmark sırasında saniyede yaklaşık 9700 DPC oluştu. Bunların %99'dan fazlası CPU 0'da çalıştı.
- CPU 0 zamanının yaklaşık %24'ü kesme ve DPC işine gitti.
- Fare hareket edince (8000 Hz) saniyede yaklaşık 4300 ek DPC oluştu. Bunların hepsi CPU 0'da çalıştı.
- Diğer çekirdeklerde DPC yok denecek kadar azdı.

Windows, GPU ve USB işini zaten CPU 0'da çalıştırır. Bu nedenle kesmeleri kayıt defteriyle CPU 0'a bağlamak yeni bir şey değiştirmez. CS2'yi CPU 0'dan uzak tutmak, bu işi oyundan ayırır.

**DPC ve kesme süreleri** ([`Measure-DpcLatency.ps1`](../scripts/windows/Measure-DpcLatency.ps1), LatencyMon'un ölçtüğü değerler, kurulum gerekmez):

| Durum | DPC/sn | En uzun DPC | En uzun kesme | 500 µs üstü | CPU 0 zamanı |
|---|---|---|---|---|---|
| Boşta, 60 sn | 1859 | 131 µs (nvlddmkm) | 72 µs | 0 | %2,4 |
| CS2 benchmark | 9754 | 395 µs (nvlddmkm, dxgkrnl) | 156 µs | 0 | %23,2 |

- Sürücü gecikmesi temizdir. En uzun DPC 500 µs sınırının altındadır.
- CS2 sırasında CPU 0 zamanının %23'ü ekran kartı DPC ve kesmelerine gider. Diğer çekirdeklerde bu oran ~%0'dır.
- Kesmeleri başka bir çekirdeğe taşımayın. Bu iş o zaman CS2'nin çekirdeklerine biner.

### Gecikme ve akıcılık

02.11'de aynı CS2 oturumunda A (CPU 0 hariç), B (tüm çekirdekler) ve C (CPU 0 hariç, kontrol) blokları 3'er koşuyla ölçüldü. Her koşuda kare süreleri ve gecikme [`Measure-FrameLatency.ps1`](../scripts/windows/Measure-FrameLatency.ps1) ile kaydedildi ([yöntem](methodology.md#presentmon)). Yalnızca `cs2.exe` işleminin çalışma anındaki işlemci maskesi değişti.

| Blok ortalaması | A: CPU 0 hariç | B: tüm çekirdekler | C: CPU 0 hariç |
|---|---|---|---|
| Ortalama FPS (VProf) | 924,3 | 901,8 | 922,1 |
| P1 (VProf) | 356,3 | 328,9 | 350,1 |
| Kare süresi p99 / p99,9 | 2,72 / 3,21 ms | 2,83 / 3,34 ms | 2,77 / 3,24 ms |
| 4 ms'den uzun kare (koşu başına) | 14,7 | 18,0 | 17,7 |
| Kare başlangıcından ekrana (ortalama / p99) | 1,968 / 3,528 ms | 1,983 / 3,574 ms | 1,964 / 3,539 ms |
| PC gecikmesi (ortalama / p99) | 3,331 / 5,972 ms | 3,412 / 5,918 ms | 3,360 / 5,960 ms |
| Kare süresi sapması | 0,444 ms | 0,463 ms | 0,455 ms |
| Kareden kareye fark (ortalama / p99) | 0,255 / 1,93 ms | 0,291 / 2,01 ms | 0,262 / 1,96 ms |
| Saniyenin en uzun karesi (medyan) | 3,02 ms | 3,16 ms | 3,06 ms |
| Animasyon hatası (ortalama / p99) | 0,255 / 1,90 ms | 0,273 / 1,94 ms | 0,258 / 1,92 ms |

- B, A ve C'nin ortalamasına göre: FPS −%2,3, P1 −%6,9, kare süresi p99 +%3,1, p99,9 +%3,5. B'nin üç koşusunun da p99 değeri, A ve C'nin bütün koşularından yüksektir.
- **Akıcılık** (03.11'de aynı kayıtlardan hesaplandı, [akıcılık ölçütleri](methodology.md#akıcılık-ölçütleri)): B'de kareden kareye fark %12,5, animasyon hatası %6,6, saniyenin en uzun karesi %3,9 ve kare süresi sapması %3,0 daha yüksektir. Kareden kareye farkta ve animasyon hatasında B'nin üç koşusu, A ve C'nin bütün koşularından yüksektir.
- P1'de koşular kısmen örtüşür. B'nin iki koşusu A ve C'nin bütün koşularından düşüktür. Üçüncü koşusu (345,0) ise A ve C'nin iki koşusundan (340,0 ve 343,8) yüksektir. P1 farkı tek oturumda ölçüldü.
- PC gecikmesi B'de ortalama 0,07 ms (%2) daha uzundur. p99 farkı yoktur. 4 ms'den uzun kare sayısı kontrol blokları arasında da 14,7 ile 17,7 arasında oynar. Bu fark ayırt edilemez.
- **Karar:** CPU 0 hariç tutmak FPS'in yanında akıcılığı da iyileştirir: kareden kareye fark %11, animasyon hatası %6 azalır. P1 artışı kesin değil.
- PC gecikmesi, CS2'nin girdiyi okuduğu andan karenin ekrana çıktığı ana kadar geçen süredir (Reflex PCLStats işaretleri). Fare ve ekran panelinin süresi dahil değildir. Reflex bu testte kapalıydı.
- Ham veri: [`latency-runs.csv`](../data/latency-runs.csv) ve [`windows-gpu-runs.csv`](../data/windows-gpu-runs.csv), `G47`.

## Tam ekran iyileştirmelerini kapatma (Legacy Flip)

Windows, tam ekran oyunları varsayılan olarak "Independent Flip" kipinde sunar. Tam ekran iyileştirmeleri (FSO) kapatılınca CS2 "Legacy Flip" kipine geçer (gerçek tam ekran).

1. CS2'yi kapatın.
2. `...\Counter-Strike Global Offensive\game\bin\win64\cs2.exe` dosyasına sağ tıklayın. **Özellikler → Uyumluluk** seçin.
3. **Tam ekran iyileştirmelerini devre dışı bırak** kutusunu işaretleyin ve **Tamam** seçin.
4. CS2'yi yeniden açın.

Aynı ayar kayıt defterinde şu değerdir: `HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers`, ad = `cs2.exe` dosyasının tam yolu, değer = `~ DISABLEDXMAXIMIZEDWINDOWEDMODE`. Geri almak için kutunun işaretini kaldırın.

**Kontrol:** PresentMon'da `PresentMode` sütunu **Hardware: Legacy Flip** göstermelidir. Varsayılan durumda **Hardware: Independent Flip** gösterir.

**Ölçüm** (üç taze CS2 oturumu, A-B-A sırasıyla, her biri 6 koşu, GPU +425, CPU 0 hariç):

| | A: Independent Flip | B: Legacy Flip (FSO kapalı) | A': Independent Flip (tekrar) |
|---|---|---|---|
| Ortalama FPS (VProf, 6 koşu) | 982,7 | **994,9** | 985,0 |
| P1 (VProf) | 346,5 | 348,4 | 346,6 |
| Kare başlangıcından ekrana (PresentMon, ortalama / p99) | 1,94 / 3,66 ms | 1,95 / 3,57 ms | 1,93 / 3,63 ms |
| GPU meşgul süresi | 0,96 ms | 0,95 ms | 0,96 ms |

- Aynı ayarda iki oturum arasındaki fark (A' − A) %0,23'tür.
- Legacy Flip, iki Independent Flip oturumunun ortalamasından **%1,13** yüksektir. 6 sıra konumunun 6'sında yüksektir.
- P1 ve gecikme değişmez.
- Independent Flip'te CPU her karede ~0,40 ms `Present` çağrısında bekler. Legacy Flip'te bu bekleme yoktur.
- **Yan etki:** Alt-Tab sırasında ekran kipi değişir ve ekran kısa bir süre kararır. Bazı bindirmeler ve bildirimler oyunun üstünde görünmeyebilir.
- Sonuç sisteme göre değişebilir. İki kipi kendi sisteminizde deneyin.

## Win32PrioritySeparation

Bu sistemde (Windows 11, derleme 26300) varsayılan değer 2'dir. Ölçüm şunu gösterdi: Ön plandaki uygulamanın iş parçacıklarının önceliği 8'den 10'a çıkar. Aynı çekirdeği paylaşan ön plan uygulaması zamanın %99'unu alır, arka plan uygulaması %1'ini alır.

İnternette önerilen 0x2A değeri sabit zaman dilimi seçer. Bu değer burada ölçülmedi. Aynı işlemci ve ekran kartıyla yapılan bir dış veri setinde (cs2kitchen/cs2FpsBoostReal) bu ayarın etkisi ölçüm sapmasının içinde kaldı. Varsayılan değeri değiştirmeyin.

## CS2 oyun içi ayarları

Ölçümler sırasında bu ayarlar sabit tutuldu. Tek istisna gölge kalitesidir: 26.10'da Düşük'ten Yüksek'e alındı. Kaynak: `cs2_video.txt`.

> [!NOTE]
> Bu tablo ölçüm ayarlarını gösterir, öneri değildir. Gölge kalitesi dışındaki grafik ayarlarının etkisi ölçülmedi. Kendi tercihinizi kullanın ve taban ölçümünü aynı ayarlarla yapın.
>
> - **NVIDIA Reflex:** Ölçümlerde kapalıydı. Gecikmeye etkisi bu depoda ölçülmedi (tıklamadan ekrana ölçüm donanımı yok).
> - **`-condebug`:** Yalnızca ölçüm için gerekir. Oyun için gerekmez.
> - **Anizotropik filtre:** NVIDIA genel ayarı oyun içi değeri geçersiz kılar. NVIDIA genel 3D ayarlarının birlikte etkisi ölçüldü: etki yok ([aşağıda](#nvidia-sürücüsü-ve-sürücü-ayarları)). İkisinden birini seçmeniz yeterlidir.

| Ayar | Değer |
|---|---|
| Çözünürlük | 1280 × 960 (4:3), tam ekran |
| Yenileme hızı | 360 Hz |
| V-Sync | Kapalı |
| `fps_max` | 0 (sınırsız) |
| MSAA | 2x |
| Anizotropik filtre | 16x. 26.10'dan beri NVIDIA genel 3D ayarında anizotropik filtre kapalıdır. Bu ayar oyun içi 16x değerini geçersiz kılar. |
| Gölge kalitesi | Yüksek (26.10'dan itibaren). Önceki ölçümler Düşük ile yapıldı. |
| Doku kalitesi | Düşük |
| Dinamik gölgeler | Tümü |
| Parçacık ve ortam aydınlatması | Düşük veya kapalı |
| FSR | Kapalı |
| NVIDIA Reflex | Kapalı |
| Başlatma seçenekleri | `+exec crosshair.cfg -condebug` ([test edilen ek seçenekler](#cs2-başlatma-seçenekleri)) |

`-condebug` seçeneği, VProf sonuçlarının `console.log` dosyasına yazılması için gerekir.

**Gölge kalitesi Yüksek:** Ortalama FPS'i %4,7 düşürdü (ayrıntı: [Ekran kartı](gpu.md#gölge-kalitesi-yüksek-ile-2610)). Kare süresi olarak bu, kare başına yaklaşık 0,05 ms demektir. Karşılığında rakip gölgeleri daha uzaktan ve daha net çizilir.

## CS2 başlatma seçenekleri

02.11'de ek başlatma seçenekleri aynı Windows oturumunda bloklar halinde ölçüldü. Her blok yeni bir CS2 işlemidir: 2 ısınma ve 3 kayıt koşusu. Seçenekler `steam -applaunch 730 <seçenekler>` ile verildi. Steam'deki kayıtlı seçenekler değişmedi. Komut satırı her blokta doğrulandı. Bloklar A, B, C, D, E, F sırasıyla ölçüldü. A, D ve F ek seçeneksiz kontrol bloklarıdır.

| Blok | Ek seçenek | 3 kayıt koşusu ortalaması | P1 (5 koşu ortalaması) | P99 medyanı |
|---|---|---|---|---|
| A | yok (kontrol 1) | 936,73 | 340,8 | 2,95 ms |
| B | `-threads 9` | 927,80 | 341,6 | 2,90 ms |
| C | `-threads 9 -mainthreadpriority 2` | 926,93 | 345,8 | 2,87 ms |
| D | yok (kontrol 2) | 927,27 | 346,5 | 2,87 ms |
| E | `-nojoy +violence_hblood 0 +engine_low_latency_sleep_after_client_tick true` | 929,10 | 338,3 | 2,97 ms |
| F | yok (kontrol 3) | 928,77 | 347,0 | 2,91 ms |

- Kontrol bloklarında FPS A'dan D'ye %1,0 düştü, D'den F'ye değişmedi. Düşüş, oturumun ilk ~40 dakikasında oldu. Yalnızca A ile karşılaştırılsaydı her seçenek ~%1 kayıp gibi görünürdü.
- En yakın kontrol bloklarına göre: B +%0,06, C −%0,04, E +%0,12. Hepsi sapma içindedir.
- E'de P1 %2,4 düşük, P99 biraz yüksek çıktı. P1 koşudan koşuya ~10 FPS oynar. Fark anlamlı değildir.
- CS2, E'deki komutları hatasız kabul etti (`console.log` içinde "Unknown command" yok).
- `violence_hblood 0` yalnızca kanı kapatır. Benchmark haritasında hasar olmadığı için bu testte etkisi görülemez.
- `engine_low_latency_sleep_after_client_tick` giriş gecikmesiyle ilgilidir. Bu depoda gecikme ölçüm donanımı yoktur. FPS ve kare süresinde fayda görülmedi.
- **Karar:** Bu seçeneklerin hiçbiri bu sistemde ölçülebilir kazanç vermedi. Eklemeyin.
- Ham veri: [`windows-gpu-runs.csv`](../data/windows-gpu-runs.csv), `G33` … `G38`.

## NVIDIA sürücüsü ve sürücü ayarları

**Sürücü sürümü:** 26.10'a kadar NVIDIA 617.42 kullanıldı. Sonra 621.01 (26.10), ardından 621.12 (02.11 itibarıyla) kuruldu.

| Oturum | Sürücü | 3 kayıt koşusu ortalaması | Not |
|---|---|---|---|
| `G25` (26.10) | 617.42 | 946,23 | Son 617.42 oturumu |
| `G26` (26.10) | 621.01 | 936,97 | Yeniden başlatmadan kuruldu. `G25`'e göre −%0,98. |
| `G28` (02.11) | 621.12 | 938,70 | Taze açılış. `G25`'e göre −%0,8 (5 sıranın 5'inde düşük). |

- P1, P99, GPU saati (3195 MHz) ve güç değişmedi.
- 621.x ile ölçülen üç oturumun hepsi 617.42 oturumlarından %0,8 ile %1,3 düşüktür. Aynı dönemde CS2 ve Windows da güncellendi. Fark sürücüye atfedilemez.

**NVIDIA App genel 3D ayarları (26.10, `G27`):** Güç yönetimi maksimum performans, V-Sync zorla kapalı, doku süzme yüksek performans, anizotropik filtre kapalı. `G26`'ya göre −%0,28. Etki yok.

**Doku süzme kalitesi (02.11, `G29` ve `G30`):** Yalnızca CS2 sürücü profilinde "Texture filtering - Quality" Kalite yapıldı. Aynı Windows oturumunda Performans ile karşılaştırıldı.

| | Kalite | Performans |
|---|---|---|
| 3 kayıt koşusu ortalaması | 932,27 | 935,67 |
| P1 / P99 (kayıt medyanı) | 348,1 / 2,87 ms | 353,8 / 2,86 ms |

- Kalite, Performans'tan %0,36 düşüktür (5 sıranın 5'inde).
- Aynı ayarın iki oturumu arasındaki fark %0,32'dir. Fark bu sapma kadardır. Kalite daha iyi değildir.
- Genel profil Performans olarak kaldı. CS2 profilindeki değişiklik silindi.

## Custom OS ayarları (AtlasOS, ReviOS, RapidOS)

02.11'de açık kaynaklı Windows playbook'larının kaynak kodu incelendi: AtlasOS 0.5.0, ReviOS 26.10 (Revision Tool ile) ve RapidOS 1.3. Tiny11 yalnızca Windows imajını küçültür. Performans ayarı yoktur. AtlasOS 0.5.0 ve RapidOS 1.3 bu sistemin Windows sürümünü (build 26300) desteklemez.

**FACEIT nedeniyle test edilmedi:** ReviOS ve RapidOS VBS/HVCI'yi varsayılan olarak kapatır. AtlasOS kurulumunda otomatik Windows Update kapatma varsayılan olarak seçilidir. Defender, Spectre ve CFG korumaları, Smart App Control ve AMD PSP aygıtı da test edilmedi.

**Bu sistemde ölçümlerden önce zaten açık olanlar:** Özel güç planı (minimum işlemci %100, EPP 0, çekirdek park etme kapalı, USB ve PCIe güç tasarrufu kapalı), Win32PrioritySeparation (2, 0x26 ile aynı davranış), fare ivmesi kapalı, MSI kesme modu, EEE kapalı, `cs2.exe` için tam ekran iyileştirmeleri kapalı. Bu liste, custom OS paketinin neden az şey değiştirdiğini açıklamak içindir. Bir öneri listesi değildir. Ölçülen ve önerilen ayarlar sayfanın başındaki tablodadır. Güç planında Dengeli yeterlidir ([Güç planı](#güç-planı)). MSI kesme modu, USB ve PCIe güç tasarrufu ve fare ivmesi ayrıca ölçülmedi.

**Bu sistemde etki mekanizması olmayanlar (salt okunur ölçüm):**

- **MMCSS** (SystemResponsiveness 10, "Games" görevi, NetworkThrottlingIndex): Yalnızca kendini MMCSS'e kaydeden iş parçacıklarını etkiler. CS2'de bunu yalnızca SDL3 kütüphanesi (ses) yapar.
- **HPET aygıtı:** QPC frekansı 10 MHz'dir. Zaman kaynağı TSC'dir. HPET kullanılmaz.
- **Zamanlayıcı çözünürlüğü:** CS2 1 ms çözünürlüğü kendisi ister (`tier0.dll`, `timeBeginPeriod`). `fps_max 0` ile kareler arasında bekleme yoktur.
- **Bellek sıkıştırma:** Sıkıştırılmış bellek ~1 MB'tır. 48 GB'ın 38 GB'ı boştur.
- **Fault Tolerant Heap:** CS2'ye uygulanmamış (`FTH\State` boş).
- **MPO:** Legacy Flip ile kullanılmaz.
- **TCP ayarları:** CS2 oyun trafiği UDP kullanır. Benchmark çevrimdışıdır.

**Paket testi (A-B-A):** B bloğunda üç playbook'un FACEIT'e dokunmayan ve yeniden başlatma gerektirmeyen ortak kalemleri uygulandı. Çalışan 9 hizmet geçici olarak durduruldu: SysMain, DiagTrack, PcaSvc, TrkWks, WSearch, DPS, WdiSystemHost, SSDPSRV ve lfsvc. Başlangıç türleri değişmedi. Game DVR, uygulama yakalama ve arka plan uygulamaları kapatıldı. Windows Update hizmetlerine dokunulmadı. Bloklar aynı Windows oturumunda ölçüldü. Her blok yeni bir CS2 işlemidir: 2 ısınma ve 3 kayıt koşusu. Arka plan yükü, blok boyunca bütün işlemlerin işlemci süresinden hesaplandı.

| Blok | Durum | 3 kayıt koşusu ortalaması | P1 (kayıt ortalaması) | P99 medyanı | Oyun içi arka plan yükü |
|---|---|---|---|---|---|
| A1 | Mevcut (kontrol 1) | 926,83 | 345,0 | 2,89 ms | 0,137 çekirdek |
| B2 | Custom OS paketi | 926,43 | 347,8 | 2,88 ms | 0,106 çekirdek |
| A3 | Mevcut (kontrol 2) | 926,93 | 338,5 | 2,99 ms | 0,138 çekirdek |

- B2, kontrol bloklarının ortalamasından %0,05 düşüktür. İki kontrol bloğu arasındaki kayma %0,01'dir. Etki yoktur.
- Paketin kapattığı hizmetler oyun sırasında 0,0046 çekirdek kullanıyordu (en çok DiagTrack). CS2 ise ~4,1 çekirdek kullanır. B2'deki arka plan düşüşünün büyük kısmı NVIDIA hizmetlerinin dalgalanmasıdır.
- Dış testlerdeki kazançlar (PCGH, Mart 2024: AtlasOS 0.3.2, Ryzen 5 5600X, ortalama +%2–8) eski işlemcilerde ve güvenlik korumaları kapatılarak ölçüldü. Bu depoda bunlar FACEIT nedeniyle uygulanmaz.
- İkinci ölçüm (aynı gün, [Oyun Modu](#oyun-modu) testiyle aynı oturumda): kontrol bloklarına göre +%0,11. İki ölçümün ortalaması sıfıra yakındır.
- **Akıcılık:** İki ölçümün 6 koşusunda P1, P99 ve tipik saniyedeki en uzun kare kontrol bloklarıyla aynıdır. Her saniyenin en uzun karesinin 95. yüzdeliği 6 koşudan birinde 5,62 ms'ye çıktı. Kontrol bloklarının 12 koşusunda en yüksek değer 4,36 ms'dir. Paket akıcılığı iyileştirmedi.
- **Karar:** Bu ayarlar ve custom OS kurulumu bu sistemde FPS kazandırmaz.
- Ham veri: [`windows-gpu-runs.csv`](../data/windows-gpu-runs.csv), `G40` … `G42` ve `G45`. `G39` ilk denemedir: betik hatası yüzünden ilk kayıt koşusundan sonra durdu ve analize alınmadı.

## Oyun Modu

02.11'de Oyun Modu (Ayarlar → Oyun → Oyun Modu) bloklu olarak ölçüldü. `cs2.exe` Windows'un oyun listesinde kayıtlıdır, bu yüzden Oyun Modu açıkken CS2'ye uygulanır. Aynı oturumda custom OS paketi ikinci kez ölçüldü. Bloklar aynı Windows oturumunda A, G, B, A sırasıyla ölçüldü. Her blok yeni bir CS2 işlemidir: 2 ısınma ve 3 kayıt koşusu.

| Blok | Durum | 3 kayıt koşusu ortalaması | P1 (kayıt ortalaması) | P99 medyanı | Oyun içi arka plan yükü |
|---|---|---|---|---|---|
| A1 | Mevcut, Oyun Modu kapalı (kontrol 1) | 926,57 | 347,1 | 2,84 ms | 0,116 çekirdek |
| G2 | Oyun Modu açık | 924,73 | 343,3 | 2,93 ms | 0,144 çekirdek |
| B3 | Custom OS paketi (ikinci ölçüm) | 927,83 | 344,4 | 2,84 ms | 0,111 çekirdek |
| A4 | Mevcut, Oyun Modu kapalı (kontrol 2) | 927,00 | 350,7 | 2,87 ms | 0,109 çekirdek |

- Kontrol bloklarının doğrusal ara değerine göre: Oyun Modu −%0,21 (P1 −%1,4), custom OS paketi +%0,11. Kontrol blokları arasındaki kayma %0,05'tir. İkisi de sapma içindedir.
- **Akıcılık:** Oyun Modu açıkken her saniyenin en uzun karesinin 95. yüzdeliği 4,38 ms, kontrol bloklarında 4,14 ms oldu. Fark, 3 koşudan birindeki 4,79 ms'lik tek değerden gelir. Tipik saniyedeki en uzun kare aynıdır (3,23 ve 3,21 ms).
- **Karar:** Oyun Modu bu sistemde FPS, P1, P99 veya akıcılık kazancı vermedi. Kapalı kalabilir.
- **Gecikme:** Her blokta PresentMon açıktı, ama canlı yakalama hiç kare kaydetmedi. PresentMon saniyede ~7.900 ETW olayı kaybetti. Bu sayı farenin 8000 Hz raporlama hızına yakındır. Bu yüzden Oyun Modu'nun gecikmesi ölçülemedi. Sonradan kurulan dosya kaydı yöntemi için bkz. [CPU 0: Gecikme ve akıcılık](#gecikme-ve-akıcılık).
- Ham veri: [`windows-gpu-runs.csv`](../data/windows-gpu-runs.csv), `G43` … `G46`.

## Arka plan uygulamalarının önceliği (Process Lasso benzeri)

Bazı rehberler Process Lasso ile CS2 dışındaki uygulamaların önceliğini düşürmeyi önerir. 02.11'de bu, Process Lasso kurulmadan ölçüldü. B bloğunda oturumdaki arka plan uygulamalarının önceliği çalışma anında en düşük seviyeye (Idle) çekildi: Chrome, Steam ve tarayıcı bileşenleri, WebView2, Afterburner ve Görev Yöneticisi (29–30 süreç). CS2, Windows kabuğu, sistem hizmetleri, Defender, NVIDIA ve ses süreçlerine dokunulmadı. Aynı CS2 oturumunda A, B ve C blokları 3'er koşuyla ölçüldü ([`Measure-FrameLatency.ps1`](../scripts/windows/Measure-FrameLatency.ps1), plan alanı `L`).

| Blok ortalaması | A: normal | B: arka plan Idle | C: normal |
|---|---|---|---|
| Ortalama FPS (VProf) | 911,4 | 910,2 | 910,4 |
| P1 (VProf) | 337,0 | 333,5 | 332,2 |
| Kare süresi p99 / p99,9 | 2,71 / 3,17 ms | 2,72 / 3,22 ms | 2,71 / 3,19 ms |
| 4 ms'den uzun kare (koşu başına) | 17,0 | 18,0 | 14,0 |
| Kare başlangıcından ekrana (ortalama) | 2,012 ms | 2,011 ms | 2,015 ms |
| PC gecikmesi (ortalama / p99) | 3,43 / 6,02 ms | 3,44 / 5,90 ms | 3,48 / 6,00 ms |

- FPS −%0,07, P1, takılma ve ortalama gecikme aynı.
- **Akıcılık** (03.11'de aynı kayıtlardan hesaplandı): B'de kareden kareye fark +%1,2, animasyon hatası +%0,2, saniyenin en uzun karesi +%1,2. Etki yok.
- PC gecikmesinin p99 değeri B'de ~0,1 ms düşüktür. Buna karşılık kare süresi p99,9 değeri 0,03 ms yüksektir.
- Neden: CS2 öndeyken Windows zaten onun iş parçacıklarına öncelik verir. Oyun sırasında arka plan yükü 0,11–0,14 çekirdektir ve CS2 ile aynı çekirdek için yarışmaz.
- **Karar:** Gerek yok. CS2 için gerçek kazanç CPU 0'ı hariç tutmaktır ([yukarıda](#cs2yi-cpu-0-dışında-çalıştırma)).
- Ham veri: [`latency-runs.csv`](../data/latency-runs.csv) ve [`windows-gpu-runs.csv`](../data/windows-gpu-runs.csv), `G48`.

## Güç planı

03.11'de yedi güç planı koşulu aynı CS2 oturumunda bloklar halinde ölçüldü. Her blok 3 kayıt koşusudur. Başta 2 ısınma koşusu, en sonda başlangıç planıyla bir kontrol bloğu vardır. Her kayıt koşusunda kare süreleri, gecikme ve [akıcılık ölçütleri](methodology.md#akıcılık-ölçütleri) PresentMon ile kaydedildi. İşlemci saatleri ve uyku durumları HWiNFO ile saniyede bir kaydedildi ([`Compare-PowerPlan.ps1`](../scripts/windows/Compare-PowerPlan.ps1)).

**Koşullar** (AC değerleri, `powercfg /qh` ile okundu):

| Blok | Plan | En düşük işlemci durumu | EPP | Çekirdek park etme | İşlemci boşta kalma |
|---|---|---|---|---|---|
| A, H | Bu sistemdeki özel plan (FPSHEAVEN2026, AMD sürümü), kontrol | %100 | 0 | Kapalı | Açık |
| B | Dengeli (Windows varsayılanı) | %0 | 25 | Kapalı | Açık |
| C | Dengeli + "En iyi performans" güç modu (Ayarlar → Sistem → Güç) | %0 | 25 | Kapalı | Açık |
| D | Yüksek performans | %0 | 10 | Kapalı | Açık |
| E | Atlas Power Scheme (Nihai performans kopyası + AtlasOS 0.5.0 ayarları) | %0 | 10 | Kapalı | Açık |
| F | RapidOS 1.3 masaüstü planı (Dengeli kopyası + "En iyi performans" güç modu) | %0 | 20 | **En az %50 çekirdek** | Açık |
| G | Özel plan + idle kapalı ("idle off" planları) | %100 | 0 | Kapalı | **Kapalı** |

**Sonuçlar** (blok ortalaması, 3 koşu):

| Blok | Ortalama FPS | P1 | Kare süresi p99 / p99,9 | Kareden kareye fark | Animasyon hatası | Saniyenin en uzun karesi | PC gecikmesi |
|---|---|---|---|---|---|---|---|
| A: özel plan (başta) | 919,8 | 337,4 | 2,69 / 3,20 ms | 0,252 ms | 0,263 ms | 3,02 ms | 3,39 ms |
| B: Dengeli | 914,4 | 345,8 | 2,67 / 3,17 ms | 0,248 ms | 0,264 ms | 2,97 ms | 3,45 ms |
| C: Dengeli + En iyi performans | 913,4 | 331,6 | 2,70 / 3,22 ms | 0,252 ms | 0,266 ms | 2,98 ms | 3,44 ms |
| D: Yüksek performans | 911,6 | 350,1 | 2,70 / 3,21 ms | 0,251 ms | 0,266 ms | 3,06 ms | 3,44 ms |
| E: Atlas | 912,3 | 336,0 | 2,71 / 3,19 ms | 0,253 ms | 0,266 ms | 2,99 ms | 3,46 ms |
| F: RapidOS | **870,6** | 316,9 | **2,98 / 3,49 ms** | **0,291 ms** | **0,294 ms** | **3,29 ms** | 3,44 ms |
| G: idle kapalı | **847,2** | 302,2 | **3,20 / 3,70 ms** | **0,324 ms** | **0,323 ms** | **3,48 ms** | **3,56 ms** |
| H: özel plan (sonda) | 913,8 | 335,8 | 2,73 / 3,25 ms | 0,256 ms | 0,269 ms | 3,03 ms | 3,43 ms |

**HWiNFO** (koşu penceresi ortalaması):

| Blok | Çekirdek saati: ortalama (en hızlı) | C6'da geçen süre | Efektif saat | Paket gücü | Tctl en yüksek |
|---|---|---|---|---|---|
| A: özel plan (başta) | 5407 (5413) MHz | %0,0 | 2084 MHz | 90,8 W | 64,2 °C |
| B: Dengeli | 5408 (5413) MHz | %0,0 | 2063 MHz | 89,9 W | 64,4 °C |
| C: Dengeli + En iyi performans | 5405 (5414) MHz | %0,0 | 2058 MHz | 89,9 W | 64,4 °C |
| D: Yüksek performans | 5411 (5414) MHz | %0,0 | 2063 MHz | 89,8 W | 64,5 °C |
| E: Atlas | 5400 (5413) MHz | %0,0 | 2067 MHz | 90,8 W | 64,4 °C |
| F: RapidOS | **4530** (5406) MHz | **%32,2** | 2067 MHz | 77,8 W | 63,8 °C |
| G: idle kapalı | **5330** (5333) MHz | %0,0 (C0 %100) | **5297** MHz | **111,1 W** | **68,4 °C** |
| H: özel plan (sonda) | 5411 (5416) MHz | %0,0 | 2084 MHz | 90,8 W | 64,3 °C |

- **Özel planın diğer ayarları:** Otonom etkinlik penceresi 1 µs (Dengeli'de 30 ms), boşta kalma yükseltme eşiği %100 ve alçaltma eşiği %0 (çekirdekler sığ uyku durumunda kalır), performans denetim aralığı 5 saniye, boost modu 5. Bu plan fpsheaven'ın Intel ve AMD planlarını içeren paketinden gelir.
- **Oturum içi kayma:** Özel planın iki kontrol bloğu arasında FPS %0,65 düştü (A'dan H'ye). B, C, D ve E son kontrol bloğuna göre +%0,06, −%0,04, −%0,24 ve −%0,17'dir. Doğrusal kayma düzeltmesiyle −%0,45 ile −%0,61 arasındadır. A bloğu, CS2 açıldıktan 21–28 dakika sonra ölçüldü. Bu, oturumun ilk ~40 dakikasındaki düşüşe denk gelir ([Sapma kaynakları](methodology.md#sapma-kaynakları)). Fark ayırt edilemez.
- **Akıcılık:** B, C, D ve E'nin akıcılık ölçütleri, özel planın iki kontrol bloğunun ortalamasından en fazla %2,6 farklıdır. Dengeli her ölçütte biraz daha iyidir (−%0,4 ile −%2,6). Bu fark da sapma içindedir. Özel planın daha akıcı olduğu görülmedi.
- **PC gecikmesi:** Özel planda ortalama 0,04 ms (40 µs) kısadır. Koşu aralıkları örtüşür (3,37–3,45 ve 3,42–3,47 ms). Bu fark hissedilmez.
- **Saatler:** B, C, D, E ve kontrol bloklarında 8 çekirdeğin hepsi 5,40–5,41 GHz'de çalıştı. Hiçbir çekirdek C6'ya girmedi. Bu işlemci CPPC otonom kipinde çalışır: saati işlemci seçer. Plan yalnızca alt sınırı, EPP ipucunu, çekirdek park etmeyi ve idle'ı belirler. Microsoft'a göre bu kipte "Aggressive" boost modları ek bir şey yapmaz ([PERFBOOSTMODE](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/options-for-perf-state-engine-perfboostmode)). CS2 yükünde planlar saati değiştirmedi. Özel planda efektif saat ~%1 yüksektir, yani çekirdekler biraz daha uzun süre aktif kalır. Olası neden, planın boşta kalma eşikleri ve otonom pencere ayarıdır. Bu fark iki kontrol bloğunda da görülür, ama FPS'e ve akıcılığa yansımadı.
- **RapidOS (en az %50 çekirdek):** HWiNFO'daki Core 6 ve Core 7 zamanın %99'unda, Core 4 %59'unda park edildi. CS2'nin işi kalan çekirdeklere yığıldı. FPS −%4,9, kare süresi p99 +%10, kareden kareye fark +%15, animasyon hatası +%11. Paket gücü 13 W düştü.
- **Idle kapalı:** Bütün iş parçacıkları sürekli aktif kaldı (C0 %100). Saat 80 MHz düştü (5,33 GHz). Güç 20 W, sıcaklık 4 °C arttı. FPS −%7,4, kare süresi p99 +%18, kareden kareye fark +%28, animasyon hatası +%22, PC gecikmesi +0,15 ms. AtlasOS'un kendi betiği de SMT açıkken idle'ın kapatılmamasını söyler.
- **Diğer planlar:** "En iyi performans" güç modu Dengeli'den farklı sonuç vermedi. Bu mod, Dengeli'nin kopyası olan RapidOS planında da etkin oldu. Atlas planının işlemci ayarları Yüksek performansla aynıdır. Bu sistemde Yüksek performans ve Nihai performans planlarında en düşük işlemci durumu %0'dır. ReviOS'un "Ultra Performance" planı Nihai performansa eşik ayarları ekler. Bu ayarlar, ReviOS'un kendi koduna göre otonom kipte etkisizdir. Bitsum Highest Performance (Process Lasso) çekirdek park etmeyi kapatır ve işlemciyi taban frekansın altına indirmez. Bu ayarlar özel planda zaten vardır. Bu yüzden ayrıca ölçülmedi.
- **Windows 11 26H2:** Bu sürümde güç planlarında duyurulmuş bir değişiklik yoktur. Yeni "Low Latency Profile", Başlat menüsü, arama veya bir uygulama açılırken işlemciyi 1–3 saniye en yüksek saate çıkarır. Oyun sırasındaki davranışı değiştirmez.
- **Karar:** Windows'un varsayılan Dengeli planı yeterlidir. Özel plan zararsızdır, ama FPS'te ve akıcılıkta kazanç vermedi. Çekirdek park etmeyi kapalı tutun. Yeni kurulumdan sonra `powercfg /qh scheme_current sub_processor CPMINCORES` ile kontrol edin: AC değeri `0x00000064` (%100) olmalıdır. Çekirdek park eden ve idle'ı kapatan planları kullanmayın.
- Ham veri: [`latency-runs.csv`](../data/latency-runs.csv), [`power-plan-cpu.csv`](../data/power-plan-cpu.csv) ve [`windows-gpu-runs.csv`](../data/windows-gpu-runs.csv), `G49`.

## FACEIT nedeniyle değiştirilmeyen ayarlar

Ölçüm sırasında bu ayarlara dokunulmadı: Secure Boot, CSM, Firmware TPM, IOMMU, SVM, DMA koruması, Pluton, VBS/HVCI ve Windows Update.

## Fan ve pompa (isteğe bağlı)

Fan ayarları performans ölçümünün parçası değildir.

- **CPU ve kasa fanı:** PWM Mode, Manual eğri. 20, 30, 40, 50, 60, 67, 70 ve 100 °C noktalarında %20, 26, 34, 45, 60, 80, 100 ve 100.
- **AIO pompa:** PWM Mode, Manual eğri. 30, 40, 50, 58, 65, 70, 85 ve 100 °C noktalarında %20, 20, 36, 52, 68, 84, 100 ve 100.
- **Ölçülen pompa devri:** Boşta yaklaşık 1240 rpm. Tam hızda yaklaşık 2780 rpm.

---

**Önceki adım:** [BIOS](bios.md) · **Sonraki adım:** [Ekran kartı](gpu.md) · [Belgeler dizini](README.md)
