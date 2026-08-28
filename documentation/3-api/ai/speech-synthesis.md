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

## 选择音色播报

`speechSynthesis.speak()` 和 `speechSynthesis.synthesize()` 都使用 `SpeechSynthesisUtterance` 作为语音合成请求，各属性的支持情况见下方 API Reference。通过 `voice` 设置音色 ID，再将同一个 `utterance` 传给需要的方法：

```javascript
const utterance = new SpeechSynthesisUtterance('欢迎使用 AIUI');
utterance.voice = 'female-tianmei';

speechSynthesis.speak(utterance, 'enqueue');

// 或者生成流式音频与字幕
const task = await speechSynthesis.synthesize(utterance, {
  subtitles: 'word',
});
```

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
- [x] `SpeechSynthesisUtterance` 上的属性同时用于 `speak()` 和 `synthesize()`。
- [x] `pitch` 支持 `-12.0` 到 `12.0`；`rate` 对应语音生成速度，支持 `0.5` 到 `2.0`；`volume` 支持 `0.0` 到 `1.0`。
- [ ] `lang` 当前不支持，设置后不会改变语音生成的语言。
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

### `SpeechSynthesisUtterance`

`SpeechSynthesisUtterance` 是一个可修改的语音合成请求对象。`speechSynthesis.speak()` 和 `speechSynthesis.synthesize()` 都接收该对象，并对当前支持的属性采用相同的处理方式。

#### `new SpeechSynthesisUtterance(text?)`

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `text` | `string` | 否 | 初始播报文本，默认为空字符串。 |

#### 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `text` | `string` | `''` | 要合成的文本。 |
| `lang` | `string` | `'en-US'` | 语音生成语言，当前不支持。 |
| `pitch` | `number` | `1.0` | 音高，取值范围为 `-12.0` 到 `12.0`。 |
| `rate` | `number` | `1.0` | 转换为语音生成速度，取值范围为 `0.5` 到 `2.0`。 |
| `voice` | `string \| null` | `null` | 要使用的音色 ID；为 `null` 时使用默认音色。 |
| `volume` | `number` | `1.0` | 音量，取值范围为 `0.0` 到 `1.0`。 |

#### `voice` 可用音色

| Voice ID | 类型 | 用途 |
| --- | --- | --- |
| `female-tianmei` | 中文甜美女声 | `tts_streaming` 中文短文本 |
| `English_radiant_girl` | 英文活力女声 | `tts_streaming` 英文短文本 |
| `English_expressive_narrator` | 英文叙事声 | `tts_streaming` 英文长文本 |
| `male-qn-qingse` | 中文青年男声 | Ink 当前默认音色、通用对话 |
| `male-qn-jingying` | 中文成熟男声 | 商务、助手播报 |
| `female-yujie` | 中文成熟御姐 | 品牌介绍、内容解说 |
| `Chinese (Mandarin)_News_Anchor` | 中文新闻女声 | 新闻和信息播报 |
| `Chinese (Mandarin)_Radio_Host` | 中文电台男声 | 长文本和故事 |
| `clever_boy` | 中文男童 | 儿童内容 |
| `lovely_girl` | 中文女童 | 儿童内容 |
| `Cantonese_ProfessionalHost（F)` | 粤语女主持 | 粤语场景 |
| `English_Trustworthy_Man` | 英文可信男声 | 英文助手、商务内容 |

### 方法

#### `speechSynthesis.speak(utterance, mode?)`

`speak()` 使用当前 `utterance` 的属性执行播报。

- `utterance`：`SpeechSynthesisUtterance` 实例，当前主要使用其中的文本内容发起播报。
- `mode`：可选的播报模式，支持以下取值：
  - `'enqueue'`：把当前播报请求追加到播放队列中。
  - `'immediate'`：立即播放当前播报。

如果省略 `mode`，默认按 `'enqueue'` 处理，也就是把当前播报请求追加到播放队列中。

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
| `audioConfig` | `SpeechSynthesisAudioConfig` | 实际生成的格式、采样率、声道、采样格式与 MIME type。 |
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
