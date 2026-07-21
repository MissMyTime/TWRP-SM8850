#!/system/bin/sh

LOG=/tmp/recovery.log

log_msg() {
    echo "nezha-pre-decrypt: $1" >> "$LOG"
    log -t nezha_pre_decrypt "$1" 2>/dev/null || true
}

if [ "$(getprop twrp.nezha.weaver_ready)" = "1" ]; then
    exit 0
fi

setprop twrp.nezha.goodix_gate_error ""
start nezha-goodix-gate

case "$(getprop twrp.nezha.crypto_route)" in
    normal_590) limit=120 ;;
    leica_597) limit=75 ;;
    *) limit=100 ;;
esac

restarts=0
second=0
while [ "$second" -lt "$limit" ]; do
    if [ "$(getprop twrp.nezha.weaver_ready)" = "1" ]; then
        log_msg "security service ready"
        exit 0
    fi

    state="$(getprop init.svc.nezha-goodix-gate)"
    error="$(getprop twrp.nezha.goodix_gate_error)"
    if [ -n "$error" ] && [ "$restarts" -lt 2 ]; then
        log_msg "gate error=$error; restarting"
        setprop twrp.nezha.goodix_gate_error ""
        start nezha-goodix-gate
        restarts=$((restarts + 1))
    elif [ "$second" -gt 15 ] && [ "$state" != "running" ] && [ "$restarts" -lt 2 ]; then
        log_msg "gate stopped before ready; restarting"
        start nezha-goodix-gate
        restarts=$((restarts + 1))
    fi

    sleep 1
    second=$((second + 1))
done

log_msg "security service timeout error=$(getprop twrp.nezha.goodix_gate_error)"
exit 1
