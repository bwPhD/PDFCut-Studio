# PDFCut Studio 快速上手 / Quick Start

版本 / Version: 1.0.0

PDFCut Studio 是一个便携式 PDF 可视化裁剪工具。双击 `PDFCut Studio.vbs` 即可启动，内置 Java 运行时，不需要提前安装 Java。

PDFCut Studio is a portable visual PDF cropping tool. Double-click `PDFCut Studio.vbs` to launch it. A Java runtime is bundled.

## 中文使用说明

1. 将 PDF 拖入启动窗口，或点击“选择 PDF”。
2. 点击“打开可视化裁剪”。可视化窗口会直接载入当前 PDF，不需要再次导入。
3. 用鼠标拖动或绘制保留矩形。矩形内是保留区域，矩形外会被裁掉。
4. 如果只想用某一页的裁剪范围统一处理整本 PDF，在可视化窗口里选中该页的裁剪框后，点击 `Apply this crop to all pages`。
5. “裁剪输出逻辑”默认使用“安全裁剪：只输出可见区域”。它会保留裁剪区内的原始可复制文字，并物理移除裁剪区外的内容。
6. 如果需要旧版高速模式，可以切换到“快速裁剪：仅设置 PDF 边界框”。这种方式速度快，但裁剪区外的内容仍可能被复制或搜索到。
7. 点击 `Preview` 预览，点击 `Export cropped PDF` 输出最终 PDF。

## English Quick Start

1. Drop a PDF into the launcher, or click **Choose PDF**.
2. Click **Open Visual Crop**. The selected PDF opens directly in the crop workspace.
3. Draw or adjust the rectangle with your mouse. The rectangle is the visible area to keep.
4. To crop every page with one page's rectangle, select that rectangle and click `Apply this crop to all pages`.
5. The default output logic is **Secure crop: visible area only**. It keeps selectable text inside the crop and removes content outside the crop.
6. Use **Fast crop: PDF boundary box only** only when you want the legacy high-speed behavior.
7. Click `Preview`, then `Export cropped PDF`.

## Output

Automatic crop writes files to the `output` folder with the suffix `_PDFCut.pdf`.
