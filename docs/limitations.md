# Sınırlar

Sonuçları yorumlarken bu sınırları göz önünde tutun.

## Ölçümün sınırları

- **Tek sistem:** Ölçümler tek işlemci, tek RAM kiti, tek anakart ve tek ekran kartıyla yapıldı. Sonuçları başka sistemlere doğrudan uygulamayın.
- **Oturum sapması:** Oturumlar arasında genelde ±%0,6 sapma vardır. Bir kez, aynı BIOS ile iki oturum arasında %1,2 fark görüldü. Ayrı oturumlarda ölçülen %1'den küçük farkları A-B-A ile doğrulamadan kesin saymayın. Aynı Windows oturumunda da FPS ilk ~40 dakikada %1'e kadar düşebilir (02.11). Bloklu ölçümde sonda bir kontrol bloğu kullanın.
- **BIOS karşılaştırmaları:** BIOS güncellemesi ve RAM ayarı aynı anda yapıldı. Bu nedenle FPS farkını yalnızca RAM ayarına bağlayamazsınız.
- **Bellek kararlılığı:** Elle DDR5-8000 profili (1,60 V, tREFI 65535) için bellek kararlılık testi yapılmadı. DDR5-6000 ve 6200 yalnızca yaklaşık 16 dakikalık OCCT Memory testinden geçti. Kitin EXPO/XMP profili bu depoda ölçülmedi. Bu nedenle varsayılan RAM önerisi kitin EXPO/XMP profilidir.
- **WHEA:** WHEA hatası görülmemesi, bellek kararlılığını kanıtlamaz. RAM kararlılığı uygun bellek testleriyle doğrulanmalıdır. Bu depodaki WHEA kontrolleri yalnızca belirgin bir donanım hatası görülmediğini gösterir.
- **İşlemci kararlılığı:** PBO, Boost Override +200, Curve Optimizer −10 ve Core Tuning Level 2 için çekirdek bazında veya düşük yükte CPU kararlılık testi yapılmadı. Tek CPU testi, BCLK 101 MHz ve DDR5-6000 ile yapılan 18 dakikalık OCCT CPU + RAM testidir. Bu nedenle Curve Optimizer ve Core Tuning için öneri Auto'dur. Bu sistem 02.11'den beri Curve Optimizer Auto kullanır.
- **PBO ölçümü:** PBO Advanced, PBO Limits Motherboard ve Boost Override +200 birlikte değişti. Her ayarın payı ayrı ölçülmedi. Sonuç tek bir işlemci örneğine aittir. Aynı değerler başka bir işlemcide kararsız olabilir.
- **Tıklamadan ekrana gecikme ölçülmedi:** LDAT veya Reflex Analyzer kullanılmadı. PresentMon ile kare başlangıcından ekrana süre ve Windows DPC/kesme süreleri ölçüldü.
- **Benchmark ve maç farkı:** Benchmark haritasında bot vardır, sunucu yükü yoktur. Maçta ortalama FPS, benchmarka göre yaklaşık %27 düşük ölçüldü. Benchmark sonuçları maç performansının birebir karşılığı değildir.
- **Ekran kartı kararlılığı:** +450 sentetik testlerin hepsini geçti (toplam yaklaşık 2 saat 20 dakika), ama CS2'de iki kez çöktü. Günlük değer +425, soğuk açılış dahil 5 CS2 koşusunda temiz geçti. +425 için ayrı uzun sentetik test yapılmadı. Uzun oyun oturumlarında ve sıcak ortamda kararlılığı izleyin.
- **CS2 sürümü:** Windows ve ekran kartı testleri, BIOS testlerinden sonraki bir CS2 sürümünde yapıldı. İki gruptaki FPS değerlerini doğrudan karşılaştırmayın.
- **Oyun ayarları:** Gölge kalitesi 26.10'da Düşük'ten Yüksek'e alındı. Bu tarihten önceki ve sonraki FPS değerlerini doğrudan karşılaştırmayın.
- **FCLK 2200 kararlılığı:** Yalnızca yaklaşık 16 dakikalık CS2 testi ve sonraki günlerin açılış sonrası WHEA kontrolleri yapıldı. Uzun kullanımda WHEA 19 olaylarını izleyin.

## Test edilmeyen konular

| Konu | Neden |
|---|---|
| Secure Boot, TPM, IOMMU, HVCI, SVM, CSM | FACEIT denetler. Bu ayarlara dokunulmadı. |
| DDR5-6400 1:1, gevşek zamanlamalar veya yüksek SOC voltajıyla | 6000 zamanlamalarıyla iki kez mavi ekran verdi. Gevşek ayarlar denenmedi. Mevcut ölçümler 6000, 6200 ve 8000 arasında güvenilir bir FPS farkı ortaya koymuyor. |
| CS2 grafik ayarları (MSAA, Reflex vb.) | Gölge kalitesi dışında ölçülmedi. |
| Thermal Limit, PBO limitleri, daha derin Curve Optimizer | İşlemci saat tavanındadır ve güç sınırından uzaktır. Kazanç beklenmez. Bu işlemci örneği −15'te CS2 sırasında çöktü (önceki Windows kurulumu, kullanıcı beyanı). |
| Turbo Game Mode, Gaming Adaptive CCD Parker | Çift CCD'li işlemciler içindir. 9800X3D tek CCD'lidir. |
| Process Lasso, PBO2 Tuner gibi çekirdek sürücüsü yükleyen araçlar | Kullanılmadı. |
| Ekran kartı belleği +3000 üstü | Sürücü sınırıdır. Aşmak için resmi olmayan araç gerekir (ör. mVolt+). Kullanılmadı. CS2'de bellek saatinin etkisi yoktur. |
| NVIDIA sürücüsünün tek başına etkisi | 621.01 ve 621.12 kuruldu ve ölçüldü (−%0,8 ile −%1,3). Aynı dönemde CS2 ve Windows da güncellendi. 617.42'ye dönüp aynı CS2 sürümünde ölçülmedi ([Windows](windows.md#nvidia-sürücüsü-ve-sürücü-ayarları)). |
| Tıklamadan ekrana gecikme etkisi olan CS2 seçenekleri (`engine_low_latency_sleep_after_client_tick` vb.) | Gecikme ölçüm donanımı yok. Yalnızca FPS ve kare süresi ölçüldü. |
| Kesmeleri kayıt defteriyle başka çekirdeğe taşıma | Varsayılan yerleşim zaten CPU 0'dır. CS2'yi CPU 0'dan uzak tutmak daha basittir. |
| RAM ikincil zamanlamaları (tRDRDSCL, tWRWRSCL, tRDWR) | FCLK'nin %10 artışı bile yalnızca +%0,23 verdi. Bu zamanlamalardan beklenen etki %0,2'den küçüktür. Önerilmedi. |
| Kitin EXPO/XMP profili | Varsayılan RAM önerisidir. FPS ve kararlılığı bu depoda ölçülmedi. |
| Uzun bellek testi (TM5, Karhu RAM Test, y-cruncher VT3, MemTest86) | Yapılmadı. Elle RAM profilleri için gereklidir ([BIOS](bios.md#bellek-kararlılık-testi)). |
| Çekirdek bazında CPU kararlılık testi | Yapılmadı. PBO ve Curve Optimizer değerleri için gereklidir. |

## Sıradaki ölçüm

Planlanmış ölçüm yok. BIOS, RAM, Windows ve ekran kartı tarafında ölçülebilir kazanç beklenen aday kalmadı.

---

[Belgeler dizini](README.md)
