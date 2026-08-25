# v0.17.0

AIUI 0.17.0 brings richer agent surfaces, media capabilities, persistent file storage, and improved rendering diagnostics. This release is especially useful for agents that combine wearable interaction, streaming content, and native host capabilities.

## Framework
- **Host Messaging**: Added `postMessage` support between App/Page and the host, enabling agents to exchange structured messages with their embedding application.

  ```js
  export default {
    onLoad() {
      this.postMessage({
        type: 'open-settings',
        source: 'focus-agent',
      });
    },
  };
  ```

- **Expanded Component Composition**: Added named slots and expanded component composition capabilities for more flexible built-in and custom component layouts.
- **Persistent Storage with OPFS**: Added OPFS support and reorganized storage APIs, including browser-compatible file and writable stream interfaces for persistent agent data.

  ```js
  const root = await navigator.storage.getDirectory();
  const file = await root.getFileHandle('session.json', { create: true });
  const writer = await file.createWritable();
  await writer.write(JSON.stringify({ completed: true }));
  await writer.close();
  ```

- **Improved XML Parsing**: Improved XML parsing, including entity decoding in attributes and text, and preserved logical operators when decoding XML entities.

## Components
- **video**: Added the `<video>` component with playback controls and wireframe rendering support.
- **table**: Added the native `<table>` component for rendering structured results.
- **streamdown**: Officially supported `<streamdown>` rendering. The currently supported Markdown syntax includes:
  - Paragraphs
  - Headings
  - Blockquotes
  - Ordered and unordered lists
  - Bold and italic text
  - Code snippets
  - Formulas
- **timed-text**: Added the `<timed-text>` component for synchronized speech transcripts and generated TTS audio experiences.
- **Markdown Primitives**: Added the `<p>`, `<header>`, `<blockquote>`, `<list>`, `<list-item>`, `<b>`, `<i>`, `<snippet>`, and `<formula>` components for paragraphs, headings, quotes, lists, list entries, bold text, italic text, code snippets, and formulas.
- **Map Traces and Layouts**: Added GPX overlay support to the `<map>` component for displaying location traces and route data, together with named slots for richer custom layouts.

  ```xml
  <view class="briefing">
    <video id="briefing" src="{{videoUrl}}" controls />
    <timed-text text="{{transcript}}" active-index="{{activeWord}}" />
  </view>
  ```

## API
- **Media Capture and Recording**: Added media capture and recording APIs, including photo capture, audio/video recording, Opus output, header callbacks, and semantic capture modes.

  ```js
  const media = await navigator.mediaDevices.getUserMedia({
    audio: true,
    video: true,
  });
  const recorder = new MediaRecorder(media, { mimeType: 'audio/opus' });
  recorder.start();
  ```

- **Video Playback**: Added video playback support, including wireframe rendering and improved native video rendering performance.

  ```js
  const video = wx.createVideoContext('briefing');
  video.play();
  ```

- **Battery Status**: Added full W3C Battery Status API support.
- **Head Gesture Events**: Added built-in head gesture events and state tracking for hands-free interactions such as nod, shake, and gesture state changes.

  ```js
  export default {
    onLoad() {
      this.enableWorldAwareness();
    },
    onHeadGesture(event) {
      if (event.gesture === 'nod') this.confirm();
    },
  };
  ```

## Performance and Compatibility
- **Improved Rendering Diagnostics**: Added paint-only dirty tracking and Canvas performance metrics, together with render-path benchmarks to help diagnose rendering costs.
- **AIX Runtime Version Checks**: Added runtime-version checks for AIX engine compatibility so incompatible agent bundles fail with clearer version information.
- **Audio Improvements**: Improved audio path resolution and media playback behavior, including MP3 support and preferred audio format hints.

# v0.16.0

## Framework
- **Page-Level Environment Awareness**: Introduced page-level environment awareness as the foundation for motion-aware and host-driven experiences. Pages can explicitly opt in with `enableWorldAwareness()` and receive higher-level interaction signals without wiring low-level device state by hand.

  ```js
  export default {
    onLoad() {
      this.enableWorldAwareness();
    },
    onOrientationStabilityChange(event) {
      if (event.stable) {
        console.log('imu is stable');
      }
    },
  };
  ```

## API
- **End-to-End Streaming Responses**: Added end-to-end streaming response support so agents can start rendering or reacting before a full payload finishes, which is especially useful for remote briefings, progressive text output, and other streaming UX patterns.

  ```js
  const response = await fetch(streamUrl);
  const reader = response.body.getReader();
  ```

- **Response Body Consumption Semantics**: Improved response body consumption behavior around pending reads and body locking, making incremental reads from `response.body` more predictable.
- **Web API Compatibility Improvements**: Improved compatibility across `fetch`, `Headers`, `ReadableStream`, and `TextDecoder`, reducing the gap between AIUI agents and browser-style networking code.
- **TextDecoder Streaming Mode**: Added `{ stream: true }` support to `TextDecoder` for incremental UTF-8 decoding across chunk boundaries, allowing agents to reconstruct streamed text without garbled intermediate output.

  ```js
  const decoder = new TextDecoder();
  const text = decoder.decode(chunk, { stream: true });
  ```

## Built-in Components and Examples
- **Audio Asset Path Resolution**: Improved audio asset path resolution, including leading-slash paths such as `/assets/foo.wav`, so packaged media can be referenced more naturally from agent code.

  ```js
  import { AudioPlayer } from 'audio';
  
  const player = new AudioPlayer('/assets/meditation-white-noise.wav');
  ```

- **Refreshed Audio Example**: Refreshed the built-in audio example to better demonstrate local playback flows, short cues, and looping ambience with packaged assets.
- **Environment Awareness Sample Pages**: Added dedicated [head gesture sample](../../samples/capabilities/pages/head-gesture/index.ink) and [orientation stability sample](../../samples/capabilities/pages/orientation-stability-change/index.ink) pages so developers can quickly validate environment awareness flows and see how sensor-driven state is surfaced in UI.
- **Richer Streaming HTTPS Example**: Added a more complete [streaming HTTPS sample page](../../samples/capabilities/pages/network_https/index.ink) that demonstrates remote content loading, streamed text assembly with `TextDecoder({ stream: true })`, and compatibility checks in one place.

# v0.15.0

## Routing and Networking
- **Duplicate Navigation Protection**: Fixed the issue where `wx.navigateTo` could still trigger a duplicate navigation when the target URL matched the current page.
- **Request Default Value Fixes**: Corrected the default parameter behavior of `wx.request`, with `responseType` defaulting to `text` and `dataType` defaulting to `json`.

## Components and Ecosystem
- **Custom Component Support**: Added support for developing and using custom components, improving component encapsulation and reuse.
- **Third-Party Package Integration**: Added support for importing third-party packages, improving project extensibility and ecosystem compatibility.

## Device and Perception
- **Absolute Orientation Sensor**: Added support for the absolute orientation sensor, enabling access to real-world device orientation information.

# v0.14.0

## Layout and Styling
- **Text and Flex Layout Improvements**: Expanded layout support with full `line-height` handling for both `px` values and unitless numbers, and added support for the `flex` property.
- **Background and Clipping Enhancements**: Added support for CSS `background` images and gradients, along with `clip-path`, `mask-image`, and `mask-mode`.

## Tooling and Runtime
- **TypeScript Workflow Support**: Improved TypeScript support across single-file components, pages, and module-based projects.
- **Locale and Region Awareness**: `navigator` now exposes `region` (Overseas or Mainland China) and `language` for runtime localization and regional adaptation.
- **Frame Scheduling Support**: Added `requestAnimationFrame` to take advantage of the highest available frame rate on the device.

## Media and Performance
- **Controllable Photo Preview**: `takePhoto` now allows disabling the system preview with `enableSystemPreview=false`.
- **Rendering and Audio Optimizations**: Improved performance for `canvas drawImage` and `Sound` playback to reduce overhead in graphics and audio scenarios.

## Stability Fixes
- **Storage Persistence Fix**: Fixed the issue where `localStorage` could still be used after a package version update.

# v0.1.1

## Runtime APIs
- **Device Serial Number**: Added `navigator.getDeviceSerialNumber()` to obtain the device SN.
- **Device Identification Info**: Added `navigator.userAgent` to return device and version information.
- **Streaming Audio Playback**: `AudioPlayer` now supports Opus streaming playback, allowing Ogg-container Opus audio streams to be appended by explicitly declaring `format: 'ogg_opus'`.

## UI Rendering
- **Fixed Positioning**: CSS now supports `position: fixed` for floating and fixed-layout scenarios.

## Components and Charts
- **scroll-view**: Fixed component rendering issues and improved display stability for scroll containers.
- **chart**: Fixed several issues in chart components and improved rendering and usability.

# v0.1.0

## Cross-Platform Runtime
- **Multi-Platform Support**: Supports loading and running across Android / iOS / macOS / Web environments, ensuring cross-platform consistency.

## AI Capabilities
- **Voice Interaction**: Supports ASR speech recognition and TTS voice playback.
- **Intelligent Conversation**: Supports LLM model invocation with contextual memory for multi-turn conversations.

## Device and Perception
- **Device Capabilities**: Supports Bluetooth connectivity and Barcode scanning.
- **IMU Perception**: Supports real-time data collection from accelerometers and gyroscopes, as well as posture change sensing.

## Business Components
- **calendar, card**: Added calendar and card business components to enhance scenario presentation capabilities.

## UI Rendering
- **Custom Fonts**: Supports importing and applying custom fonts through CSS for more personalized UI presentation.

## Multimedia Capabilities
- **Sound**: Designed specifically for sound effect playback with low-latency audio feedback.

## Scene Interaction
- **Navigation Mechanism**: Supports entry and switching logic for card-style pages.
- **Exit Mechanism**: Supports system-level interactions such as double-click exit and out-of-bounds exit.
- **Resource Loading**: Supports importing static resources such as images and audio (`Sound`) via ESM, ensuring correct path resolution.

# v0.0.0 (Internal Beta)

## Core Framework
- **Lifecycle Management**: Fully covers the lifecycle from initialization and rendering to destruction.
- **Application Model**: Supports App / Page-level loading and page navigation mechanisms.
- **Module Registration**: Fully supports ES Module and `export default` registration mechanisms.
- **.ink Components**: Supports running single-file components (SFC) with a complete component lifecycle.

## UI Rendering and Layout
- **Rendering Performance**: Provides high-performance rendering based on Skia.
- **Layout Capabilities**: Integrates the Taffy layout engine and provides comprehensive Flexbox layout support.
- **Style Animations**: Supports Transform, basic style properties, and animation effects.

## Component Library
- **Basic Components**: Provides basic rendering components such as view, text, and button.
- **Graphic Components**: Supports image, canvas, and simple chart components (including line charts and area charts).
    - *Known issue: PNG image animations are not yet effective on the Glasses side.*

## Runtime APIs
- **Network Communication**: Supports fetch, WebSocket, and SSE (Server-Sent Events).
- **Data Storage**: Supports localStorage and `wx.storage` storage APIs.
- **Multimedia Capabilities**: Integrates permission management and invocation for Recorder recording and Camera features.

## Development Tools and Engineering
- **.aix Packaging**: Supports project packaging, building, distribution, and loading.
- **Debugging and Editing**: Provides full-chain development tools including online debugging, code editing, and build export.

## Version Notes
- Initial internal beta release of AIUI.
- Established the foundational framework architecture and component specifications.
- Completed the initial integration of core runtime APIs.
