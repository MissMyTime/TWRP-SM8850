# patches/annibale — 红米 K90

本机**不需要** `system/vold` 补丁，此目录仅作占位说明。

annibale 的默认 KeyMint 使用 QTI 服务，StrongBox/Weaver 使用 NXP 后端。该设备当前保留已经验证的原版 vold 与 `patches/common` 的 Weaver1.cpp 组合。

注意：请勿把 `patches/nezha` 或 `patches/neo8` 的 vold 文件混入本机构建。
