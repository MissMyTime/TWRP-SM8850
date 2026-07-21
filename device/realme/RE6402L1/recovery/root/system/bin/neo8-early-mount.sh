#!/system/bin/sh
#
# Neo8 early-mount helper for recovery boot.
#
# This script runs at `early-init` (before first-stage init has handed
# off to second-stage init). On realme Neo8 (RE6402L1), the super
# partition logical-partition devices (/dev/block/dm-0, dm-4, dm-3, …)
# are created by the kernel uevent path almost immediately after
# first-stage init has loaded the `ufshc` driver. Once they appear,
# we mount /system, /system_ext and /product read-only so that:
#
#   * hwservicemanager / servicemanager / logd / keystore2 / vold can
#     exec and start during the first pass through init.rc actions.
#   * /odm and /vendor binaries (also needed by the HAL services) are
#     mounted alongside.
#
# Without this helper, the logical partitions remain unmounted until
# TWRP's partitionmanager starts ~5-6 seconds after init's second
# stage.  By then the Android core services have already been tried
# and entered an uninterruptible restarting state that only a reboot
# clears.

# Wait up to 4 s for system uevent (poll every 100 ms).
wait_dm() {
    local dev="$1"
    local tries
    for tries in $(seq 1 40); do
        if [ -e "$dev" ]; then
            return 0
        fi
        usleep 100000
    done
    return 1
}

# Mount a device at a mount point, trying all supported fs types.
# Keeps the LAST_ERROR reported by the mount syscall.
try_mount() {
    local dev="$1" mp="$2" opts="$3"
    local rc=1
    for fs in erofs ext4 f2fs; do
        if mount -t "$fs" -o "$opts" "$dev" "$mp" 2>/dev/null; then
            echo "[neo8-mount] ${dev} -> ${mp} (type=${fs}) OK"
            return 0
        else
            rc=$?
        fi
    done
    echo "[neo8-mount] WARN mount ${dev} -> ${mp} FAILED rc=${rc}"
    return ${rc}
}

# Make sure /system exists as a mountpoint.
mkdir -p /system /system_ext /product /vendor /odm

# 1. system  (logical partition dm-0)
if wait_dm /dev/block/dm-0; then
    try_mount /dev/block/dm-0 /system ro,noatime
else
    echo "[neo8-mount] WARN /dev/block/dm-0 uk未能 uevent"
fi

# 2. system_ext  (logical partition dm-4)
if wait_dm /dev/block/dm-4; then
    try_mount /dev/block/dm-4 /system_ext ro,noatime
else
    echo "[neo8-mount] WARN /dev/block/dm-4 uk未能 uevent"
fi

# 3. product  (logical partition dm-3)
if wait_dm /dev/block/dm-3; then
    try_mount /dev/block/dm-3 /product ro,noatime
else
    echo "[neo8-mount] WARN /dev/block/dm-3 uk未能 uevent"
fi

# 4. vendor  (logical partition dm-2)  — the fstab parser also does
#    this; doing it again is harmless.
if wait_dm /dev/block/dm-2; then
    try_mount /dev/block/dm-2 /vendor ro,noatime
fi

# 5. odm  (logical partition dm-1)
if wait_dm /dev/block/dm-1; then
    try_mount /dev/block/dm-1 /odm ro,noatime
fi

echo "[neo8-mount] done"
exit 0
