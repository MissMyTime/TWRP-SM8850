# patches/nezha — 小米 17 Ultra

本目录为 nezha **专用**的 `system/vold` 补丁，**禁止**混入其他设备构建。

背景：nezha 的徕卡版与普通版安全芯片不同，设备树同时带 Thales（`weaver-service.thales` / `ese_weaver_thales.so`）与 Goodix（`secure_element-service-goodix`）两套栈。其 KeyMint 环境取自 build 属性，而 recovery 出于 FBE 兼容伪装了平台版本（99.87.36 / 2099-12-31），解密 `begin()` 时环境比密钥 blob 新，会被当成新环境反复触发密钥升级，表现为两个版本之间解密不稳定、易卡 Logo。

原理：解密前把 KeyMint 环境（OS 版本 / OS 补丁 / vendor 补丁）压制为已安装系统的真实值，使密钥环境保持一致，不再触发不必要的升级。

本目录内容：

- `files/system/vold/Decrypt.cpp`：KeyMint 环境压制与解密流程，不包含 Neo8 的 persist、TMS Weaver 或 ColorOS 路径兼容代码。
- `files/system/vold/KeyStorage.cpp`：`KM_TAG_FBE_ICE` 与升级写回保护。
- `patches/system_vold/key_storage_recovery_safety.patch`：KeyStorage 改动的 diff 形式。

配套设备树部分（Thales/Goodix 服务、解密前等待、失败重试与重启清理）位于 `device/xiaomi/nezha/`，通过公共脚本钩子接入 recovery 框架。
