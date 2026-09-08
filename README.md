# Zap 下载 / Releases

Zap 的公开分发仓库，用于发布安装包、校验文件和使用说明。应用源码不存放在本仓库。

## macOS Apple Silicon 内测版

当前预览版本：**v1.12.0-vm-preview.1**。仅支持 Apple Silicon（arm64），未验证 Intel Mac。

- [查看版本说明](https://github.com/JackCaow/zapcode-releases/releases/tag/v1.12.0-vm-preview.1)
- [下载完整包（约 320 MiB）](https://github.com/JackCaow/zapcode-releases/releases/download/v1.12.0-vm-preview.1/zap-macos-arm64-full-local-20260908.tar.gz)
- [下载 SHA256 校验文件](https://github.com/JackCaow/zapcode-releases/releases/download/v1.12.0-vm-preview.1/zap-macos-arm64-full-local-20260908.tar.gz.sha256)

> **开发者内测，不是正式版。** 本版本使用 ad-hoc 签名，未完成 Apple Developer ID 签名和公证。
> 浏览器下载后可能被 Gatekeeper 阻止；本机启动成功不代表另一台 Mac 已验收。
> 如遇系统安全提示，请停止并反馈，不要全局关闭 Gatekeeper 或 SIP。
> 需要开箱即用安装体验的用户，请等待签名、公证完成后的版本。

## 下载与启动

在同一目录下载压缩包和校验文件。可通过上面的链接下载，也可以在终端执行：

```sh
curl -fL --retry 3 -O https://github.com/JackCaow/zapcode-releases/releases/download/v1.12.0-vm-preview.1/zap-macos-arm64-full-local-20260908.tar.gz
curl -fL --retry 3 -O https://github.com/JackCaow/zapcode-releases/releases/download/v1.12.0-vm-preview.1/zap-macos-arm64-full-local-20260908.tar.gz.sha256
shasum -a 256 -c zap-macos-arm64-full-local-20260908.tar.gz.sha256
```

只有显示 `OK` 后才解压。请使用没有同名旧目录的位置，以免覆盖旧版本：

```sh
tar -xzf zap-macos-arm64-full-local-20260908.tar.gz
./zap-macos-arm64-full-local-20260908/start-local-vm.command
```

要操作自己的项目，先在终端进入项目目录，再通过**完整路径**调用解压目录中的
`start-local-vm.command`。保留整个目录，不要只移动 `zap` 二进制。

首次进入后，用 `/connect` 配置自己的模型服务。包内不含个人 API Key、配置或会话。
VM 镜像已经包含在包内，无需首次联网下载；使用远端模型 API 仍需联网。

## 数据与权限

- 启动器默认使用独立数据目录 `~/.zapcode-local-vm`，不替换已有 `zapdev` 安装或会话。
- 可用 `ZAPCODE_DATA_DIR` 指定另一个独立目录。若检测到 Cloud 绑定、Resident 模式或禁用 VM 的设置，启动器会拒绝启动。
- Zap Agent 在 Host 上运行，工作区进程工具进入 VM；Host 文件工具和 MCP 不等于已被 VM 隔离。
- VM 工作区可读写，`.git` 等受保护路径只读。运行状态位于数据目录内，不写回发布包。
- 退出聊天后 VM 可能在空闲超时前保持运行。确认没有任务后，可用包内的
  `zapvm-runtime/bin/zapvm daemon stop --endpoint "$HOME/.zapcode-local-vm/runtime-state/zapvm/daemon.sock"`
  停止默认测试数据目录对应的 daemon；自定义数据目录请同步修改路径。

## 验证与已知限制

- 本机通过：包内 Zap 自动发现 zapVM、真实 Linux VM 启动、挂载读写、`.git` 写保护、换目录解压复测。
- 打包链路使用本地固定响应测试服务驱动 CLI，VM 和文件操作均为真实执行；不把它当成模型能力测试。
- 已通过镜像签名校验、包内文件 SHA256 校验及 10 项安装/打包测试；未声称全仓测试全绿。
- Guest 内嵌 Resident Runner 未重新构建，本包不是新 Resident Agent 的部署验收。
- Guest 命令失败仍可能被包装为 `unavailable` / 退出码 69，这是已知错误分类问题。
- 本包来自未提交的开发工作树，不能仅凭基线 commit 重建；二进制摘要及镜像信息见包内 `build-info.json`。
- Homebrew 与 npm 安装入口尚未发布。不要把本预览包交给旧版自动安装器：文件名和目录布局不同。

## 问题反馈

请在 [Issues](https://github.com/JackCaow/zapcode-releases/issues) 提供版本号、macOS 版本、芯片架构、复现步骤和经过脱敏的错误日志。
不要上传 API Key、访问令牌、私人会话、项目源码或 VM 工作磁盘。
