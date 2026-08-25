# Web API

AIUI 旨在为 AI + AR 开发者提供一套符合现代 Web 标准的开发体验。AIUI 的底层运行时深度支持 Web 标准，以提升代码复用性和互操作性。

## WinterCG 兼容性

AIUI 积极拥护并主要支持 **WinterCG (Web-interoperable Runtimes Community Group)** 提出的：

- **[Minimum Common Web API](https://min-common-api.proposal.wintertc.org/)**

这意味着开发者可以在 AIUI 中使用诸如 `fetch`、`URL`、`TextEncoder/Decoder`、`Web Crypto` 等通用的 Web API，使得大量的 npm 包和现有的 Web 代码可以无缝运行在 AI + AR 环境中。

## 能力分布

为了让开发者按使用场景更快找到文档，Web 标准能力不再集中挂在一个子目录下，而是并入各自更贴近业务的分类中：

- **[画布](/AIUI/api/canvas)**：查看 Canvas 2D 绘图接口与图像处理能力。
- **[多媒体](/AIUI/api/media)**：查看 `Web Audio API` 在 AIUI 中的音频能力入口。
- **[AI](/AIUI/api/ai)**：查看 Web Speech 相关能力与 AI 语音能力的关系。
- **[设备](/AIUI/api/device)**：查看 `BarcodeDetector` 等感知类能力。
- **[网络](/AIUI/api/network)**：查看 `fetch`、`URL` 等通用 Web 网络能力。
- **[编码](/AIUI/api/encoding)**：查看 `TextEncoder`、`TextDecoder` 等文本编码与解码能力。
- **[加密](/AIUI/api/crypto)**：查看 `crypto`、`SubtleCrypto` 等 Web Crypto 能力。
- **[数据存储](/AIUI/api/storage)**：查看 `localStorage` 与 OPFS 本地持久化能力。
- **[控制台](/AIUI/api/console)**：查看标准调试输出接口。
- **[性能](/AIUI/api/performance)**：查看运行性能监控能力。

## 推荐阅读

- **[URL](/AIUI/api/network-url)**：URL 构造、解析与查询参数处理。
- **[Encoding](/AIUI/api/encoding)**：文本编码与解码。
- **[Crypto](/AIUI/api/crypto)**：Web Crypto 能力。
- **[Storage API](/AIUI/api/storage-api)**：本地存储详细接口。
- **[Audio](/AIUI/api/media-audio)**：Web 标准音频接口。
- **[BarcodeDetector](/AIUI/api/device-barcode)**：条码检测接口。

## 核心设计理念

AIUI 的 Web API 实现遵循以下原则：

1. **标准优先**：尽可能遵循 WHATWG 和 W3C 标准。
2. **空间化适配**：在保持 API 签名的同时，自动处理 3D 空间中的坐标转换和深度信息。
3. **高性能**：所有底层实现均经过 C++ 优化，确保在穿戴设备上低延迟运行。
