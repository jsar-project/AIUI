# Web API

AIUI is designed to provide AI + AR developers with a development experience aligned with modern Web standards. Its underlying runtime provides deep Web standards support to improve code reuse and interoperability.

## WinterCG Compatibility

AIUI actively embraces and primarily supports the following proposal from **WinterCG (Web-interoperable Runtimes Community Group)**:

- **[Minimum Common Web API](https://min-common-api.proposal.wintertc.org/)**

This means developers can use common Web APIs such as `fetch`, `URL`, `TextEncoder/Decoder`, and `Web Crypto` in AIUI, allowing a large number of npm packages and existing Web codebases to run seamlessly in an AI + AR environment.

## Capability Distribution

To help developers find documentation faster by usage scenario, Web-standard capabilities are no longer grouped under a single subdirectory. Instead, they are organized into categories that are closer to actual business needs:

- **[Canvas](/AIUI/api/canvas)**: See Canvas 2D drawing APIs and image-processing capabilities.
- **[Media](/AIUI/api/media)**: See the `Web Audio API` entry point in AIUI.
- **[AI](/AIUI/api/ai)**: See the relationship between Web Speech capabilities and AI speech capabilities.
- **[Device](/AIUI/api/device)**: See perception-related capabilities such as `BarcodeDetector`.
- **[Network](/AIUI/api/network)**: See common Web networking capabilities such as `fetch` and `URL`.
- **[Encoding](/AIUI/api/encoding)**: See text encoding and decoding capabilities such as `TextEncoder` and `TextDecoder`.
- **[Crypto](/AIUI/api/crypto)**: See Web Crypto capabilities such as `crypto` and `SubtleCrypto`.
- **[Storage](/AIUI/api/storage)**: See local persistence through `localStorage` and OPFS.
- **[Console](/AIUI/api/console)**: See standard debugging output APIs.
- **[Performance](/AIUI/api/performance)**: See runtime performance monitoring capabilities.

## Recommended Reading

- **[URL](/AIUI/api/network-url)**: URL construction, parsing, and query parameter handling.
- **[Encoding](/AIUI/api/encoding)**: Text encoding and decoding.
- **[Crypto](/AIUI/api/crypto)**: Web Crypto capabilities.
- **[Storage API](/AIUI/api/storage-api)**: Detailed local storage APIs.
- **[Audio](/AIUI/api/media-audio)**: Web-standard audio APIs.
- **[BarcodeDetector](/AIUI/api/device-barcode)**: Barcode detection API.

## Core Design Principles

AIUI's Web API implementation follows these principles:

1. **Standards first**: Follow WHATWG and W3C standards whenever possible.
2. **Spatial adaptation**: Keep API signatures intact while automatically handling coordinate transforms and depth information in 3D space.
3. **High performance**: All underlying implementations are optimized in C++ to ensure low-latency execution on wearable devices.
