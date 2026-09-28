# Tinycast 简体中文版

本分支基于上游 Tinycast，使用 macOS 原生本地化资源，跟随系统语言显示简体中文或英文。
可在「系统设置 → 通用 → 语言与地区 → 应用程序」为 Tinycast Chinese 单独选择语言，重启应用生效。

## 下载与构建

1. 打开本仓库的 **Actions → Build Chinese Edition**。
2. 点击 **Run workflow**，选择 `main`。
3. 成功后下载 `Tinycast-Chinese-运行编号` 产物，解压并打开 DMG，将应用拖到 Applications。
4. `SHA256SUMS.txt` 提供安装包校验值；`Verification-运行编号` 包含源码版本、检查日志及 UI 测试的 `.xcresult`（含中英文截图）。

GitHub 登录后才能下载 Actions 产物。产物保留 30 天，过期后可重新构建。
本工作流不发布 GitHub Release、不修改上游 Homebrew 仓库、不发送社区公告。

## 平台与签名

- 运行要求 macOS 26 或更高版本；安装包同时包含 arm64 和 x86_64。
- `Tinycast Chinese.app` 使用 `io.github.houxiaozhao.tinycast.zh` 标识，与官方版分开保存设置。
- 应用使用固定自签名证书，不是 Apple Developer ID 公证版本。macOS 可能阻止首次打开；请先确认来自自己的构建，再按系统提示处理。
- 首次使用粘贴、窗口管理等功能时，需为中文版单独授予辅助功能权限。
- 复用上游的 development 更新策略：不自动下载或安装官方版本，升级请重新运行本工作流。
- 不要同时为原版和中文版绑定相同的全局快捷键。两者仍注册上游相同的 URL scheme，测试深层链接时请只安装/运行需要的版本。

Actions 需要两个仓库 Secrets：`SIGNING_P12_BASE64`（固定自签名证书的 P12 Base64）和
`SIGNING_P12_PASSWORD`。证书名称为 `Tinycast Self-Signed`，按 [signing.md](signing.md) 创建自己的证书。
证书和密码不能提交到仓库；缺少 Secrets 会使签名步骤失败。

## 翻译范围与维护

包含 2073 条中英文资源，覆盖设置、新手引导、启动器、内置命令、系统操作、窗口管理、备份结果、常用工具界面和应用自身的错误提示。
中文命令保留英文原名作为搜索别名；设置搜索支持中文标题和原英文标题。
扩展提供的文案、用户自定义内容、外部服务错误、表情数据和计算器自然语言词库保持原内容。
部分动态计数和较少使用的功能提示仍可能显示英文，未翻译的文案回退英文。

译文位于 `Tinycast/Resources/zh-Hans.lproj/Localizable.strings`，英文回退位于 `en.lproj`。
权限提示位于 `zh-Hans.lproj/InfoPlist.strings`。不要翻译持久化 ID、路径、脚本、模型 ID 或占位符名称。

SwiftUI 的字符串字面量直接读取资源；自定义组件和 AppKit 接收普通 String 的位置显式使用
`String(localized:)`。设置搜索目录和目标标题必须一致；修改后运行：

```sh
node Scripts/check-localization.js
node Scripts/check-settings-search.js
xcodegen generate
./Scripts/lint.sh
./Scripts/run-tests.sh
xcodebuild test -project Tinycast.xcodeproj -scheme Tinycast -configuration Debug \
  -destination 'platform=macOS' CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual
```

工作流在全新运行器上完成中文新手引导、启动器英文别名搜索、全部 22 个设置页及中英文设置搜索 UI 测试，并保留截图，之后编译并核验实际发布应用的
语言资源、bundle ID、嵌入 helper、架构和签名。构建成功不代表所有界面的视觉布局已人工检查。

上游更新需先合并并解决翻译冲突，再运行构建验证。当前没有自动同步上游或自动机器翻译任务。
原项目版权、AGPL-3.0-or-later 许可及 NOTICE 保留，分发时须遵守相应要求。
