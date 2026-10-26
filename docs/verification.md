# Kontrol

Ayarları uyguladıktan sonra, BIOS güncellemesinden sonra veya CMOS sıfırlamasından sonra tüm ayarları tek komutla doğrulayın.

## Kontrol betiğini çalıştırma

Yönetici PowerShell'de depo klasörünü açın ve şu komutları çalıştırın:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\check\Test-Configuration.ps1          # BIOS ve Windows
.\scripts\check\Test-Configuration.ps1 -Fan     # Fan ve pompa eğrileriyle birlikte
```

> [!NOTE]
> Bu betik **yalnızca okur**. NVRAM'e, kayıt defterine veya başka bir dosyaya yazmaz.

Betik şunları yapar:
- Canlı BIOS değerlerini (UEFI NVRAM) [`config/bios-target-2503.csv`](../config/bios-target-2503.csv) listesiyle karşılaştırır.
- Windows'ta şunları denetler: SMT, RAM hızı (8000), Secure Boot, TPM, VBS/HVCI, HAGS, `steam.exe` ve `cs2.exe` CPU 0 durumu ve WHEA hataları.
- Her farklı ayar için menü yolunu yazar.
- Çıkış kodu, farklı ayar sayısını verir. 0 ise tüm ayarlar doğrudur.

Örnek çıktının son satırı:

```text
Ozet: BIOS 72/72 tamam, Windows 8/9 tamam, toplam farkli: 0
```

HAGS satırı kayıt defterinde değer yoksa "BILGI" olarak görünür. Bu durumda Windows varsayılanı geçerlidir ve farklı ayar sayılmaz.

## Yeni BIOS sürümü kullanıyorsanız

Ayarların NVRAM içindeki konumu değişmiş olabilir. Yeni BIOS dosyasından sözlük oluşturun ve kontrolü bu sözlükle yapın:

```powershell
Add-Type -Path .\scripts\bios\BiosIfr.cs, .\scripts\bios\EfiDec3b.cs
[Prog]::Main(@('C:\indirilenler\BIOS.CAP', '.\yeni_sozluk'))
.\scripts\check\Test-Configuration.ps1 -IfrFile .\yeni_sozluk\ifr_all.tsv
```

AMD Overclocking ayarları (PBO ve Curve Optimizer) sözlükte yoktur. Değişkenin boyutu değiştiyse betik "DUZEN FARKLI" uyarısı verir. Bu ayarları menüden elle kontrol edin.

Ayrıntılı fark için güncelleme öncesi ve sonrası görüntüleri karşılaştırın:

```powershell
.\scripts\bios\Save-NvramSnapshot.ps1 -OutDir .\snap_sonra -Label sonra
.\scripts\bios\Compare-NvramSnapshot.ps1 -A .\snap_guncelleme_oncesi -B .\snap_sonra
```

Betiklerin ayrıntısı: [scripts/README.md](../scripts/README.md).

---

**Önceki adım:** [Ekran kartı](gpu.md) · [Belgeler dizini](README.md)
