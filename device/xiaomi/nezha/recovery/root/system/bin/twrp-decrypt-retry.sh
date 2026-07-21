#!/system/bin/sh

setprop twrp.nezha.weaver_ready 0
setprop twrp.nezha.goodix_gate_error ""
stop nezha-goodix-gate
stop goodix_weaver_hal_service
stop secure_element_hal_service
killall android.hardware.weaver-service-goodix-recovery 2>/dev/null || true
killall android.hardware.secure_element-service-goodix-recovery 2>/dev/null || true
sleep 1
start nezha-goodix-gate
exec /system/bin/twrp-pre-decrypt.sh
