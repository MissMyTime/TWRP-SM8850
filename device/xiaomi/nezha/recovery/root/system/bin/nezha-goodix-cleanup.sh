#!/system/bin/sh
# Stop recovery-local Goodix services before leaving TWRP.  This keeps the
# stock system boot from inheriting stale recovery eSE/Weaver state.

LOG=/tmp/recovery.log

log_msg() {
    echo "nezha-goodix-cleanup: $1" >> "$LOG"
    log -t nezha_goodix_cleanup "$1" 2>/dev/null || true
}

repair_goodix_data() {
    # The stock Goodix secure-element HAL scans these data/log paths on Android
    # boot. If recovery leaves the directory missing or mislabeled, the stock
    # HAL can abort in readdir() and lockscreen verification stalls.
    if [ -d /data/vendor ] || [ -d /data/media ]; then
        mkdir -p /data/vendor/goodix/secure_element
        mkdir -p /data/vendor/secure_element
        mkdir -p /mnt/vendor/persist/goodix /mnt/vendor/persist/data

        chown -R system:system /data/vendor/goodix /data/vendor/secure_element 2>/dev/null || true
        chmod -R 0770 /data/vendor/goodix /data/vendor/secure_element 2>/dev/null || true

        restorecon -RFv /data/vendor/goodix /data/vendor/secure_element \
            /mnt/vendor/persist/goodix /mnt/vendor/persist/data \
            >> "$LOG" 2>&1 || true
    fi
}

log_msg "start"
setprop twrp.nezha.weaver_ready 0
setprop twrp.nezha.goodix_cleanup_started 1

repair_goodix_data

stop goodix_weaver_hal_service
stop secure_element_hal_service
killall android.hardware.weaver-service-goodix-recovery 2>/dev/null || true
killall android.hardware.secure_element-service-goodix-recovery 2>/dev/null || true

# qseecomd/minkdaemon are only needed in recovery to serve credential unlock.
# Leaving those sessions alive across reboot can make Android lockscreen wait
# for secure-world recovery, so stop the whole chain before sys.powerctl wins.
stop vendor.minkdaemon
stop vendor.qseecomd
sleep 1

rm -rf /tmp/nezha-goodix /tmp/goodix* /tmp/SELog* 2>/dev/null || true
repair_goodix_data
sync

setprop twrp.nezha.goodix_cleanup_done 1
log_msg "done"
exit 0
