#!/bin/bash
# scripts/apply-patches.sh
# Apply TWRP source changes for SM8850 devices.
# Applies patches/common first, then only the target device's own set.
# Usage: ./scripts/apply-patches.sh [TWRP_SOURCE_ROOT] [DEVICE_CODENAME]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."
TWRP_SOURCE="${1:-$(pwd)}"
DEVICE="${2:-}"

echo "========================================"
echo "TWRP SM8850 Source Patch Apply Script"
echo "========================================"
echo "TWRP source root: $TWRP_SOURCE"
echo "Device codename:  ${DEVICE:-<none, common only>}"
echo ""

# Device codename -> per-device patch directory
device_patch_dir() {
    case "$1" in
        myron)            echo "myron" ;;
        annibale)         echo "annibale" ;;
        nezha)            echo "nezha" ;;
        RE6402L1|neo8)    echo "neo8" ;;
        *)                echo "" ;;
    esac
}

# Option 1: Apply git patches (recommended for upstream tracking)
apply_patch_files() {
    local set_root="$1"
    for patch_file in "$set_root"/patches/*/*.patch; do
        [ -f "$patch_file" ] || continue
        dir=$(basename "$(dirname "$patch_file")")
        # Convert underscore notation to path
        target="${dir/_//}"
        echo "  -> Applying: $(basename "$patch_file") to $target"
        if [ -d "$TWRP_SOURCE/$target" ]; then
            (cd "$TWRP_SOURCE/$target" && git apply "$patch_file") || {
                echo "     WARNING: patch may have already been applied or source differs."
            }
        else
            echo "     WARNING: target directory $TWRP_SOURCE/$target not found, skipping."
        fi
    done
}

# Option 2: Copy modified files directly (fallback / exact replacement)
apply_files() {
    local set_root="$1"
    if [ -d "$set_root/files" ]; then
        ( cd "$set_root/files" && find . -type f ) | while read -r file; do
            src="$set_root/files/$file"
            dst="$TWRP_SOURCE/$file"
            mkdir -p "$(dirname "$dst")"
            echo "  -> Copying: $file"
            cp -f "$src" "$dst"
        done
    fi
}

apply_set() {
    echo "[set] $2"
    apply_patch_files "$1"
    apply_files "$1"
    echo ""
}

# 1. Common patches: applied for every device.
apply_set "$REPO_ROOT/patches/common" "common (all devices)"

# 2. Per-device patches: only for the requested device.
DEVICE_SET="$(device_patch_dir "$DEVICE")"
if [ -n "$DEVICE_SET" ] && { [ -d "$REPO_ROOT/patches/$DEVICE_SET/files" ] || [ -d "$REPO_ROOT/patches/$DEVICE_SET/patches" ]; }; then
    apply_set "$REPO_ROOT/patches/$DEVICE_SET" "device-specific: $DEVICE_SET"
else
    echo "No device-specific patches for '${DEVICE:-unknown}'."
    echo "(myron/annibale intentionally have none; see patches/<device>/README.md)"
    echo ""
fi

echo "========================================"
echo "Done. Source changes applied."
echo "========================================"
