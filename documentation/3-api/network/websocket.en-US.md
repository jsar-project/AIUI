# WebSocket

`WebSocket` is suitable for scenarios where the client and server need bidirectional real-time communication. Compared with `HTTPS` and `SSE`, it is better for frequent message exchange, low-latency interaction, and continuous communication after a connection is established.

If your scenario only needs to request a result once, or only needs the server to keep pushing content, you usually do not need `WebSocket`. Prefer it only when the client also needs to keep sending messages actively and both sides need a long-lived online channel.

## Example

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
  console.log('Message received:', data);
});

socket.onClose(() => {
  console.log('Connection closed');
});
```

<!-- /aiui-api-style -->

## When to Use WebSocket

- Chat, multi-user collaboration, and real-time synchronization
- The client needs to continuously report status to the server
- The server also needs to push messages to the client at any time
- Lower latency and a more stable bidirectional channel are needed compared with polling

## Recommendations

- Split connection setup, message sending, message parsing, and connection teardown into separate logic instead of putting everything into page code.
- Define a stable message format such as `type`, `payload`, and `sessionId` to avoid mixing different messages into the same parsing logic.
- Design reconnect behavior explicitly so the page does not become unavailable for a long time because of network fluctuations.
- Close the connection proactively when the page is destroyed, the session ends, or the user exits.

## Connection Management Recommendations

- Clarify session identity and authentication before establishing the connection.
- Send business messages only after the connection succeeds. Do not assume the connection is available immediately after creation.
- Handle abnormal closure, authentication failure, and server rejection separately instead of reporting them all as "network errors".
- If your business logic depends on long-lived connections, consider adding heartbeat or activity detection.

## When Not to Use WebSocket

- When only calling ordinary APIs
- When only requesting one complete result
- When only needing one-way incremental pushes from the server

For these scenarios, [HTTPS](/AIUI/api/network-https) or [Event Source](/AIUI/api/network-event-source) is usually simpler and easier to maintain.

## Read Next

- **[HTTPS](/AIUI/api/network-https)**: Learn which business scenarios are better suited to request-response.
- **[Event Source](/AIUI/api/network-event-source)**: Learn which business scenarios are better suited to one-way streaming pushes from the server.
- **[WeChat Mini Program Compatible APIs](/AIUI/api/weixin-compatible-apis)**: See the wx APIs supported by AIUI.

## API Reference

### `new WebSocket(url)`

Creates a Web-standard WebSocket connection. `url` must use the `ws` or `wss` protocol.

### `WebSocket` Events and Methods

- `addEventListener('open', callback)`: Observes the connection opening.
- `addEventListener('message', callback)`: Observes messages; event `data` contains the payload.
- `addEventListener('close', callback)`: Observes connection closure.
- `addEventListener('error', callback)`: Observes connection errors.
- `send(data)`: Sends string or binary data.
- `close()`: Closes the connection.

### wx APIs

#### `wx.connectSocket(options)` / `wx.createSocket(options)`

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `options.url` | `string` | Yes | A `ws` or `wss` service URL. |
| `options.header` | `object` | No | Connection request headers. `Referer` cannot be set. |

**Returns:** `SocketTask`.

#### `SocketTask`

- `onOpen(callback)`, `onMessage(callback)`, `onClose(callback)`, `onError(callback)`: Observe connection events.
- `send(data)`: Sends a `String`, `ArrayBuffer`, or `Uint8Array`.
- `close()`: Closes the connection.

All methods return `undefined`; `send()` throws `TypeError` for other data types.
