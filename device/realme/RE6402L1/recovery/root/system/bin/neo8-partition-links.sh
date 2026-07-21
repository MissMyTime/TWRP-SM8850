#!/system/bin/sh

LOG=/tmp/neo8-partition-links.log
SLOT="$(getprop ro.boot.slot_suffix)"
TARGETS="boot init_boot vendor_boot recovery dtbo vbmeta vbmeta_system vbmeta_vendor"

: > "$LOG"
echo "slot_suffix=$SLOT" >> "$LOG"

mkdir -p /dev/block/by-name /dev/block/bootdevice/by-name

link_partition() {
    local base="$1"
    local wanted sysdev partname block

    for wanted in "${base}${SLOT}" "$base"; do
        for sysdev in /sys/class/block/*; do
            [ -f "$sysdev/uevent" ] || continue
            partname="$(sed -n 's/^PARTNAME=//p' "$sysdev/uevent" | head -n 1)"
            [ "$partname" = "$wanted" ] || continue

            block="/dev/block/$(basename "$sysdev")"
            [ -b "$block" ] || continue

            ln -sf "$block" "/dev/block/by-name/$base"
            ln -sf "$block" "/dev/block/bootdevice/by-name/$base"
            echo "$base <= $partname <= $block" >> "$LOG"
            return 0
        done
    done

    echo "$base: no matching PARTNAME" >> "$LOG"
    return 1
}

for target in $TARGETS; do
    link_partition "$target"
done

exit 0
