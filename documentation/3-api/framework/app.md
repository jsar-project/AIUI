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

## API Reference

### 生命周期回调

| 回调函数 | 说明 | 触发时机 |
| :--- | :--- | :--- |
| `onLaunch` | 监听智能体初始化 | 智能体初始化完成时（全局只触发一次） |
| `onShow` | 监听智能体显示 | 智能体启动，或从后台进入前台显示时 |
| `onHide` | 监听智能体隐藏 | 智能体从前台进入后台时 |
| `onError` | 错误监听函数 | 智能体发生脚本错误，或者 API 调用失败时 |
