# Zap 下载 / Releases

Zap 的公开分发仓库，用于发布安装包、校验文件和使用说明。应用源码不存放在本仓库。

## zapAgent — macOS Apple Silicon 正式版 1.13.0

- [正式版下载及校验文件](https://github.com/JackCaow/zapcode-releases/releases/tag/v1.13.0)
- 使用个人 Developer ID Application 证书签名并通过 Apple 公证。
- 仅支持 macOS Apple Silicon；Intel Mac、Linux、Windows 和 npm 安装入口不属于此次发布。
- Agent 在 Host 上运行，进程工具进入本地 VM；**不是整个 Agent 或 Host 的完全隔离**。
- 镜像已内置，不含模型、API Key 或用户会话。首次通过 `/connect` 配置模型。
- TAR/ZIP 内的命令行二进制已公证但没有 stapled ticket；首次 Gatekeeper 校验需要联网。不要移除 quarantine 或关闭 Gatekeeper。

```sh
brew tap JackCaow/zapcode-releases https://github.com/JackCaow/zapcode-releases
brew install jackcaow/zapcode-releases/zapagent
zapAgent
# Equivalent commands: zap / zapcode
```

如 Homebrew 要求信任 Formula，检查 [源码](Formula/zapagent.rb) 后运行
`brew trust --formula jackcaow/zapcode-releases/zapagent`。
若已有同名 `zapAgent`、`zap` 或 `zapcode`，不要使用 `--overwrite`；先 `brew install --skip-link jackcaow/zapcode-releases/zapagent`，
通过 `$(brew --prefix jackcaow/zapcode-releases/zapagent)/bin/zapAgent` 启动，确认后再自行选择默认命令。
不会修改 `zapdev` 或旧的 `zap-vm-preview`。

正式版默认数据目录为 `~/.zapcode-vm`，升级或卸载前先结束任务并停止该 profile 的 VM daemon：

```sh
"$(brew --prefix jackcaow/zapcode-releases/zapagent)/libexec/zapvm-runtime/bin/zapvm" daemon stop --endpoint "$HOME/.zapcode-vm/runtime-state/zapvm/daemon.sock"
```

手动安装时，先核验下载的 `.sha256`，解压后在项目目录调用完整路径的 `start-local-vm.command`。
请保留整个包目录。发布附带源码版本、签名、公证日志和校验文件；本机验证不等于所有用户机器均已验收。

## macOS Apple Silicon 内测版

当前预览版本：**v1.12.0-vm-preview.1**。仅支持 Apple Silicon（arm64），未验证 Intel Mac。

- [查看版本说明](https://github.com/JackCaow/zapcode-releases/releases/tag/v1.12.0-vm-preview.1)
- [下载完整包（约 320 MiB）](https://github.com/JackCaow/zapcode-releases/releases/download/v1.12.0-vm-preview.1/zap-macos-arm64-full-local-20260908.tar.gz)
- [下载 SHA256 校验文件](https://github.com/JackCaow/zapcode-releases/releases/download/v1.12.0-vm-preview.1/zap-macos-arm64-full-local-20260908.tar.gz.sha256)

> **开发者内测，不是正式版。** 本版本使用 ad-hoc 签名，未完成 Apple Developer ID 签名和公证。
> 浏览器下载后可能被 Gatekeeper 阻止；本机启动成功不代表另一台 Mac 已验收。
> 如遇系统安全提示，请停止并反馈，不要全局关闭 Gatekeeper 或 SIP。
> 需要开箱即用安装体验的用户，请等待签名、公证完成后的版本。

## Homebrew 安装

本仓库同时作为自定义 Tap。由于仓库名没有 `homebrew-` 前缀，首次添加时请显式指定 URL：

```sh
brew tap JackCaow/zapcode-releases https://github.com/JackCaow/zapcode-releases
```

如果 Homebrew 提示需要信任第三方 Formula，请先检查
[Formula 源码](Formula/zap-vm-preview.rb)，再仅信任这一项（支持 `brew trust` 的版本）：

```sh
brew trust --formula jackcaow/zapcode-releases/zap-vm-preview
```

安装并从项目目录启动：

```sh
brew install jackcaow/zapcode-releases/zap-vm-preview
zap-vm-preview
```

该命令不覆盖现有 `zap`、`zapdev` 或独立 `zapvm`。仍使用独立的
`~/.zapcode-local-vm` 数据目录，首次通过 `/connect` 配置模型。
Homebrew 会校验固定下载包的 SHA256；它不能代替 Apple 签名、公证。

升级或卸载前，请先结束预览版任务，并用 `brew info zap-vm-preview` 中的命令停止对应 VM daemon：

```sh
brew update
brew upgrade jackcaow/zapcode-releases/zap-vm-preview
# 不再需要时：
brew uninstall zap-vm-preview
```

卸载不会删除用户配置、会话和 VM 工作状态。

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
- Homebrew 本机验证通过：`brew install`、`brew test`（版本、VM 签名、能力检查、全部文件摘要），以及 `zap-vm-preview` 实际入口的 VM 挂载/写保护闭环。原 `zap` / `zapdev` 内容未变。
- Guest 内嵌 Resident Runner 未重新构建，本包不是新 Resident Agent 的部署验收。
- Guest 命令失败仍可能被包装为 `unavailable` / 退出码 69，这是已知错误分类问题。
- 本包来自未提交的开发工作树，不能仅凭基线 commit 重建；二进制摘要及镜像信息见包内 `build-info.json`。
- npm 安装入口尚未发布。不要把本预览包交给旧版自动安装器：文件名和目录布局不同。

## 问题反馈

请在 [Issues](https://github.com/JackCaow/zapcode-releases/issues) 提供版本号、macOS 版本、芯片架构、复现步骤和经过脱敏的错误日志。
不要上传 API Key、访问令牌、私人会话、项目源码或 VM 工作磁盘。
