#!/bin/bash
# scripts/build.sh
# Unified build script for SM8850 devices
# Usage: ./scripts/build.sh <codename> [vendor]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."
CODENAME="${1:-}"
VENDOR="${2:-}"
TWRP_SOURCE="${TWRP_SOURCE:-$(pwd)}"
LUNCH_TARGET="${LUNCH_TARGET:-twrp_${CODENAME}-bp2a-eng}"

if [ -z "$CODENAME" ]; then
    echo "Usage: ./scripts/build.sh <codename> [vendor]"
    echo ""
    echo "Supported devices:"
    ls -1 "$REPO_ROOT/device"/*/* 2>/dev/null | while read -r line; do
        if [ -d "$line" ]; then
            v=$(basename "$(dirname "$line")")
            c=$(basename "$line")
            echo "  $c (vendor: $v)"
        fi
    done
    echo ""
    echo "Example: ./scripts/build.sh RE6402L1 realme"
    exit 1
fi

# Auto-detect vendor if not provided
if [ -z "$VENDOR" ]; then
    for vdir in "$REPO_ROOT"/device/*/; do
        v=$(basename "$vdir")
        if [ -d "$REPO_ROOT/device/$v/$CODENAME" ]; then
            VENDOR="$v"
            break
        fi
    done
fi

if [ -z "$VENDOR" ] || [ ! -d "$REPO_ROOT/device/$VENDOR/$CODENAME" ]; then
    echo "Error: Device '$CODENAME' not found."
    exit 1
fi

DEVICE_PATH="$REPO_ROOT/device/$VENDOR/$CODENAME"
if [ ! -f "$TWRP_SOURCE/build/envsetup.sh" ]; then
    echo "Error: '$TWRP_SOURCE' is not a TWRP source root."
    echo "Run this script from the TWRP source root or set TWRP_SOURCE."
    exit 1
fi

TWRP_SOURCE="$(cd "$TWRP_SOURCE" && pwd)"
DEVICE_PATH="$(cd "$DEVICE_PATH" && pwd)"
TARGET_DEVICE_PATH="$TWRP_SOURCE/device/$VENDOR/$CODENAME"

echo "========================================"
echo "Building TWRP for: $CODENAME"
echo "Vendor: $VENDOR"
echo "Device path: $DEVICE_PATH"
echo "TWRP source: $TWRP_SOURCE"
echo "Lunch target: $LUNCH_TARGET"
echo "========================================"
echo ""

# Install the selected tree at the path expected by Android's product loader.
if [ "$DEVICE_PATH" != "$TARGET_DEVICE_PATH" ]; then
    echo "Syncing device tree to: $TARGET_DEVICE_PATH"
    mkdir -p "$TARGET_DEVICE_PATH"
    if command -v rsync >/dev/null 2>&1; then
        rsync -a "$DEVICE_PATH/" "$TARGET_DEVICE_PATH/"
    else
        cp -a "$DEVICE_PATH/." "$TARGET_DEVICE_PATH/"
    fi
    echo ""
fi

# Apply source changes
"$SCRIPT_DIR/apply-patches.sh" "$TWRP_SOURCE" "$CODENAME"

# Build
cd "$TWRP_SOURCE"
source build/envsetup.sh
lunch "$LUNCH_TARGET"
mka recoveryimage

echo ""
echo "========================================"
echo "Build complete."
echo "Output: out/target/product/$CODENAME/recovery.img"
echo "========================================"
