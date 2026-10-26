# Güvenlik

## Desteklenen sürüm

Yalnızca `main` dalındaki güncel sürüm desteklenir.

## Kapsam

- Betikler yalnızca yerel bilgisayarda çalışır. Ağ bağlantısı kurmaz ve veri göndermez.
- Hangi betiğin yönetici izni istediği ve sistemde neyi değiştirdiği [scripts/README.md](scripts/README.md) içinde yazılıdır.
- [`Save-NvramSnapshot.ps1`](scripts/bios/Save-NvramSnapshot.ps1), parola, anahtar, lisans ve TPM içeren UEFI değişkenlerini kaydetmez.

## Güvenlik sorunu bildirme

Bir betikte güvenlik sorunu bulursanız (örneğin belgelenmeyen bir yazma işlemi veya kişisel bilgi sızıntısı):

1. Depo sayfasında **Security → Report a vulnerability** seçeneği varsa onu kullanın.
2. Bu seçenek yoksa ayrıntı vermeden yalnızca konuyu belirten bir sorun (issue) açın. Ayrıntıları herkese açık olarak yazmayın.
