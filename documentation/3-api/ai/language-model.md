# 大语言模型

大语言模型用于完成问答、总结、提取、改写、生成和推理等任务。在 AIUI 中，它通常作为智能体的核心理解与生成能力。

如果你的应用需要根据上下文生成回复，或者基于用户输入完成更复杂的语义处理，通常可以从 `LanguageModel` 开始。

## 开始前先判断可用性

```javascript
const status = await LanguageModel.availability();

if (status !== 'available') {
  throw new Error('LanguageModel 当前不可用');
}
```

## 创建会话

```javascript
const session = await LanguageModel.create({
  initialPrompts: [
    { role: 'system', content: '请用简洁中文回答。' },
  ],
});
```

## 一次性请求

```javascript
const text = await session.prompt('请用一句话介绍 AIUI');
console.log(text);
```

## 流式输出

```javascript
const stream = session.promptStreaming('请分点总结这段内容');

while (true) {
  const { done, value } = await stream.read();
  if (done) break;
  if (value !== undefined) {
    console.log(value);
  }
}
```

## tools 调用示例

如果你的模型请求需要声明可用工具，可以在创建会话时通过 `tools` 传入函数声明。当模型认为需要调用工具时，会触发 `toolcall` 事件。

### 声明工具并监听回调

```javascript
const session = await LanguageModel.create({
  initialPrompts: [
    { role: 'system', content: '你是一个天气助手，请优先使用已声明的工具。' },
  ],
  tools: [
    {
      type: 'function',
      function: {
        name: 'get_weather',
        description: '查询某个城市的天气',
        parameters: {
          type: 'object',
          properties: {
            city: { type: 'string' },
          },
          required: ['city'],
        },
      },
    },
  ],
});

// 监听工具调用事件
session.addEventListener('toolcall', (event) => {
  console.log('收到工具调用请求:', event.functionName);
  console.log('参数:', event.arguments);
  
  if (event.functionName === 'get_weather') {
    // 处理天气查询逻辑
    const { city } = event.arguments;
    console.log(`正在查询 ${city} 的天气...`);
  }
});

const result = await session.prompt('帮我查询一下杭州今天天气');
```

## 当前能力边界

- [x] 向模型声明可用函数及其参数结构。
- [x] 通过 `session.addEventListener('toolcall', ...)` 接收结构化的工具调用请求。
- [x] 后端返回的普通文本或文本增量通过 `prompt()` 或 `promptStreaming()` 暴露给前端。

## 适用场景

- 对话式问答
- 内容总结与改写
- 信息提取与结构化输出
- 流式生成回复
- 带上下文的多轮交互

## 使用建议

- 把会话视为一次有上下文的交互单元，而不是全局单例。
- 对长文本输出优先使用 `promptStreaming()`，更适合做增量展示和播报联动。
- 当页面离开、会话结束或不再需要上下文时，及时调用 `destroy()`。
- 如果业务需要声明工具能力，可以在 `create()` 时通过 `tools` 传入函数声明。

## 注意事项

- 同一个会话在同一时间只应运行一个活跃请求。
- `initialPrompts` 更适合放系统约束和初始上下文，不建议把每次用户输入都塞进去。
- 如果没有显式传入 `model`，运行环境需要提供默认模型配置。
- 流式输出返回的是轮询式读取对象，适合逐段消费文本增量。

## 继续阅读

- **[语音识别](/AIUI/api/ai-speech-recognition)**：查看如何把用户语音输入交给模型处理。
- **[语音播报](/AIUI/api/ai-speech-synthesis)**：查看如何把模型回复播报给用户。

## API Reference

### 入口

`LanguageModel` 可以直接使用，也可以从内置模块导入：

```javascript
const status = await LanguageModel.availability();
```

```javascript
import { LanguageModel } from 'language-model';
```

### 常用方法

#### `availability()`
- **返回值**：`Promise<'available' | 'unavailable'>`
- **说明**：检查当前运行环境是否可提供大语言模型能力。

#### `create(options?)`
- **返回值**：`Promise<LanguageModelSession>`
- **说明**：创建一个新的模型会话。

#### `prompt(input)`
- **返回值**：`Promise<string>`
- **说明**：发送一次请求，并在完成后返回最终文本。

#### `promptStreaming(input)`
- **返回值**：`LanguageModelTextStream`
- **说明**：发起流式请求，逐步读取模型增量输出。

#### `clone()`
- **说明**：复制当前会话上下文，创建一个新的独立会话。

#### `destroy()`
- **说明**：销毁当前会话，释放后续使用所需的会话资源。

### toolcall 事件对象

`toolcall` 事件对象包含以下属性：

- `callId`: 工具调用的唯一标识符。
- `functionName`: 要调用的函数名称。
- `arguments`: 经过解析的函数参数（通常是一个 JavaScript 对象）。
- `toolType`: 工具类型，当前固定为 `"function"`。
- `index`: 该工具调用在当前请求中的索引。
- `isComplete`: 标识该工具调用是否已完成，当前固定为 `true`。
