# 语音识别

语音识别用于把用户实时说出的内容转换成文本，适合语音输入、语音命令、免手输入和对话式交互等场景。

在 AIUI 中，语音识别通常作为语音交互链路的第一步：先把用户语音识别成文本，再把文本交给业务逻辑或大语言模型处理。

## 识别一次语音输入

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const recognition = new SpeechRecognition();

recognition.onresult = (event) => {
  const best = event.results[0][0];
  console.log(best.transcript, best.confidence);
};

recognition.onerror = (event) => {
  console.error(event.error, event.message);
};

recognition.start();
```

**wx**

```javascript api-style=wx
const sessionId = wx.speech.startRecognition();
console.log('识别会话:', sessionId);
```

<!-- /aiui-api-style -->

## 使用当前麦克风进行识别

`SpeechRecognitionSession` 不会直接打开麦克风。需要先获取当前麦克风，再用 `MediaRecorder` 把录音片段持续写入会话。使用前在 `app.json` 中声明录音权限：

```json
{
  "permissions": ["RECORD_AUDIO"]
}
```

下面的页面示例会自动选择录音和识别服务都支持的音频格式，同时加入热词和初始 ASR 上下文：

```javascript
export default {
  session: null,
  recorder: null,
  microphone: null,
  writer: null,
  writeQueue: Promise.resolve(),

  async startMicrophoneRecognition() {
    const capabilities = await SpeechRecognitionSession.getCapabilities();
    const candidates = ['audio/ogg;codecs=opus', 'audio/wav'];
    const mimeType = candidates.find((candidate) =>
      MediaRecorder.isTypeSupported(candidate) &&
      capabilities.audioFormats.some(
        (format) => format.mimeType.toLowerCase() === candidate
      )
    );

    if (!mimeType) {
      throw new Error('当前没有录音和语音识别都支持的音频格式');
    }

    const session = new SpeechRecognitionSession({
      lang: 'zh-CN',
      interimResults: capabilities.interimResults,
      audio: { mimeType },
      phrases: capabilities.phrases
        ? [
            { phrase: 'Rokid', boost: 5 },
            { phrase: 'AIUI', boost: 5 },
          ]
        : undefined,
    });
    this.session = session;

    if (capabilities.contextUpdates) {
      await session.updateContext([
        { role: 'user', text: '我正在使用语音查询 Rokid 产品' },
        { role: 'assistant', text: '好的，请说出产品名称或问题' },
      ]);
    }

    session.onresult = (event) => {
      const result = event.results[event.resultIndex][0];
      console.log(result.transcript);
    };
    session.onerror = (event) => {
      console.error(event.error, event.message);
    };

    this.microphone = await navigator.mediaDevices.getUserMedia({ audio: true });
    this.writer = session.audio.getWriter();
    this.writeQueue = Promise.resolve();
    this.recorder = new MediaRecorder(this.microphone, { mimeType });

    this.recorder.ondataavailable = (event) => {
      if (event.data.size === 0) return;
      this.writeQueue = this.writeQueue.then(() =>
        this.writer.write(event.data)
      );
    };

    this.recorder.onstop = async () => {
      try {
        await this.writeQueue;
        await this.writer.close();
      } finally {
        this.microphone.getTracks().forEach((track) => track.stop());
        this.recorder = null;
        this.microphone = null;
        this.writer = null;
        this.session = null;
      }
    };

    // 在用户点击事件中开始录音，每 250 ms 产生一个音频片段。
    this.recorder.start(250);
  },

  stopMicrophoneRecognition() {
    if (this.recorder && this.recorder.state !== 'inactive') {
      this.recorder.stop();
    }
  },
};
```

```xml
<button bindtap="startMicrophoneRecognition">开始识别</button>
<button bindtap="stopMicrophoneRecognition">停止识别</button>
```

`startMicrophoneRecognition()` 必须由用户点击等有效交互触发。停止时要等待所有录音片段写入完成，再关闭 `writer`；`writer.close()` 会通知识别服务音频已经结束，使其生成最终结果。最后调用每条麦克风音轨的 `stop()` 释放设备。

## 识别已有或分段到达的音频

`SpeechRecognitionSession` 不会主动打开麦克风。你可以把录音文件、已有音频，或者持续收到的音频片段写入 `audio`：

```javascript
const session = new SpeechRecognitionSession({
  lang: 'zh-CN',
  interimResults: true
});

session.onresult = (event) => {
  const result = event.results[event.resultIndex][0];
  console.log(result.transcript);
};

session.onerror = (event) => {
  console.error(event.error, event.message);
};

const audio = await fetch('/assets/question.wav').then(response => response.blob());
const writer = session.audio.getWriter();
await writer.write(audio);
await writer.close();
```

每次 `write()` 可以传入 `Blob`、`ArrayBuffer` 或 TypedArray。调用 `close()` 表示音频已经全部写完，识别服务随后完成最终结果。需要取消时调用 `writer.abort()`。

写入原始 PCM 数据时，必须明确设置格式：

```javascript
const session = new SpeechRecognitionSession({
  audio: {
    mimeType: 'audio/pcm',
    sampleRate: 16000,
    channelCount: 1,
    sampleFormat: 's16'
  }
});
```

## 添加自定义热词

热词可以帮助识别服务更准确地理解产品名、人名、地点和行业词汇。先通过 `getCapabilities()` 确认当前服务支持热词，再通过 `phrases` 创建会话：

```javascript
const capabilities = await SpeechRecognitionSession.getCapabilities();

const options = {
  lang: 'zh-CN',
  interimResults: true,
};

if (capabilities.phrases) {
  options.phrases = [
    { phrase: 'Rokid', boost: 5 },
    { phrase: 'AIUI', boost: 5 },
    { phrase: '灵伴', boost: 3 },
  ];
}

const session = new SpeechRecognitionSession(options);
const writer = session.audio.getWriter();
const audio = await fetch('/assets/product-intro.wav')
  .then((response) => response.blob());

await writer.write(audio);
await writer.close();
```

`phrase` 是希望优先识别的词语，不能为空。`boost` 是可选权重，省略时为 `1`；数值越高，表示越希望识别服务优先考虑这个词。是否支持热词以 `capabilities.phrases` 为准。

## 更新 ASR 上下文

上下文用于告诉识别服务当前对话正在讨论什么。可以在写入第一段音频前设置初始上下文，也可以在识别过程中通过 `updateContext()` 替换上下文：

```javascript
const capabilities = await SpeechRecognitionSession.getCapabilities();
const session = new SpeechRecognitionSession({
  lang: 'zh-CN',
  audio: {
    mimeType: 'audio/pcm',
    sampleRate: 16000,
    channelCount: 1,
    sampleFormat: 's16',
  },
});

if (capabilities.contextUpdates) {
  await session.updateContext([
    { role: 'user', text: '我正在查询杭州明天的天气' },
    { role: 'assistant', text: '好的，我会关注杭州和明天这个时间范围' },
  ]);
}

const writer = session.audio.getWriter();
const firstPart = await fetch('/assets/question-1.pcm')
  .then((response) => response.arrayBuffer());
await writer.write(firstPart);

// 对话主题发生变化时，替换当前上下文。
if (capabilities.contextUpdates) {
  await session.updateContext([
    { role: 'user', text: '接下来改为查询上海的航班' },
    { role: 'assistant', text: '好的，请告诉我出发日期' },
  ]);
}

const secondPart = await fetch('/assets/question-2.pcm')
  .then((response) => response.arrayBuffer());
await writer.write(secondPart);
await writer.close();
```

每条消息的 `role` 只能是 `user` 或 `assistant`，`text` 不能为空。当前服务不支持更新上下文时，不要调用该方法。

## 适用场景

- 语音输入框
- 语音问答
- 语音控制命令
- 需要边听边处理的交互流程

## 事件处理建议

- 使用 `onresult` 接收识别结果。
- 使用 `onerror` 处理权限、设备或识别失败等异常情况。
- 使用 `onend` 感知本轮识别已经结束，并及时更新界面状态。

## 使用建议

- 开始识别前，先确保当前界面处于可交互状态。
- 把“正在聆听”“识别中”“识别完成”“识别失败”这些状态明确展示给用户。
- 不要在同一个实例上并发启动多轮识别请求。

## 继续阅读

- **[语音播报](/AIUI/api/ai-speech-synthesis)**：查看如何把文本结果播报给用户。
- **[大语言模型](/AIUI/api/ai-language-model)**：查看如何把识别文本继续交给模型处理。
- **[媒体采集](/AIUI/api/media-media-capture)**：查看麦克风、相机和 `MediaRecorder` 的完整用法。

## API Reference

### 入口

语音识别基于 `SpeechRecognition`：

```javascript
const recognition = new SpeechRecognition();
```

### 常用方法

#### `start()`
- 开始一轮识别会话。

#### `stop()`
- 请求结束当前识别，并尽可能产出最终结果。

#### `abort()`
- 立即中止当前识别，不等待正常结束结果。

### 事件处理建议

- 用 `onresult` 接收识别结果。
- 用 `onerror` 处理权限、设备或识别失败等异常情况。
- 用 `onend` 感知本轮识别已经结束，及时更新界面状态。

### `new SpeechRecognitionSession(options?)`

创建一个可写入音频的识别会话。常用选项包括：

| 选项 | 类型 | 说明 |
| --- | --- | --- |
| `lang` | `string` | 识别语言，例如 `zh-CN`。 |
| `interimResults` | `boolean` | 是否接收尚未最终确认的中间结果，默认 `false`。 |
| `maxAlternatives` | `number` | 每个结果最多返回多少个候选，默认且最小为 `1`。 |
| `phrases` | `SpeechRecognitionPhrase[]` | 自定义热词及可选权重。使用前检查 `capabilities.phrases`。 |
| `segmentation` | `string` | 分段方式：`auto`、`vad` 或 `semantic`。使用前检查 `segmentationModes`。 |
| `audio` | `SpeechRecognitionAudioOptions` | 输入音频格式。 |

**`SpeechRecognitionPhrase`**

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `phrase` | `string` | 是 | 热词文本，不能为空。 |
| `boost` | `number` | 否 | 热词权重，默认 `1`。 |

**`SpeechRecognitionAudioOptions`**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `mimeType` | `string` | 音频 MIME 类型，例如 `audio/pcm`。 |
| `sampleRate` | `number` | 采样率，例如 `16000`。 |
| `channelCount` | `number` | 声道数，例如单声道为 `1`。 |
| `sampleFormat` | `'s16' \| 'f32'` | PCM 采样格式。 |

实例提供只读的 `audio` 可写流和 `state`。当前实现中的 `state` 可能为 `idle`、`opening`、`streaming`、`closing` 或 `closed`。实例还支持 `onstart`、`onaudiostart`、`onresult`、`onerror`、`onaudioend` 和 `onend` 事件。

### `SpeechRecognitionSession.getCapabilities()`

```javascript
const capabilities = await SpeechRecognitionSession.getCapabilities();
```

返回 `Promise<SpeechRecognitionCapabilities>`。建议在创建会话前调用，按照实际支持情况选择音频格式、热词、上下文和分段方式。查询失败时 Promise 会拒绝。

| 属性 | 类型 | 说明 |
| --- | --- | --- |
| `audioFormats` | `SpeechRecognitionAudioFormatCapability[]` | 支持的音频格式及其采样率、声道数和采样格式。 |
| `maxChunkBytes` | `number` | 每个传输片段支持的最大字节数。写入更大的数据时，会自动拆分后发送。 |
| `interimResults` | `boolean` | 是否支持返回中间识别结果。 |
| `maxAlternatives` | `number` | 每个识别结果支持的最大候选数量。 |
| `phrases` | `boolean` | 是否支持 `phrases` 自定义热词。 |
| `contextUpdates` | `boolean` | 是否支持设置和更新 ASR 上下文。 |
| `segmentationModes` | `Array<'auto' \| 'vad' \| 'semantic'>` | 支持的音频分段方式。 |

`audioFormats` 中的每一项包含：

| 属性 | 类型 | 说明 |
| --- | --- | --- |
| `mimeType` | `string` | 支持的音频 MIME 类型。 |
| `sampleRates` | `number[]` | 支持的采样率；空数组表示不限制。 |
| `channelCounts` | `number[]` | 支持的声道数；空数组表示不限制。 |
| `sampleFormats` | `Array<'s16' \| 'f32'>` | 支持的 PCM 采样格式；空数组表示不限制。 |

### `session.updateContext(messages)`

使用一组新的消息替换当前 ASR 上下文，返回 `Promise<void>`。

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| `messages` | `SpeechRecognitionContextMessage[]` | 按对话顺序排列的上下文消息。 |

| 消息字段 | 类型 | 说明 |
| --- | --- | --- |
| `role` | `'user' \| 'assistant'` | 消息角色，只支持这两个值。 |
| `text` | `string` | 消息内容，不能为空。 |

- 在首次写入音频前调用时，上下文会随会话一起开始。
- 在识别过程中调用时，会立即替换正在使用的上下文。
- `messages` 不是数组、角色不受支持或文本为空时，会抛出 `TypeError`。
- 在会话开始前调用时，方法会先保存上下文；如果服务不支持上下文，首次 `writer.write()` 会拒绝。
- 在识别过程中更新失败时，`updateContext()` 返回的 Promise 会拒绝。调用前应检查 `getCapabilities()` 返回的 `contextUpdates`。
