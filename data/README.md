# Veri sözlüğü

Bu klasör, rehberdeki tüm sonuçların ham verisini içerir. Dosyalar CSV biçimindedir.

## Genel kurallar

- **Biçim:** Virgülle ayrılmış, tırnaklı alanlar, UTF-8 kodlama. Bazı dosyalarda UTF-8 BOM vardır (Excel için).
- **Ondalık ayırıcı:** Nokta (örnek: `942.2`).
- **Tarih:** `YYYY-AA-GG` (örnek: `2026-10-24`).
- **Boş hücre:** Değer kaydedilmedi.
- **Metin:** Türkçe karakterler ASCII olarak yazıldı (örnek: `Golge Yuksek`, `kayit`, `isinma`).
- **FPS değerleri:** CS2'nin VProf özetinden alındı. Benchmark haritası: Workshop `3240880604` (de_dust2). Ayrıntı: [Ölçüm yöntemi](../docs/methodology.md).

## Dosyalar

| Dosya | Satır | İçerik |
|---|---|---|
| [`bios-runs.csv`](bios-runs.csv) | 134 | BIOS testlerinin tüm benchmark koşuları ve 2 maç |
| [`bios-summary.csv`](bios-summary.csv) | 18 | BIOS testlerinde test ve koşul başına medyan, en düşük ve en yüksek değerler |
| [`bios-tests.csv`](bios-tests.csv) | 14 | Her BIOS testinin durumu, değişen ayar, yöntem ve sonuç |
| [`bios-final-state.csv`](bios-final-state.csv) | 2336 | Güncel BIOS ayarlarının tam dökümü (26.10.2026) |
| [`bios-aod-fields.csv`](bios-aod-fields.csv) | 227 | AMD Overclocking değişkeninin (AodSetupRpl) alanları |
| [`windows-gpu-runs.csv`](windows-gpu-runs.csv) | 132 | Windows, ekran kartı, FCLK, sunum kipi ve gölge testlerinin CS2 koşuları |
| [`gpu-superposition.csv`](gpu-superposition.csv) | 53 | Unigine Superposition 1080p Extreme puanları |
| [`gpu-stability.csv`](gpu-stability.csv) | 24 | Ekran kartı kararlılık testleri |

## bios-runs.csv

BIOS testlerinin (18–19.10.2026) her CS2 koşusu.

| Sütun | Anlamı | Birim |
|---|---|---|
| `Tarih` | Koşunun tarihi | |
| `Oturum` | CS2 oturumu: `O0` … `O10`. `O1m` = maç. Oturumun testleri `bios-tests.csv` dosyasındadır. | |
| `Sira` | Koşunun oturumdaki sırası | |
| `Dakika` | Oturumun ilk koşusundan sonra geçen süre | dakika |
| `Test` | Test adı (örnek: `PBO200_MB`, `CoreL2`, `NitroCombo`) | |
| `Kosul` | Koşul etiketi ve CS2 affinity maskesi. Örnek: `B (0xFFFF)` tüm çekirdekler, `A1 (0xFFFE, CPU0 haric)`, `H (0xFFFF, High)` yüksek öncelik | |
| `Tip` | `kayit` = karşılaştırmaya girer. `isinma` = ısınma koşusu, karşılaştırmaya girmez. `olcum-disi` = başka bir ölçüm sırasında alındı. `mac` = gerçek maç, benchmark ile karşılaştırılamaz. | |
| `Avg_FPS` | Ortalama FPS | FPS |
| `P1_FPS` | %1 düşük FPS | FPS |
| `P99_ms` | Karelerin %99'unun altında kaldığı süre | ms |
| `Ort_kare_ms` | Ortalama kare süresi | ms |
| `Maks1s_P50_ms` | Her saniyedeki en uzun karenin medyanı | ms |
| `Maks1s_P95_ms` | Her saniyedeki en uzun karenin 95. yüzdeliği. Takılmayı gösterir. | ms |
| `Kare` | Koşudaki kare sayısı | |
| `Saniye` | Koşudaki 1 saniyelik aralık sayısı | saniye |
| `Not` | Özel durumlar | |

## bios-summary.csv

`bios-runs.csv` dosyasındaki `kayit` koşularından hesaplandı. Sütunlar: `Test`, `Oturum`, `Kosul`, `n` (koşu sayısı), ardından `Avg`, `P1`, `P99` için `_medyan`, `_min`, `_maks` değerleri, `Ort_kare_medyan_ms`, `Maks1s_P50_medyan_ms` ve `Maks1s_P95_medyan_ms`. Birimler `bios-runs.csv` ile aynıdır.

## bios-tests.csv

| Sütun | Anlamı |
|---|---|
| `Test`, `Oturum`, `Tarih` | Test adı, CS2 oturumu ve tarih |
| `BIOS_durumu` | Testteki BIOS ayarlarının özeti |
| `Bu_testte_degisen` | Bir önceki teste göre değişen ayar |
| `Affinity`, `Oncelik` | CS2 affinity maskesi ve işlem önceliği |
| `Isinma`, `Kayit` | Isınma ve kayıt koşusu sayısı |
| `Yontem` | Ölçüm yöntemi (elle veya otomatik, dönüşümlü sıra) |
| `NVRAM_goruntusu` | Testin BIOS görüntüsünün adı |
| `Karsilastirma` | Karşılaştırılan test |
| `Sonuc` | Ölçülen etki ve karar |

## bios-final-state.csv

Güncel BIOS ayarlarının tam dökümü. 26.10.2026 tarihli NVRAM görüntüsünden [`Export-BiosSetting.ps1`](../scripts/bios/Export-BiosSetting.ps1) ile oluşturuldu. Bu işlemciyle ilgisi olmayan `AmdSetupPHX` ve `AmdSetupSTXKRK` değişkenleri çıkarıldı.

| Sütun | Anlamı |
|---|---|
| `Form` | BIOS menü sayfası |
| `Prompt` | Ayarın menüdeki adı |
| `VarStore` | Ayarın saklandığı UEFI değişkeni (örnek: `VARSTORE_OCMR_SETTINGS_NAME`, `AmdSetupRPL`, `Setup`) |
| `Off`, `Size` | Değişken içindeki konum (onaltılık) ve bayt sayısı |
| `Value`, `ValueHex` | Ham değer (ondalık ve onaltılık) |
| `Option` | Değerin menüdeki karşılığı |
| `Default` | `E` = varsayılan değerde. `H` = varsayılandan farklı. `?` = varsayılan bilinmiyor. |
| `Sup` | `GIZLI` = menüde her zaman gizli. `KOSUL` = başka bir ayara bağlı olarak görünür. Boş = her zaman görünür. |
| `Gray` | `GRI` = koşula bağlı olarak değiştirilemez |
| `Range` | En küçük, en büyük değer ve adım |
| `Kind` | Ayar türü: `OneOf` (seçim listesi), `Numeric` (sayı), `CheckBox` |

## bios-aod-fields.csv

AMD Overclocking menüsünün ayarlarını saklayan `AodSetupRpl` değişkeninin alanları. Bu menü BIOS ayar sözlüğünde yoktur. Alan adları ve konumları NVRAM farklarından çıkarıldı.

| Sütun | Anlamı |
|---|---|
| `Ofset` | Alanın değişken içindeki konumu (onaltılık) |
| `Alan` | Alan adı (örnek: `AodFclkFrequency`, `AodAllCoreCurveOptimizerMagnitude`) |
| `Bayt` | Alanın bayt sayısı |
| `Son_durum` | Güncel değer (26.10.2026) |
| `Baslangic_Asama1` | RAM Aşama 1 başlangıcındaki değer |
| `Eski_profil_2402` | BIOS 2402 profilindeki değer |

Çok baytlı alanlarda (örnek: `Header`, 44 bayt) değer bir sayı olarak gösterilir ve anlamlı değildir.

## windows-gpu-runs.csv

Windows ve ekran kartı testlerinin (23–26.10.2026) her CS2 koşusu.

| Sütun | Anlamı | Birim |
|---|---|---|
| `Tarih` | Koşunun tarihi | |
| `Oturum` | CS2 oturumu: `G1` … `G20` | |
| `Sira` | Koşunun oturumdaki sırası | |
| `Test` | Test adı (örnek: `2x2`, `Sunum modu`, `Undervolt`, `Golge Yuksek`) | |
| `Kosul` | Oturumdaki koşul etiketi. `W1`, `W2` = ısınma. | |
| `GPU_ayar` | Ekran kartı ayarı: çekirdek ofseti / bellek ofseti / güç sınırı yüzdesi. `V0` = Core Voltage 0. `VF ... @ ... mV` = undervolt eğrisi. | MHz / MHz / % |
| `Benzesim` | CS2 affinity maskesi: `0xFFFF` tüm mantıksal işlemciler, `0xFFFE` CPU 0 hariç | |
| `Tip` | `kayit`, `isinma`, `gecersiz` (koşul bozuldu) veya `cokme` (koşu yarıda kaldı) | |
| `Avg_FPS`, `P1_FPS` | Ortalama FPS ve %1 düşük FPS | FPS |
| `GPU_MHz` | Yük altında GPU çekirdek saatinin medyanı (`nvidia-smi`) | MHz |
| `Bellek_MHz` | Yük altında bellek saatinin medyanı (`nvidia-smi` birimi) | MHz |
| `GPU_W` | Yük altında ortalama kart gücü (`nvidia-smi`) | W |
| `Not` | Özel durumlar | |

## gpu-superposition.csv

Unigine Superposition 1.1, 1080p Extreme puanları.

| Sütun | Anlamı | Birim |
|---|---|---|
| `Tarih` | Ölçüm tarihi | |
| `Seri` | `A` = 23.10, stok, çekirdek ve bellek adımları (fan %70 sabit). `UV` = 23.10, ilk undervolt denemesi. `B` = 23.10, bellek +3000 ile çekirdek sınırı (fan otomatik). `V` = 24.10, Core Voltage %100. `U` = 25.10, undervolt serisi. | |
| `Sira` | Serideki sıra | |
| `Cekirdek_ofset`, `Bellek_ofset` | Afterburner ofsetleri. `VF egrisi` = undervolt eğrisi kullanıldı. | MHz |
| `Guc_limiti_yuzde` | Güç sınırı (%100 = 300 W, %116 = 350 W) | % |
| `Fan` | Fan ayarı | |
| `VF_hedef` | Undervolt hedefi (frekans @ voltaj) veya Core Voltage ayarı | |
| `Puan` | Superposition puanı | |
| `GPU_MHz`, `Bellek_MHz` | Koşu sırasında çekirdek ve bellek saati | MHz |
| `Voltaj_mV` | Çekirdek voltajı | mV |
| `GPU_W` | Kart gücü | W |
| `Sonuc` | `temiz`, `TDR` (sürücü sıfırlandı) veya `cokme` | |
| `Not` | Özel durumlar | |

## gpu-stability.csv

| Sütun | Anlamı | Birim |
|---|---|---|
| `Tarih` | Test tarihi | |
| `Ayar` | Ekran kartı ayarı (çekirdek / bellek / güç veya VF eğrisi) | |
| `Test` | Test aracı: OCCT, MSI Kombustor, Superposition veya CS2 benchmark | |
| `Test_ayari` | Testin ayarları | |
| `Sure_dk` | Test süresi | dakika |
| `Sonuc` | `gecti`, `temiz`, `TDR` veya `cokme` | |
| `GPU_MHz` | Çekirdek saati | MHz |
| `GPU_W` | Ortalama kart gücü | W |
| `Maks_C` | En yüksek GPU sıcaklığı | °C |
| `Not` | Özel durumlar | |

## Lisans

Bu klasördeki veriler deponun [MIT lisansı](../LICENSE) kapsamındadır.

---

[Ana sayfa](../README.md) · [Belgeler](../docs/README.md)
