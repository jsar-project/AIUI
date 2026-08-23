# Event Source

In AIUI, `EventSource` is suitable for communication patterns where the server continuously pushes incremental content to the frontend in a one-way stream.

If you already have a server interface that needs to continuously output a text stream, status stream, or task progress, prefer `EventSource` instead of switching to `WebSocket` just for streaming output.

## Event Source Example

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const eventSource = new EventSource('/api/agent/stream');

eventSource.onmessage = (event) => {
  console.log('Received incremental content:', event.data);
};

eventSource.onerror = () => {
  console.error('Event Source connection error');
  eventSource.close();
};
```

**wx**

```javascript api-style=wx
const eventSource = wx.createEventSource({
  url: '/api/agent/stream',
});

eventSource.onMessage(({ data }) => {
  console.log('Incremental content received:', data);
});

eventSource.onError((error) => {
  console.error('Event Source connection error', error);
  eventSource.close();
});
```

<!-- /aiui-api-style -->

## When to Use Event Source

- The server continuously pushes text deltas
- Task execution progress needs to be displayed
- Only one-way server-to-client pushing is needed, without continuous reverse messages from the client
- You want to keep an HTTP-like integration model while still getting a streaming experience

## Event Source Recommendations

- When the server is only responsible for continuous pushing, prefer `EventSource`.
- Design each pushed message as an independently consumable fragment, such as text deltas, phase states, or progress updates.
- Clearly distinguish UI states such as "connected", "streaming", "completed", and "interrupted".
- Close the instance promptly after the connection ends to avoid continuing to occupy resources after page switches.

## When Not to Use Event Source

- When you only need one complete result
- When you are only calling ordinary APIs
- When the client needs to keep sending real-time messages to the server

If you only need one request and one response, use [HTTPS](/AIUI/api/network-https). If you need bidirectional real-time communication, use [WebSocket](/AIUI/api/network-websocket) instead.

## Read Next

- **[HTTPS](/AIUI/api/network-https)**: Learn how to handle ordinary request-response scenarios.
- **[WebSocket](/AIUI/api/network-websocket)**: Learn how to design and manage bidirectional real-time long connections.
- **[WeChat Mini Program Compatible APIs](/AIUI/api/weixin-compatible-apis)**: See the wx APIs supported by AIUI.

## API Reference

### `new EventSource(url)`

Creates a Web-standard SSE client that connects to the required `url` with a GET request.

### `EventSource` Events and Methods

- `onopen`: Called when the connection opens.
- `onmessage`: Called for default message events; `data` contains the payload.
- `onerror`: Called when a connection error occurs.
- `close()`: Closes the connection.

### `wx.createEventSource(options)`

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `options.url` | `string` | Yes | SSE service URL. |
| `options.method` | `string` | No | HTTP method. Defaults to `GET`. |
| `options.header` | `object` | No | Request headers. |
| `options.data` / `options.body` | `string \| object \| ArrayBuffer` | No | Request body. |

**Returns:** `EventSourceTask`.

### `EventSourceTask`

- `onOpen(callback)`: Observes the connection-open event.
- `onMessage(callback)`: Observes messages with `{ data, event, id }`.
- `onError(callback)`: Observes errors with `{ errMsg }`.
- `close()`: Closes the connection.

All methods return `undefined`.
