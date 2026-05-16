# Scanner WebP 解码性能优化设计

## 背景

当前 `samples/scanner` 的扫码热路径是：

1. `takePhoto()` 返回 WebP 编码字节
2. `decodeWebP()` 将 WebP 解码为 RGBA
3. 页面侧再把 RGBA 转成灰度
4. 调用 `BarcodeDetector.detect({ data, width, height })`

当前实现能工作，但对扫码场景来说存在几处明显的延迟热点：

- `decodeWebP()` 会把 `Uint8Array` 转成 `Array`
- `VP8X` 归一化会重新组装 WebP 数据
- `rawArgb.slice(...)` 会复制整块像素数据
- `argbToRgba()` 会再做一次整图遍历和复制
- 页面侧 `rgbaToGray()` 又会做一次整图遍历

对于眼镜端单次扫码，这些额外拷贝和遍历会直接增加“按键到结果”的等待时间。

## 目标

- 以降低单次扫码延迟为第一优先级
- 不改变当前扫码交互和页面结构
- 不更换当前纯 JS WebP 解码路线
- 尽量减少整图级别的数据拷贝和重复遍历

## 非目标

- 不重写 WebP 解码器
- 不迁移到底层 Rust 或 wasm
- 不引入复杂缓存策略
- 不为了省内存而牺牲首帧延迟

## 选定方案

采用“解码层直接支持灰度输出 + 减少中间缓冲复制”的方案：

- `decodeWebP()` 新增输出模式参数
- 扫码场景直接请求灰度输出
- 页面不再执行 `rgbaToGray()`
- 同时减少解码阶段不必要的像素复制

推荐接口：

- `decodeWebP(data, { output: 'gray' | 'rgba' })`

默认可保持 `rgba`，扫码页显式传 `gray`。

## 关键优化点

### 1. 把灰度输出前移到 `webp.js`

当前链路是：

- `ARGB -> RGBA -> Gray`

优化后改成：

- `ARGB -> Gray`

这样可以直接省掉：

- 一次完整的 RGBA 重排
- 一次页面侧灰度遍历
- 一份 `Uint8Array(width * height * 4)` 的中间结果

### 2. 避免 `slice()` 复制整块像素

当前实现：

- `rawArgb.slice(0, expectedLength)`

应改为优先基于原缓冲创建视图，而不是复制出一个新数组。

### 3. 保留 `VP8X` 归一化，但避免额外无意义工作

只在输入确实是 `VP8X` 时进入重组路径：

- `VP8`
- `VP8L`

这两类简单路径继续直接走原始输入，不做额外包装。

### 4. 页面侧改为直接消费灰度输出

当前页面：

- `decodeWebP(photo.data)` 得到 `rgba`
- `rgbaToGray(...)`

优化后页面：

- `decodeWebP(photo.data, { output: 'gray' })`

这样页面逻辑更薄，也减少一次 JS 层热循环。

## 接口变化

`decodeWebP()` 返回值调整为按输出模式变化：

- `output = 'rgba'`
  - 返回 `{ width, height, rgba }`
- `output = 'gray'`
  - 返回 `{ width, height, gray }`

约束：

- `gray.length === width * height`
- `rgba.length === width * height * 4`

## 错误处理

本次优化不改变错误语义：

- 容器无效仍报容器错误
- bitstream 失败仍报解码错误
- 动画 WebP 仍明确不支持

只调整内部热路径，不改变页面对错误的展示方式。

## 影响范围

本次预期只影响：

- `samples/scanner/lib/webp.js`
- `samples/scanner/pages/camera/index.ink`

## 验证点

- 扫码页仍能正确识别当前设备拍照产生的 WebP
- `decodeWebP(..., { output: 'gray' })` 输出长度正确
- 页面不再保留 `rgbaToGray()` 这段转换
- 标准公开样本的 `rgba` 输出不回归
- `VP8X` 降级路径不回归

## 成功标准

- 单次扫码路径中的整图遍历次数减少
- 单次扫码路径中的大块中间缓冲分配减少
- 用户主观等待时间缩短，至少不回归
