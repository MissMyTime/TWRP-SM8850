# patches/common — 全机型通用补丁

本目录只保存 myron、annibale、nezha 与 RE6402L1 都能安全使用的源码修改。设备相关实现必须放在 `patches/<device>/` 或对应设备树中；公共源码只能通过通用脚本钩子和显式属性开关调用它们。

## files/bootable/recovery/

- `twinstall.cpp`：Virtual A/B 槽位检测与 recovery 自动恢复
- `partition.cpp` / `partitionmanager.cpp`：动态分区、FBE 与存储处理
- `twrp.cpp` / `twrp-functions.cpp`：启动、重启和通用设备钩子
- `gui/`：通用界面、语言和网络支持
- `prebuilt/Android.mk`：公共预编译文件打包规则

设备钩子采用固定名称，并且仅在设备树提供对应脚本时运行：

- `/system/bin/twrp-pre-decrypt.sh`
- `/system/bin/twrp-decrypt-retry.sh`
- `/system/bin/twrp-reboot-cleanup.sh`

## files/system/vold/Weaver1.cpp

Android 16 FBE / Weaver 服务等待与重试，四台设备共同使用。

## patches/

- `bootable_recovery/0002-nullptr-crash-fix.patch`：存储分区查找失败时的空指针保护
- `external_*/soong_namespace.patch`：隔离额外 recovery 工具的 Soong 模块命名空间
- `system_vold/system_vold.patch`：Weaver1 服务重试
- `system_extras/partition_tools_target_build.patch`：同时生成 recovery 使用的 `lpmake`、`lpadd` 与 `lpunpack` 目标端程序

完整源码文件是 recovery 框架修改的唯一基准。设备专属的完整文件和增量补丁分别位于 `patches/neo8/` 与 `patches/nezha/`。
