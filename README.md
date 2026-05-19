# PDFCut Studio

> 中文 | [English](#english)

当前版本：**1.0.0**

PDFCut Studio 是一个基于 [Briss 2.0](https://github.com/mbaeuerle/Briss-2.0) 修改的开源 PDF 页面裁剪工具。它面向 Windows 便携使用场景，内置运行时，支持鼠标可视化框选裁剪区域，并提供“安全裁剪：只输出可见区域”模式：保留裁剪区域内的可复制文字，同时移除裁剪区域外的 PDF 内容。


## 主要功能

- **中英文双语界面**：启动器默认中文，可在右上角切换到 English。
- **可视化 PDF 裁剪**：用鼠标直接框选保留区域，所见即所得。
- **选择一次 PDF 即可进入裁剪**：启动器选择 PDF 后，打开可视化裁剪窗口时会自动载入该文件。
- **单页定义，全书批量裁剪**：只需在其中一页标出裁剪范围，即可将同一范围应用到所有页面。
- **安全裁剪：只输出可见区域**：默认推荐模式。导出的 PDF 只保留裁剪区域内的内容，区域内文字仍可复制，区域外内容会被移除。
- **快速裁剪：仅设置 PDF 边界框**：保留 Briss 原有的高速裁剪逻辑，适合对速度和体积优先的场景。
- **便携版发布**：内置 Java 运行时，解压后即可使用。
- **本地处理**：PDF 文件在本机处理，不上传到服务器。

## 下载与运行

1. 从 GitHub Release 下载 `PDFCut-Studio-portable.zip`。
2. 解压到任意目录。
3. 双击 `PDFCut Studio.vbs` 启动。
4. 拖入 PDF，或点击“选择 PDF”。
5. 点击“打开可视化裁剪”，调整裁剪框并导出。

更详细的双语使用说明见：[PDFCut-Studio/docs/QUICK_START.md](PDFCut-Studio/docs/QUICK_START.md)。

## 裁剪输出逻辑

PDFCut Studio 提供两种输出逻辑：

| 模式 | 说明 | 适合场景 |
| --- | --- | --- |
| 安全裁剪：只输出可见区域 | 物理移除裁剪范围外的内容，保留裁剪范围内的可复制文本 | 需要避免裁剪区外内容被复制、搜索或泄露 |
| 快速裁剪：仅设置 PDF 边界框 | 只设置 PDF 页面边界框，速度快，但区域外内容可能仍存在于 PDF 内部 | 快速阅读、屏幕适配、无需隐藏内容 |

## 项目结构

```text
PDFCut-Studio/                     便携版应用目录
PDFCut-Studio/app/                 WPF 启动器
PDFCut-Studio/docs/                用户说明与发布材料
PDFCut-Studio/lib/                 构建后的应用 JAR
PDFCut-Studio/runtime/             内置 Java 运行时
source-Briss-2.0/                  基于 Briss 2.0 修改的 Java 源码
LICENSE.txt                        GPLv3 许可证
NOTICE.md                          来源与修改说明
THIRD_PARTY_NOTICES.md             第三方组件说明
RELEASE_NOTES.md                   发布说明
```

## 从源码构建

需要 JDK 11 到 19。进入源码目录后运行：

```powershell
cd source-Briss-2.0
.\gradlew.bat shadowJar test
```

构建完成后，将生成的 shadow jar 复制到：

```text
PDFCut-Studio/lib/Briss-2.0-all.jar
```

## 开源协议与致谢

PDFCut Studio 是 Briss 2.0 的修改衍生版本，按 **GNU General Public License v3.0** 发布。完整许可证文本见 [LICENSE.txt](LICENSE.txt)。

上游项目：

- Briss 2.0: https://github.com/mbaeuerle/Briss-2.0
- License: GPL-3.0

Briss 2.0 的 README 中说明，它基于 SourceForge 上的 Briss 0.9，并由 Briss 2.0 维护者独立开发。本项目不是 Briss 原作者或维护者的官方版本，也不暗示获得其背书。

发布二进制版本时，请同时提供对应源码、许可证文本、第三方组件说明和修改说明，以遵守 GPLv3 及相关依赖的许可要求。

---

## English

Current version: **1.0.0**

PDFCut Studio is an open-source visual PDF cropper based on [Briss 2.0](https://github.com/mbaeuerle/Briss-2.0). It is designed as a portable Windows application with a polished bilingual launcher, mouse-based crop selection, and a secure visible-area-only crop mode.

## Features

- **Bilingual UI**: Chinese by default, English available from the launcher.
- **Visual PDF cropping**: draw and adjust crop rectangles with your mouse.
- **Open once, crop directly**: choose a PDF in the launcher and open it directly in the visual crop workspace.
- **Apply one page's crop to all pages**: define a crop rectangle on one page and reuse it across the whole document.
- **Secure crop: visible area only**: the recommended default. It removes content outside the crop while keeping text inside the crop selectable.
- **Fast crop: PDF boundary box only**: keeps the legacy Briss-style boundary-box workflow for maximum speed.
- **Portable Windows package**: bundled runtime, no separate Java installation required.
- **Local processing**: PDF files stay on your machine.

## Download And Run

1. Download `PDFCut-Studio-portable.zip` from GitHub Releases.
2. Extract it.
3. Run `PDFCut Studio.vbs`.
4. Drop in a PDF, or click **Choose PDF**.
5. Click **Open Visual Crop**, adjust the crop rectangle, and export.

See [PDFCut-Studio/docs/QUICK_START.md](PDFCut-Studio/docs/QUICK_START.md) for bilingual instructions.

## Output Modes

| Mode | Description | Best For |
| --- | --- | --- |
| Secure crop: visible area only | Physically removes content outside the crop while keeping visible text selectable | Preventing cropped-away content from being copied, searched, or exposed |
| Fast crop: PDF boundary box only | Sets PDF page boundary boxes only; cropped-away content may still exist internally | Fast reading layout adjustments where hidden content is not sensitive |

## Repository Layout

```text
PDFCut-Studio/                     Portable application package
PDFCut-Studio/app/                 WPF launcher
PDFCut-Studio/docs/                User and release documents
PDFCut-Studio/lib/                 Built application JAR
PDFCut-Studio/runtime/             Bundled Java runtime
source-Briss-2.0/                  Modified Java source based on Briss 2.0
LICENSE.txt                        GPLv3 license
NOTICE.md                          Attribution and modification notice
THIRD_PARTY_NOTICES.md             Third-party notices
RELEASE_NOTES.md                   Release notes
```

## Build From Source

JDK 11 to 19 is recommended. Run:

```powershell
cd source-Briss-2.0
.\gradlew.bat shadowJar test
```

Then copy the generated shadow jar to:

```text
PDFCut-Studio/lib/Briss-2.0-all.jar
```

## License And Attribution

PDFCut Studio is a modified derivative of Briss 2.0 and is distributed under the **GNU General Public License v3.0**. See [LICENSE.txt](LICENSE.txt) for the full license text.

Upstream project:

- Briss 2.0: https://github.com/mbaeuerle/Briss-2.0
- License: GPL-3.0

The Briss 2.0 README states that Briss 2.0 is based on Briss 0.9 from SourceForge and developed independently by the Briss 2.0 maintainers. PDFCut Studio is not an official Briss release and is not endorsed by the original Briss authors or maintainers.

When distributing binary releases, provide the corresponding source code, license text, third-party notices, and modification notices to comply with GPLv3 and the relevant dependency licenses.
