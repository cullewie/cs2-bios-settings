# Veri dosyaları

Tüm CSV'ler UTF-8, virgülle ayrılmış, ondalık ayırıcı nokta.

## kosular.csv

Koşu başına bir satır: 132 benchmark koşusu ve 2 gerçek maç. Kaynaklar:
- CS2 `console.log` yedeklerindeki `[VProf]` satırları.
- `run_bench.ps1` ilerleme kaydı (koşu etiketleri).
- 18.10'daki elle yapılan koşular için günlükteki ham VProf satırları.

Gizlilik için saat yazılmadı; oturum içindeki sıra ve dakika verildi.

| Sütun | Anlamı |
|---|---|
| `Tarih` | Ölçüm günü |
| `Oturum` | CS2 oturumu. O0 Aşama 0, O1 Aşama 1, O1m maçlar, O2 CPU 0 testi, O3 PBO200_MB, O4 CO-10, O5 CoreL2, O6 NitroCombo, O7 NitroAuto, O8 L2Tekrar + HWiNFO, O9 PRI2x2, O10 SMT kapalı |
| `Sira` | Oturum içindeki sıra |
| `Dakika` | Oturumun ilk koşusundan bu yana geçen dakika (VProf rapor zamanı) |
| `Test` | Test adı (`testler.csv` ile aynı) |
| `Kosul` | Affinity maskesi / öncelik / koşul etiketi |
| `Tip` | `isinma` (karşılaştırmaya katılmaz), `kayit`, `olcum-disi` (HWiNFO açıktı), `mac` |
| `Avg_FPS`, `P1_FPS` | VProf `FPS: Avg=`, `P1=` |
| `P99_ms` | FrameTotal: karelerin %99'unun altında kaldığı süre |
| `Ort_kare_ms` | FrameTotal: ortalama kare süresi |
| `Maks1s_P50_ms`, `Maks1s_P95_ms` | Her 1 saniyedeki en uzun karenin medyanı ve 95. yüzdeliği |
| `Kare`, `Saniye` | Analize giren kare sayısı, 1 saniyelik aralık sayısı |
| `Not` | Özel durum (odak kaybı, eksik kaynak vb.) |

Notlar:
- HWiNFO testinin iki koşusunun `console.log` yedeği yok; Avg/P1/P99/1 sn P95 değerleri günlükten alındı, diğer sütunlar boş.
- O0'ın ilk koşusu ayrı bir CS2 açılışında yapıldı.

## ozet.csv

Test ve koşul başına yalnız `kayit` koşularının medyanı, en düşüğü ve en yükseği.

## testler.csv

Her testin BIOS durumu, o testte değişen ayar, affinity, öncelik, ısınma/kayıt sayısı, yöntem, ilgili NVRAM görüntüsünün adı, neyle karşılaştırıldığı ve sonucu.

## bios_son_durum.csv

Projenin sonundaki BIOS durumunun tam dökümü. NVRAM ham baytları BIOS 2503'ün ayar sözlüğüyle (IFR) çözüldü. Başka işlemci ailelerine ait etkin olmayan CBS kopyaları (AmdSetupPHX, AmdSetupSTXKRK) çıkarıldı.

| Sütun | Anlamı |
|---|---|
| `Form` | BIOS menü sayfası |
| `Prompt` | Ayar adı |
| `VarStore` | NVRAM değişkeni |
| `Off` | Değişken içindeki ofset (onaltılık) |
| `Size` | Boyut (bayt) |
| `Value` / `ValueHex` | Değer |
| `Option` | Seçeneğin metni |
| `Default` | `E` = BIOS varsayılanıyla aynı (Evet), `H` = varsayılandan farklı (Hayır), `?` = varsayılan bilinmiyor |
| `Sup` | Menüde gizli mi (`suppressif`) |
| `Gray` | Koşullu olarak gri mi |
| `Range` | Sayısal aralık |
| `Kind` | Öğe türü (OneOf, Numeric, CheckBox) |

AMD Overclocking menüsünün değişkeni (`AodSetupRpl`) sözlükte yok. Onun alanları `bios_aod_alanlari.csv` dosyasında.

## bios_aod_alanlari.csv

`AodSetupRpl` değişkeninin 226 alanı. Alan adları ASUS profil dosyasındaki yapı tanımlarından alındı.

| Sütun | Anlamı |
|---|---|
| `Ofset`, `Alan`, `Bayt` | Konum, alan adı, uzunluk |
| `Son_durum` | Projenin sonundaki değer |
| `Baslangic_Asama1` | Aşama 1'deki değer (CPU ayarları varsayılan) |
| `Eski_profil_2402` | Projeden önce kaydedilmiş, BIOS 2402 dönemine ait profil dosyasındaki değer (yüklenmedi, yalnız karşılaştırma) |

Değer 255 ya da 65535 genellikle "Auto" demektir.
