# Redmi K90 Pro Max / myron TWRP 设备树改动说明

本设备树用于 Redmi K90 Pro Max / myron 的 TWRP 3.7.1 Android 16 适配。

## 当前状态

- 基础功能：可启动 TWRP，触摸、亮度、解密、MTP、ADB、Wlan、振动均已适配。
- 分区形态：独立 recovery 分区。
- 目标系统：HyperOS 3 / Android 16，FBE metadata 加密，动态分区，Virtual A/B。

## 构建说明

在 `/root/twrp16` 下执行：

```bash
source build/envsetup.sh
lunch twrp_myron-myron-eng
m recoveryimage
```

输出文件：

```text
out/target/product/myron/recovery.img
```

## 注意事项

- 刷入命令应使用：

```bash
adb reboot bootloader
fastboot flash recovery_ab recovery.img
fastboot reboot recovery
```
