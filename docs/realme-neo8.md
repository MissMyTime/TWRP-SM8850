# realme Neo8 (RE6402L1 / RMX8899)

## Device Information

| Parameter | Value |
|-------------|-------|
| Device | realme Neo8 |
| Product | RE6402L1 |
| Model | RMX8899 |
| Platform | Qualcomm SM8850 (canoe) |
| Architecture | arm64 |
| Android Version | 16 (BP2A) |
| Shipping API | 36 |
| Recovery Header | v4 |
| Screen | 1080x2354, 474dpi, 120Hz |
| Brightness | 0-4095 (default: 1600) |
| Recovery Partition Size | 104857600 bytes (100 MB) |
| Super Partition Size | 18790481920 bytes (17.5 GB) |
| File System (logical) | EROFS |
| File System (userdata) | F2FS |
| Virtual A/B | Yes (gz compression) |

## Key Features

- **File-based encryption (FBE)** and metadata encryption support
- **OPlus touch service** and touch firmware support
- **WLAN service** with WPA2/WPA3 connection and status display
- **Dynamic recovery partition aliases** for image flashing
- **Fastboot / Fastbootd** handling
- **Center punch-hole** and status bar layout adjustments
- **Optional F2FS virtual SD card** partition (`rannki` -> `/SDKa`)

## Partition Table

| Partition | Size | Type | Notes |
|-----------|------|------|-------|
| boot | 100663296 | Image | A/B slot |
| init_boot | 8388608 | Image | A/B slot |
| vendor_boot | 100663296 | Image | A/B slot |
| dtbo | 25165824 | Image | A/B slot |
| vbmeta | 65536 | Image | A/B slot |
| vbmeta_system | 65536 | Image | A/B slot |
| vbmeta_vendor | 65536 | Image | A/B slot |
| recovery | 104857600 | Image | A/B slot |
| system | Logical | EROFS | A/B slot, dynamic |
| system_ext | Logical | EROFS | A/B slot, dynamic |
| system_dlkm | Logical | EROFS | A/B slot, dynamic |
| product | Logical | EROFS | A/B slot, dynamic |
| vendor | Logical | EROFS | A/B slot, dynamic |
| vendor_dlkm | Logical | EROFS | A/B slot, dynamic |
| odm | Logical | EROFS | A/B slot, dynamic |
| metadata | - | F2FS | Encryption key storage |
| userdata | - | F2FS | Data + FBE |
| misc | - | EMMC | Boot control |
| persist | - | EXT4 | Persist partition |

## FBE / Decryption

| Parameter | Value |
|-----------|-------|
| FBE Policy | `fscrypt_policy_v2` |
| Keymaster | Vendor Keymint (QTI) |
| OMAPI | Enabled (`636F6D2E6E78702E7365637572697479`) |
| StrongBox / Weaver | TMS secure-element services (`vendor.weaver_tms`) with SPU support components |
| SELinux | Permissive in recovery |

## Prebuilt Components

### `prebuilt/kernel/`

Prebuilt kernel image (Image, boot header v4).

### `prebuilt/odm/firmware/secure_ta/`

TrustZone / Secure TA firmware blobs for keymint, weaver, crypto, FIDO, etc.

### `prebuilt/sbin/`

- `neo8_wifi_hal_client`: Wi-Fi HAL client for recovery
- `wifi-dhcp.sh`: DHCP script for Wi-Fi
- `wifi-load-modules.sh`: Kernel module loader for Wi-Fi
- `vendor/etc/vintf/`: Wi-Fi supplicant manifest

### `prebuilt/system/`

- Boot service (recovery variant)
- Health service (recovery variant)
- SELinux policy contexts
- VINTF manifests

### `prebuilt/vendor/`

- Boot service
- Gatekeeper (Rust + legacy)
- Health service
- Keymint (onekeymint)
- Secretkeeper
- `init` scripts, `ueventd.rc`
- Firmware, firmware_mnt, vintf, Wi-Fi config
- `lib` / `lib64` libraries
- `odm` overlay

### `prebuilt/system_ext/`

System extension prebuilts for recovery.

## Recovery Init Scripts

| Script | Purpose |
|--------|---------|
| `init.recovery.qcom.rc` | Qualcomm platform init, service start, property setup |
| `init.recovery.usb.rc` | USB configuration, MTP, ADB, fastbootd |
| `ueventd.qcom.rc` | Device node permissions |
| `system/bin/neo8-early-mount.sh` | Early mount helper |
| `system/bin/neo8-partition-links.sh` | Partition alias links |
| `system/bin/neo8-touch-props.sh` | Touch properties setup |

## Touch Stack

OPlus touch service integration:

- `vendor.oplus.hardware.touch` AIDL HAL
- TensorFlow Lite touch model
- Touch firmware config (`synaptics` / `fts` depending on variant)

## Wi-Fi

- Full supplicant support with WPA2/WPA3
- DHCP client with fallback
- Status display in TWRP UI
- Module loading via `wifi-load-modules.sh`

## Sepolicy

- `file_contexts`: Recovery file context labels
- `recovery.te`: Recovery-specific SELinux rules

## Build

```bash
source build/envsetup.sh
lunch twrp_RE6402L1-bp2a-eng
mka recoveryimage
```

Output: `out/target/product/RE6402L1/recovery.img`

## Flash

```bash
fastboot flash recovery_ab recovery.img
```

> **Note:** `fastboot boot recovery.img` (temporary boot) is **not supported** on this
> device. The recovery image is ramdisk-only (kernel is in `vendor_boot`); most
> SM8850 bootloaders will reject booting it directly. Flash the A/B recovery
> partition with `recovery_ab`; temporary boot is not supported.

## Known Issues / Notes

- `TW_NO_AUTO_DECRYPT := true` — decryption must be triggered manually.
- `TW_SKIP_POST_GUI_FSTAB_SETUP := true` — fstab is set up before GUI.
- `TW_FORCE_STOCK_THEME_ON_BOOT := true` — forces stock theme at boot to avoid UI corruption.
- `TW_SKIP_ADDITIONAL_FSTAB := true` — skips additional fstab overlay.
- `TW_HAS_EDL_MODE := false` — no EDL mode entry in TWRP.

## Device Tree Path

```
device/realme/RE6402L1/
├── AndroidProducts.mk
├── BoardConfig.mk
├── device.mk
├── recovery.fstab
├── recovery/
│   └── root/
│       ├── init.recovery.qcom.rc
│       ├── init.recovery.usb.rc
│       ├── ueventd.qcom.rc
│       └── system/bin/
│           ├── neo8-early-mount.sh
│           ├── neo8-partition-links.sh
│           └── neo8-touch-props.sh
├── prebuilt/
│   ├── kernel
│   ├── odm/firmware/secure_ta/
│   ├── sbin/
│   ├── system/
│   ├── system_ext/
│   └── vendor/
├── sepolicy/
├── system.prop
├── twrp_RE6402L1.mk
└── vendorsetup.sh
```
