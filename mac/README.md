# macOS 启动器

这个版本在 macOS 上播放仓库的 `media/startup.mp4`，同时启动已安装的 ChatGPT / Codex 桌面客户端。按 **Esc** 可以跳过；视频结束或跳过后，遮罩淡出并显示真实客户端。它不修改官方 App，也不安装后台服务。

Windows 版的 DWM 实时窗口嵌入没有移植到 macOS。因此动画末尾是淡出交接，视频中的界面不是实时可操作窗口。遮罩只覆盖主显示器；通过 Spotlight 搜索原版 ChatGPT、协议链接或直接打开原 App 仍会绕过动画。

## 构建和使用

需要 macOS 13 或更新版本、Apple Command Line Tools，以及已安装的 ChatGPT / Codex 桌面客户端。构建时使用仓库已有的视频文件；动画及其中角色、音乐和标志的许可边界见 [`media/MEDIA_NOTICE.md`](../media/MEDIA_NOTICE.md)。

```sh
zsh mac/build.sh
ditto 'build/mac/Dragon Codex Boot.app' '/Applications/Dragon Codex Boot.app'
open '/Applications/Dragon Codex Boot.app'
```

构建产物在 `build/mac/`，不会提交到仓库。构建脚本会进行本机临时签名；这里没有提供经过 Apple 公证的发布包，也没有包含官方应用图标。

## 可选：替换当前 Dock 固定项

如果 Dock 已经固定了原版 ChatGPT，可以运行：

```sh
python3 mac/dock_integration.py install
```

此命令只替换识别到的一个原版 ChatGPT 固定项，保留原位置，并在 `~/Library/Application Support/Dragon Codex Boot/` 保存原固定项。它不会拦截其他启动入口。恢复时运行：

```sh
python3 mac/dock_integration.py restore
```

恢复只替换仍指向此启动器的 Dock 固定项，并保留其余 Dock 项目。恢复后可删除 `/Applications/Dragon Codex Boot.app`。

## 已验证范围

在 Apple Silicon macOS 上验证了视频实际播放、Esc 跳过、完整播放后启动器退出，以及 ChatGPT 继续运行。未验证 Intel Mac、多显示器、首次启动客户端或各 macOS 版本的窗口行为。
