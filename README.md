# SM8850 TWRP Device Trees & Source Changes
> SM8850 芯片机型 TWRP 适配源码与修改补丁

[![酷安](./.github/assets/coolapk.svg)](https://www.coolapk.com/u/4327352)
[![反馈](./.github/assets/discuss.svg)](https://github.com/MissMyTime/twrp_device_sm8850/issues)

适配高通SM8850（canoe）平台机型的TWRP设备树与源码修改，支持Android 16/API 36/BP2A，适配Virtual A/B分区。
目前已适配列表内机型，其他SM8850机型可提Issues反馈适配需求。
**支持特性：Android 16 / API 36 / BP2A / Virtual A/B 分区**

## English Overview
**[Full English documentation → README_EN.md](./README_EN.md)**

TWRP device trees and source patches for the **Qualcomm Snapdragon 8 Elite Gen 5 (SM8850 / canoe)** platform, targeting **Android 16 (API 36, BP2A)** with **Virtual A/B** partitions. Supported: **Redmi K90** (annibale), **Redmi K90 Pro Max** (myron), **Xiaomi 17 Ultra** (nezha), **realme Neo8** (RE6402L1). Features FBE data decryption, Weaver/Keymaster/KeyMint support, and TWRP auto-restore after ROM flash.

## 支持设备（Supported Devices）
| Vendor | Device | Codename | Status |
|--------|--------|----------|--------|
| Xiaomi | Redmi K90 | annibale | Supported |
| Xiaomi | Redmi K90 Pro Max | myron | Supported |
| Xiaomi | Xiaomi 17 Ultra | nezha | Supported |
| realme | realme Neo8 | RE6402L1 | Supported |

## 讨论区（Discussion）
- XDA: [TWRP for POCO F8 Ultra / Redmi K90 Pro Max (myron)](https://xdaforums.com/t/twrp-3-7-1-for-poco-f8-ultra-redmi-k90-pro-max-myron-android-16-fbe-decrypt.4795272/)
- XDA: [TWRP for Xiaomi 17 Ultra (nezha)](https://xdaforums.com/t/twrp-3-7-1-for-xiaomi-17-ultra-nezha-android-16-fbe-decrypt.4795275/)
- XDA: [TWRP for realme Neo8 (RE6402L1)](https://xdaforums.com/t/twrp-3-7-1-for-realme-neo8-re6402l1-android-16-fbe-decrypt.4795276/)
- 4PDA: [Realme Neo 8 讨论帖](https://4pda.to/forum/index.php?showtopic=1109949)

## 仓库结构（Repository Layout）
```
twrp_device_sm8850/
├── README.md                          # 本说明文件
├── docs/                              # 机型专属文档
│   ├── BUILD.md                       # 编译教程（WSL2环境、依赖安装）
│   ├── PATCHES.md                     # 源码修改详细说明
│   ├── xiaomi-annibale.md
│   ├── xiaomi-myron.md
│   ├── xiaomi-nezha.md
│   └── realme-neo8.md
├── device/                            # 设备树
│   ├── qcom/
│   │   └── sm8850-common/             # （后续更新）SM8850通用板级配置
│   ├── xiaomi/
│   │   ├── annibale/                  # Redmi K90 设备树
│   │   ├── myron/                     # Redmi K90 Pro Max 设备树
│   │   └── nezha/                     # Xiaomi 17 Ultra 设备树
│   └── realme/
│       └── RE6402L1/                  # realme Neo8 设备树
├── source_changes/                    # TWRP源码修改补丁
│   ├── files/                         # 修改后完整源码文件
│   │   ├── bootable/recovery/...
│   │   └── system/vold/...
│   └── patches/                       # Git格式补丁，方便上游跟踪
│       ├── bootable_recovery/
│       └── system_vold/
└── scripts/
    ├── apply-patches.sh               # 一键应用源码补丁
    └── build.sh                       # 统一编译入口脚本
```

## 快速开始（Quick Start）
### 1. 克隆本仓库到TWRP源码同级目录
```bash
cd ~/android/twrp
git clone https://github.com/MissMyTime/twrp_device_sm8850.git
```
### 2. 应用源码修改补丁
```bash
cd ~/android/twrp
twrp_device_sm8850/scripts/apply-patches.sh .
```
### 3. 编译指定机型Recovery
```bash
cd ~/android/twrp
source build/envsetup.sh
lunch twrp_RE6402L1-eng
mka recoveryimage
```
也可以使用一键编译脚本：
```bash
cd ~/android/twrp
twrp_device_sm8850/scripts/build.sh RE6402L1 realme
```

## 编译要求（Build Requirements）
- 推荐环境：WSL2 + Ubuntu 24.04
- 内存建议：64GB+（或配置等量swap）
- 磁盘空间：预留200GB+空闲空间
- 完整环境搭建教程见 [docs/BUILD.md](docs/BUILD.md)

## 源码修改说明（Source Changes Summary）
详细补丁说明见 [docs/PATCHES.md](docs/PATCHES.md)
### bootable/recovery 部分
- **槽位检测修复** (`twinstall.cpp`)：修正Virtual A/B分区槽位识别逻辑，避免刷入错分区
- **自动重刷TWRP** (`action.cpp`)：刷入ROM前自动备份Recovery，刷完自动恢复到双槽位，避免TWRP被官方ROM覆盖
- **清除Bootloader消息** (`twrp-functions.cpp`)：重启前自动清除bootloader错误消息，避免卡开机
- **Fastboot重启修复** (`twrp-functions.cpp`)：修复`rb_fastboot`命令使用错误属性的问题
- **UI/界面适配**：中文字符串、布局调整，适配中置挖孔屏状态栏位置
- **分区处理优化**：支持Virtual A/B分区别名，修复动态分区刷入问题
- **Wi-Fi支持**（myron/Neo8）：Recovery下Wi-Fi框架、supplicant、DHCP客户端适配
- **ST54空指针崩溃修复** (`partition.cpp`, `gui.cpp`)：修复小米17 Ultra（nezha）初始化ST54安全元件时的空指针崩溃
- **SELog屏蔽**：屏蔽Recovery启动时ST54 DAC访问的SELinux拒绝日志，避免启动卡第一屏
### system/vold 部分
- **FBE/Weaver兼容**：适配Android 16文件级加密与Weaver/Keymaster解密
- **ST54密钥存储安全补丁** (`KeyStorage.cpp`, `Decrypt.cpp`)：增加ST54 weaver密钥访问空指针校验，修复nezha机型解密失败问题
- **Thales weaver支持**：适配小米SM8850 nezha机型使用的Thales强box keymint/weaver服务

## 机型注意事项（Device-specific Notes）
每个机型在`docs/`目录下有单独说明文档，包含：
- 分区表与分区大小
- FBE/Keymaster/Weaver支持状态
- 已知问题与临时解决方法
- 预编译二进制（keymint、weaver、触控等）说明

## 贡献指南（Contributing）
新增机型适配欢迎提交PR：
1. 在`device/<厂商>/<机型代号>/`目录下提交完整设备树
2. 在`docs/`目录下新增对应机型的说明文档
3. 如有新的源码修改，提交到`source_changes/`目录
4. 更新本README的支持设备列表

## 致谢（Thanks）
- TeamWin Recovery Project 团队提供TWRP开源基础代码
- AOSP项目提供Android系统开源基础
- 高通提供QCOM内核与设备树开源资源

## 协议（License）
各设备树与源码文件遵循其原有开源协议。本仓库原创内容采用 [Apache-2.0](./LICENSE) 协议。
