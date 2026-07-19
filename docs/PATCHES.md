# Source Changes (Patches) Reference

This document describes the purpose of each source modification under `patches/`.

Patches are grouped by scope:

- `patches/common/` — applied to **all four devices**. Recovery framework changes plus the Weaver retry adjustment.
- `patches/<device>/` — applied **only** when building that device. Today only `neo8` and `nezha` carry device-specific patches (the KeyMint environment fix); `myron` and `annibale` run stock vold and need none.

`scripts/apply-patches.sh <twrp-source> <codename>` always applies `common` first, then the codename's own directory.

## Common Patch Files (`patches/common/patches/`)

### `bootable_recovery/bootable_recovery.patch`

A consolidated git patch covering the following recovery framework changes:

| File | Change Description |
|------|-------------------|
| `twinstall.cpp` | Virtual A/B slot detection fix. Ensures correct active slot is detected when flashing ZIPs. |
| `action.cpp` | Auto-reflash TWRP after ROM flash. Backs up the current recovery image before flashing, then restores it to both slots afterward. |
| `twrp-functions.cpp` | Clear bootloader message before reboot to prevent bootloop. Also fixes `rb_fastboot` to use the correct `reboot,bootloader` property. |
| `gui/theme/common/languages/en.xml` | Added `reflash_twrp_after_zip` and `reflash_twrp_err` language strings. |
| `gui/theme/extra-languages/languages/zh_CN.xml` | Added Chinese translations for reflash TWRP strings. |
| `gui/theme/extra-languages/languages/zh_TW.xml` | Added Traditional Chinese translations for reflash TWRP strings. |
| `gui/theme/portrait_hdpi/ui.xml` | UI layout adjustments. |
| `partition.cpp` / `partitionmanager.cpp` | Dynamic partition / Virtual A/B alias handling. |
| `twrp-functions.cpp` / `twrp.cpp` | Recovery behavior, storage handling, USB/MTP fixes. |

### `bootable_recovery/0002-nullptr-crash-fix.patch`

| File | Change Description |
|------|-------------------|
| `twrp-functions.cpp` | Null-pointer guard in `TWFunc::Init_Recovery` when the current storage partition is not found (avoids a crash on devices where the storage lookup fails early). |

### `system_vold/system_vold.patch`

| File | Change Description |
|------|-------------------|
| `Weaver1.cpp` | Android 16 FBE / Weaver compatibility adjustment. Fixes interaction with Qualcomm Keymaster/Weaver HAL for file-based encryption decryption in recovery. |

## Per-device Patch Files

### `patches/neo8/patches/system_vold/key_storage_recovery_safety.patch`

| File | Change Description |
|------|-------------------|
| `KeyStorage.cpp` | Adds the `KM_TAG_FBE_ICE` tag required by QTI wrapped keys and recovery-side protection around key upgrade write-back. Part of the KeyMint environment fix for realme Neo8 (QCOM TMS/SPU + OPlus weaver stack). |

### `patches/nezha/patches/system_vold/key_storage_recovery_safety.patch`

Same content as the neo8 patch, for Xiaomi 17 Ultra (Thales/Goodix stack); the copy is kept separate so each device can evolve independently.

## Full File Copies

Each `patches/<set>/files/` directory contains complete modified source files intended to be copied directly over the upstream TWRP source tree. These are the same changes expressed as full file replacements rather than diffs.

### `patches/common/files/bootable/recovery/`

Contains the full modified recovery framework used for SM8850 devices, including:
- Core recovery logic (`partition.cpp`, `partitionmanager.cpp`, `twrp.cpp`, `twrp-functions.cpp`)
- GUI framework (`action.cpp`, `gui.cpp`, `theme/`)
- Build system (`Android.mk`, `Android.bp`, `libguitwrp_defaults.go`)
- Device-specific additions (e.g., `minuitwrp/graphics_drm.cpp` for Neo8)

**Note:** For Neo8, some files in this directory may differ from the Xiaomi device variants due to device-specific adjustments (e.g., DRM graphics init, OPlus touch stack integration, custom init scripts).

### `patches/common/files/system/vold/Weaver1.cpp`

Weaver HAL retry/wait adjustment, needed by all four devices regardless of secure-element stack.

### `patches/neo8/files/system/vold/` and `patches/nezha/files/system/vold/`

`Decrypt.cpp` + `KeyStorage.cpp`: before decryption, pin the KeyMint environment (OS version / OS patch level / vendor patch level) to the installed system's real values, so the recovery's spoofed platform version (`99.87.36` / `2099-12-31`) is not treated as a newer environment that would trigger a KeyMint key upgrade on every boot. On Neo8 the values can also be overridden via the `twrp.neo8.osver/ospatch/venpatch` properties.

**Do not apply these to myron/annibale.** Those two devices use NXP KeyMint, which takes its environment from vendor properties; the spoofed recovery version never reaches KeyMint, and this environment-switching logic would only invent inconsistent environments there.

## How to Apply

Use the provided script:
```bash
./scripts/apply-patches.sh /path/to/twrp-source <codename>
```

This will first attempt to apply git patches from `patches/common/patches/` (and the device set, if any), then copy any files from the corresponding `files/` directories as fallback/exact replacement.
