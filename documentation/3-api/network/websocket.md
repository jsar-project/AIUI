# WebSocket

`WebSocket` 适合客户端与服务端需要双向实时通信的场景。和 `HTTPS`、`SSE` 相比，它更适合频繁收发消息、低延迟互动、连接建立后持续通信的业务。

如果你的场景只是请求一个结果，或者只是让服务端持续推送内容，通常不需要上 `WebSocket`。只有在客户端也要持续主动发消息，并且双方都需要长期保持在线通道时，再优先考虑它。

## 示例

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const socket = new WebSocket('wss://example.com/realtime');

socket.addEventListener('open', () => {
  socket.send(JSON.stringify({
    type: 'hello',
    sessionId: 'demo-session',
  }));
});

socket.addEventListener('message', (event) => {
  console.log('收到消息:', event.data);
});

socket.addEventListener('close', () => {
  console.log('连接已关闭');
});
```

**wx**

```javascript api-style=wx
const socket = wx.connectSocket({
  url: 'wss://example.com/realtime',
});

socket.onOpen(() => {
  socket.send(JSON.stringify({
    type: 'hello',
    sessionId: 'demo-session',
  }));
});

socket.onMessage(({ data }) => {
  console.log('收到消息:', data);
});

socket.onClose(() => {
  console.log('连接已关闭');
});
```

<!-- /aiui-api-style -->

## 什么时候用 WebSocket

- 聊天、多人协作、实时同步
- 客户端需要持续向服务端上报状态
- 服务端也要随时向客户端推送消息
- 需要比轮询更低的延迟和更稳定的双向通道

## 使用建议

- 把连接建立、消息发送、消息解析、连接关闭拆成独立逻辑，不要全部堆在页面代码里。
- 为消息定义稳定的格式，例如 `type`、`payload`、`sessionId`，避免不同消息混用同一种解析逻辑。
- 对断线重连做明确设计，避免因为网络波动导致页面长期不可用。
- 在页面销毁、会话结束或用户退出时主动关闭连接。

## 连接管理建议

- 建连前先明确会话身份和鉴权方式。
- 连接成功后再发送业务消息，不要假设连接一创建就立即可用。
- 对异常关闭、鉴权失败、服务端拒绝等情况分别处理，不要统一提示为“网络错误”。
- 如果业务依赖长连接，建议补充心跳或活跃检测机制。

## 何时不要用 WebSocket

- 只是调用普通接口时
- 只是请求一次完整结果时
- 只是需要服务端单向推送增量时

这些场景通常用 [HTTPS](/AIUI/api/network-https) 或 [Event Source](/AIUI/api/network-event-source) 更简单，也更容易维护。

## 继续阅读

- **[HTTPS](/AIUI/api/network-https)**：查看普通请求响应更适合怎样的业务。
- **[Event Source](/AIUI/api/network-event-source)**：查看服务端单向流式推送更适合怎样的业务。
- **[微信小程序兼容 API](/AIUI/api/weixin-compatible-apis)**：查看 AIUI 支持的 wx API 列表。

## API Reference

### `new WebSocket(url)`

创建 Web 标准的 WebSocket 连接。`url` 必须使用 `ws` 或 `wss` 协议。

### `WebSocket` 事件与方法

- `addEventListener('open', callback)`：监听连接打开。
- `addEventListener('message', callback)`：监听消息，事件的 `data` 为消息内容。
- `addEventListener('close', callback)`：监听连接关闭。
- `addEventListener('error', callback)`：监听连接错误。
- `send(data)`：发送字符串或二进制数据。
- `close()`：关闭连接。

### wx APIs

#### `wx.connectSocket(options)` / `wx.createSocket(options)`

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `options.url` | `string` | 是 | `ws` 或 `wss` 服务地址。 |
| `options.header` | `object` | 否 | 建连请求头，不能设置 `Referer`。 |

**返回值：** `SocketTask`。

#### `SocketTask`

- `onOpen(callback)`、`onMessage(callback)`、`onClose(callback)`、`onError(callback)`：监听连接事件。
- `send(data)`：发送 `String`、`ArrayBuffer` 或 `Uint8Array`。
- `close()`：关闭连接。

以上方法均返回 `undefined`；`send()` 收到其他数据类型时抛出 `TypeError`。
