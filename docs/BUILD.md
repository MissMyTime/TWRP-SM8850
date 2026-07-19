# Build Guide

## Environment

**Recommended:** WSL2 + Ubuntu 24.04

## Prerequisites

```bash
sudo apt update
sudo apt install -y git-core gnupg flex bison build-essential zip curl \
    zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
    libncurses5-dev lib32ncurses5-dev x11proto-core-dev libx11-dev \
    lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig \
    repo bc ccache
```

## Initialize TWRP Source

```bash
mkdir -p ~/android/twrp && cd ~/android/twrp
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-16
repo sync -c --no-tags --no-clone-bundle -j$(nproc)
```

## Clone This Repository

```bash
cd ~/android/twrp
git clone https://github.com/MissMyTime/twrp_device_sm8850.git
```

## Apply Source Changes

```bash
cd ~/android/twrp
twrp_device_sm8850/scripts/apply-patches.sh . <codename>
```

The second argument is the device codename (`myron` / `annibale` / `nezha` / `RE6402L1`). The script will:

1. Apply git patches from `patches/common/patches/`, then copy the full source files from `patches/common/files/`
2. Do the same for `patches/<device>/` if that directory contains device-specific patches

Only `nezha` and `neo8` carry device-specific vold patches today; `myron` and `annibale` intentionally use stock vold plus the common Weaver1.cpp (see each directory's README).

## Build

```bash
source build/envsetup.sh
lunch twrp_<codename>-eng
mka recoveryimage
```

Example for realme Neo8:
```bash
lunch twrp_RE6402L1-eng
mka recoveryimage
```

Output path:
```
out/target/product/<codename>/recovery.img
```

## Flash

```bash
fastboot flash recovery recovery.img
```

> **Note for Android 16 / boot header v4 devices:**
> This device uses `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`, meaning the
> generated `recovery.img` is a **ramdisk-only image** (kernel resides in `vendor_boot`).
> Therefore `fastboot boot recovery.img` (temporary boot) is **not supported** on most
> Qualcomm SM8850 bootloaders. Always flash the recovery partition instead.

```bash
fastboot flash recovery recovery.img
```

Or temporarily boot:
```bash
fastboot boot recovery.img
```

## Troubleshooting

### WSL2 Out of Memory

Create `~/.wslconfig`:
```ini
[wsl2]
memory=64GB
swap=32GB
processors=16
```

### Symlinks on Windows

If you cloned this repo on Windows and then copied to WSL2, symbolic links in `device/<vendor>/<codename>/recovery/root/odm/` may be broken. On WSL2, re-clone or use:
```bash
git config core.symlinks true
git checkout .
```
