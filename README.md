```
 ██████╗███████╗██████╗
██╔════╝██╔════╝╚════██╗
██║     ███████╗ █████╔╝
██║     ╚════██║██╔═══╝
╚██████╗███████║███████╗
 ╚═════╝╚══════╝╚══════╝
██████╗ ██╗ ██████╗ ███████╗
██╔══██╗██║██╔═══██╗██╔════╝
██████╔╝██║██║   ██║███████╗
██╔══██╗██║██║   ██║╚════██║
██████╔╝██║╚██████╔╝███████║
╚═════╝ ╚═╝ ╚═════╝ ╚══════╝
███████╗███████╗████████╗████████╗██╗███╗   ██╗ ██████╗ ███████╗
██╔════╝██╔════╝╚══██╔══╝╚══██╔══╝██║████╗  ██║██╔════╝ ██╔════╝
███████╗█████╗     ██║      ██║   ██║██╔██╗ ██║██║  ███╗███████╗
╚════██║██╔══╝     ██║      ██║   ██║██║╚██╗██║██║   ██║╚════██║
███████║███████╗   ██║      ██║   ██║██║ ╚████║╚██████╔╝███████║
╚══════╝╚══════╝   ╚═╝      ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
```

# CS2 BIOS, Windows ve ekran kartı ayar rehberi

[![Lisans: MIT](https://img.shields.io/badge/lisans-MIT-blue)](LICENSE)
[![Son güncelleme](https://img.shields.io/github/last-commit/cullewie/cs2-bios-settings?label=son%20g%C3%BCncelleme)](CHANGELOG.md)
![İşlemci](https://img.shields.io/badge/i%C5%9Flemci-Ryzen%207%209800X3D-ED1C24)
![Ekran kartı](https://img.shields.io/badge/ekran%20kart%C4%B1-RTX%205070%20Ti-76B900)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1-5391FE)

Ryzen 7 9800X3D ve RTX 5070 Ti ile ölçülmüş CS2 ayarları. Ham veri, ölçüm betikleri ve ayar kontrol aracı dahil.

**Türkçe** · [English](README.en.md)

> [!WARNING]
> RAM ve ekran kartı hız aşırtması, voltaj artışı ve PBO garanti kapsamını etkileyebilir. Sistem kararsız çalışabilir ve veri kaybı olabilir. Tüm sorumluluk size aittir. Değerler tek bir sistemde ölçüldü.

## İçindekiler

- [Öne çıkan sonuçlar](#öne-çıkan-sonuçlar)
- [Hızlı başlangıç](#hızlı-başlangıç)
- [Belgeler](#belgeler)
- [Test sistemi](#test-sistemi)
- [Ölçüm yöntemi](#ölçüm-yöntemi)
- [Depo yapısı](#depo-yapısı)
- [Katkı](#katkı)
- [Atıf](#atıf)
- [Lisans](#lisans)

## Öne çıkan sonuçlar

![Ölçülen ortalama FPS kazancı](docs/img/fps-gains.svg)

| Ayar | Ortalama FPS | Karar |
|---|---|---|
| PBO Advanced, PBO Limits Motherboard, Boost Override +200 | **+%3,5** | Kullanın |
| Ekran kartı hız aşırtma (günlük profil: +425 / +3000 / %116) | **+%2,6** (gölge Düşük), **+%3,3** (gölge Yüksek) | Kullanın |
| CS2'yi CPU 0 dışında çalıştırma | **+%1,8 ile +%2,5** | Kullanın |
| `cs2.exe` için tam ekran iyileştirmeleri kapalı (Legacy Flip) | **+%1,13** | Kullanın |
| RAM DDR5-6000 CL28 1:1 (8000 Gear 2 yerine) | +%0,2 ile +%0,4 (sapma içinde) | İkisi de olur |
| DDR5 Nitro Mode 1-3-1 | **−%1,4** | Auto bırakın |
| CS2'yi Vulkan ile çalıştırma | **−%6** | DX11 (varsayılan) kalsın |
| Ekran kartı undervolt (VF eğrisi) | FPS aynı, güç −5 W | Kullanmayın: uzun oturumda sürücü hatası |

**Toplam:** BIOS ayarları ve CPU 0 dışlama ile ortalama FPS 911'den 970'e çıktı (+%6,4). Aynı BIOS ile CPU 0 dışlama ve ekran kartı hız aşırtması 926,8'den 971,4'e çıkardı (+%4,8). İki toplam CPU 0 adımını ortak içerir. Bu nedenle toplamları birbirine eklemeyin.

Tüm ayarlar ve kararlar: [docs/results.md](docs/results.md).

## Hızlı başlangıç

Ayarları bu sırayla uygulayın:

1. **[BIOS](docs/bios.md):** RAM, işlemci, Auto kalacak ayarlar, FACEIT ve güvenlik.
2. **[Windows ve CS2](docs/windows.md):** CPU 0 dışlama, Legacy Flip, oyun içi ayarlar.
3. **[Ekran kartı](docs/gpu.md):** MSI Afterburner profili.
4. **[Kontrol](docs/verification.md):** Tüm ayarları tek komutla doğrulayın.

   ```powershell
   .\scripts\check\Test-Configuration.ps1
   ```

BIOS güncellemesinden veya CMOS sıfırlamasından sonra aynı sırayı izleyin. Başka bir sistem kullanıyorsanız önce [Başka sistemlere uyarlama](docs/adapting.md) sayfasını okuyun.

## Belgeler

| Sayfa | Konu |
|---|---|
| [Sonuçlar](docs/results.md) | Her ayarın ölçülen etkisi ve kararı |
| [BIOS](docs/bios.md) | RAM zamanlamaları, PBO, Auto kalacak ayarlar, FACEIT ayarları |
| [Windows ve CS2](docs/windows.md) | CPU 0 dışlama, Legacy Flip, DPC ölçümü, oyun içi ayarlar |
| [Ekran kartı](docs/gpu.md) | Günlük profil, undervolt, gölge kalitesi, kendi sınırınızı bulma |
| [Kontrol](docs/verification.md) | Kontrol betiği, BIOS güncellemesinden sonra yapılacaklar |
| [Başka sistemlere uyarlama](docs/adapting.md) | Farklı RAM, işlemci, anakart veya ekran kartı |
| [Ölçüm yöntemi](docs/methodology.md) | Benchmark, karar kuralları, sapma kaynakları |
| [Sorun giderme](docs/troubleshooting.md) | Açılmama, WHEA, TDR, FACEIT, CS2 çökmeleri |
| [Sınırlar](docs/limitations.md) | Ölçümün sınırları ve test edilmeyen konular |
| [Betikler](scripts/README.md) | Ölçüm, kontrol ve analiz betikleri |
| [Veri sözlüğü](data/README.md) | CSV dosyaları ve sütunları |

## Test sistemi

| Parça | Değer |
|---|---|
| İşlemci | AMD Ryzen 7 9800X3D |
| Anakart | ASUS ROG STRIX X870-A GAMING WIFI, BIOS 2503 |
| Bellek | 2 × 24 GB DDR5-8000, SK Hynix M-die |
| Ekran kartı | GIGABYTE GeForce RTX 5070 Ti AERO OC 16G, NVIDIA 617.42 |
| Ekran | 1920×1080, 360 Hz |
| İşletim sistemi | Windows 11 Pro, derleme 26300 |

Tam liste: [Ölçüm yöntemi](docs/methodology.md#test-sistemi).

## Ölçüm yöntemi

- **Benchmark:** Steam Workshop haritası `3240880604` (de_dust2), yaklaşık 129 saniye. FPS değerleri CS2'nin VProf özetinden alındı.
- **BIOS testleri:** Her ayar ayrı bir CS2 oturumunda ölçüldü: 6 ısınma koşusu ve 6 kayıt koşusu. Oturumlar arası sapma genelde ±%0,6'dır, bir kez %1,2 görüldü. RAM ve BCLK testleri A-B-A sırasıyla doğrulandı.
- **Windows ve ekran kartı testleri:** Koşullar aynı CS2 oturumunda dönüşümlü veya bloklu sırayla ölçüldü. Her koşuda GPU saati, gücü ve sürücü hataları kaydedildi.
- **Veri:** BIOS testlerinde 132 koşu ve 2 maç. Windows, ekran kartı, RAM ve BCLK testlerinde 157 koşu, 53 Superposition koşusu ve 24 kararlılık testi.

Ayrıntı: [Ölçüm yöntemi](docs/methodology.md).

## Depo yapısı

```text
.
├── docs/           Rehber sayfaları ve grafik
├── data/           Ham ölçüm verisi (CSV) ve veri sözlüğü
├── config/         BIOS hedef ayar listesi
├── scripts/        PowerShell betikleri
│   ├── bench/      CS2 benchmark otomasyonu ve analiz
│   ├── bios/       NVRAM okuma ve BIOS ayar sözlüğü
│   ├── check/      Ayar kontrolü
│   ├── gpu/        Afterburner profilleri ve ekran kartı ölçümü
│   ├── hwinfo/     HWiNFO sensör kaydı
│   └── windows/    Kesme, DPC, PresentMon ve döküm analizi
├── .github/        Sorun ve pull request şablonları
├── CHANGELOG.md    Değişiklik günlüğü
├── CITATION.cff    Atıf bilgisi
├── CODE_OF_CONDUCT.md  Davranış kuralları
├── CONTRIBUTING.md Katkı rehberi
├── SECURITY.md     Güvenlik politikası
└── LICENSE         MIT lisansı
```

## Katkı

Kendi sisteminizdeki ölçüm sonuçlarını paylaşabilir, hata bildirebilir veya düzeltme önerebilirsiniz. Kurallar ve şablonlar: [CONTRIBUTING.md](CONTRIBUTING.md).

## Atıf

Bu depodaki verileri kullanırsanız sayfanın sağındaki **Cite this repository** bağlantısını kullanın ([CITATION.cff](CITATION.cff)).

## Lisans

[MIT](LICENSE) © cs2-bios-settings contributors
