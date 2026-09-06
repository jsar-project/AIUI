# Web Audio

Web Audio API 用于生成声音、处理 PCM 音频、调整音量、添加滤波器，以及读取波形或频率数据。它适合需要实时音频处理的场景。

如果只是播放 MP3、Ogg 等音频文件，优先使用 [`AudioPlayer`](/AIUI/api/media-audio-player)，通常更省电，也更容易使用。

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

## API Reference

### `new AudioContext(options?)`

创建音频处理上下文。`options.sampleRate` 设置采样率；`latencyHint` 可设为 `interactive`、`balanced`、`playback` 或数字。

| 成员 | 说明 |
| --- | --- |
| `state` | `suspended`、`running` 或 `closed`。 |
| `currentTime` | 音频时间线当前秒数。 |
| `sampleRate` | 当前采样率。 |
| `destination` | 最终声音输出节点。 |
| `resume()` | 恢复处理。 |
| `suspend()` | 暂停处理。 |
| `close()` | 关闭上下文并释放资源。 |
| `decodeAudioData(data)` | 把编码音频的 `ArrayBuffer` 解码为 `AudioBuffer`。 |

### 创建节点

| 方法 | 返回值 | 用途 |
| --- | --- | --- |
| `createBufferSource()` | `AudioBufferSourceNode` | 播放 `AudioBuffer`。 |
| `createOscillator()` | `OscillatorNode` | 生成正弦、方波、锯齿或三角波。 |
| `createGain()` | `GainNode` | 调整音量。 |
| `createBiquadFilter()` | `BiquadFilterNode` | 对声音进行滤波。 |
| `createAnalyser()` | `AnalyserNode` | 读取波形和频率数据。 |
| `createBuffer(channels, length, sampleRate)` | `AudioBuffer` | 创建 PCM 音频缓冲区。 |

### `AudioParam`

音量、频率等可变化参数通过 `AudioParam` 控制。除了直接设置 `value`，还可以使用 `setValueAtTime()`、`linearRampToValueAtTime()`、`exponentialRampToValueAtTime()`、`setTargetAtTime()` 和 `setValueCurveAtTime()` 安排随时间变化的参数。
