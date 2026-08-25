# App

`App` is used to register an agent application.

## Define the App Lifecycle

```javascript
export default {
  onLaunch(options) {
    // 智能体初始化
  },
  onShow(options) {
    // 智能体显示
  },
  onHide() {
    // 智能体隐藏
  },
  globalData: {
    // 全局数据
  }
}
```

## Send a Message to the Host

The App instance can send structured data to the embedding AIUI host with `postMessage()`:

```javascript
export default {
  onLaunch() {
    this.postMessage(
      { type: 'app.ready' },
      { origin: 'aiui-agent', lastEventId: 'launch-1' },
    );
  },
};
```

## API Reference

### `getApp()`

Returns the current `App` instance so pages or components can access app-level state and methods.

### `app.postMessage(data, options?)`

Sends a JSON-compatible structured message to the host.

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `data` | `any` | Yes | JSON-compatible data to send. |
| `options.origin` | `string` | No | Sender identifier. Defaults to `'ink-js'`. |
| `options.lastEventId` | `string` | No | Correlation identifier forwarded with the message. |

### Lifecycle Callbacks

| Callback | Description | Trigger Timing |
| :--- | :--- | :--- |
| `onLaunch` | Listens for agent initialization | When agent initialization completes, only once globally |
| `onShow` | Listens for the agent being shown | When the agent starts, or returns from background to foreground |
| `onHide` | Listens for the agent being hidden | When the agent moves from foreground to background |
| `onError` | Error listener function | When a script error occurs in the agent, or when an API call fails |
