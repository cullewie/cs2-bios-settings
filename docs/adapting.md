# Başka sistemlere uyarlama

Bu rehberdeki değerler tek bir sistemde ölçüldü. Başka bir sistemde aşağıdaki tabloyu kullanın.

| Durum | Yapılacak işlem |
|---|---|
| Aynı işlemci ve anakart, farklı RAM | Önce Ai Overclock Tuner = EXPO veya XMP deneyin. [RAM bölümündeki](bios.md#ram) zamanlamaları yalnızca **SK Hynix 24 Gbit M-die, 2 × 24 GB, tek rank** kitinde başlangıç noktası olarak kullanın. PBO, Windows ve FACEIT adımları aynen geçerlidir. |
| Başka X3D işlemci | Boost Override üst sınırı işlemciye göre değişir. Çift CCD'li X3D işlemcilerde (9900X3D, 9950X3D) Turbo Game Mode, CCD Parker ve Core Flex X3D preset anlamlı olabilir. Bu değerler burada test edilmedi. |
| Başka ASUS AM5 anakart | Menü adları büyük ölçüde aynıdır. NVRAM ofsetleri farklıdır. Kendi BIOS dosyanızdan ayar sözlüğü çıkarın ve `-IfrFile` ile kontrol edin ([Kontrol](verification.md#yeni-bios-sürümü-kullanıyorsanız)). |
| Başka marka anakart | Menü adları farklıdır. Ayarların anlamı aynıdır. Kontrol betiği çalışmaz. Listeyi elle uygulayın. |
| Başka ekran kartı | Günlük değeri kopyalamayın. [Kendi sınırınızı bulma](gpu.md#kendi-sınırınızı-bulma) adımlarını izleyin. |
| Tüm durumlar | Her seferde tek ayarı değiştirin. Her değişiklikten sonra ölçün ve WHEA hatası olup olmadığına bakın. |

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
