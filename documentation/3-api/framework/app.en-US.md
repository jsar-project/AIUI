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

## API Reference

### Lifecycle Callbacks

| Callback | Description | Trigger Timing |
| :--- | :--- | :--- |
| `onLaunch` | Listens for agent initialization | When agent initialization completes, only once globally |
| `onShow` | Listens for the agent being shown | When the agent starts, or returns from background to foreground |
| `onHide` | Listens for the agent being hidden | When the agent moves from foreground to background |
| `onError` | Error listener function | When a script error occurs in the agent, or when an API call fails |
