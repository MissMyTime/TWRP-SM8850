# Build Guide

## Environment

- WSL2 or native Ubuntu 24.04
- 64 GB RAM recommended, or sufficient swap
- At least 200 GB of free disk space

## Install dependencies

```bash
sudo apt update
sudo apt install -y git-core gnupg flex bison build-essential zip curl \
    zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
    libncurses-dev lib32ncurses-dev x11proto-core-dev libx11-dev \
    lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig \
    python3 python3-pip repo bc ccache rsync libssl-dev \
    liblz4-tool lz4 zstd
```

## Initialize the TWRP source tree

```bash
mkdir -p ~/android/twrp
cd ~/android/twrp
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-16
repo sync -c --no-tags --no-clone-bundle -j$(nproc)
```

## Fetch additional recovery tools

The Myron recovery image includes the same nano, ncurses, logical-partition and OMAPI components as the verified image. If they are not present in the manifest checkout, clone them before applying this repository's source patches:

```bash
cd ~/android/twrp
git clone -b lineage-22.2 https://github.com/LineageOS/android_external_nano.git external/nano
git clone -b lineage-22.2 https://github.com/LineageOS/android_external_libncurses.git external/libncurses
git clone -b master https://github.com/phhusson/vendor_lptools.git external/lptools
git clone -b twrp-16.0 https://github.com/Just-TWRP/android_se_omapi.git external/se_omapi
git clone -b twrp-16.0 https://github.com/adontoo/android_external_libmicrohttpd.git external/libmicrohttpd
```

## Clone this repository

Clone it inside the TWRP source root so the device paths resolve as expected:

```bash
cd ~/android/twrp
git clone https://github.com/MissMyTime/twrp_device_sm8850.git
```

## Registered build targets

| Device | Codename | Lunch target |
|---|---|---|
| Redmi K90 | `annibale` | `twrp_annibale-bp2a-eng` |
| Redmi K90 Pro Max | `myron` | `twrp_myron-myron-eng` |
| Xiaomi 17 Ultra | `nezha` | `twrp_nezha-bp2a-eng` |
| realme Neo8 | `RE6402L1` | `twrp_RE6402L1-bp2a-eng` |

## Apply source changes

For a manual build, first copy the selected device tree to the path expected by the Android build system. Example for Myron:

```bash
cd ~/android/twrp
mkdir -p device/xiaomi/myron
rsync -a twrp_device_sm8850/device/xiaomi/myron/ device/xiaomi/myron/
```

Then apply the source changes:

```bash
cd ~/android/twrp
twrp_device_sm8850/scripts/apply-patches.sh . <codename>
```

The codename may be `myron`, `annibale`, `nezha`, `RE6402L1` or `neo8`. The script applies the common set first, then only the selected device set:

1. Apply Git-format patches when the target source repository matches.
2. Copy the maintained full source files to produce the exact expected tree.

Myron and Annibale intentionally use stock vold plus the common `Weaver1.cpp`. Nezha and Neo8 each carry a separate device-specific vold implementation.

## Build manually

Example for realme Neo8:

```bash
cd ~/android/twrp
source build/envsetup.sh
lunch twrp_RE6402L1-bp2a-eng
m recoveryimage
```

Output:

```text
out/target/product/RE6402L1/recovery.img
```

Replace the lunch target and product directory with the values from the table for another device.

## Use the unified build script

The script synchronizes the selected device tree, applies the correct patch sets and builds the registered product target:

```bash
cd ~/android/twrp
twrp_device_sm8850/scripts/build.sh RE6402L1
```

The vendor directory is detected automatically. A different registered lunch target can be selected explicitly:

```bash
LUNCH_TARGET=twrp_myron-myron-eng twrp_device_sm8850/scripts/build.sh myron
```

## Flash

Confirm the codename, unlock the bootloader and back up important data first.

```bash
adb reboot bootloader
fastboot getvar current-slot
fastboot --slot=b flash recovery recovery.img
fastboot reboot recovery
```

The example assumes slot `b`; use `--slot=a` when `current-slot` reports `a`. All four device trees use A/B recovery partitions. They also set `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`, so the generated image is ramdisk-only and the kernel remains in `vendor_boot`. Most affected bootloaders cannot temporarily boot this image with `fastboot boot recovery.img`.

## Troubleshooting

### WSL2 runs out of memory

Create or update `%UserProfile%\.wslconfig` on Windows:

```ini
[wsl2]
memory=64GB
swap=32GB
processors=16
```

Run `wsl --shutdown` from PowerShell before starting the build again.

### A patch no longer matches

Use the TWRP 16 branch specified above and start from a clean source checkout. The apply script stops when a Git patch does not match instead of silently applying a partial change.

### Wrong lunch target

Use the exact BP2A target from the table. In particular, Neo8 registers `twrp_RE6402L1-bp2a-eng`, not `twrp_RE6402L1-eng`.
