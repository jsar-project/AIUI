# Scanner WebP 解码器设计

## 背景

当前 `samples/scanner/pages/camera/index.ink` 的扫码链路是：

- `takePhoto()` 获取拍照结果
- 解析图片尺寸
- 调用 `BarcodeDetector.detect({ data, width, height })`

当前已确认的问题：

- 相机返回的 `mimeType` 为 `webp`
- 当前页面只实现了 PNG/JPEG 尺寸解析
- 更关键的是，`BarcodeDetector.detect()` 当前需要的是灰度像素数据，而不是编码后的图片文件字节

因此，仅补尺寸解析并不能让扫码真正工作。需要在 JavaScript 侧增加一个 WebP 解码器，把拍照返回的 WebP 数据解成像素缓冲，再转成扫码可用的灰度数据。

## 目标

- 在 JavaScript 侧提供一个可复用的 WebP 解码模块
- 支持通用 WebP 静态图片解码，而不是只为当前设备写特殊分支
- 为扫码页输出稳定的像素数据接口
- 让扫码页可以把 WebP 拍照结果转成 `BarcodeDetector.detect()` 可用的灰度输入
- 在失败时提供清晰可调试的错误信息

## 非目标

- 不修改当前底层 `BarcodeDetector` 的 Rust 接口
- 不修改相机 API 返回值结构
- 不实现动画 WebP 解码
- 不实现图片显示级别的高级后处理能力
- 不为了第一版支持所有元数据块的完整语义

## 选定方案

采用“独立 JS WebP 解码模块 + 页面侧灰度转换”的方案：

- 新增一个独立模块，例如 `samples/scanner/lib/webp.js`
- 对页面暴露统一接口：
  - `decodeWebP(arrayBuffer) -> { width, height, rgba }`
- 页面拿到 RGBA 后，再把它转换成灰度数据
- 页面最终调用：
  - `BarcodeDetector.detect({ data: gray, width, height })`

选择这个方案的原因：

- 解码逻辑与页面 UI 解耦
- 扫码页只依赖稳定接口，便于后续替换实现
- WebP 解码器后续可被其他 sample 或页面复用
- 页面层只保留扫码链路，不承担 WebP bitstream 解析细节

## 模块边界

建议新增模块：

- `samples/scanner/lib/webp.js`

模块职责：

- 校验 WebP 容器头
- 识别 WebP 子格式
- 解码为像素数据
- 返回统一的尺寸与 RGBA 缓冲

模块不负责：

- UI 展示
- 扫码逻辑
- 结果渲染
- 图片预览生成

## 对外接口

建议暴露：

- `decodeWebP(arrayBuffer)`

返回值形态：

- `width`
- `height`
- `rgba`

约束：

- `width` 和 `height` 为正整数
- `rgba` 为 `Uint8Array`
- `rgba.length === width * height * 4`

错误约定：

- 输入不是合法 WebP 容器时抛明确错误
- 子格式不支持时抛明确错误
- bitstream 解析失败时抛明确错误
- 解码结果尺寸非法或像素长度不匹配时抛明确错误

## 支持范围

第一版按“通用静态 WebP”设计，至少覆盖：

- `VP8 `：有损 WebP
- `VP8L`：无损 WebP
- `VP8X`：扩展容器

对 `VP8X` 的处理要求：

- 正确解析容器级尺寸信息
- 能分派到实际图像数据块
- 支持带 alpha 的静态图片

第一版明确不支持：

- 动画 WebP
- 多帧播放
- 元数据块的完整业务语义

对元数据块的处理建议：

- 可以识别但忽略 `ICCP`、`EXIF`、`XMP`
- 不应因为这些块存在就解码失败

## 扫码接入链路

扫码页中的链路调整为：

1. `takePhoto()` 获取 `{ data, mimeType }`
2. 如果 `mimeType` 为 `webp`，调用 `decodeWebP(photo.data)`
3. 将解码得到的 RGBA 转为灰度缓冲
4. 调用：
   - `BarcodeDetector.detect({ data: gray, width, height })`
5. 继续沿用现有扫码结果展示逻辑

建议新增一个页面侧工具函数：

- `rgbaToGray(rgba, width, height)`

职责：

- 输入 RGBA 像素缓冲
- 输出长度为 `width * height` 的灰度 `Uint8Array`

不建议把灰度转换塞进 WebP 解码器内部，原因是：

- WebP 解码器应保持通用
- 灰度转换是扫码场景特有需求
- 以后若有图片展示或像素分析用途，仍需要原始 RGBA

## 错误处理

### 解码器错误

模块内部应区分以下错误：

- 非 WebP 容器
- 不支持的 WebP 子格式
- 容器结构损坏
- bitstream 解码失败
- 输出像素缓冲非法

错误消息应包含足够上下文，例如：

- `Invalid WebP container.`
- `Unsupported WebP chunk type.`
- `Failed to decode VP8L payload.`
- `Decoded WebP pixel buffer is invalid.`

### 页面层错误

页面接住解码错误后，建议统一显示：

- `Failed to decode WebP photo for barcode scanning.`

并保留调试信息：

- `mimeType`
- `byteLength`
- `headerHex`
- 可能的话增加：
  - `webpChunkType`
  - `decodeStage`

## 测试策略

至少准备以下静态样本：

- 一个 `VP8 ` 样本
- 一个 `VP8L` 样本
- 一个 `VP8X` 样本

每组样本验证：

- 能拿到正确 `width`
- 能拿到正确 `height`
- `rgba.length === width * height * 4`
- 转成灰度后可传入 `BarcodeDetector.detect()`

失败样本至少包括：

- 非 WebP 数据
- 截断 WebP 数据
- WebP 容器存在但子块不支持的数据

若仓库不适合放完整图片资源，可采用：

- 最小二进制 fixture
- base64 或 hex fixture

## 实现策略建议

虽然目标是“通用 WebP 解码器”，但不建议完全从零手写整个格式栈后再接入页面。

建议策略：

- 对外接口和模块边界按自研模块来设计
- 内部实现允许参考、裁剪或移植现成的 JavaScript WebP 解码逻辑
- 保留最小接口面，避免页面层依赖具体实现细节

这样做的好处：

- 页面代码稳定
- 如果后续替换解码实现，页面无需大改
- 可以在“先跑通扫码”和“保持通用性”之间取得平衡

## 验证点

- WebP 拍照结果能成功解码出 `width`、`height`、`rgba`
- RGBA 转灰度后能成功喂给 `BarcodeDetector.detect()`
- 扫码成功时，页面继续显示图片和识别结果
- 解码失败时，页面给出明确错误且保留调试卡片
- 不同 WebP 子格式不会互相误判
- 非 WebP 输入能快速失败且错误信息明确

## 影响范围

本次设计预期影响：

- `samples/scanner/pages/camera/index.ink`
- `samples/scanner/lib/webp.js`

如果实现过程中发现必须改动底层 Rust 接口，应另起一个设计，不与本方案混改。
