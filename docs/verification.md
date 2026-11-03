# Kontrol

Ayarları uyguladıktan sonra, BIOS güncellemesinden sonra veya CMOS sıfırlamasından sonra tüm ayarları tek komutla doğrulayın.

## Kontrol betiğini çalıştırma

Yönetici PowerShell'de depo klasörünü açın ve şu komutları çalıştırın:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\check\Test-Configuration.ps1               # BIOS, Windows ve ekran kartı
.\scripts\check\Test-Configuration.ps1 -Fan          # Fan ve pompa eğrileriyle birlikte
.\scripts\check\Test-Configuration.ps1 -RamMts 6000  # RAM hızı hedefi (EXPO/XMP veya DDR5-6000)
.\scripts\check\Test-Configuration.ps1 -NoGpu        # Ekran kartı hız aşırtması kullanmıyorsanız
```

> [!NOTE]
> Bu betik **yalnızca okur**. NVRAM'e, kayıt defterine veya başka bir dosyaya yazmaz.

Betik şunları yapar:
- Canlı BIOS değerlerini (UEFI NVRAM) [`config/bios-target-2503.csv`](../config/bios-target-2503.csv) listesiyle karşılaştırır.
- Windows'ta şunları denetler: SMT, RAM hızı, Secure Boot, TPM, VBS/HVCI, HAGS, `steam.exe` ve `cs2.exe` CPU 0 durumu, WHEA hataları, `cs2.exe` için tam ekran iyileştirmeleri (Legacy Flip), güç planında çekirdek park etme ve işlemci boşta kalma.
- Ekran kartında güç sınırını denetler. Afterburner profili uygulanmışsa güç sınırı kartın en yüksek değerindedir. Yeniden başlatmadan veya sürücü hatasından (TDR) sonra stok değere döner. Açılıştan beri TDR olup olmadığını da yazar.
- Oyun Modu ve Ethernet EEE durumunu bilgi olarak gösterir. Etkileri ölçülmedi veya sapma içinde kaldı. Bu satırlar farklı ayar sayılmaz.
- Her farklı ayar için menü yolunu veya düzeltme adımını yazar.
- Çıkış kodu, farklı ayar sayısını verir. 0 ise tüm ayarlar doğrudur.

Örnek çıktının son satırı (CS2 kapalıyken):

```text
Ozet: BIOS 70/70 tamam, Windows 12/16 tamam, toplam farkli: 0
```

"BILGI" satırları farklı ayar sayılmaz. Örnek: HAGS için kayıt defterinde değer yoksa Windows varsayılanı geçerlidir. CS2 kapalıysa `cs2.exe` satırı "calismiyor" gösterir.

**RAM hızı:** Varsayılan hedef, listedeki **Memory Frequency** değeridir (8000). EXPO/XMP veya DDR5-6000 kullanıyorsanız `-RamMts` ile kitin hızını verin. `-RamMts 0` bu kontrolü atlar.

**Ekran kartı saati:** Saat ofseti NVIDIA'nın `nvidia-smi` ve NVML arayüzlerinde görünmez (Afterburner'ın yazdığı ofset orada 0 okunur). Bu yüzden betik güç sınırını gösterge olarak kullanır. Afterburner profil değerlerini birlikte uygular ve sürücü hepsini birlikte sıfırlar.

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
