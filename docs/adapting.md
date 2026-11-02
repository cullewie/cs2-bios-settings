# Başka sistemlere uyarlama

Bu rehberdeki değerler tek bir sistemde ölçüldü. Başka bir sistemde aşağıdaki tabloyu kullanın.

| Durum | Yapılacak işlem |
|---|---|
| Aynı işlemci ve anakart, farklı RAM | Kitin kendi EXPO veya XMP profilini kullanın (Ai Overclock Tuner). Elle zamanlamaları ([DDR5-6000](bios.md#ddr5-6000-11-alternatifi), [DDR5-8000](bios.md#ddr5-8000-ileri-düzey)) yalnızca **SK Hynix 24 Gbit M-die, 2 × 24 GB, tek rank** kitinde, başlangıç noktası olarak ve [bellek kararlılık testiyle](bios.md#bellek-kararlılık-testi) kullanın. Windows ve FACEIT adımları aynen geçerlidir. PBO ve Curve Optimizer değerleri işlemci örneğine göre değişir. Bu değerleri kopyalamayın, kararlılığı kendi sisteminizde test edin. |
| Başka X3D işlemci | PBO ve Curve Optimizer değerlerini kopyalamayın. Boost Override üst sınırı işlemciye göre değişir. Çift CCD'li X3D işlemcilerde (9900X3D, 9950X3D) Turbo Game Mode, CCD Parker ve Core Flex X3D preset anlamlı olabilir. Bu değerler burada test edilmedi. |
| Başka ASUS AM5 anakart | Menü adları büyük ölçüde aynıdır. NVRAM ofsetleri farklıdır. Kendi BIOS dosyanızdan ayar sözlüğü çıkarın ve `-IfrFile` ile kontrol edin ([Kontrol](verification.md#yeni-bios-sürümü-kullanıyorsanız)). |
| Başka marka anakart | Menü adları farklıdır. Ayarların anlamı aynıdır. Kontrol betiği çalışmaz. Listeyi elle uygulayın. |
| Başka ekran kartı | Günlük değeri kopyalamayın. [Kendi sınırınızı bulma](gpu.md#kendi-sınırınızı-bulma) adımlarını izleyin. |
| Tüm durumlar | Her seferde tek ayarı değiştirin. Her değişiklikten sonra ölçün ve WHEA hatası olup olmadığına bakın. WHEA hatası olmaması kararlılığı kanıtlamaz. Bellek ve CPU için kararlılık testi yapın. |

## Kendi ayar listenizi oluşturma

1. Ayarlarınızı BIOS'tan elle girin.
2. BIOS görüntüsü alın ve döküm oluşturun:

   ```powershell
   .\scripts\bios\Save-NvramSnapshot.ps1 -OutDir .\snap_benim
   .\scripts\bios\Export-BiosSetting.ps1 -SnapDir .\snap_benim -IfrFile .\sozluk\ifr_all.tsv -OutCsv .\benim.csv -OutMd .\benim.md
   ```

3. [`config/bios-target-2503.csv`](../config/bios-target-2503.csv) dosyasının kopyasında `Hedef` ve `Hedef_ham` sütunlarını kendi değerlerinizle değiştirin. Sütunların anlamı: [config/README.md](../config/README.md).
4. Kontrolü kendi listenizle çalıştırın:

   ```powershell
   .\scripts\check\Test-Configuration.ps1 -Hedef .\benim_hedeflerim.csv
   ```

Ayar sözlüğünü (`ifr_all.tsv`) kendi BIOS dosyanızdan oluşturun: [Kontrol](verification.md#yeni-bios-sürümü-kullanıyorsanız).

---

[Belgeler dizini](README.md)
