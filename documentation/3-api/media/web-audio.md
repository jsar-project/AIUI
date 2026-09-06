# 音频处理（Web Audio）

音频处理适合需要实时生成、采集或改变声音的场景。AIUI 通过 Web Audio API 支持生成声音、处理 PCM 音频、接入麦克风、调整音量、添加滤波器，以及读取波形或频率数据。

如果只是播放 MP3、Ogg 等完整音频文件，优先使用[音频播放](/AIUI/api/media-audio-player)，通常更省电，也更容易使用。

## 生成一段提示音

```javascript
const context = new AudioContext();
await context.resume();

const oscillator = context.createOscillator();
oscillator.frequency.value = 440;
oscillator.connect(context.destination);
oscillator.start();
oscillator.stop(context.currentTime + 0.2);
```

`AudioContext` 创建后初始状态可能是 `suspended`，开始播放前调用 `resume()`。

## 调整音量和音色

把音频节点按处理顺序连接起来：

```javascript
const context = new AudioContext();
await context.resume();

const oscillator = context.createOscillator();
const filter = context.createBiquadFilter();
const gain = context.createGain();

filter.type = 'lowpass';
filter.frequency.value = 1200;
gain.gain.value = 0.25;

oscillator.connect(filter);
filter.connect(gain);
gain.connect(context.destination);

oscillator.start();
oscillator.stop(context.currentTime + 0.5);
```

`connect()` 决定声音依次经过哪些处理节点。上面的声音先经过低通滤波器，再降低音量，最后输出。

## 播放 PCM 数据

```javascript
const context = new AudioContext({ sampleRate: 16000 });
const buffer = context.createBuffer(1, pcmSamples.length, 16000);
buffer.copyToChannel(pcmSamples, 0);

const source = context.createBufferSource();
source.buffer = buffer;
source.connect(context.destination);

await context.resume();
source.start();
```

`pcmSamples` 是 `Float32Array`，每个采样值通常位于 `-1` 到 `1` 之间。

## 读取波形和频率数据

```javascript
const analyser = context.createAnalyser();
analyser.fftSize = 2048;
source.connect(analyser);
analyser.connect(context.destination);

const waveform = new Uint8Array(analyser.fftSize);
analyser.getByteTimeDomainData(waveform);

const spectrum = new Uint8Array(analyser.frequencyBinCount);
analyser.getByteFrequencyData(spectrum);
```

不再使用时调用 `context.close()` 释放音频资源。

## 分析麦克风输入

可以把 `getUserMedia()` 获取的麦克风媒体流接入 Web Audio，例如显示音量动画、绘制实时波形，或根据声音控制界面。

先在 `app.json` 中声明录音权限：

```json
{
  "permissions": ["RECORD_AUDIO"]
}
```

下面的页面示例在用户点击按钮后开始计算麦克风音量，并在页面卸载时释放资源：

```javascript
export default {
  async startMicrophoneAnalysis() {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    const context = new AudioContext();
    const source = context.createMediaStreamSource(stream);
    const analyser = context.createAnalyser();
    const waveform = new Float32Array(analyser.fftSize);

    source.connect(analyser);
    await context.resume();

    this.microphone = { stream, context, source };
    this.volumeTimer = setInterval(() => {
      analyser.getFloatTimeDomainData(waveform);
      let energy = 0;
      for (const sample of waveform) energy += sample * sample;
      const volume = Math.sqrt(energy / waveform.length);
      console.log('当前音量：', volume);
    }, 50);
  },

  async stopMicrophoneAnalysis() {
    clearInterval(this.volumeTimer);
    if (!this.microphone) return;

    const { stream, context, source } = this.microphone;
    source.disconnect();
    for (const track of stream.getTracks()) track.stop();
    await context.close();
    this.microphone = null;
  },

  onUnload() {
    return this.stopMicrophoneAnalysis();
  },
};
```

请从按钮的 `bindtap` 等用户操作中调用 `startMicrophoneAnalysis()`。分析音量时不需要连接 `context.destination`，否则麦克风声音会从扬声器播放，可能产生啸叫。

## API Reference

### `new AudioContext(options?)`

`AudioContext` 是 Web Audio 的入口，也是唯一需要主动创建的上下文。`options.sampleRate` 设置采样率；`latencyHint` 可设为 `interactive`、`balanced`、`playback` 或数字。

| 成员 | 说明 |
| --- | --- |
| `state` | `suspended`、`running` 或 `closed`。 |
| `currentTime` | 音频时间线当前秒数。 |
| `sampleRate` | 当前采样率。 |
| `destination` | 最终声音输出节点。 |
| `onstatechange` | 上下文状态变化时调用。 |
| `resume()` | 恢复处理。 |
| `suspend()` | 暂停处理。 |
| `close()` | 关闭上下文并释放资源。 |
| `decodeAudioData(data)` | 把编码音频的 `ArrayBuffer` 解码为 `AudioBuffer`。 |
| `createMediaStreamSource(mediaStream)` | 创建读取媒体流中音频轨道的 `MediaStreamAudioSourceNode`。媒体流没有音频轨道时会抛出 `InvalidStateError`。 |

`AudioContext` 继承 `BaseAudioContext` 的所有属性和创建方法。

### `BaseAudioContext`

`BaseAudioContext` 定义所有音频上下文共用的能力，不能直接使用 `new BaseAudioContext()` 创建。

| 方法 | 返回值 | 用途 |
| --- | --- | --- |
| `createBufferSource()` | `AudioBufferSourceNode` | 播放 `AudioBuffer`。 |
| `createOscillator()` | `OscillatorNode` | 生成正弦、方波、锯齿或三角波。 |
| `createGain()` | `GainNode` | 调整音量。 |
| `createBiquadFilter()` | `BiquadFilterNode` | 对声音进行滤波。 |
| `createAnalyser()` | `AnalyserNode` | 读取波形和频率数据。 |
| `createBuffer(channels, length, sampleRate)` | `AudioBuffer` | 创建 PCM 音频缓冲区。 |
| `decodeAudioData(data, success?, error?)` | `Promise<AudioBuffer>` | 解码编码音频，也可以提供成功和失败回调。 |

它还提供只读的 `sampleRate`、`currentTime`、`state`、`destination`，以及 `onstatechange`。

### `AudioNode`

`AudioNode` 是所有处理节点的基类，不能直接构造。节点通过 `connect()` 连接成处理链，通过 `disconnect()` 断开。

| 成员 | 说明 |
| --- | --- |
| `context` | 节点所属的 `BaseAudioContext`。 |
| `numberOfInputs` / `numberOfOutputs` | 输入和输出数量。 |
| `channelCount` | 处理的声道数。 |
| `channelCountMode` | `max`、`clamped-max` 或 `explicit`。 |
| `channelInterpretation` | `speakers` 或 `discrete`。 |
| `connect(destination, output?, input?)` | 连接到另一个 `AudioNode` 或 `AudioParam`。 |
| `disconnect(...)` | 断开全部连接，或断开指定输出、节点或参数。 |

### `AudioDestinationNode`

`AudioDestinationNode` 表示最终声音输出，通过 `context.destination` 获得，不能直接构造。只读的 `maxChannelCount` 表示输出支持的最大声道数。

### `AudioScheduledSourceNode`

`AudioScheduledSourceNode` 是可以安排开始和停止时间的声音源基类，不能直接构造。

| 成员 | 说明 |
| --- | --- |
| `start(when?)` | 在指定音频时间开始；省略时立即开始。 |
| `stop(when?)` | 在指定音频时间停止；省略时立即停止。 |
| `onended` | 声音源播放结束时调用。 |

`OscillatorNode` 和 `AudioBufferSourceNode` 都继承这些能力。

### `new AudioBuffer(options)`

`AudioBuffer` 保存内存中的 PCM 采样。也可以通过 `context.createBuffer()` 创建。

| 成员 | 说明 |
| --- | --- |
| `sampleRate` | 采样率。 |
| `length` | 每个声道的采样数量。 |
| `duration` | 音频时长，单位为秒。 |
| `numberOfChannels` | 声道数。 |
| `getChannelData(channel)` | 返回指定声道的 `Float32Array`。 |
| `copyToChannel(source, channel, start?)` | 把采样复制到指定声道。 |
| `copyFromChannel(destination, channel, start?)` | 从指定声道复制采样。 |

构造参数必须包含 `length` 和 `sampleRate`；`numberOfChannels` 可选。

### `new AudioBufferSourceNode(context, options?)`

`AudioBufferSourceNode` 播放一个 `AudioBuffer`。也可以通过 `context.createBufferSource()` 创建。

| 成员 | 说明 |
| --- | --- |
| `buffer` | 要播放的 `AudioBuffer`，可以为 `null`。 |
| `playbackRate` | 控制播放速度的 `AudioParam`。 |
| `detune` | 以音分为单位调整音高的 `AudioParam`。 |
| `loop` | 是否循环播放。 |
| `loopStart` / `loopEnd` | 循环区间，单位为秒。 |
| `start(when?, offset?, duration?)` | 安排播放，并可指定起点和播放时长。 |

一个声音源只能启动一次。需要再次播放同一个 `AudioBuffer` 时，应创建新的 `AudioBufferSourceNode`。

### `AudioParam`

`AudioParam` 表示音量、频率等可随时间变化的数值，不能直接构造。它通常由节点的 `gain`、`frequency`、`detune` 等属性提供。

| 成员 | 说明 |
| --- | --- |
| `value` | 当前参数值。 |
| `automationRate` | `a-rate` 或 `k-rate`。 |
| `defaultValue` / `minValue` / `maxValue` | 默认值和有效范围，只读。 |
| `setValueAtTime(value, time)` | 在指定时间设置值。 |
| `linearRampToValueAtTime(value, endTime)` | 线性变化到目标值。 |
| `exponentialRampToValueAtTime(value, endTime)` | 指数变化到目标值。 |
| `setTargetAtTime(target, startTime, timeConstant)` | 从指定时间开始趋近目标值。 |
| `setValueCurveAtTime(values, startTime, duration)` | 按数值曲线变化。 |
| `cancelScheduledValues(time)` | 取消指定时间之后的安排。 |
| `cancelAndHoldAtTime(time)` | 取消后续安排并保持该时刻的值。 |

所有设置和安排方法都返回当前 `AudioParam`，可以继续链式调用。

### `new GainNode(context, options?)`

`GainNode` 调整输入声音的音量，也可以通过 `context.createGain()` 创建。只读属性 `gain` 是一个 `AudioParam`；构造选项中的 `gain` 可以设置初始值。

### `new OscillatorNode(context, options?)`

`OscillatorNode` 生成连续波形，也可以通过 `context.createOscillator()` 创建。

| 成员 | 说明 |
| --- | --- |
| `type` | `sine`、`square`、`sawtooth` 或 `triangle`。 |
| `frequency` | 频率 `AudioParam`，单位为 Hz。 |
| `detune` | 音高偏移 `AudioParam`，单位为音分。 |

构造选项可以设置 `type`、`frequency` 和 `detune`。

### `new BiquadFilterNode(context, options?)`

`BiquadFilterNode` 对声音进行常见滤波，也可以通过 `context.createBiquadFilter()` 创建。

| 成员 | 说明 |
| --- | --- |
| `type` | `lowpass`、`highpass`、`bandpass`、`lowshelf`、`highshelf`、`peaking`、`notch` 或 `allpass`。 |
| `frequency` | 截止或中心频率。 |
| `detune` | 频率偏移。 |
| `Q` | 品质因数。 |
| `gain` | 部分滤波类型使用的增益。 |
| `getFrequencyResponse(frequencies, magnitudes, phases)` | 计算一组频率对应的幅度和相位响应。 |

`frequency`、`detune`、`Q` 和 `gain` 都是 `AudioParam`。

### `new AnalyserNode(context, options?)`

`AnalyserNode` 读取正在播放的波形和频率数据，也可以通过 `context.createAnalyser()` 创建。它不会改变经过节点的声音。

| 成员 | 说明 |
| --- | --- |
| `fftSize` | 分析窗口大小。 |
| `frequencyBinCount` | 频率数据长度，等于 `fftSize / 2`。 |
| `minDecibels` / `maxDecibels` | 频率数据的分贝范围。 |
| `smoothingTimeConstant` | 多次分析结果之间的平滑程度。 |
| `getFloatTimeDomainData(array)` | 写入浮点波形数据。 |
| `getByteTimeDomainData(array)` | 写入 0–255 的波形数据。 |
| `getFloatFrequencyData(array)` | 写入浮点分贝数据。 |
| `getByteFrequencyData(array)` | 写入 0–255 的频率数据。 |

### `new MediaStreamAudioSourceNode(context, options)`

`MediaStreamAudioSourceNode` 把麦克风等 `MediaStream` 的音轨接入 Web Audio。也可以调用 `context.createMediaStreamSource(mediaStream)` 创建。

```javascript
const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
const context = new AudioContext();
const microphone = context.createMediaStreamSource(stream);
const analyser = context.createAnalyser();

microphone.connect(analyser);
```

| 成员 | 说明 |
| --- | --- |
| `new MediaStreamAudioSourceNode(context, { mediaStream })` | 使用指定媒体流创建节点；`mediaStream` 必填且必须包含音频轨道。 |
| `mediaStream` | 只读，返回创建节点时使用的媒体流。 |
| `numberOfInputs` | 始终为 `0`，声音来自媒体流而不是其他音频节点。 |

节点使用媒体流中的音频轨道。将轨道的 `enabled` 设为 `false` 可以暂时静音，重新设为 `true` 后继续输入；调用 `track.stop()` 后，该轨道结束，节点将输出静音。

不再使用时，应依次调用 `source.disconnect()`、停止媒体流中的轨道，并调用 `context.close()`。如果传入的值不是 `MediaStream`，构造函数和 `createMediaStreamSource()` 会抛出 `TypeError`。
