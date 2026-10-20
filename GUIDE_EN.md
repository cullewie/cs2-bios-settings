# Guide: CS2 settings for Ryzen 7 9800X3D + ROG STRIX X870-A + DDR5-8000

This guide has two uses:

1. **Similar systems:** apply the settings that were measured to help.
2. **After a BIOS update or CMOS reset:** the BIOS returns to defaults. Re-enter these settings in order, then run `kontrol/ayar_kontrol.ps1` to verify everything is back.

Full Turkish guide: [REHBER.md](REHBER.md). Measurement details (Turkish): [docs/SONUCLAR.md](docs/SONUCLAR.md).

> **Warning:** Memory overclocking, raised voltages and PBO may affect warranty and stability. Use at your own risk. These values were validated on one system only.

**System:**
- Ryzen 7 9800X3D.
- ASUS ROG STRIX X870-A GAMING WIFI, BIOS 2503.
- G.Skill F5-8000J4048F24GX2-TZ5RK (2 × 24 GB, SK Hynix M-die, single rank, slots A2/B2).
- RTX 5070 Ti.
- Windows 11 Pro.
- CS2 with FACEIT.

**What it gives (benchmark map, average FPS):**

| Change | Effect |
|---|---|
| PBO + Boost Override +200 MHz | **+3.5%** |
| Keeping CS2 off CPU 0 (Windows affinity) | **+1.8% to +2.5%** |
| RAM 8000 tuning | 1% low +4.3%, P99 −4.0% |
| DDR5 Nitro Mode 1-3-1 | **−1.4%**, so leave it on Auto |
| Total | 911 → 970 (**+6.4%**) |

## 0. Before / after a BIOS update

**Before updating:**
1. Save a profile: **Tool → ASUS User Profile → Save to Profile**, and also save it to USB. Profiles usually do not load on a different BIOS version.
2. Optionally take an NVRAM snapshot: `.\nvram\nvram_snap.ps1 -OutDir .\snap_before`.
3. If you use BitLocker, keep the recovery key ready. An fTPM reset can trigger recovery.

**After updating:** apply sections 1 → 4 in order, saving and booting (F10) after the RAM step. Then run the check (section 7).

## 1. BIOS: memory (do this first)

**Ai Tweaker:**
- Ai Overclock Tuner = Manual
- Memory Frequency = DDR5-8000
- FCLK Frequency = 2000 MHz
- High DRAM Voltage Mode = Enabled (otherwise the DRAM voltage limit is 1.435 V)
- DRAM VDD Voltage = 1.600
- DRAM VDDQ Voltage = 1.600

**Ai Tweaker → DRAM Timing Control:**

| Setting | Value | Setting | Value |
|---|---|---|---|
| Tcl | 34 | Trtp | 14 |
| Trcd Rd / Trcd Wr | 46 / 46 | TrrdL / TrrdS | 10 / 8 |
| Trp | 46 | Tfaw | 20 |
| Tras | 50 | TwtrL / TwtrS | 16 / 6 |
| Trc | 96 | TrdrdScl / Sc / Sd / Dd | 8 / 1 / 1 / 1 |
| Twr | 48 | TwrwrScl / Sc / Sd / Dd | 8 / 1 / 1 / 1 |
| Refresh Interval (tREFI) | 65535 | Twrrd | 6 |
| Trfc1 / Trfc2 / Trfcsb | 664 / 852 / 730 | Trdwr | 20 |

Other DRAM Timing Control settings:
- Memory Context Restore = Enabled
- Power Down Enable = Disabled
- Gear Down Mode = Enabled
- Bank Refresh Mode = Mixed(REFab/REFsb) Mode
- UCLK DIV1 MODE = Auto (Gear 2 at 8000 MT/s)
- DDR5 Nitro Mode = Auto
- Everything else Auto, including RTT/ODT, VDDIO and SOC.

Limits found on this kit:
- Twr cannot go below 48 at 8000 MT/s (BIOS clamps it).
- TwtrL 14 does not boot.
- Trcd and Trp 44 do not boot.

Measured voltages with the rails left on Auto:
- SOC 1.29 V
- VDDIO 1.46 V
- VDD_MISC 1.10 V
- PMIC VDD/VDDQ 1.60 V

## 2. BIOS: CPU

**Advanced → AMD Overclocking → Precision Boost Overdrive** (accept the warning):
- Precision Boost Overdrive = Advanced
- PBO Limits = Motherboard
- CPU Boost Clock Override = Enabled (Positive)
- Max CPU Boost Clock Override(+) = 200

**… → Curve Optimizer:** All Cores, Negative, 10. No measurable effect; optional.

**Ai Tweaker:** Core tunings Configuration for gaming = Level 2. Effect not confirmed; optional.

Leave the duplicate PBO, Boost Override and Curve Optimizer items under **Ai Tweaker → Precision Boost Overdrive** on **Auto**. Do not set the same thing in two places.

## 3. BIOS: keep on Auto (tested: no gain, or harmful)

- DDR5 Nitro Mode (1-3-1 measured −1.4%)
- Latency Under Load (Advanced → AMD CBS → CPU Common Options)
- Medium Load Boostit
- CPU Load-line Calibration
- SMT Control (disabling had no effect; re-enabling needs a full power cycle)
- Global C-state Control
- AI Cache Boost
- Thermal Limit (Level 2, 80 °C)
- Turbo Game Mode and Gaming Adaptive CCD Parker: Disabled (these are for dual-CCD CPUs)

## 4. BIOS: FACEIT / security (always re-check after an update)

- Boot → Secure Boot: OS Type = Windows UEFI mode. If no keys are installed: Key Management → Install Default Secure Boot Keys.
- Boot → CSM: Launch CSM = Disabled
- Advanced → AMD fTPM configuration: Firmware TPM switch = Enable Firmware TPM
- Advanced → CPU Configuration: SVM Mode = Enabled (required for VBS/HVCI)
- Advanced → AMD CBS: IOMMU = Auto
- Advanced → PCI Subsystem Settings: Above 4G Decoding = Enabled, Resize BAR Support = Enabled

## 5. Optional (personal)

**Tool → Auto Install ASUS Utilities:** DriverHub = Disabled.

**Monitor → Q-Fan Configuration** (all channels PWM mode, Manual profile, source CPU):

| | Points (temperature °C / duty %) |
|---|---|
| CPU fan and chassis fan 1 | 20/20, 30/26, 40/34, 50/45, 60/60, 67/80, 70/100, 100/100 |
| AIO pump | 30/20, 40/20, 50/36, 58/52, 65/68, 70/84, 85/100, 100/100 |

Save a profile again, then F10.

## 6. Windows

- **Hardware-accelerated GPU scheduling:** On.
- **Process priority:** Normal (High was tested: no gain).
- **Memory Integrity (HVCI):** On (required by FACEIT).
- **Keep CS2 off CPU 0** (re-apply each time Steam starts):
  1. Task Manager → Details → `steam.exe` → Set affinity → untick CPU 0.
  2. Launch CS2 from Steam; it inherits the affinity.
  - Persistent alternative, not tested here: start Steam with `cmd /c start "" /affinity FFFE "C:\Program Files (x86)\Steam\steam.exe"`.
  - No official FACEIT statement on either method was found.
- **CS2 in-game settings** (unchanged throughout):
  - Display: 1280×960 fullscreen, 360 Hz, V-Sync off, `fps_max 0`.
  - Quality: MSAA 2x, AF 16x, low shaders/textures/particles/shadows, dynamic shadows All, AO off, FSR off.
  - NVIDIA Reflex off.

## 7. Check that everything is in place

Run in an elevated PowerShell from the repo folder:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\kontrol\ayar_kontrol.ps1          # BIOS + Windows checks
.\kontrol\ayar_kontrol.ps1 -Fan     # include fan/pump curves
```

What the script does:
- It is read-only.
- It compares the live BIOS (UEFI NVRAM) with `ayarlar/hedef_ayarlar_2503.csv`, and prints the menu path for every setting that differs.
- It checks on the Windows side: SMT, RAM speed, Secure Boot, TPM, VBS/HVCI, HAGS, CPU 0 affinity of `steam.exe` / `cs2.exe`, and WHEA errors.
- The exit code is the number of differences.

**New BIOS version:** setting offsets may move. Extract the setting dictionary from the new BIOS file and check by name:

```powershell
Add-Type -Path .\tools\BiosIfr.cs, .\tools\EfiDec3b.cs
[Prog]::Main(@('C:\Downloads\BIOS.CAP', '.\new_dictionary'))
.\kontrol\ayar_kontrol.ps1 -IfrFile .\new_dictionary\ifr_all.tsv
```

AMD Overclocking (PBO/CO) items are not in the dictionary. If their variable size changed, they are reported as "DUZEN FARKLI" (layout differs); check those in the menu by hand.

**Using the checker for your own settings:** edit the `Hedef_ham` (raw target value) column of `ayarlar/hedef_ayarlar_2503.csv`. See [ayarlar/README.md](ayarlar/README.md).

## 8. Adapting to other systems

| Situation | What to do |
|---|---|
| Different RAM | Start from EXPO/XMP. Use these timings only as a starting point on SK Hynix 24 Gbit M-die, 2 × 24 GB single rank. |
| Different X3D CPU | Boost Override limits differ per CPU. Dual-CCD X3D parts may benefit from the CCD options that are irrelevant here. |
| Other ASUS AM5 boards | Menus are similar but offsets differ; use `-IfrFile` with your own BIOS. |
| Other brands | Apply the list by hand; the checker will not work. |
| Always | Change one thing at a time, measure (`bench/`), and watch for WHEA errors. |
