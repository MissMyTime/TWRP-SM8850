# Redmi K90 Pro Max (myron)

## Device information

| Parameter | Value |
|---|---|
| Product | Redmi K90 Pro Max / POCO F8 Ultra |
| Codename | `myron` |
| Product platform | `canoe` |
| Board platform | `sm8850` |
| Architecture | arm64 |
| Shipping API | 36 |
| Display | 1200 × 2608, 480 dpi |
| Recovery partition | 104857600 bytes (100 MiB), A/B |
| Super partition | 14495514624 bytes (13.5 GiB) |
| Userdata / metadata | F2FS |
| Build target | `twrp_myron-myron-eng` |

## Encryption and security services

| Component | Recovery implementation |
|---|---|
| Default KeyMint | QTI `onekeymint-service-qti` |
| StrongBox | NXP `keymint3-service.strongbox.nxp` |
| Weaver | NXP `weaver-service.nxp-qti` |
| Gatekeeper | QTI vendor service |
| FBE policy | fscrypt policy v2 with wrapped keys |

Myron uses stock vold together with the common `Weaver1.cpp` compatibility change. It does not apply the Neo8 or Nezha KeyMint environment implementations.

## Partition handling

- Virtual A/B and dynamic partitions are enabled.
- `AB_OTA_PARTITIONS` follows the 58 entries from the official OS3.0.306.4.WPMCNXM full-OTA payload.
- `/data` uses Android 16 FBE and metadata encryption with `wrappedkey_v0`.
- Recovery is stored in A/B recovery partitions and the image excludes the kernel.

## Build

```bash
cd ~/android/twrp
source build/envsetup.sh
lunch twrp_myron-myron-eng
m recoveryimage
```

Output:

```text
out/target/product/myron/recovery.img
```

The unified build script may also be used:

```bash
twrp_device_sm8850/scripts/build.sh myron
```

## Flash

```bash
adb reboot bootloader
fastboot getvar current-slot
fastboot --slot=b flash recovery recovery.img
fastboot reboot recovery
```

Use `--slot=a` when `current-slot` reports `a`.

`fastboot boot recovery.img` is not supported because the generated recovery image is ramdisk-only.

## Notes

- `TW_NO_AUTO_DECRYPT := true`: start decryption manually from TWRP when required.
- The device tree includes Wi-Fi, MTP, ADB, touch, brightness and haptics support.
- CPU frequency scaling defaults to `schedutil`; set `recovery.perf.mode=1` for `performance` and `0` to return to `schedutil`.
- Keep Myron on stock vold; do not apply the Neo8 or Nezha `Decrypt.cpp`/`KeyStorage.cpp` pair.
