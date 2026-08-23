# Recorder

The recorder API is provided by the current app's native recorder manager:

```javascript
const recorderManager = wx.media.getRecorderManager();
```

It returns `undefined` on wasm32, in an app with `lifetime: 'cut'`, without a current app instance, or when the app has no recorder manager.

## Record an Audio Clip

```javascript
const recorderManager = wx.media.getRecorderManager();
if (!recorderManager) return;

recorderManager.onFrameRecorded(({ frameBuffer }) => {
  // Process an audio frame provided by the native recorder backend.
});
recorderManager.onError(({ errMsg }) => console.error(errMsg));

await recorderManager.start({ sampleRate: 16000, numberOfChannels: 1, format: 'pcm' });
```

## Continue Reading

- **[WeChat Mini Program Compatible APIs](/AIUI/api/weixin-compatible-apis)**: See the compatibility API list.

## API Reference

### Methods

#### `start(options)`

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `options.sampleRate` | `number` | No | `16000` | Requested sample rate. |
| `options.numberOfChannels` | `number` | No | `1` | Requested channel count. |
| `options.format` | `string` | No | `pcm` | Requested encoding format. |

**Returns:** `Promise<void>`. It must be called from a valid user interaction while the host window is focused. Final audio parameters and supported formats vary by host platform.

#### `pause()` / `resume()` / `stop()`

These methods take no parameters and return `Promise<void>`. The Promise rejects if the native recorder backend rejects the state operation; `resume()` also requires a focused host window.

### Events

Each `on*` method sets one callback for its event; setting it again replaces the previous callback.

| Method | Parameters | Callback arguments |
| --- | --- | --- |
| `onStart(callback)`, `onPause(callback)`, `onResume(callback)` | `callback: Function` | None |
| `onStop(callback)` | `callback: Function` | `{ tempFilePath: string }` |
| `onFrameRecorded(callback)` | `callback: Function` | `{ frameBuffer: ArrayBuffer }` |
| `onHeader(callback)` | `callback: Function` | `(format: string, buffer: ArrayBuffer)` |
| `onError(callback)` | `callback: Function` | `{ errMsg: string }` |
| `onInterruptionBegin(callback)`, `onInterruptionEnd(callback)` | `callback: Function` | None |
