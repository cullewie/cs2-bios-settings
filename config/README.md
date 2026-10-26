# Hedef ayar listesi

[`bios-target-2503.csv`](bios-target-2503.csv), bu rehberin BIOS ayarlarını makine tarafından okunabilir biçimde içerir. [`Test-Configuration.ps1`](../scripts/check/Test-Configuration.ps1) canlı BIOS değerlerini bu listeyle karşılaştırır ([Kontrol](../docs/verification.md)).

- **BIOS sürümü:** ASUS ROG STRIX X870-A GAMING WIFI, 2503
- **Satır sayısı:** 126 (72 ayar + 54 fan ve pompa eğrisi noktası). Fan satırları yalnızca `-Fan` seçeneğiyle kontrol edilir.

## Sütunlar

| Sütun | Anlamı |
|---|---|
| `Sira` | Satır numarası |
| `Grup` | Uygulama sırası: `1-RAM`, `2-CPU`, `3-Auto`, `4-FACEIT`, `5-Sistem`, `6-Fan` |
| `Menu` | BIOS menü yolu |
| `Ayar` | Ayarın menüdeki adı |
| `Hedef` | Menüde seçilecek değer |
| `Degisken` | Ayarın saklandığı UEFI değişkeni: `OCMR` (ASUS Ai Tweaker), `AOD` (AMD Overclocking), `CBS` (AMD CBS), `SETUP`, `QFAN` (fan ve pompa) |
| `Ofset` | Değişken içindeki konum (onaltılık, BIOS 2503) |
| `Bayt` | Ayarın bayt sayısı |
| `Hedef_ham` | Hedef değerin NVRAM'deki ham karşılığı. Kontrol betiği bu değeri karşılaştırır. |
| `Tur` | Ayarın türü: `RAM`, `Performans`, `Notr` (zararsız, etkisiz), `Opsiyonel`, `Auto kalmali`, `FACEIT`, `Sistem`, `Fan (kisisel)` |
| `IFR_Ad` | BIOS ayar sözlüğündeki ad. Yeni BIOS sürümünde ofseti ada göre bulmak için kullanılır (`-IfrFile`). AMD Overclocking ayarlarında boştur. |
| `Not` | Açıklama ve ölçülen etki |

## Kendi listenizi oluşturma

Bu dosyanın bir kopyasında `Hedef` ve `Hedef_ham` sütunlarını kendi değerlerinizle değiştirin. Ayrıntı: [Başka sistemlere uyarlama](../docs/adapting.md#kendi-ayar-listenizi-oluşturma).

---

[Ana sayfa](../README.md) · [Belgeler](../docs/README.md)
