# 音频播放器 (AudioPlayer)

提供底层音频播放的核心能力，支持常规音频播放与流式播放。

> **为什么不使用 AudioContext？**
> AudioContext 主要用于处理和合成 PCM 原始音频数据。虽然它也可以播放音乐，但由于其处理逻辑通常在软件层面完成，会失去调用硬件解码（Hard Decoded）的能力，从而增加系统功耗并降低性能。
>
> 因此，作为 Web 开发中 `HTMLAudioElement` 的替代方案，`AudioPlayer` 是在 AIUI 中播放音频的最佳选择，它能充分利用硬件加速来保证播放的流畅性与能效比。

## 文件播放

如果你要播放一个完整的音频文件，优先使用文件播放模式。这种方式更适合背景音乐、完整语音内容或已经落盘的本地音频资源。

- 使用 `src` 设置本地路径或网络 URL。
- 本地路径既可以是相对路径，也可以是相对于项目根目录解析的绝对路径，例如 `/assets/intro.ogg`。
- 如果是本地 `.ogg` 文件，可直接设置到 `src`。
- 如果你已经拿到了完整的二进制数据，也可以通过 `setBuffer(data, hint)` 一次性设置，其中本地 `.ogg` 数据可传入 `hint = "ogg"`。

### 示例：通过 `src` 播放文件

```javascript
const player = new AudioPlayer();

player.src = '/assets/intro.ogg';
player.autoplay = false;
player.onCanplay(() => {
  player.play();
});
player.onEnded(() => {
  console.info('playback finished');
});
```

### 示例：通过 `setBuffer()` 播放本地 Ogg 文件数据

```javascript
import introOgg from '../assets/intro.ogg';

const player = new AudioPlayer();
const bytes = new Uint8Array(await introOgg.arrayBuffer());

player.setBuffer(bytes, 'ogg');
player.play();
```

## 流式播放

如果你的音频数据是边生成边下发的，例如实时 TTS、分段解码或服务端推流，使用流式播放模式。

- 流式播放需要在构造函数中传入 `options`，并显式声明 `format`。
- 如需追加 PCM 数据，请设置 `format: 'pcm'`。
- 如需播放 Ogg 容器封装的 Opus 流，请设置 `format: 'ogg_opus'`。
- 数据分段通过 `append()` 追加，流结束后调用 `finish()`。

### 示例：流式追加 PCM 数据

```javascript
const player = new AudioPlayer({
  format: 'pcm',
});

player.play();

for await (const chunk of pcmChunks) {
  player.append(chunk);
}

player.finish();
```

### 示例：流式追加 Ogg/Opus 数据

```javascript
const player = new AudioPlayer({
  format: 'ogg_opus',
});

player.play();

for await (const chunk of oggOpusChunks) {
  player.append(chunk);
}

player.finish();
```

## API Reference

### 构造函数

```javascript
new AudioPlayer(options)
```

- `options`: 可选配置对象，会透传到底层音频运行时，可包含 `audio_setting` 等参数。
- 只有传入 `options` 时才会启用流式模式。
- 流式播放时必须显式声明 `options.format`，当前文档明确支持 `pcm` 和 `ogg_opus`。

### 支持的格式

`AudioPlayer` 当前文档明确支持以下几类格式/输入路径：

- `format: 'pcm'`：用于 `append()` 追加原始 PCM 音频块。
- `format: 'ogg_opus'`：用于 `append()` 追加 Ogg 容器封装的 Opus 音频流。
- `hint: 'ogg'`：用于 `setBuffer()` 指定本地 `.ogg` 资源的格式提示。
- 本地 `.ogg` 文件：可通过 `src` 或 `setBuffer()` 播放本地 Ogg/Opus 资源。

#### 流式格式说明

- `append()` 仅文档化支持 `pcm` 和 `ogg_opus` 两种流式输入格式。
- 当使用 `format: 'ogg_opus'` 时，首次追加的数据必须包含标准 Ogg 头，例如 `OpusHead` 和 `OpusTags`，以便运行时先完成解码器初始化。
- 流式播放必须显式声明 `format`；不要依赖隐式默认值。

### 属性

#### `src`
- **类型**: `String`
- **说明**: 音频资源的 URL 或路径。支持本地路径和网络 URL；本地路径既支持相对路径，也支持相对于项目根目录解析的绝对路径，例如 `/assets/music.mp3`。文档中额外明确支持本地 `.ogg` 资源路径。
- **示例**: `player.src = "/assets/music.mp3";`

#### `startTime`
- **类型**: `Number`
- **说明**: 开始播放的时间位置（单位：秒）。默认从 0 开始。

#### `autoplay`
- **类型**: `Boolean`
- **说明**: 是否在设置 `src` 后自动开始播放。默认值为 `false`。

#### `loop`
- **类型**: `Boolean`
- **说明**: 是否循环播放当前音频。默认值为 `false`。

#### `volume`
- **类型**: `Number`
- **说明**: 播放音量大小，范围为 `0.0` (静音) 到 `1.0` (最大音量)。

#### `duration`
- **类型**: `Number` (只读)
- **说明**: 音频的总时长（单位：秒）。在元数据加载完成前，该值为 `0`。

#### `sampleRate`
- **类型**: `Number` (只读)
- **说明**: 音频的采样率（如 44100）。

#### `channels`
- **类型**: `Number` (只读)
- **说明**: 音频的声道数。

#### `currentTime`
- **类型**: `Number`
- **说明**: 当前播放的时间位置（单位：秒）。设置该值会使播放器跳转到指定位置。

#### `paused`
- **类型**: `Boolean` (只读)
- **说明**: 当前播放器是否处于暂停状态。

#### `buffered`
- **类型**: `Number` (只读)
- **说明**: 已缓冲的音频时长（单位：秒）。

### 方法

#### `play()`
- **说明**: 开始播放音频。如果音频处于暂停状态，则从当前位置继续播放。

#### `pause()`
- **说明**: 暂停当前音频播放。

#### `stop()`
- **说明**: 停止播放并将播放位置重置为初始状态。

#### `append(buffer)`
- **参数**: `buffer` (`ArrayBuffer` | `TypedArray`)
- **说明**: 向播放器追加流式音频数据。当前文档明确支持原始 PCM 数据和 Ogg/Opus 字节流。

#### `finish()`
- **说明**: 标记流式音频数据追加结束。调用后，播放器将在播放完剩余缓存数据后进入 `ended` 状态。

#### `seek(position)`
- **参数**: `position` (`Number`) - 目标位置（秒）
- **说明**: 跳转到音频的指定时间点进行播放。

#### `setBuffer(data, hint)`
- **参数**: 
  - `data` (`ArrayBuffer` | `TypedArray`) - 完整的音频数据。
  - `hint` (`String`, 可选) - 格式提示；本地 `.ogg` 资源可传入 `"ogg"`。
- **说明**: 直接设置播放器的音频数据缓冲区。当前文档额外明确支持通过 `hint = "ogg"` 播放本地 Ogg/Opus 数据。

#### `destroy()`
- **说明**: 销毁播放器实例，释放底层解码器和相关硬件资源。调用后该实例将不再可用。

### 事件监听

AudioPlayer 提供了一系列监听方法来响应播放状态的变化：

#### 播放状态事件
- **`onCanplay(callback)`**: 当音频数据加载到足以开始播放时触发。
- **`onPlay(callback)`**: 当调用 `play()` 方法或 `autoplay` 生效开始播放时触发。
- **`onPause(callback)`**: 当调用 `pause()` 方法暂停播放时触发。
- **`onStop(callback)`**: 当调用 `stop()` 方法停止播放时触发。
- **`onEnded(callback)`**: 当音频播放到末尾时触发。

#### 进度与交互事件
- **`onTimeUpdate(callback)`**: 播放位置发生变化时连续触发（通常每秒多次）。
- **`onSeeking(callback)`**: 当开始执行跳转（seek）操作时触发。
- **`onSeeked(callback)`**: 当跳转（seek）操作完成且音频准备好继续播放时触发。

#### 异常与缓冲事件
- **`onError(callback)`**: 当播放过程中发生解码错误、网络错误或资源不存在时触发。
- **`onWaiting(callback)`**: 当网络加载速度赶不上播放速度，导致播放暂停进入缓冲状态时触发。

#### 移除监听
- 每个 `onXxx` 方法都对应一个 `offXxx([callback])` 方法，用于移除特定的回调或清空所有监听器。
- **示例**: `player.offPlay(myPlayCallback);` 或 `player.offPlay();` (移除所有 play 监听)
