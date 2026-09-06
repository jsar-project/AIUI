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

## 适用场景

- 语音输入框
- 语音问答
- 语音控制命令
- 需要边听边处理的交互流程

## 使用建议

- 开始识别前，先确保当前界面处于可交互状态。
- 把“正在聆听”“识别中”“识别完成”“识别失败”这些状态明确展示给用户。
- 不要在同一个实例上并发启动多轮识别请求。

## 继续阅读

- **[语音播报](/AIUI/api/ai-speech-synthesis)**：查看如何把文本结果播报给用户。
- **[大语言模型](/AIUI/api/ai-language-model)**：查看如何把识别文本继续交给模型处理。

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
| `lang` | String | 识别语言，例如 `zh-CN`。 |
| `interimResults` | Boolean | 是否接收尚未最终确认的中间结果。 |
| `maxAlternatives` | Number | 每个结果最多返回多少个候选。 |
| `phrases` | Array | 提示词及可选的 `boost` 权重。 |
| `segmentation` | String | 分段方式：`auto`、`vad` 或 `semantic`。 |
| `audio` | Object | 音频格式，可包含 `mimeType`、`sampleRate`、`channelCount`、`sampleFormat`。 |

实例提供只读的 `audio` 可写流和 `state` 状态，并支持 `onstart`、`onaudiostart`、`onresult`、`onerror`、`onaudioend`、`onend` 事件。

### `SpeechRecognitionSession.getCapabilities()`

返回当前识别服务支持的音频格式、单个片段大小、候选数量和分段方式等能力。需要适配多种音频来源时，建议在创建会话前查询。

### `session.updateContext(messages)`

在识别过程中更新对话上下文。每条消息包含 `role` 和 `text`。如果当前识别服务不支持动态上下文，Promise 会拒绝。
