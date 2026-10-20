# Hedef ayar listesi

`hedef_ayarlar_2503.csv`: Bu kurulumun tüm BIOS ayarları. Hem rehberin (REHBER.md) hem de `kontrol/ayar_kontrol.ps1` betiğinin kaynağıdır. Liste, projenin sonundaki NVRAM görüntüsüyle karşılaştırıldı (125 satırın hepsi aynı).

| Sütun | Anlamı |
|---|---|
| `Sira` | Uygulama sırası |
| `Grup` | `1-RAM`, `2-CPU`, `3-Auto` (Auto/kapalı kalmalı), `4-FACEIT`, `5-Sistem`, `6-Fan` (kişisel; yalnız `-Fan` ile kontrol edilir) |
| `Menu` | BIOS menü yolu |
| `Ayar` | Menüde görünen ad |
| `Hedef` | Menüde seçilecek / yazılacak değer |
| `Degisken` | NVRAM değişkeni: `OCMR` (Ai Tweaker), `AOD` (AMD Overclocking), `CBS` (AMD CBS), `SETUP`, `QFAN` |
| `Ofset`, `Bayt` | Değişken içindeki konum (onaltılık) ve uzunluk. **BIOS 2503 için.** |
| `Hedef_ham` | NVRAM'de beklenen ham değer (küçük-endian tamsayı) |
| `Tur` | Performans / RAM / Nötr / Opsiyonel / Auto kalmalı / FACEIT / Sistem / Fan (kişisel) |
| `IFR_Ad` | BIOS sözlüğündeki tam ad. `-IfrFile` verildiğinde ofset bu adla bulunur. AOD satırlarında boş, çünkü AMD Overclocking menüsü sözlükte yok. |
| `Not` | Ölçülen etki veya uyarı |

## Kendi ayarların için kullanmak

1. Ayarlarını BIOS'tan elle gir.
2. Ham değerleri görmek için bir görüntü al ve okunur döküm üret:

   ```powershell
   .\nvram\nvram_snap.ps1 -OutDir .\snap_benim
   .\nvram\bios_dump.ps1 -SnapDir .\snap_benim -IfrFile .\sozluk\ifr_all.tsv -OutCsv .\benim.csv -OutMd .\benim.md
   ```

   Sözlüğü kendi BIOS dosyandan çıkar: REHBER.md bölüm 7.
3. Bu CSV'nin bir kopyasında `Hedef` ve `Hedef_ham` sütunlarını kendi değerlerinle değiştir. İstemediğin satırları sil.
4. Kontrolü kendi listenle çalıştır:

   ```powershell
   .\kontrol\ayar_kontrol.ps1 -Hedef .\benim_hedeflerim.csv
   ```

Kod örnekleri:
- Açık/kapalı ayarlarda genellikle 255 = Auto, 0 = Disabled, 1 = Enabled. Ama ayara göre değişir; doğrusu `data/bios_son_durum.csv` dosyasında ya da sözlükte.
- DRAM voltajı: volt = 0,79 + 0,01 × kod (81 = 1,60 V).
