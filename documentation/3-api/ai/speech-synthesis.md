# 语音播报

语音播报用于把文本内容转换成语音输出，适合欢迎语、回复播报、导航提示、状态提醒等场景。

在 AIUI 中，语音播报通常用在结果输出阶段：当大语言模型或业务逻辑已经得到文本结果后，再由播报能力把它读给用户听。

## 播报一段文本

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const utterance = new SpeechSynthesisUtterance('欢迎使用 AIUI');
speechSynthesis.speak(utterance, 'enqueue');
```

**wx**

```javascript api-style=wx
wx.speech.playTTS('欢迎使用 AIUI');
```

<!-- /aiui-api-style -->

## 生成音频与同步字幕

如果需要把生成与播放分开，使用 `synthesize()` 创建任务，再交给 `SpeechAudioPlayer` 播放：

```javascript
const utterance = new SpeechSynthesisUtterance('欢迎使用 AIUI');
const task = await speechSynthesis.synthesize(utterance, {
  subtitles: 'word',
  audio: { preferredFormat: 'mp3' },
});

console.log('actual format:', task.audioConfig.format);

const player = new SpeechAudioPlayer(task);
player.textTrack.addEventListener('cuechange', () => {
  const cue = player.textTrack.activeCues.item(0);
  console.log(cue?.text ?? '');
});
player.play();
```

`preferredFormat` 只是偏好提示，实际格式始终以 `task.audioConfig.format` 为准。

## 使用建议

- 把要播报的文本控制在适合一次听清的长度内，避免整段长文本直接朗读。
- 对于连续多条回复，建议在业务层控制播报节奏，避免用户同时收到过多语音输出。
- 对重要提示和普通提示使用不同的文案长度与语气。

## 当前能力范围

- [x] 通过 `speechSynthesis.speak()` 发起播报，并支持通过 `mode` 控制排队或立即播放。
- [x] 通过 `speechSynthesis.synthesize()` 生成音频分片与字幕 cue，并使用 `SpeechAudioPlayer` 播放。
- [ ] `SpeechSynthesisUtterance` 上的 `lang`、`pitch`、`rate`、`volume`、`voice` 等参数（当前暂未生效）。
- [ ] `cancel()`、`pause()`、`resume()`、`getVoices()` 以及完整的 utterance 生命周期事件（当前未暴露）。

## 继续阅读

- **[语音识别](/AIUI/api/ai-speech-recognition)**：查看如何把用户语音转换成文本。
- **[大语言模型](/AIUI/api/ai-language-model)**：查看如何生成可播报的回复内容。

## API Reference

### 入口

语音播报基于全局 `speechSynthesis` 对象和 `SpeechSynthesisUtterance`：

```javascript
const utterance = new SpeechSynthesisUtterance('欢迎使用 AIUI');
speechSynthesis.speak(utterance);
speechSynthesis.speak(utterance, 'enqueue');
speechSynthesis.speak(utterance, 'immediate');
```

`SpeechSynthesisUtterance` 也可通过内置 `speech` 模块使用。

### 方法

#### `speechSynthesis.speak(utterance, mode?)`

`speak()` 会把当前 `utterance` 的状态转发给宿主运行时执行播报。

- `utterance`：`SpeechSynthesisUtterance` 实例，当前主要使用其中的文本内容发起播报。
- `mode`：可选的播报模式，支持以下取值：
  - `'enqueue'`：把当前播报请求追加到播放队列中。
  - `'immediate'`：请求宿主立即播放当前播报。

如果省略 `mode`，默认按 `'enqueue'` 处理，也就是尽量不打断当前正在进行的播报，最终行为仍以宿主实现为准。

#### `speechSynthesis.synthesize(utterance, options?)`

创建流式语音生成任务，但不会自动开始播放。返回 `Promise<SpeechSynthesisTask>`。

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `utterance` | `SpeechSynthesisUtterance` | 是 | 要合成的语音请求。 |
| `options.subtitles` | `'none' \| 'sentence' \| 'word'` | 否 | 字幕 cue 的粒度。 |
| `options.audio.preferredFormat` | `'pcm' \| 'mp3' \| 'ogg_opus'` | 否 | 目标音频格式偏好。 |
| `options.audio.sampleRate` | `number` | 否 | 期望采样率。 |
| `options.audio.channels` | `1 \| 2` | 否 | 期望声道数。 |
| `options.audio.bitrate` | `number` | 否 | 期望比特率。 |
| `options.signal` | `AbortSignal` | 否 | 用于取消生成任务。 |

### `SpeechSynthesisTask`

| 成员 | 类型 | 说明 |
| --- | --- | --- |
| `id` | `string` | 任务标识。 |
| `state` | `'running' \| 'completed' \| 'aborted' \| 'errored'` | 当前任务状态。 |
| `audioConfig` | `SpeechSynthesisAudioConfig` | 宿主实际返回的格式、采样率、声道、采样格式与 MIME type。 |
| `language` | `string` | 实际语言。 |
| `granularity` | `'none' \| 'sentence' \| 'word'` | 实际字幕粒度。 |
| `finished` | `Promise<{ duration: number }>` | 任务结束后解析。 |
| `abort()` | `void` | 中止生成任务。 |

任务会分发 `chunk`、`end`、`error` 与 `abort` 事件，也可以使用对应的 `onchunk`、`onend`、`onerror` 与 `onabort` 属性。`chunk` 事件包含 `audio: Uint8Array` 和 `cues: readonly SpeechSynthesisCue[]`。

### `new SpeechAudioPlayer(task, options?)`

创建一个消费 `SpeechSynthesisTask` 的播放器。`options.trackMode` 可设为 `'hidden'` 或 `'showing'`。

| 成员 | 类型 | 说明 |
| --- | --- | --- |
| `audioPlayer` | `AudioPlayer` | 底层音频播放器。 |
| `textTrack` | `TextTrack` | 根据生成 cue 更新的字幕轨道。 |
| `activeCue` | `VTTCue \| null` | 当前激活字幕。 |
| `currentTime` / `duration` | `number` | 当前播放时间与时长。 |
| `paused` | `boolean` | 当前是否暂停。 |
| `play()` / `pause()` / `stop()` | `void` | 控制播放状态。 |
| `seek(position)` | `void` | 跳转到指定秒数。 |
| `destroy()` | `void` | 释放播放器资源。 |
