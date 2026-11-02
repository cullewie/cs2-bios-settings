# Windows ve CS2 ayarları

Windows 11 Pro (derleme 26300) ve CS2 için uygulanan ayarlar. BIOS ayarlarından sonra uygulayın.

## Windows

| Ayar | Değer | Not |
|---|---|---|
| Donanım hızlandırmalı GPU zamanlaması (HAGS) | Açık | Ayarlar → Sistem → Ekran → Grafik |
| CS2'yi CPU 0 dışında çalıştırma | Uygulayın | Aşağıdaki adımlar. Ölçülen kazanç +%1,8 ile +%2,5. |
| İşlem önceliği | Normal | Yüksek öncelik denendi. Etkisi yok. |
| Bellek Bütünlüğü (HVCI) | Açık | FACEIT için gerekir. |
| Oyun Modu | Kapalı | Test edilmedi. |
| Ethernet: Energy Efficient Ethernet | Kapalı | Aygıt Yöneticisi → ağ bağdaştırıcısı → Gelişmiş. Etkisi ölçülmedi. Bağlantı kısa bir süre kopar. |
| Win32PrioritySeparation | Varsayılan (2) | Değiştirmeyin. Ayrıntı aşağıda. |
| Kesme yerleşimi (Interrupt Affinity) | Varsayılan | Değiştirmeyin. GPU ve USB DPC işi zaten CPU 0'da çalışır. |
| Tam ekran iyileştirmeleri (yalnızca `cs2.exe`) | Kapalı (Legacy Flip) | Aşağıdaki adımlar. Ölçülen kazanç +%1,13. |
| Güç planı | En az işlemci durumu %100, çekirdek park etme kapalı | Değişiklik ölçülmedi. |

## CS2'yi CPU 0 dışında çalıştırma

Bu adımı her Steam açılışında tekrarlayın.

1. Steam açıkken Görev Yöneticisi'nde **Ayrıntılar** sekmesini açın.
2. `steam.exe` satırına sağ tıklayın ve **Benzeşimi ayarla** seçin.
3. **CPU 0** kutusunun işaretini kaldırın ve **Tamam** seçin.
4. CS2'yi Steam'den başlatın. CS2 bu ayarı Steam'den devralır. `cs2.exe` dosyasına ayrıca dokunmanız gerekmez.

CS2'yi NVIDIA App ile başlatırsanız CS2 yine `steam.exe` altında açılır ve ayarı devralır. Bu durum denendi ve doğrulandı.

> [!NOTE]
> Steam, Windows açılışında kendiliğinden başlarsa CPU 0 ayarı uygulanmamış olur. Ayarı her Steam açılışında kontrol edin.

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

## FACEIT nedeniyle değiştirilmeyen ayarlar

Ölçüm sırasında bu ayarlara dokunulmadı: Secure Boot, CSM, Firmware TPM, IOMMU, SVM, DMA koruması, Pluton, VBS/HVCI ve Windows Update.

## Fan ve pompa (isteğe bağlı)

Fan ayarları performans ölçümünün parçası değildir.

- **CPU ve kasa fanı:** PWM Mode, Manual eğri. 20, 30, 40, 50, 60, 67, 70 ve 100 °C noktalarında %20, 26, 34, 45, 60, 80, 100 ve 100.
- **AIO pompa:** PWM Mode, Manual eğri. 30, 40, 50, 58, 65, 70, 85 ve 100 °C noktalarında %20, 20, 36, 52, 68, 84, 100 ve 100.
- **Ölçülen pompa devri:** Boşta yaklaşık 1240 rpm. Tam hızda yaklaşık 2780 rpm.

---

**Önceki adım:** [BIOS](bios.md) · **Sonraki adım:** [Ekran kartı](gpu.md) · [Belgeler dizini](README.md)
