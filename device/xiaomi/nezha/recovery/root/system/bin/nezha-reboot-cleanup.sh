#!/system/bin/sh
# Release recovery-owned Goodix/eSE/Weaver sessions before Android takes over.

LOG=/tmp/recovery.log

log_msg() {
    echo "nezha-reboot-cleanup: $1" >> "$LOG"
    log -t nezha_reboot_cleanup "$1" 2>/dev/null || true
}

log_status() {
    log_msg "qsee=$(getprop init.svc.vendor.qseecomd) mink=$(getprop init.svc.vendor.minkdaemon) se=$(getprop init.svc.secure_element_hal_service) weaver=$(getprop init.svc.goodix_weaver_hal_service) ready=$(getprop twrp.nezha.weaver_ready)"
}

repair_goodix_data() {
    # Keep Android-side Goodix secure-element storage sane before rebooting out
    # of recovery. This mirrors the proven online rescue command for lockscreen
    # stalls caused by secure_element-service-goodix aborting in readdir().
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
log_status
setprop twrp.nezha.weaver_ready 0
repair_goodix_data

stop goodix_weaver_hal_service
stop secure_element_hal_service
sleep 1

killall android.hardware.weaver-service-goodix-recovery 2>/dev/null
killall android.hardware.secure_element-service-goodix-recovery 2>/dev/null

# qseecomd/minkdaemon were started by recovery only to serve credential unlock.
# Stop them before reboot so Android starts with a fresh secure-world session.
stop vendor.minkdaemon
stop vendor.qseecomd
sleep 1

repair_goodix_data

log_status
sync
log_msg "done"
exit 0
