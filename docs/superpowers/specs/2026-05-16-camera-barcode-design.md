# Camera 页面扫码页设计

## 背景

当前 `samples/native/pages/camera/index.ink` 是一个最小相机示例，已支持：

- 相机预览
- 拍照
- 将最近一次拍照结果展示为图片预览

目标是将该页面直接改造成一个单用途扫码页：用户按 `Enter` 后拍照并扫码，再把图片和识别结果展示出来。

## 目标

- 将当前页面从相机示例改成单用途扫码页
- 使用 `onKeyDown` 监听 `Enter` 触发扫码
- 扫码流程采用“拍照后识别”
- 扫码成功后同时保留照片预览和识别结果
- 未识别到条码时给出明确的非报错提示
- 出错时给出清晰错误信息，并尽量保留已拍到的照片
- 再次按 `Enter` 时直接开始下一次扫码，并覆盖旧图和旧结果

## 非目标

- 不实现实时连续扫码
- 不实现识别结果自动跳转、自动打开链接或自动路由
- 不保留独立的拍照演示按钮
- 不修改现有 `BarcodeDetector` 或相机 API 文档约定

## 选定方案

采用“单用途扫码页 + Enter 触发”方案：

- 页面不再保留 `Take Photo` 按钮
- 页面默认展示相机预览和操作提示
- 用户按 `Enter` 后触发一次完整的“拍照 -> 预览 -> 识别 -> 展示结果”流程
- 再次按 `Enter` 时直接覆盖旧图和旧结果

选择这个方案的原因：

- 页面定位更清晰，直接就是扫码页
- 与设备按键交互更贴合
- 操作路径更短，用户只需按 `Enter`
- 重复扫码行为简单直接，适合 sample

## 页面结构

页面继续保持三段式结构：

1. 顶部说明区
2. 中部相机预览区
3. 底部结果区

具体调整如下：

- 标题改成扫码页语义，例如 `Barcode Scanner`
- 在标题区展示操作提示，例如 `Press Enter to scan`
- 继续保留 `Latest Photo` 卡片
- 在照片卡片下新增 `Scan Result` 卡片
- `Scan Result` 卡片只在执行过扫码流程后显示

## 数据模型

页面 `data` 增加以下字段：

- `isScanning`: 布尔值，用于阻止重入
- `scanResults`: 数组，元素只保留 `format` 和 `rawValue`
- `scanMessage`: 字符串，用于显示“识别到 N 个结果”或“未识别到条码”

页面 `data` 继续保留以下字段：

- `status`
- `errorMessage`
- `photoUrl`

状态值扩展为：

- `READY`
- `SCANNING`
- `SCANNED`
- `NO_RESULT`
- `ERROR`

## 方法设计

新增：

- 一个内部公共拍照方法，用于统一处理相机上下文初始化、拍照、预览地址生成和照片对象返回
- `scanBarcode()`
- `onKeyDown(event)`

职责划分：

- `onKeyDown(event)` 负责筛选 `Enter` 并调用 `scanBarcode()`
- `scanBarcode()` 负责整条扫码链路
- 公共拍照方法只负责拍照和生成可展示图片

页面生命周期要求：

- 页面显示时注册按键监听
- 页面隐藏或销毁时移除按键监听，避免重复注册

## 交互流程

### 页面初始状态

- `status = 'READY'`
- `isScanning = false`
- 页面显示相机预览和操作提示

### `onKeyDown`

1. 监听页面按键事件
2. 当按键不是 `Enter` 时忽略
3. 当 `isScanning = true` 时忽略
4. 当按键是 `Enter` 且当前不在扫码中时，触发 `scanBarcode()`

### `scanBarcode()`

1. 设置 `status = 'SCANNING'`
2. 设置 `isScanning = true`
3. 清空旧的 `errorMessage`
4. 清空旧的 `scanResults` 和 `scanMessage`
5. 调用公共拍照方法并更新 `photoUrl`
6. 创建 `BarcodeDetector`
7. 调用 `detect(...)`
8. 根据返回结果更新页面
9. 在结束阶段统一恢复 `isScanning = false`

结果分支：

- 有识别结果：
  - `status = 'SCANNED'`
  - 保留 `photoUrl`
  - 写入 `scanResults`
  - 写入类似“识别到 N 个结果”的 `scanMessage`
- 无识别结果：
  - `status = 'NO_RESULT'`
  - 保留 `photoUrl`
  - `scanResults = []`
  - `scanMessage = 'No barcode detected.'`
- 发生异常：
  - `status = 'ERROR'`
  - 写入 `errorMessage`
  - 若已得到可预览照片，则继续保留

重复扫码规则：

- 再次按 `Enter` 时，直接开始新的扫码流程
- 新图片覆盖旧图片
- 新结果覆盖旧结果

## 结果展示

`Scan Result` 卡片展示：

- 一行概述文案，例如“识别到 2 个结果”或“未识别到条码”
- 一个结果列表

每个结果项展示：

- `format`
- `rawValue`

第一版不做以下增强：

- 复制按钮
- 自动跳转
- 对 URL、Wi-Fi、文本等不同内容做类型化渲染

## 错误处理

统一面向页面显示的错误信息：

- 相机不可用：`Camera is unavailable.`
- 拍照失败：`Failed to capture photo.`
- 无法完成扫码：`Failed to scan barcode.`

无结果不是错误：

- 使用 `NO_RESULT` 状态
- 不写入 `errorMessage`
- 通过 `scanMessage` 告知用户没有识别到条码

重入保护规则：

- 当一次扫码尚未完成时，后续 `Enter` 按键不触发新流程
- 这样可以避免并发拍照或并发识别

## 实现前置校验

当前已确认的拍照结果字段只有：

- `data`
- `mimeType`

当前已确认的 `BarcodeDetector.detect()` 输入要求包含：

- `data`
- `width`
- `height`

因此实现时必须先验证拍照结果是否能提供 `width` 和 `height`，或是否存在当前页面可直接使用的等效尺寸信息。

明确约束如下：

- 如果能拿到合法尺寸，则直接完成扫码实现
- 如果拿不到合法尺寸，不应伪造尺寸
- 如果拿不到合法尺寸，页面应显示明确的“不支持当前扫码输入”的错误信息，并保留拍照预览

## 验证点

- 页面打开后能正常显示相机预览
- 按 `Enter` 能触发一次扫码
- 连续快速按 `Enter` 不会造成并发扫码
- 识别成功时，结果卡片正确显示 `format` 与 `rawValue`
- 无识别结果时，显示空结果提示而不是错误
- 再次按 `Enter` 时，新结果和新图片覆盖旧内容
- 扫码失败后再次尝试，页面仍可恢复正常
- 页面离开后不会残留按键监听

## 影响范围

本次设计预期只影响：

- `samples/native/pages/camera/index.ink`

如实现阶段发现需要补充额外能力，应先确认是否超出 sample 范围，再决定是否扩展。
