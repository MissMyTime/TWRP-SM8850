# SM8850 TWRP Device Trees & Source Changes
> TWRP device trees and TWRP source patches for Qualcomm SM8850 (Snapdragon 8 Elite Gen 5 / canoe) devices

[中文说明](./README.md)

TWRP adaptation for devices on the Qualcomm SM8850 (canoe) platform, targeting **Android 16 / API 36 / BP2A** with **Virtual A/B** partitions. Devices already adapted are listed below; other SM8850 devices can be requested via Issues.

## Supported Devices
| Vendor | Device | Codename | Status |
|--------|--------|----------|--------|
| Xiaomi | Redmi K90 | annibale | Supported |
| Xiaomi | Redmi K90 Pro Max | myron | Supported |
| Xiaomi | Xiaomi 17 Ultra | nezha | Supported |
| realme | realme Neo8 | RE6402L1 | Supported |

## Discussion
- XDA: [TWRP for POCO F8 Ultra / Redmi K90 Pro Max (myron)](https://xdaforums.com/t/twrp-3-7-1-for-poco-f8-ultra-redmi-k90-pro-max-myron-android-16-fbe-decrypt.4795272/)
- XDA: [TWRP for Xiaomi 17 Ultra (nezha)](https://xdaforums.com/t/twrp-3-7-1-for-xiaomi-17-ultra-nezha-android-16-fbe-decrypt.4795275/)
- XDA: [TWRP for realme Neo8 (RE6402L1)](https://xdaforums.com/t/twrp-3-7-1-for-realme-neo8-re6402l1-android-16-fbe-decrypt.4795276/)
- 4PDA: [Realme Neo 8 discussion thread](https://4pda.to/forum/index.php?showtopic=1109949)

## Repository Layout
```
twrp_device_sm8850/
├── README.md                          # Chinese documentation
├── README_EN.md                       # This file
├── docs/                              # Per-device documentation
│   ├── BUILD.md                       # Build guide (WSL2, dependencies)
│   ├── PATCHES.md                     # Detailed patch descriptions
│   ├── xiaomi-annibale.md
│   ├── xiaomi-myron.md
│   ├── xiaomi-nezha.md
│   └── realme-neo8.md
├── device/                            # Device trees
│   ├── qcom/
│   │   └── sm8850-common/             # (planned) SM8850 common board config
│   ├── xiaomi/
│   │   ├── annibale/                  # Redmi K90
│   │   ├── myron/                     # Redmi K90 Pro Max
│   │   └── nezha/                     # Xiaomi 17 Ultra
│   └── realme/
│       └── RE6402L1/                  # realme Neo8
├── patches/                           # TWRP source patches (grouped by scope)
│   ├── common/                        # All devices: framework hooks + Weaver retry
│   │   ├── files/                     # Full patched source files
│   │   └── patches/                   # Git-format patches for upstream tracking
│   ├── myron/                         # Redmi K90 Pro Max only (no vold patch, see README inside)
│   ├── annibale/                      # Redmi K90 only (no vold patch, see README inside)
│   ├── nezha/                         # Xiaomi 17 Ultra only: KeyMint environment patch
│   └── neo8/                          # realme Neo8 only: recovery overrides + KeyMint patch
└── scripts/
    ├── apply-patches.sh               # One-click patch apply (common + one device)
    └── build.sh                       # Unified build entry
```

Patches are grouped by scope because the devices use different security and recovery startup stacks. myron/annibale keep stock vold; nezha's Thales/Goodix decryption chain and Neo8's TMS/SPU, OPlus Weaver, DRM and init overrides live in separate device sets. Common recovery code exposes only generic hooks, and each build applies `common` plus one target device directory.

## Quick Start
### 1. Clone this repo next to your TWRP source tree
```bash
cd ~/android/twrp
git clone https://github.com/MissMyTime/twrp_device_sm8850.git
```
### 2. Apply the source patches
The second argument is the device codename (myron / annibale / nezha / RE6402L1). The script applies `patches/common` first, then that device's own patch directory:
```bash
cd ~/android/twrp
twrp_device_sm8850/scripts/apply-patches.sh . myron
```
### 3. Build recovery for a device
```bash
cd ~/android/twrp
source build/envsetup.sh
lunch twrp_RE6402L1-eng
mka recoveryimage
```
Or use the one-click build script:
```bash
cd ~/android/twrp
twrp_device_sm8850/scripts/build.sh RE6402L1 realme
```

## Build Requirements
- Recommended environment: WSL2 + Ubuntu 24.04
- RAM: 64 GB+ recommended (or equivalent swap)
- Disk: 200 GB+ free space
- Full setup guide: [docs/BUILD.md](docs/BUILD.md)

## Source Changes Summary
See [docs/PATCHES.md](docs/PATCHES.md) for details.
### bootable/recovery (patches/common)
- **Slot detection fix** (`twinstall.cpp`): correct Virtual A/B slot detection to avoid flashing the wrong slot
- **Auto re-flash TWRP** (`action.cpp`): back up recovery before a ROM flash and restore it to both slots afterwards, so stock ROMs don't overwrite TWRP
- **Clear bootloader messages** (`twrp-functions.cpp`): clear stale bootloader error messages before reboot to avoid boot hangs
- **Fastboot reboot fix** (`twrp-functions.cpp`): fix `rb_fastboot` using the wrong property
- **UI adaptation**: Chinese strings, layout tweaks, status bar position for centered hole-punch displays
- **Partition handling**: Virtual A/B partition aliases, dynamic partition flashing fixes
- **Wi-Fi support** (myron/Neo8): in-recovery Wi-Fi framework, supplicant and DHCP client
- **Device hook isolation**: pre-decrypt waiting, retry and reboot cleanup use generic script names and run only when the target device tree provides them
### system/vold
- **FBE/Weaver compatibility** (`Weaver1.cpp`, patches/common): Android 16 file-based encryption with Weaver/Keymaster decryption
- **KeyMint environment patch** (`Decrypt.cpp`, `KeyStorage.cpp`; maintained separately under patches/neo8 and patches/nezha): pins the KeyMint environment (OS version / patch levels) to the installed system's real values before decryption, so the recovery's spoofed platform version is not treated as a newer environment that triggers key upgrades; includes `KM_TAG_FBE_ICE` for QTI wrapped keys and recovery-side upgrade write-back protection
- **No vold patch for myron/annibale**: both NXP KeyMint devices take their environment from vendor properties, so the recovery's spoofed version never reaches KeyMint; stock vold + Weaver1.cpp is the verified stable combination

## Device-specific Notes
Each device has its own document under `docs/` covering:
- Partition table and sizes
- FBE / Keymaster / Weaver support status
- Known issues and workarounds
- Notes on prebuilt binaries (keymint, weaver, touchscreen, etc.)

## Contributing
PRs for new device adaptations are welcome:
1. Add a complete device tree under `device/<vendor>/<codename>/`
2. Add the corresponding device document under `docs/`
3. For new source changes: common changes go to `patches/common/`, device-specific changes go to `patches/<device>/` with the reason documented in that directory's README
4. Update the supported device list in the README

## Thanks
- The TeamWin Recovery Project team for the open-source TWRP base
- The AOSP project for the Android open-source base
- Qualcomm for open-sourcing QCOM kernel and device tree resources

## License
Device trees and source files follow their original open-source licenses. Original content in this repository is licensed under [Apache-2.0](./LICENSE).
