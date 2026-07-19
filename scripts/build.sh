#!/bin/bash
# scripts/build.sh
# Unified build script for SM8850 devices
# Usage: ./scripts/build.sh <codename> [vendor]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."
CODENAME="${1:-}"
VENDOR="${2:-}"

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
echo "========================================"
echo "Building TWRP for: $CODENAME"
echo "Vendor: $VENDOR"
echo "Device path: $DEVICE_PATH"
echo "========================================"
echo ""

# Apply source changes
"$SCRIPT_DIR/apply-patches.sh" "$REPO_ROOT" "$CODENAME"

# Build
cd "$REPO_ROOT"
source build/envsetup.sh
lunch "twrp_${CODENAME}-eng"
mka recoveryimage

echo ""
echo "========================================"
echo "Build complete."
echo "Output: out/target/product/$CODENAME/recovery.img"
echo "========================================"
