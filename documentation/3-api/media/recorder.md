# 录音

录音接口通过当前应用的原生录音管理器提供：

```javascript
const recorderManager = wx.media.getRecorderManager();
```

wasm32 目标、`lifetime: 'cut'` 应用、没有当前应用实例，或应用未配置录音管理器时，该方法返回 `undefined`。

## 录制一段音频

```javascript
const recorderManager = wx.media.getRecorderManager();
if (!recorderManager) return;

recorderManager.onFrameRecorded(({ frameBuffer }) => {
  // 处理原生录音后端提供的音频帧。
});
recorderManager.onError(({ errMsg }) => console.error(errMsg));

await recorderManager.start({ sampleRate: 16000, numberOfChannels: 1, format: 'pcm' });
```

## 继续阅读

- **[微信小程序兼容 API](/AIUI/api/weixin-compatible-apis)**：查看兼容接口列表。

## API Reference

### 方法

#### `start(options)`

| 参数 | 类型 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| `options.sampleRate` | `number` | 否 | `16000` | 请求的采样率。 |
| `options.numberOfChannels` | `number` | 否 | `1` | 请求的声道数。 |
| `options.format` | `string` | 否 | `pcm` | 请求的编码格式。 |

**返回值：** `Promise<void>`。必须在有效用户交互中调用，且宿主窗口必须处于焦点状态。不同宿主平台最终支持的格式和实际音频参数可能不同。

#### `pause()` / `resume()` / `stop()`

均无参数，返回 `Promise<void>`。底层录音后端拒绝对应状态操作时，Promise 会拒绝；`resume()` 还要求宿主窗口具有焦点。

### 事件

每个 `on*` 方法为对应事件设置一个回调；再次设置会替换前一个回调。

| 方法 | 参数 | 回调参数 |
| --- | --- | --- |
| `onStart(callback)`、`onPause(callback)`、`onResume(callback)` | `callback: Function` | 无 |
| `onStop(callback)` | `callback: Function` | `{ tempFilePath: string }` |
| `onFrameRecorded(callback)` | `callback: Function` | `{ frameBuffer: ArrayBuffer }` |
| `onHeader(callback)` | `callback: Function` | `(format: string, buffer: ArrayBuffer)` |
| `onError(callback)` | `callback: Function` | `{ errMsg: string }` |
| `onInterruptionBegin(callback)`、`onInterruptionEnd(callback)` | `callback: Function` | 无 |
