# Redmi K90 (annibale)

## Device information

| Parameter | Value |
|---|---|
| Product | Redmi K90 |
| Codename | `annibale` |
| Product / board platform | `sun` |
| Architecture | arm64 |
| Shipping API | 36 |
| Display | 1200 × 2608, 480 dpi |
| Recovery partition | 104857600 bytes (100 MiB), A/B |
| Super partition | 14495514624 bytes (13.5 GiB) |
| Userdata / metadata | F2FS |
| Build target | `twrp_annibale-bp2a-eng` |

## Encryption and security services

| Component | Recovery implementation |
|---|---|
| Default KeyMint | QTI vendor KeyMint |
| StrongBox | NXP `keymint-service.strongbox-nxp` |
| Weaver | NXP `weaver-service.nxp` |
| Gatekeeper | QTI vendor service |
| FBE policy | fscrypt policy v2 with wrapped keys |

Annibale uses stock vold together with the common `Weaver1.cpp` compatibility change. It does not use the Nezha Goodix secure-element chain or the Neo8 TMS/OPlus chain.

## Device-specific components

- Wi-Fi uses the `kiwi_v2` configuration and matching recovery modules.
- The Goodix entries in this device tree belong to the touchscreen stack (`goodix_core.ko` and touch algorithms), not to the Goodix eSE/Weaver service used by Nezha.
- `/data` uses Android 16 FBE and metadata encryption with `wrappedkey_v0`.
- Virtual A/B and dynamic partitions are enabled.

## Build

```bash
cd ~/android/twrp
source build/envsetup.sh
lunch twrp_annibale-bp2a-eng
mka recoveryimage
```

Output:

```text
out/target/product/annibale/recovery.img
```

The unified build script may also be used:

```bash
twrp_device_sm8850/scripts/build.sh annibale
```

## Flash

```bash
adb reboot bootloader
fastboot flash recovery_ab recovery.img
fastboot reboot recovery
```

`fastboot boot recovery.img` is not supported because the generated recovery image is ramdisk-only.

## Notes

- `TW_NO_AUTO_DECRYPT := true`: start decryption manually from TWRP when required.
- Keep Annibale on stock vold; do not apply the Neo8 or Nezha `Decrypt.cpp`/`KeyStorage.cpp` pair.
