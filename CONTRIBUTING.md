# Katkı rehberi

Katkılarınız memnuniyetle karşılanır. Bu rehber tek bir sistemin ölçümlerine dayanır. Başka sistemlerden gelen sonuçlar rehberi daha yararlı yapar.

## Ölçüm sonucu paylaşma

Yeni bir sorun (issue) açın ve **Ölçüm sonucu** şablonunu seçin. Şu bilgileri ekleyin:

- **Sistem:** İşlemci, anakart ve BIOS sürümü, RAM kiti ve ayarı, ekran kartı ve sürücü sürümü.
- **Değiştirilen ayar:** Yalnızca bir ayar. Birden çok ayar değiştiyse hepsini yazın.
- **Sonuç:** Her koşul için ortalama FPS, P1 ve koşu sayısı.
- **Yöntem:** Harita, ısınma koşusu sayısı, CS2 sürümü, oyun içi ayarlar.

**Ölçüm kuralları:**

1. Benchmark haritasını kullanın: Steam Workshop `3240880604` (de_dust2).
2. Her yeni CS2 oturumunda önce ısınma koşuları çalıştırın. Bunları sonuca katmayın.
3. Her koşul için en az 3 kayıt koşusu çalıştırın.
4. Mümkünse koşulları aynı CS2 oturumunda dönüşümlü sırayla ölçün (A B B A).
5. Ölçüm sırasında arka plan uygulamalarını kapatın. CS2 sürümünün değişmediğini kontrol edin.

Yöntemin ayrıntısı: [Ölçüm yöntemi](docs/methodology.md).

> [!CAUTION]
> Kişisel bilgi paylaşmayın. `console.log` dosyası oyuncu adları ve IP adresleri içerebilir. Dosyanın tamamını değil, yalnızca `[VProf]` satırlarını kopyalayın. Ekran görüntülerinde kullanıcı adı, PC adı ve seri numarası görünmemelidir.

## Hata bildirme ve düzeltme önerme

- Yanlış bilgi, kırık bağlantı veya çalışmayan betik için **Hata veya düzeltme** şablonuyla sorun açın.
- Yazım ve bağlantı düzeltmelerini doğrudan pull request olarak gönderebilirsiniz.

## Yazım kuralları

- Belgeler Türkçe yazılır. Cümleler kısa ve tek anlamlıdır: bir cümlede bir bilgi, etken çatı, tutarlı terimler (ASD-STE100 yaklaşımı).
- Belgelerde ondalık ayırıcı virgüldür (`%2,6`). CSV dosyalarında noktadır (`942.2`).
- Yeni bir sonuç eklerken ham veriyi `data/` klasörüne ekleyin. Sonra [docs/results.md](docs/results.md) tablosunu ve [CHANGELOG.md](CHANGELOG.md) dosyasını güncelleyin.
- Bağlantılar göreli olmalıdır (örnek: `docs/bios.md`).

## Betik kuralları

- Betikler Windows PowerShell 5.1 ile çalışmalıdır.
- Betik adı onaylı bir PowerShell fiili ve tekil bir isimden oluşur (`Get-Verb` listesi). Örnek: `Get-VProfReport.ps1`.
- Betiklerde yalnızca ASCII karakter kullanın. Windows PowerShell 5.1, BOM'suz UTF-8 dosyalardaki Türkçe karakterleri yanlış okur.
- Betiğin yalnızca okuduğunu veya neyi değiştirdiğini ilk satırlarda yazın. Sisteme yazan betikler önce yedek almalıdır.

## Dosya ve klasör adları

- Klasör ve dosya adları İngilizce, küçük harf ve tire ile yazılır (örnek: `windows-gpu-runs.csv`).
- PowerShell betikleri `Fiil-İsim.ps1` biçimindedir (örnek: `Test-Configuration.ps1`).

## Lisans

Katkılarınız deponun [MIT lisansı](LICENSE) kapsamında yayımlanır.
