# Widget

Widget 是智能体提供的小尺寸独立界面，适合展示天气、播放状态、设备数据、快捷操作等一眼即可理解的信息。它和 Page 使用相同的 `.ink` 语法、数据绑定、组件与样式，但拥有独立入口和更精简的生命周期。

## 声明 Widget

先在 `app.json` 的 `widgets` 数组中声明 Widget。`path` 不包含扩展名，`family` 当前支持 `1x1` 和 `1x2`。

```json
{
  "pages": ["pages/index/index"],
  "widgets": [
    { "path": "widgets/clock/index", "family": "1x1" },
    { "path": "widgets/weather/index", "family": "1x2" }
  ]
}
```

每个路径都对应一个 `.ink` 文件。例如 `widgets/weather/index` 对应 `widgets/weather/index.ink`。

## 创建 Widget 界面

Widget 文件使用 `<widget>` 作为界面根节点。`<script def>` 中声明的 `family` 必须与 `app.json` 保持一致。

```html
<script def>
{
  "widget": { "family": "1x2" },
  "usingComponents": {
    "weather-icon": "/components/weather-icon/index"
  }
}
</script>

<script setup>
export default {
  data: {
    city: '杭州',
    temperature: 24,
  },
  refresh() {
    this.setData({ temperature: this.data.temperature + 1 });
  },
};
</script>

<widget>
  <view class="weather" bindtap="refresh">
    <weather-icon />
    <text>{{city}}</text>
    <text>{{temperature}}°C</text>
  </view>
</widget>

<style>
.weather {
  display: flex;
  flex-direction: column;
  padding: 12px;
}
</style>
```

一个 `.ink` 文件不能同时包含 `<page>` 和 `<widget>`。如果文件中的 `family` 与 `app.json` 不一致，Widget 将无法加载。

## 更新显示内容

Widget 使用 `data` 保存界面数据，并通过 `setData()` 更新显示内容。可以更新顶层字段，也可以使用点路径更新嵌套字段。

```javascript
export default {
  data: {
    status: { label: '待机' },
    count: 0,
  },
  activate() {
    this.setData({
      count: this.data.count + 1,
      'status.label': '运行中',
    });
  },
};
```

## 处理 Widget 的状态变化

Widget 提供四个可选回调：

| 回调 | 适合执行的操作 |
| :--- | :--- |
| `onCreate()` | 初始化 Widget 数据和只需执行一次的资源 |
| `onAttach()` | 刷新即将展示的数据，恢复可见时需要的任务 |
| `onDetach()` | 暂停只在 Widget 显示时需要的任务 |
| `onDestroy()` | 取消请求、移除监听并释放资源 |

```javascript
export default {
  data: { updatedAt: 0 },
  refresh() {
    this.setData({ updatedAt: Date.now() });
  },
  onCreate() {
    console.log('Widget 已创建');
  },
  onAttach() {
    this.refreshTimer = setInterval(() => this.refresh(), 60_000);
  },
  onDetach() {
    clearInterval(this.refreshTimer);
  },
  onDestroy() {
    clearInterval(this.refreshTimer);
  },
};
```

`onAttach()` 和 `onDetach()` 可能多次调用，因此恢复和暂停逻辑应允许重复执行。

## Widget 与 Page 的区别

- Widget 不进入 Page 导航栈。
- Widget 使用 `onCreate()`、`onAttach()`、`onDetach()` 和 `onDestroy()`，不使用 Page 的 `onLoad()`、`onShow()`、`onReady()`、`onHide()` 和 `onUnload()`。
- Widget 不提供 `enableWorldAwareness()` 和 `finish()` 等 Page 专属能力。
- Widget 可以使用数据绑定、自定义组件、事件处理、图片和 Canvas。
- Widget 的 `family` 用于表达界面尺寸类别；布局仍应适应实际可用宽高。

## 继续阅读

- [Widget API](/AIUI/api/framework-widget)：查看 `data`、`setData()`、尺寸和状态属性
- [app.json](/AIUI/framework/open-agent-format-app-json)：查看应用入口配置
- [组件](/AIUI/framework/open-agent-format-custom-components)：在 Widget 中复用界面组件
- [Canvas](/AIUI/api/canvas)：在 Widget 中绘制图形
