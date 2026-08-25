# HTTPS

在 AIUI 中，`HTTPS` 用于基于 HTTP / HTTPS 的请求式通信。最常见的形式是“发起一次请求，再等待服务端返回响应”，但这并不意味着响应体一定要一次性读完。

如果你在做配置拉取、普通 REST 接口、表单提交、调用智能体服务，通常优先使用 `HTTPS`。当服务端采用分块传输时，你也可以通过 `fetch()` 返回的 `Response` 对象按流式方式读取响应体。

## 发起 JSON 请求

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const response = await fetch('/api/agent/chat', {
  method: 'POST',
  headers: {
    'content-type': 'application/json',
  },
  body: JSON.stringify({
    message: '帮我总结今天的会议内容',
  }),
});

if (!response.ok) {
  throw new Error(`请求失败: ${response.status}`);
}

const data = await response.json();
console.log(data);
```

**wx**

```javascript api-style=wx
wx.request({
  url: '/api/agent/chat',
  method: 'POST',
  header: {
    'content-type': 'application/json',
  },
  data: {
    message: '帮我总结今天的会议内容',
  },
  success(res) {
    console.log(res.statusCode, res.data);
  },
  fail(error) {
    console.error(error);
  },
});
```

<!-- /aiui-api-style -->

## 使用 `fetch` 流式读取文本响应

```javascript
const response = await fetch('/api/agent/stream');
const reader = response.body.getReader();
const decoder = new TextDecoder('utf-8');
let text = '';

while (true) {
  const { value, done } = await reader.read();
  if (done) {
    break;
  }

  text += decoder.decode(value, { stream: true });
}

text += decoder.decode();
console.log(text);
```

## 使用 `RequestTask` 监听响应头和分块

```javascript
const task = wx.request({
  url: '/api/agent/stream',
  method: 'GET',
  success(res) {
    console.log('最终结果:', res.data);
  },
});

task.onHeadersReceived((headers) => {
  console.log('收到响应头:', headers);
});

task.onChunkReceived((chunk) => {
  console.log('收到分块数据:', chunk);
});
```

## 什么时候用 HTTPS

- 拉取页面初始化数据
- 调用普通 REST 接口
- 提交一次性表单或指令
- 请求一个完整结果，随后用 `json()`、`text()` 或 `arrayBuffer()` 一次性读取
- 发起一次 HTTP 请求，但希望对响应体做分块消费

## 接入方式

AIUI 当前提供两种常见入口：

- **`fetch(url, options?)`**：更接近 Web 标准，适合 Promise 风格与 `Response` 风格的读取方式。
- **`wx.request(options)`**：更接近微信小程序兼容接口，适合回调风格与 `RequestTask` 风格的控制方式。

## 流式消费说明

- 如果你需要边收边处理文本或字节，优先使用 `response.body.getReader()`。
- 如果你只关心最终结果，优先使用 `text()`、`json()` 或 `arrayBuffer()`。
- 一旦 body 被 reader 锁定，`text()`、`json()` 这类便捷读取方法就不能再复用同一个 body。
- 当文本可能跨 chunk 边界时，配合 `TextDecoder.decode(value, { stream: true })` 做增量解码会更安全。

## HTTPS 使用建议

- 优先把一次业务动作建模成一次明确的 HTTP 请求。
- 如果只关心最终结果，直接使用 `response.json()` 或 `wx.request().success` 会更简单。
- 如果服务端是一次请求但响应会持续分块返回，优先用 `fetch` 配合 `response.body` 做流式消费。
- 为请求设置清晰的超时、取消、失败提示和重试策略。
- 对于需要鉴权的接口，把认证信息统一放在请求头或会话机制里处理。

## 什么时候不用 HTTPS

- 需要服务端主动长期单向推送，而不是由一次请求触发返回时
- 需要客户端与服务端保持双向实时通信时

如果你需要服务端单向持续推送，继续参考 [Event Source](/AIUI/api/network-event-source)。如果需要双向实时通信，改用 [WebSocket](/AIUI/api/network-websocket)。

## 继续阅读

- **[Event Source](/AIUI/api/network-event-source)**：查看服务端单向流式推送的典型使用方式。
- **[WebSocket](/AIUI/api/network-websocket)**：查看双向实时长连接场景如何设计与管理。
- **[微信小程序兼容 API](/AIUI/api/weixin-compatible-apis)**：查看 AIUI 支持的 wx API 列表。

## API Reference

### `fetch(url, options?)`

`fetch()` 会发起一个 HTTP / HTTPS 请求，并返回一个 `Promise<Response>`。

#### 参数

#### `url`

请求地址。当前实现要求传入字符串。

```javascript
const response = await fetch('https://example.com/data.json');
```

#### `options.method`

HTTP 方法，默认是 `GET`。

```javascript
await fetch('https://example.com/items', {
  method: 'POST',
});
```

#### `options.headers`

请求头对象。当前实现会按字符串方式读取 header 值。

```javascript
await fetch('https://example.com/items', {
  headers: {
    Authorization: `Bearer ${token}`,
    'content-type': 'application/json',
  },
});
```

#### `options.body`

请求体。当前实现会把 `body` 按字符串读取，并将其字节发送给服务端。

```javascript
await fetch('https://example.com/items', {
  method: 'POST',
  headers: {
    'content-type': 'application/json',
  },
  body: JSON.stringify({
    title: 'hello',
  }),
});
```

#### `options.timeout`

单次请求超时时间，单位为毫秒。

```javascript
await fetch('https://example.com/items', {
  timeout: 3000,
});
```

#### `options.signal`

用于取消请求的 `AbortSignal`。

```javascript
const signal = new AbortSignal();

fetch('https://example.com/items', { signal });
signal.abort();
```

### `Response`

`fetch()` 返回的 `Promise` 会在响应头可用时进入 resolved 状态，而不是等整个响应体下载完成以后才返回。这意味着：

- 你可以先检查 `status`、`ok` 等元信息。
- 如果服务端分块返回数据，可以通过 `response.body` 按块消费。
- 如果你只关心最终结果，也可以直接使用 `text()`、`json()`、`arrayBuffer()` 这类便捷方法。
- 如果响应带有 HTTP `Content-Encoding`，读取到的是解码后的 body 字节，而不是原始压缩传输字节。

#### 常用字段

#### `response.ok`

当状态码位于 `200-299` 区间时为 `true`。

#### `response.status`

HTTP 数字状态码，例如 `200`、`404`、`500`。

#### `response.statusText`

HTTP 状态文本。当前实现中，`200` 返回 `"OK"`，其他状态通常为空字符串。

#### `response.url`

本次响应对应的 URL。

#### `response.body`

响应体对应的 `ReadableStream`。如果服务端按块返回数据，可以通过 `getReader()` 逐块读取，而不是等待整个响应结束。

```javascript
const response = await fetch('https://example.com/stream');
const reader = response.body.getReader();
const decoder = new TextDecoder('utf-8');
let buffer = '';

while (true) {
  const { value, done } = await reader.read();
  if (done) {
    break;
  }

  buffer += decoder.decode(value, { stream: true });
}

buffer += decoder.decode();
console.log(buffer);
```

#### `response.bodyUsed`

表示响应体是否已经被消费。一旦 body 被 `getReader()` 锁定，或者已经通过 `text()`、`json()`、`arrayBuffer()` 读取，`bodyUsed` 就会变为 `true`。

#### 常用方法

#### `response.clone()`

返回当前响应的一个新副本。当前实现支持分别消费原始响应与克隆响应。

```javascript
const response = await fetch('https://example.com/data.json');
const copy = response.clone();

console.log(await response.text());
console.log(await copy.text());
```

#### `response.text()`

把响应体解码为字符串。它会等待整个响应体读取完成，再返回最终文本。

```javascript
const response = await fetch('https://example.com/message.txt');
console.log(await response.text());
```

#### `response.json()`

把响应体解析为 JSON。它会先完整读取响应体，再执行解析。

```javascript
const response = await fetch('https://example.com/data.json');
console.log(await response.json());
```

#### `response.arrayBuffer()`

把响应体读取为 `ArrayBuffer`，适合二进制内容。

```javascript
const response = await fetch('https://example.com/model.bin');
const buffer = await response.arrayBuffer();
console.log(buffer.byteLength);
```

### wx APIs

#### `wx.request(options)`

`wx.request()` 提供了微信小程序兼容风格的 HTTPS 请求入口，更适合基于回调或 `RequestTask` 的写法。

#### 参数

#### `options.url`

请求地址。

#### `options.method`

HTTP 方法，默认是 `GET`。

#### `options.header`

请求头对象。

```javascript
wx.request({
  url: 'https://example.com/items',
  header: {
    Authorization: `Bearer ${token}`,
  },
});
```

#### `options.data`

请求数据。当前实现支持：

- `String`
- `ArrayBuffer`
- 普通对象
- 类表单对象

当 `content-type` 包含 `application/x-www-form-urlencoded` 时，对象会按表单方式编码；否则普通对象通常会被序列化为 JSON 字符串。

```javascript
wx.request({
  url: 'https://example.com/items',
  method: 'POST',
  header: {
    'content-type': 'application/json',
  },
  data: {
    title: 'hello',
  },
});
```

#### `options.body`

当 `data` 未提供时，可以使用备用字符串请求体。

#### `options.timeout`

单次请求超时时间，单位为毫秒。

#### `options.responseType`

响应体模式，默认是 `text`。当设置为 `arraybuffer` 时，`success` 回调中的 `res.data` 会是 `ArrayBuffer`。

#### `options.dataType`

返回值解析模式，默认是 `json`。当设置为 `json` 时，运行时会尝试在赋值给 `res.data` 之前先做一次 JSON 解析。

#### `options.success`

请求成功回调，接收的结果对象通常包含：

- `data`
- `statusCode`
- `header`
- `cookies`
- `errMsg`

#### `options.fail`

请求失败回调，通常接收包含 `errMsg` 的对象。

#### `options.complete`

请求结束回调。无论成功还是失败都会调用。

#### `RequestTask`

`wx.request(...)` 会返回一个 `RequestTask`，可用于中断请求或监听更早到达的响应事件。

#### 方法

- **`abort()`**：中断当前请求。
- **`onHeadersReceived(callback)`** / **`offHeadersReceived(callback?)`**：监听或移除响应头到达事件。
- **`onChunkReceived(callback)`** / **`offChunkReceived(callback?)`**：监听或移除分块响应到达事件。

#### 行为说明

- `onHeadersReceived()` 会在响应头到达时触发，早于请求最终完成。
- `onChunkReceived()` 会在新的响应体分块到达时持续触发。
- 即使启用了分块事件，`success()` 与 `complete()` 仍然会等待完整响应结束。
