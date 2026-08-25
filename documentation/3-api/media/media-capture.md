# 媒体采集

AIUI 提供 `navigator.mediaDevices`、`ImageCapture` 与 `MediaRecorder`，用于获取摄像头或麦克风媒体流、拍摄静态图像以及录制音视频。

## 获取摄像头和麦克风媒体流

媒体采集必须在有效用户交互中发起，并且宿主窗口需要处于焦点状态：

```javascript
const stream = await navigator.mediaDevices.getUserMedia({
  audio: true,
  video: {
    width: { ideal: 1280 },
    height: { ideal: 720 },
  },
});

console.log(stream.getAudioTracks(), stream.getVideoTracks());
```

使用完毕后，应停止所有轨道以释放设备：

```javascript
for (const track of stream.getTracks()) {
  track.stop();
}
```

## 拍摄照片

拍摄照片时可以使用 Web `ImageCapture`，也可以使用 `wx.media` 提供的兼容接口：

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const stream = await navigator.mediaDevices.getUserMedia({ video: true });
const [videoTrack] = stream.getVideoTracks();
const capture = new ImageCapture(videoTrack);

const photo = await capture.takePhoto({
  quality: 'high',
  mode: 'default',
  enableSystemPreview: true,
});

console.log(photo.type, photo.size);
videoTrack.stop();
```

**wx**

```javascript api-style=wx
const camera = wx.media.createCameraContext();
if (!camera) throw new Error('当前环境不支持相机');

const photo = await camera.takePhoto({
  quality: 'high',
  mode: 'default',
  enableSystemPreview: true,
});

console.log(photo.mimeType, photo.data.byteLength);
```

<!-- /aiui-api-style -->

Web 写法中的 `ImageCapture` 需要一个视频轨道。`takePhoto()` 返回编码后的 `Blob`，`grabFrame()` 可用于获取内存中的 `ImageBitmap`。使用完毕后应停止视频轨道。

## 录制音频

录制音频时，两种 API 风格都会持续交付可处理的数据分片：

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
const recorder = new MediaRecorder(stream, {
  mimeType: 'audio/ogg;codecs=opus',
});

recorder.addEventListener('dataavailable', async (event) => {
  const chunk = await event.data.arrayBuffer();
  console.log(chunk.byteLength);
});

recorder.start(250);
// 完成后调用 recorder.stop()。
```

**wx**

```javascript api-style=wx
const recorder = wx.media.getRecorderManager();
if (!recorder) throw new Error('当前环境不支持录音');

recorder.onHeader((format, headerBuffer) => {
  console.log(format, headerBuffer.byteLength);
});
recorder.onFrameRecorded(({ frameBuffer }) => {
  console.log(frameBuffer.byteLength);
});

await recorder.start({
  sampleRate: 16000,
  numberOfChannels: 1,
  format: 'opus',
  frameSize: 250,
});
```

<!-- /aiui-api-style -->

## 权限与当前限制

- `getUserMedia()` 与 `MediaRecorder.start()` 必须在有效用户交互中调用，且宿主窗口必须处于焦点状态。
- `app.config.lifetime === 'cut'` 时，媒体采集不可用。
- Agent Manifest 必须声明对应的摄像头或麦克风权限；拒绝权限时 Promise 会拒绝。
- `MediaRecorder` 当前识别 `audio/wav`、`audio/ogg;codecs=opus`、`video/webm;codecs=vp8,opus` 与 `video/mp4`。
- 约束是请求值，实际设备与宿主可以返回不同但兼容的设置；使用 `track.getSettings()` 读取最终结果。

## API Reference

### `navigator.mediaDevices`

| 方法 | 返回值 | 说明 |
| --- | --- | --- |
| `getUserMedia(constraints)` | `Promise<MediaStream>` | 请求音频或视频媒体流。 |
| `enumerateDevices()` | `Promise<MediaDeviceInfo[]>` | 枚举可用的音频输入与视频输入设备。 |
| `getSupportedConstraints()` | `MediaTrackSupportedConstraints` | 返回运行时识别的约束字段。 |

`constraints.audio` 与 `constraints.video` 可以是 `boolean` 或约束对象。当前约束字段包括 `deviceId`、`sampleRate`、`channelCount`、`echoCancellation`、`facingMode`、`width`、`height` 与 `frameRate`。

### `MediaStream`

| 成员 | 类型 | 说明 |
| --- | --- | --- |
| `id` | `string` | 媒体流标识。 |
| `active` | `boolean` | 是否仍包含活动轨道。 |
| `getTracks()` | `MediaStreamTrack[]` | 返回所有轨道。 |
| `getAudioTracks()` | `MediaStreamTrack[]` | 返回音频轨道。 |
| `getVideoTracks()` | `MediaStreamTrack[]` | 返回视频轨道。 |
| `getTrackById(id)` | `MediaStreamTrack \| null` | 按标识查找轨道。 |

### `MediaStreamTrack`

公开属性包括 `id`、`kind`、`label`、`enabled`、`muted` 与 `readyState`。`getConstraints()` 返回请求约束，`getSettings()` 返回最终设置，`stop()` 结束轨道。

### `new ImageCapture(videoTrack)`

| 方法 | 返回值 | 说明 |
| --- | --- | --- |
| `takePhoto(settings?)` | `Promise<Blob>` | 拍摄编码后的图像；设置支持 `quality`、`mode` 与 `enableSystemPreview`。 |
| `grabFrame()` | `Promise<ImageBitmap>` | 获取当前视频帧的内存位图。 |

### `new MediaRecorder(stream, options?)`

`options.mimeType` 用于指定输出格式；省略时默认使用 `audio/wav`。不支持的格式会抛出 `TypeError`。

| 成员 | 类型 | 说明 |
| --- | --- | --- |
| `state` | `'inactive' \| 'recording' \| 'paused'` | 当前录制状态。 |
| `mimeType` | `string` | 当前输出 MIME type。 |
| `start(timeslice?)` | `void` | 开始录制；`timeslice` 控制数据分片间隔，单位为毫秒。 |
| `pause()` / `resume()` | `void` | 暂停或恢复录制。 |
| `requestData()` | `void` | 请求立即输出当前数据分片。 |
| `stop()` | `void` | 停止录制并完成输出。 |
| `MediaRecorder.isTypeSupported(type)` | `boolean` | 检查 MIME type 是否受支持。 |

`dataavailable` 事件的 `event.data` 为 `Blob`。录制器还会分发 `start`、`pause`、`resume`、`stop` 与 `error` 事件。

### wx APIs

#### `wx.media.createCameraContext()`

返回 `CameraContext | undefined`。wasm32 目标、`app.config.lifetime === 'cut'`、没有当前应用实例或宿主未提供相机能力时返回 `undefined`。

#### `CameraContext.takePhoto(options)`

必须在有效用户交互中调用，且宿主窗口需要处于焦点状态。返回 `Promise<{ data: ArrayBuffer, mimeType: string }>`。

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `options.quality` | `'high' \| 'normal' \| 'low'` | 是 | 图像质量。 |
| `options.mode` | `'default' \| 'wide' \| 'telephoto'` | 否 | 由宿主映射到具体镜头或能力的语义化拍摄模式。 |
| `options.enableSystemPreview` | `boolean` | 否 | 是否先显示系统相机预览，默认是 `true`。 |

#### `wx.media.getRecorderManager()`

返回 `RecorderManager | undefined`。wasm32 目标、`app.config.lifetime === 'cut'`、没有当前应用实例或宿主未提供录音能力时返回 `undefined`。

#### `RecorderManager`

`start(options)`、`pause()`、`resume()` 与 `stop()` 均返回 `Promise<void>`。`start()` 与 `resume()` 要求宿主窗口处于焦点状态。

| `start()` 参数 | 类型 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| `options.sampleRate` | `number` | 否 | `16000` | 请求的采样率。 |
| `options.numberOfChannels` | `number` | 否 | `1` | 请求的声道数。 |
| `options.format` | `'pcm' \| 'opus'` | 否 | `'pcm'` | 请求的编码格式。 |
| `options.frameSize` | `number` | 否 | `250` | 音频帧回调间隔，单位为毫秒；仅正数生效。 |

| 事件注册方法 | 回调参数 |
| --- | --- |
| `onStart()`、`onPause()`、`onResume()` | 无 |
| `onStop()` | `{ tempFilePath: '', duration: number, fileSize: number }` |
| `onFrameRecorded()` | `{ frameBuffer: ArrayBuffer, isLastFrame: false }` |
| `onHeader()` | `(format: 'opus', headerBuffer: ArrayBuffer)` |
| `onError()` | `{ errMsg: string }` |
| `onInterruptionBegin()`、`onInterruptionEnd()` | 无 |

PCM 模式下，帧回调返回去除 WAV 容器头的原始 PCM 分片。Opus 模式会先通过 `onHeader()` 返回初始化 header，再通过 `onFrameRecorded()` 交付有效载荷。当前不会生成临时文件。
