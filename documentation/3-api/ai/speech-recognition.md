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
