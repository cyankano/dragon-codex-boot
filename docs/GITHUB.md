# 发布到 GitHub

建议仓库名：`dragon-codex-boot`，可见性：Public，默认分支：`main`。

## 上传源码

本仓库源码已经独立整理。只上传 Git 跟踪文件，避免把原制作项目、下载目录和本机配置一起上传。

有 GitHub CLI 并登录后，在仓库根目录执行：

```powershell
gh repo create dragon-codex-boot --public --source . --remote origin --push --description "Custom animation startup and live-window handoff for Codex on Windows"
```

如果仓库已经创建，不再次执行创建命令。用 `git remote -v` 检查远端，并推送到对应仓库。

## 首次 Release

1. 推送源码后，检查 GitHub Actions 的 Windows 构建结果。
2. 执行 `scripts/test.ps1` 和 `scripts/package.ps1`，确认程序包没有私有媒体。
3. 上传版本包和对应 `.sha256` 到 Release。
4. Release 说明写明默认无启动视频，以及视频导入方法。

`build.yml` 会构建、运行离线检查、打包，并把 ZIP 与哈希作为 Actions artifact 保留；它不自动建立 Release 或上传本机视频。

## 发布内容边界

- 源码、配置模板和本项目文档使用 MIT 许可证。
- 默认 ZIP 包含程序、示例配置、导入及快捷方式脚本、许可证和文档。
- 龙娘人设、原启动动画、声音、提取的官方图标、本机路径与日志没有纳入源码仓库。
- 若要另外发布角色动画，先记录素材来源及适用的再分发许可，不默认把代码的 MIT 许可套到媒体上。
