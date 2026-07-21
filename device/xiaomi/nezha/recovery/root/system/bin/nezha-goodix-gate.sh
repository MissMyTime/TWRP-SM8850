#!/system/bin/sh
# Start the Xiaomi 17 Ultra Goodix eSE/Weaver chain used by the stock system.
# The same recovery image is used for both nezha hardware variants.  Pick a
# conservative startup route at runtime so 5.9.0 and 5.9.7 do not race the eSE
# stack in the same way.

LOG=/tmp/recovery.log
TMPROOT=/tmp/nezha-goodix
TMPLOG=$TMPROOT/log

log_msg() {
    echo "nezha-goodix-gate: $1" >> "$LOG"
    echo "nezha-goodix-gate: $1" >> "$TMPLOG" 2>/dev/null || true
    log -t nezha_goodix_gate "$1" 2>/dev/null || true
}

wait_stable_running() {
    name="$1"
    stable_needed="$2"
    limit="$3"
    stable=0
    i=0
    while [ "$i" -lt "$limit" ]; do
        if [ "$(getprop "init.svc.$name")" = "running" ]; then
            stable=$((stable + 1))
            [ "$stable" -ge "$stable_needed" ] && return 0
        else
            stable=0
        fi
        sleep 1
        i=$((i + 1))
    done
    return 1
}

detect_route() {
    model="$(getprop ro.product.model)"
    hwver="$(getprop ro.boot.hwversion)"
    vbstate="$(getprop ro.boot.verifiedbootstate)"
    fp="$(getprop ro.vendor.build.fingerprint)"

    route=fallback
    case "$model:$hwver" in
        *25128PNA1C*|*:5.9.7*) route=leica_597 ;;
        *2512BPNDAC*|*:5.9.0*) route=normal_590 ;;
    esac

    setprop twrp.nezha.model "$model"
    setprop twrp.nezha.hwversion "$hwver"
    setprop twrp.nezha.verifiedbootstate "$vbstate"
    setprop twrp.nezha.crypto_route "$route"
    log_msg "route=$route model=$model hwversion=$hwver vbstate=$vbstate fp=$fp"
}

reset_goodix_services() {
    stop goodix_weaver_hal_service
    stop secure_element_hal_service
    killall android.hardware.weaver-service-goodix-recovery 2>/dev/null || true
    killall android.hardware.secure_element-service-goodix-recovery 2>/dev/null || true
}

prepare_tmp_state() {
    mkdir -p "$TMPROOT" "$TMPROOT/data" "$TMPROOT/persist" "$TMPROOT/logs"
    chmod 0700 "$TMPROOT" "$TMPROOT/data" "$TMPROOT/persist" "$TMPROOT/logs"
    rm -rf /tmp/SELog* /tmp/goodix* 2>/dev/null || true
}

setprop twrp.nezha.goodix_gate_started 1
setprop twrp.nezha.goodix_gate_error ""
setprop twrp.nezha.weaver_ready 0
prepare_tmp_state
detect_route
log_msg "start"

# PRODUCT_COPY_FILES can normalize rootfs overlay executables to 0644.
# Restore executable mode before init launches the stable /sbin copies.
chmod 0755 /sbin/android.hardware.secure_element-service-goodix-recovery
chmod 0755 /sbin/android.hardware.weaver-service-goodix-recovery

# qseecomd and Mink must be started only after smcinvoke_dlkm is loaded and
# /dev/smcinvoke has usable ownership. Their stock early-boot attempt can race
# recovery's late module loader and leave the TA opener in a broken state.
reset_goodix_services

case "$(getprop twrp.nezha.crypto_route)" in
    normal_590)
        # 5.9.0 has been observed to report "running" before the eSE pair is
        # actually usable. Give QSEE/Mink and the Goodix pair more settle time.
        qsee_stable=3
        qsee_limit=25
        mink_stable=3
        mink_limit=25
        se_stable=4
        se_limit=35
        weaver_stable=5
        weaver_limit=14
        weaver_attempts=7
        settle_before_goodix=3
        retry_sleep=3
        ;;
    leica_597)
        qsee_stable=2
        qsee_limit=15
        mink_stable=2
        mink_limit=15
        se_stable=2
        se_limit=20
        weaver_stable=3
        weaver_limit=8
        weaver_attempts=5
        settle_before_goodix=1
        retry_sleep=2
        ;;
    *)
        qsee_stable=3
        qsee_limit=25
        mink_stable=3
        mink_limit=25
        se_stable=3
        se_limit=30
        weaver_stable=4
        weaver_limit=12
        weaver_attempts=6
        settle_before_goodix=2
        retry_sleep=3
        ;;
esac

stop vendor.qseecomd
stop vendor.minkdaemon
sleep 1
start vendor.qseecomd
if ! wait_stable_running vendor.qseecomd "$qsee_stable" "$qsee_limit"; then
    setprop twrp.nezha.goodix_gate_error vendor_qseecomd_not_stable
    log_msg "vendor.qseecomd did not stay running"
    exit 0
fi

# Goodix uses libGPMTEEC_vendor through the HLOS Mink opener. Keep the
# dependency explicit instead of relying only on Android's early-boot event.
start vendor.minkdaemon
if ! wait_stable_running vendor.minkdaemon "$mink_stable" "$mink_limit"; then
    setprop twrp.nezha.goodix_gate_error vendor_minkdaemon_not_stable
    log_msg "vendor.minkdaemon did not stay running"
    exit 0
fi

sleep "$settle_before_goodix"

start secure_element_hal_service
if ! wait_stable_running secure_element_hal_service "$se_stable" "$se_limit"; then
    setprop twrp.nezha.goodix_gate_error secure_element_hal_not_stable
    log_msg "secure_element_hal_service did not stay running"
    exit 0
fi

attempt=1
while [ "$attempt" -le "$weaver_attempts" ]; do
    setprop twrp.nezha.goodix_gate_attempt "$attempt"
    log_msg "start goodix_weaver_hal_service attempt $attempt"
    start goodix_weaver_hal_service
    if wait_stable_running goodix_weaver_hal_service "$weaver_stable" "$weaver_limit"; then
        setprop twrp.nezha.weaver_ready 1
        log_msg "Goodix eSE and Weaver stable route=$(getprop twrp.nezha.crypto_route)"
        exit 0
    fi
    stop goodix_weaver_hal_service
    killall android.hardware.weaver-service-goodix-recovery 2>/dev/null || true
    sleep "$retry_sleep"
    attempt=$((attempt + 1))
done

if [ "$(getprop init.svc.goodix_weaver_hal_service)" != "running" ]; then
    setprop twrp.nezha.goodix_gate_error goodix_weaver_hal_not_stable
    log_msg "goodix_weaver_hal_service did not stay running"
fi

exit 0
