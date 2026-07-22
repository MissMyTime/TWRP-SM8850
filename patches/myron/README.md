# patches/myron — 红米 K90 Pro Max

本目录保存 Myron 专用的 `system/vold` 基线、四个已验证的 recovery init 映射，以及构建期 CTS 版本白名单补丁。CTS 补丁只允许已验证镜像使用的 `99.87.36` 版本值通过 Android 16 构建检查，不进入 recovery 运行时。

Myron 不使用 KeyMint 环境切换。解密前停止 keystore2，将 `/data/misc/keystore` 绑定到 recovery 的 keystore2 工作目录，再重新启动服务；绑定或服务启动失败时直接中止解密。KeyMint 没有返回升级 blob 时不会写密钥；返回升级 blob 时，`KeyStorage.cpp` 在原密钥目录完成原子替换并同步目录，避免升级结果只留在 `/tmp`。

构建脚本会用本目录中的两个 vold 文件覆盖构建树并逐文件比对，防止旧的 WSL 修改进入镜像。请勿把 `patches/nezha` 或 `patches/neo8` 的 vold、MTP 或密钥环境代码混入 Myron。
