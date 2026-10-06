# Dragon Codex Boot

给 Windows 版 Codex 桌面客户端播放自定义启动动画，并把动画结尾自然交接到真实、可操作的软件窗口。

**社区独立项目，与 OpenAI 无隶属关系。** 源码使用 MIT 许可证。仓库与默认程序包包含一段完整的 1080p 龙娘启动动画，解压即可播放，也支持换成自己的 MP4。视频许可说明见 [随附媒体说明](media/MEDIA_NOTICE.md)。

## 它做什么

1. 居中播放启动视频，默认窗口为 **1920 × 1080 物理像素**。
2. 同时打开已安装的 Codex 客户端；如果客户端已开，衔接到现有窗口。
3. 客户端尚未出现时，在可配置的动画节点暂停等待。
4. 把真实客户端客户区对齐到播放窗口，以 Windows DWM 实时缩略图填入动画里的屏幕。
5. 随着动画屏幕扩大，真实界面逐渐显现；视频结束后撤掉播放窗口，把操作交还给客户端。

支持 `Esc` 跳过、自定义音量、衔接时段、屏幕矩形关键帧，以及可撤销的开始菜单快捷方式。DWM 连接失败时使用淡出交接。

默认配置来自一段约 14 秒、16:9 的动画：11.3 秒等待节点，12.7–13.65 秒交接。这些时间和屏幕坐标必须按自己的视频修改，**不是适用于所有视频的通用模板**。

## 环境

- Windows 10/11 x64，.NET Framework 4.8。
- 已安装 Windows 版 Codex 桌面客户端。
- 本地 MP4，建议 H.264 视频与 AAC 音频、16:9。
- 播放依赖 Windows 自带媒体能力。Windows N 等缺少媒体组件的系统可能无法播放。

不需要 Node、Python、NuGet、API key、视频生成服务或管理员权限。

## 下载版：解压后直接运行

从仓库的 **Releases** 下载 `DragonCodexBoot-版本-win-x64-with-video.zip`，解压到一个长期保留的位置，然后双击 **DragonCodexBoot.exe**。

程序包已经包含 `media/startup.mp4` 与匹配这段动画的配置。已安装 Codex 且客户端标识与示例一致时，即可播放动画并接入客户端；标识不一致时参考 [配置说明](docs/CONFIGURATION.md) 更新 `AppLaunch`。

### 换成自己的动画

1. 在该目录打开 PowerShell，将自己的视频导入：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Import-Animation.ps1 -VideoPath "D:\Animations\startup.mp4"
   ```

2. 用文本编辑器打开同目录的 `launcher.json`，按视频修改等待节点、过渡时间和屏幕位置。详见 [配置说明](docs/CONFIGURATION.md)。
3. 双击 `DragonCodexBoot.exe`。它播放动画，然后进入真实 Codex。

导入脚本复制视频到 `media/startup.mp4`，验证副本哈希，已有视频和配置会保留备份。它只导入文件，不分析、重新生成或自动修改分镜。

### 固定到开始菜单

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-start-menu.ps1
```

随后在资源管理器中右键 `DragonCodexBoot.exe`，选择 **固定到“开始”**。以后从这个入口启动。

恢复：先在开始菜单取消这个入口的固定，再执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-start-menu.ps1 -Action Restore
```

安装脚本只创建当前用户的 `Dragon Codex Boot.lnk`，会校验和备份同名快捷方式。它不会改写官方程序、替换应用包或注册后台监听。

## 从源码构建

克隆或下载源码，在仓库根目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

输出位于 `build/DragonCodexBoot/`。首次构建复制配置模板；再次构建保留已有的 `launcher.json`。

导入自己的视频：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Import-Animation.ps1 -VideoPath "D:\Animations\startup.mp4"
```

制作包含随附演示视频的可分发程序包：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\package.ps1
```

包和 SHA-256 文件写入 `dist/`。默认使用公开配置模板与仓库中的 `media/startup.mp4`，不会自动把后来导入到本机 build 目录的个人视频打包进去。可加 `-WithoutMedia` 生成不含视频的程序包。

### 自定义名称与图标

- 显示名：修改配置中的 `DisplayName`。
- 图标：构建时可传入自己有权使用的 `.ico`：

  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build.ps1 -IconPath "D:\MyAssets\my-icon.ico"
  ```

公开默认名是 **Dragon Codex Boot**。官方图标不包含在仓库或默认发布包中；本机私人版本可继续使用自己的名称和图标设置。

## 当前实现的限制

- 为 16:9 视频设计；实际显示器小于配置的物理窗口尺寸时可能超出屏幕，应降低 `PlayerWidth` / `PlayerHeight`。
- 找到“可见、可响应且稳定”的客户端窗口是一种启发式检查，无法证明所有后台任务已加载完。
- `MatchClientToPlayer: true` 会恢复并移动、调整真实客户端窗口，结束后保留该位置和尺寸。
- 动画里的生成式界面和真实界面可能不同；最好让最后屏幕的比例、配色、结构接近真实软件。
- DWM 缩略图在过渡阶段只显示实时画面，交接完成后才能操作真实客户端。
- 不提供开机自启、官方入口拦截或持续后台服务。

## 项目结构

```text
src/                         C# WPF 启动器与 DPI 清单
config/launcher.example.json 公开配置模板
scripts/                     构建、导入、测试、快捷方式和打包
tests/                       配置拒绝、插值和几何定位测试
docs/                        配置、发布与手动验收
.github/workflows/           Windows 构建及程序包检查
```

日志在启动器目录的 `logs/launcher.log`，记录步骤和错误；不保存聊天正文或画面，没有网络遥测。[手动验收](docs/TESTING.md)说明真实窗口检查的范围。

参与改进请阅读 [贡献说明](CONTRIBUTING.md)。软件许可见 [LICENSE](LICENSE)，媒体和第三方名称说明见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
