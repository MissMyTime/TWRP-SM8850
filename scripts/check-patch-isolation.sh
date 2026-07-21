#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."

fail() {
    echo "ERROR: $1" >&2
    exit 1
}

assert_no_match() {
    local pattern="$1"
    shift
    if grep -RIniE -- "$pattern" "$@"; then
        fail "unexpected device-specific content found"
    fi
}

assert_no_match_outside_stock_matrix() {
    local pattern="$1"
    shift
    if grep -RIniE --exclude='compatibility_matrix.device.xml' -- "$pattern" "$@"; then
        fail "unexpected device-specific content found"
    fi
}

assert_no_match \
    'neo8|nezha|RE6402L1|RMX8899|Goodix|OPlus|realme|ColorOS|ST54|SELog|Thales|vendor\.weaver_tms' \
    "$REPO_ROOT/patches/common/files" "$REPO_ROOT/patches/common/patches"

assert_no_match \
    'neo8|RE6402L1|RMX8899|OPlus|realme|ColorOS|vendor\.weaver_tms' \
    "$REPO_ROOT/patches/nezha/files" "$REPO_ROOT/patches/nezha/patches"

assert_no_match \
    'nezha|Goodix|ST54|SELog|Thales' \
    "$REPO_ROOT/patches/neo8/files" "$REPO_ROOT/patches/neo8/patches"

assert_no_match_outside_stock_matrix \
    'annibale|neo8|nezha|RE6402L1|RMX8899|Goodix|OPlus|realme|ColorOS|vendor\.weaver_tms' \
    "$REPO_ROOT/device/xiaomi/myron"

assert_no_match_outside_stock_matrix \
    'myron|neo8|nezha|RE6402L1|RMX8899|Goodix|OPlus|realme|ColorOS|vendor\.weaver_tms' \
    "$REPO_ROOT/device/xiaomi/annibale"

for file in \
    etc/init.rc \
    etc/init.recovery.logd.rc \
    gui/Android.bp \
    minuitwrp/graphics_drm.cpp; do
    [ ! -e "$REPO_ROOT/patches/common/files/bootable/recovery/$file" ] || \
        fail "$file must not be stored in the common set"
    [ -f "$REPO_ROOT/patches/neo8/files/bootable/recovery/$file" ] || \
        fail "$file is missing from the Neo8 set"
done

[ -f "$REPO_ROOT/patches/common/files/bootable/recovery/partitions.hpp" ] || \
    fail "common partitions.hpp is required by the shared partition interfaces"

for hook in twrp-pre-decrypt.sh twrp-decrypt-retry.sh twrp-reboot-cleanup.sh; do
    [ -f "$REPO_ROOT/device/xiaomi/nezha/recovery/root/system/bin/$hook" ] || \
        fail "missing nezha hook: $hook"
done

grep -q 'setRecoveryKeyMintEnvironment' \
    "$REPO_ROOT/patches/common/files/bootable/recovery/partitionmanager.cpp" || \
    fail "common KeyMint extension point is missing"
for set_name in neo8 nezha; do
    grep -q 'bool setRecoveryKeyMintEnvironment(bool stock_environment)' \
        "$REPO_ROOT/patches/$set_name/files/system/vold/Decrypt.cpp" || \
        fail "$set_name KeyMint implementation is missing"
done

for set_name in myron annibale; do
    [ ! -e "$REPO_ROOT/patches/$set_name/files/system/vold/Decrypt.cpp" ] || \
        fail "$set_name must use stock Decrypt.cpp"
done

for device in myron annibale; do
    prop="$REPO_ROOT/device/xiaomi/$device/system.prop"
    if grep -nE '^(twrp\.recovery\.|twrp\.keymint\.)' "$prop"; then
        fail "$device must not opt into another device's recovery behavior"
    fi
done

while IFS= read -r patch; do
    git apply --numstat "$patch" >/dev/null
done < <(find "$REPO_ROOT/patches" -type f -name '*.patch' -print)

if grep -RniE '^[[:space:]]*fastboot[[:space:]]+(flash[[:space:]]+recovery[[:space:]]|boot[[:space:]]+recovery\.img)' \
        "$REPO_ROOT" --include='*.md' --include='*.sh' \
        --exclude-dir=.git; then
    fail "non-A/B recovery flashing instructions found"
fi

bash -n "$REPO_ROOT/scripts/apply-patches.sh"
bash -n "$REPO_ROOT/scripts/build.sh"
find "$REPO_ROOT/device" "$REPO_ROOT/scripts" -type f -name '*.sh' -print0 | \
    xargs -0 -r -n1 bash -n

echo "Patch isolation checks passed."
