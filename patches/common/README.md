# patches/common — 全机型通用补丁

本目录补丁对四台设备（myron / annibale / nezha / RE6402L1）全部应用，`apply-patches.sh` 会先应用这里，再应用目标设备自己的目录。

## files/bootable/recovery/

TWRP 框架层修改，与具体安全芯片无关：

- `twinstall.cpp`：Virtual A/B 槽位检测修正，避免刷错槽位
- `action.cpp`：刷入 ROM 前自动备份 recovery，刷完恢复双槽位，防止被官方 ROM 覆盖
- `twrp-functions.cpp`：重启前清除 bootloader 错误消息；修正 `rb_fastboot` 属性
- `partition.cpp` / `partitionmanager.cpp` / `partitions.hpp`：动态分区与 Virtual A/B 别名处理
- `gui/`：中文字符串、布局、中置挖孔屏状态栏适配
- `minuitwrp/`：DRM 显示与触摸事件适配
- `etc/init.rc` 等：recovery 启动脚本调整
- `prebuilt/Android.mk`：预编译二进制打包规则

## files/system/vold/Weaver1.cpp

Android 16 FBE / Weaver 兼容调整：Weaver 服务未就绪时的重试等待。四台设备都需要，与安全芯片方案无关。

## patches/

上述修改的 git diff 形式，便于跟踪上游：

- `bootable_recovery/bootable_recovery.patch`：recovery 框架修改合集
- `bootable_recovery/0002-nullptr-crash-fix.patch`：`Init_Recovery` 找不到当前存储分区时的空指针防护
- `system_vold/system_vold.patch`：Weaver1.cpp 重试改进
