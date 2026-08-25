# Media Capture

AIUI provides `navigator.mediaDevices`, `ImageCapture`, and `MediaRecorder` for camera or microphone streams, still-image capture, and audio/video recording.

## Acquire Camera and Microphone Streams

Media capture must begin during a valid user interaction while the host window is focused:

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

Stop every track after use to release its device:

```javascript
for (const track of stream.getTracks()) {
  track.stop();
}
```

## Capture a Photo

To capture a photo, use either the Web `ImageCapture` API or the compatible API provided by `wx.media`:

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
if (!camera) throw new Error('Camera is unavailable');

const photo = await camera.takePhoto({
  quality: 'high',
  mode: 'default',
  enableSystemPreview: true,
});

console.log(photo.mimeType, photo.data.byteLength);
```

<!-- /aiui-api-style -->

The Web `ImageCapture` API requires a video track. `takePhoto()` returns an encoded `Blob`, while `grabFrame()` can capture an in-memory `ImageBitmap`. Stop the video track after use.

## Record Audio

Both API styles continuously deliver data chunks that the application can process:

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
// Call recorder.stop() when recording is complete.
```

**wx**

```javascript api-style=wx
const recorder = wx.media.getRecorderManager();
if (!recorder) throw new Error('Recorder is unavailable');

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

## Permissions and Current Limits

- `getUserMedia()` and `MediaRecorder.start()` must run during a valid user interaction while the host window is focused.
- Media capture is unavailable when `app.config.lifetime === 'cut'`.
- The Agent Manifest must declare the corresponding camera or microphone permission; permission denial rejects the Promise.
- `MediaRecorder` currently recognizes `audio/wav`, `audio/ogg;codecs=opus`, `video/webm;codecs=vp8,opus`, and `video/mp4`.
- Constraints are requests. A device or host may return different compatible settings; read the final result with `track.getSettings()`.

## API Reference

### `navigator.mediaDevices`

| Method | Return Value | Description |
| --- | --- | --- |
| `getUserMedia(constraints)` | `Promise<MediaStream>` | Requests an audio or video media stream. |
| `enumerateDevices()` | `Promise<MediaDeviceInfo[]>` | Enumerates available audio-input and video-input devices. |
| `getSupportedConstraints()` | `MediaTrackSupportedConstraints` | Returns constraint fields recognized by the runtime. |

`constraints.audio` and `constraints.video` can be booleans or constraint objects. Current fields include `deviceId`, `sampleRate`, `channelCount`, `echoCancellation`, `facingMode`, `width`, `height`, and `frameRate`.

### `MediaStream`

| Member | Type | Description |
| --- | --- | --- |
| `id` | `string` | Media stream identifier. |
| `active` | `boolean` | Whether the stream still contains active tracks. |
| `getTracks()` | `MediaStreamTrack[]` | Returns all tracks. |
| `getAudioTracks()` | `MediaStreamTrack[]` | Returns audio tracks. |
| `getVideoTracks()` | `MediaStreamTrack[]` | Returns video tracks. |
| `getTrackById(id)` | `MediaStreamTrack \| null` | Finds a track by identifier. |

### `MediaStreamTrack`

Public properties include `id`, `kind`, `label`, `enabled`, `muted`, and `readyState`. `getConstraints()` returns requested constraints, `getSettings()` returns final settings, and `stop()` ends the track.

### `new ImageCapture(videoTrack)`

| Method | Return Value | Description |
| --- | --- | --- |
| `takePhoto(settings?)` | `Promise<Blob>` | Captures an encoded image; settings support `quality`, `mode`, and `enableSystemPreview`. |
| `grabFrame()` | `Promise<ImageBitmap>` | Captures the current video frame as an in-memory bitmap. |

### `new MediaRecorder(stream, options?)`

`options.mimeType` selects the output format. It defaults to `audio/wav`; an unsupported value throws a `TypeError`.

| Member | Type | Description |
| --- | --- | --- |
| `state` | `'inactive' \| 'recording' \| 'paused'` | Current recording state. |
| `mimeType` | `string` | Current output MIME type. |
| `start(timeslice?)` | `void` | Starts recording; `timeslice` controls the data interval in milliseconds. |
| `pause()` / `resume()` | `void` | Pauses or resumes recording. |
| `requestData()` | `void` | Requests the current data chunk immediately. |
| `stop()` | `void` | Stops recording and finalizes output. |
| `MediaRecorder.isTypeSupported(type)` | `boolean` | Checks whether a MIME type is supported. |

The `dataavailable` event exposes a `Blob` as `event.data`. The recorder also dispatches `start`, `pause`, `resume`, `stop`, and `error` events.

### wx APIs

#### `wx.media.createCameraContext()`

Returns `CameraContext | undefined`. It returns `undefined` on wasm32, when `app.config.lifetime === 'cut'`, when no current app exists, or when the host provides no camera capability.

#### `CameraContext.takePhoto(options)`

Must run during a valid user interaction while the host window is focused. Returns `Promise<{ data: ArrayBuffer, mimeType: string }>`.

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `options.quality` | `'high' \| 'normal' \| 'low'` | Yes | Image quality. |
| `options.mode` | `'default' \| 'wide' \| 'telephoto'` | No | Semantic capture mode mapped by the host to a device lens or capability. |
| `options.enableSystemPreview` | `boolean` | No | Whether to show the system camera preview first. Defaults to `true`. |

#### `wx.media.getRecorderManager()`

Returns `RecorderManager | undefined`. It returns `undefined` on wasm32, when `app.config.lifetime === 'cut'`, when no current app exists, or when the host provides no recorder capability.

#### `RecorderManager`

`start(options)`, `pause()`, `resume()`, and `stop()` all return `Promise<void>`. `start()` and `resume()` require the host window to be focused.

| `start()` Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `options.sampleRate` | `number` | No | `16000` | Requested sample rate. |
| `options.numberOfChannels` | `number` | No | `1` | Requested channel count. |
| `options.format` | `'pcm' \| 'opus'` | No | `'pcm'` | Requested encoding format. |
| `options.frameSize` | `number` | No | `250` | Audio-frame callback interval in milliseconds; only positive values apply. |

| Event Registration Method | Callback Data |
| --- | --- |
| `onStart()`, `onPause()`, `onResume()` | None |
| `onStop()` | `{ tempFilePath: '', duration: number, fileSize: number }` |
| `onFrameRecorded()` | `{ frameBuffer: ArrayBuffer, isLastFrame: false }` |
| `onHeader()` | `(format: 'opus', headerBuffer: ArrayBuffer)` |
| `onError()` | `{ errMsg: string }` |
| `onInterruptionBegin()`, `onInterruptionEnd()` | None |

In PCM mode, frame callbacks return raw PCM chunks with the WAV container header removed. Opus mode delivers its initialization header through `onHeader()` before payload chunks arrive through `onFrameRecorded()`. No temporary file is currently generated.
