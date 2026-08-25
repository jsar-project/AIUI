# App

`App` 用于注册一个智能体应用。

## 定义应用生命周期

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

## 向宿主发送消息

应用实例可以通过 `postMessage()` 向嵌入 AIUI 的宿主发送结构化数据：

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

返回当前 `App` 实例，可用于从页面或组件访问应用级状态与方法。

### `app.postMessage(data, options?)`

向宿主发送 JSON 兼容的结构化消息。

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `data` | `any` | 是 | 要发送的 JSON 兼容数据。 |
| `options.origin` | `string` | 否 | 发送方标识，默认是 `'ink-js'`。 |
| `options.lastEventId` | `string` | 否 | 随消息透传的关联标识。 |

### 生命周期回调

| 回调函数 | 说明 | 触发时机 |
| :--- | :--- | :--- |
| `onLaunch` | 监听智能体初始化 | 智能体初始化完成时（全局只触发一次） |
| `onShow` | 监听智能体显示 | 智能体启动，或从后台进入前台显示时 |
| `onHide` | 监听智能体隐藏 | 智能体从前台进入后台时 |
| `onError` | 错误监听函数 | 智能体发生脚本错误，或者 API 调用失败时 |
