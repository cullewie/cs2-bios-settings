# Sorun giderme

| Belirti | Çözüm |
|---|---|
| RAM ayarından sonra açılmıyor veya bellek eğitimi bitmiyor | Bekleyin. Açılmazsa **Clear CMOS** yapın ve ayarları yeniden girin. Hâlâ açılmazsa bir kademe gevşetin (örneğin Trcd/Trp +2, Trfc1 +32). Bu gevşek değerler denenmedi. |
| RAM frekansını artırdıktan sonra açılıştan kısa süre sonra mavi ekran (`0xA`, `IRQL_NOT_LESS_OR_EQUAL`) | Bellek kararsızdır. BIOS'ta **Tool → ASUS User Profile → Load from Profile** ile önceki ayarı yükleyin. Bu sistemde 6400 1:1, 6000 zamanlamalarıyla iki açılışta da bu hatayı verdi. |
| BCLK değiştirdikten sonra açılmıyor veya BIOS varsayılana dönüyor | Bu anakartta BCLK, PCIe saatini de değiştirir. BCLK'yi 100 MHz yapın ve kayıtlı profili yükleyin. Bu sistemde 102 MHz açılmadı. |
| Rastgele çökme veya WHEA hatası | Önce RAM sıcaklığını kontrol edin. tREFI 65535 sıcaklığa duyarlıdır. Sonra FCLK değerini iki menüde de 2000'e düşürün (WHEA 19 genellikle FCLK kararsızlığıdır). Gerekirse RAM'i EXPO veya XMP profiline alın. |
| FACEIT, Secure Boot, TPM veya VBS hatası | [BIOS: FACEIT ve güvenlik](bios.md#faceit-ve-güvenlik) ayarlarını kontrol edin. Windows Güvenliği → Cihaz güvenliği → Çekirdek yalıtımı → Bellek bütünlüğü açık olmalıdır. |
| Windows 8 mantıksal işlemci gösteriyor | SMT kapalı kalmıştır. Advanced → AMD CBS → SMT Control değerini Auto yapın ve bilgisayarı tamamen kapatıp açın. |
| BIOS güncellemesinden sonra BitLocker anahtarı isteniyor | fTPM sıfırlanmıştır. Kurtarma anahtarını girin. Sonra fTPM'in açık olduğunu kontrol edin. |
| Steam yeniden başlatıldıktan sonra CPU 0 ayarı kayboldu | [CPU 0 adımlarını](windows.md#cs2yi-cpu-0-dışında-çalıştırma) tekrarlayın. |
| Ekran bir an kararıyor, oyun kapanıyor. Olay Görüntüleyicisi'nde `nvlddmkm` 153 veya 14 var. | Ekran kartı hız aşırtması kararsızdır (TDR). Çekirdeği 25 MHz düşürün. TDR sonrası sürücü ofsetleri ve güç sınırını sıfırlar. Afterburner'da profili yeniden yükleyin. |
| TDR yalnızca oyunun ilk dakikalarında oluyor | Kart soğukken saat daha yükseğe çıkar. Soğuk açılıştaki en yüksek saati çökme sınırıyla karşılaştırın ([Ekran kartı](gpu.md#günlük-ayar-msi-afterburner-profil-1)). |
| Yeniden başlatmadan sonra ekran kartı stok saatte | Afterburner'ı açın ve Profil 1'i yükleyin ([Ekran kartı](gpu.md#günlük-ayar-msi-afterburner-profil-1)). |
| CS2 oyundan çıkarken çöküyor. Olay günlüğünde `tier0.dll`, erişim ihlali. | CS2'nin kendi hatasıdır. Kapanış sırasında log sistemi kapatılırken olur. Hız aşırtmadan önce de vardı. Oyun içinde etkisi yoktur. |
| Alt-Tab sırasında ekran kararıyor | Tam ekran iyileştirmeleri kapalıyken normaldir (gerçek tam ekran). İstemiyorsanız `cs2.exe` Uyumluluk sekmesindeki kutunun işaretini kaldırın. |
| CS2 aniden kapandı. Döküm `soundsystem.dll` içinde. | Kablosuz kulaklık alıcısı oyun açıkken yeniden bağlanmıştır. CS2 ses aygıtını yeniden başlatırken çöker. CS2 açıkken alıcıyı çıkarıp takmayın. Dökümü [`Get-DumpSummary.ps1`](../scripts/windows/Get-DumpSummary.ps1) ile okuyun. |
| FPS bir gün öncekinden düşük | CS2 sürümünü, oyun ayarlarını ve arka planda çalışan uygulamaları kontrol edin ([Sapma kaynakları](methodology.md#sapma-kaynakları)). |

---

[Belgeler dizini](README.md)
