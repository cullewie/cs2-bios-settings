# Sınırlar

Sonuçları yorumlarken bu sınırları göz önünde tutun.

## Ölçümün sınırları

- **Tek sistem:** Ölçümler tek işlemci, tek RAM kiti, tek anakart ve tek ekran kartıyla yapıldı. Sonuçları başka sistemlere doğrudan uygulamayın.
- **Oturum sapması:** Oturumlar arasında ±%0,6 sapma vardır. Bundan küçük farklar ayırt edilemez.
- **BIOS karşılaştırmaları:** BIOS güncellemesi ve RAM ayarı aynı anda yapıldı. Bu nedenle FPS farkını yalnızca RAM ayarına bağlayamazsınız.
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
| DDR5-6000 ve 6400, 1:1 (UCLK = MEMCLK) | Henüz ölçülmedi. Ölçüm planlandı. |
| CS2 grafik ayarları (MSAA, Reflex vb.) | Gölge kalitesi dışında ölçülmedi. |
| BCLK | PCIe saatini de değiştirir. Önerilmez. |
| Thermal Limit, PBO limitleri, daha derin Curve Optimizer | İşlemci saat tavanındadır ve güç sınırından uzaktır. Kazanç beklenmez. |
| Turbo Game Mode, Gaming Adaptive CCD Parker | Çift CCD'li işlemciler içindir. 9800X3D tek CCD'lidir. |
| Process Lasso, PBO2 Tuner gibi çekirdek sürücüsü yükleyen araçlar | Kullanılmadı. |
| Ekran kartı belleği +3000 üstü | Sürücü sınırıdır. Aşmak için resmi olmayan araç gerekir (ör. mVolt+). Kullanılmadı. CS2'de bellek saatinin etkisi yoktur. |
| NVIDIA sürücüsü güncelleme (617.42 → 621.01) | Yapılmadı. Sürüm notlarında CS2 maddesi yok. |
| Kesmeleri kayıt defteriyle başka çekirdeğe taşıma | Varsayılan yerleşim zaten CPU 0'dır. CS2'yi CPU 0'dan uzak tutmak daha basittir. |
| RAM ikincil zamanlamaları (tRDRDSCL, tWRWRSCL, tRDWR) | FCLK'nin %10 artışı bile yalnızca +%0,23 verdi. Bu zamanlamalardan beklenen etki %0,2'den küçüktür. Önerilmedi. |

## Sıradaki ölçüm

- **DDR5-6000 CL28, 1:1:** 8000 MT/s (Gear 2) ile karşılaştırma. Temiz geçerse 6200 ve 6400 MT/s, 1:1.

---

[Belgeler dizini](README.md)
