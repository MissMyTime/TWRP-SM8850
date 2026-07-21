#!/system/bin/sh
RP=/system/bin/resetprop
LOG=/tmp/neo8-touch-props.log
echo "neo8-touch-props start $(date 2>/dev/null)" > "$LOG"
if [ ! -x "$RP" ]; then echo "resetprop missing" >> "$LOG"; exit 0; fi

$RP -n "ro.product.device" "u9" 2>/dev/null || $RP "ro.product.device" "u9" 2>/dev/null
$RP -n "ro.product.name" "twrp_u9" 2>/dev/null || $RP "ro.product.name" "twrp_u9" 2>/dev/null
$RP -n "ro.product.model" "twrp_u9" 2>/dev/null || $RP "ro.product.model" "twrp_u9" 2>/dev/null
$RP -n "ro.product.manufacturer" "unknown" 2>/dev/null || $RP "ro.product.manufacturer" "unknown" 2>/dev/null
$RP -n "ro.product.system.device" "u9" 2>/dev/null || $RP "ro.product.system.device" "u9" 2>/dev/null
$RP -n "ro.product.system.name" "twrp_u9" 2>/dev/null || $RP "ro.product.system.name" "twrp_u9" 2>/dev/null
$RP -n "ro.product.system.model" "twrp_u9" 2>/dev/null || $RP "ro.product.system.model" "twrp_u9" 2>/dev/null
$RP -n "ro.product.system.manufacturer" "unknown" 2>/dev/null || $RP "ro.product.system.manufacturer" "unknown" 2>/dev/null
$RP -n "ro.product.vendor.device" "u9" 2>/dev/null || $RP "ro.product.vendor.device" "u9" 2>/dev/null
$RP -n "ro.product.vendor.name" "twrp_u9" 2>/dev/null || $RP "ro.product.vendor.name" "twrp_u9" 2>/dev/null
$RP -n "ro.product.vendor.model" "twrp_u9" 2>/dev/null || $RP "ro.product.vendor.model" "twrp_u9" 2>/dev/null
$RP -n "ro.product.vendor.manufacturer" "unknown" 2>/dev/null || $RP "ro.product.vendor.manufacturer" "unknown" 2>/dev/null
$RP -n "ro.product.odm.device" "u9" 2>/dev/null || $RP "ro.product.odm.device" "u9" 2>/dev/null
$RP -n "ro.product.odm.name" "twrp_u9" 2>/dev/null || $RP "ro.product.odm.name" "twrp_u9" 2>/dev/null
$RP -n "ro.product.odm.model" "twrp_u9" 2>/dev/null || $RP "ro.product.odm.model" "twrp_u9" 2>/dev/null
$RP -n "ro.product.odm.manufacturer" "unknown" 2>/dev/null || $RP "ro.product.odm.manufacturer" "unknown" 2>/dev/null
$RP -n "ro.product.product.device" "u9" 2>/dev/null || $RP "ro.product.product.device" "u9" 2>/dev/null
$RP -n "ro.product.product.name" "twrp_u9" 2>/dev/null || $RP "ro.product.product.name" "twrp_u9" 2>/dev/null
$RP -n "ro.product.product.model" "twrp_u9" 2>/dev/null || $RP "ro.product.product.model" "twrp_u9" 2>/dev/null
$RP -n "ro.product.product.manufacturer" "unknown" 2>/dev/null || $RP "ro.product.product.manufacturer" "unknown" 2>/dev/null
$RP -n "ro.product.system_ext.device" "u9" 2>/dev/null || $RP "ro.product.system_ext.device" "u9" 2>/dev/null
$RP -n "ro.product.system_ext.name" "twrp_u9" 2>/dev/null || $RP "ro.product.system_ext.name" "twrp_u9" 2>/dev/null
$RP -n "ro.product.system_ext.model" "twrp_u9" 2>/dev/null || $RP "ro.product.system_ext.model" "twrp_u9" 2>/dev/null
$RP -n "ro.product.system_ext.manufacturer" "unknown" 2>/dev/null || $RP "ro.product.system_ext.manufacturer" "unknown" 2>/dev/null
# Do not spoof platform, OS version, patch level, or fingerprints here.
# Those props are part of the FBE/KeyMint input chain on this device.

setprop persist.twrp.neo8_touch_spoof u9 2>/dev/null
echo "device=$(getprop ro.product.device) system=$(getprop ro.product.system.device) vendor=$(getprop ro.product.vendor.device) board=$(getprop ro.board.platform) first_api=$(getprop ro.product.first_api_level)" >> "$LOG"
echo "done" >> "$LOG"
exit 0
