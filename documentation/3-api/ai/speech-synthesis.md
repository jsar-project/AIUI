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

## 适用场景

- 智能体回复播报
- 系统提示音后的文字播报
- 导航与状态提醒
- 免手查看场景下的语音输出

## 使用建议

- 把要播报的文本控制在适合一次听清的长度内，避免整段长文本直接朗读。
- 对于连续多条回复，建议在业务层控制播报节奏，避免用户同时收到过多语音输出。
- 对重要提示和普通提示使用不同的文案长度与语气。

## 当前能力范围

- [x] 通过 `speechSynthesis.speak()` 发起播报，并支持通过 `mode` 控制排队或立即播放。
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
