# patches/annibale — 红米 K90

本机**不需要** `system/vold` 补丁，此目录仅作占位说明。

原因与 myron 相同：annibale 使用 NXP KeyMint，环境值取自 vendor 属性，recovery 侧伪装版本号不会触发密钥升级。原版 vold + `patches/common` 的 Weaver1.cpp 即为已验证的稳定组合。

注意：请勿把 `patches/nezha` 或 `patches/neo8` 的 vold 文件混入本机构建。
