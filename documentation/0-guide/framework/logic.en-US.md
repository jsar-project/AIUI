# Logic Development

In AIUI, the logic layer is the part that turns user intent into executable behavior. It adopts a modular development model similar to modern frontend frameworks: you register an agent or page by exporting a configuration object with `export default`, and organize lifecycle, state, and event handlers around how intent should be processed.

## Register an Agent (App)

Every agent project must have an `app.js` or `app.ink` in the root directory (in SFC mode). In a `.js` file, the agent instance is registered by exporting it with `export default`. In a `.ink` file, as the SFC entry, module export is not supported directly. Instead, agent logic must be defined inside script blocks and other ESM modules can be imported as needed. The agent instance is used to handle global lifecycle hooks, coordinate agent-level intent flow, and store global shared data.

### Example Code

```javascript
// app.js
export default {
  // 智能体初始化时触发
  onLaunch(options) {
    console.log('Agent Launch', options);
  },
  // 智能体启动或从后台进入前台时触发
  onShow(options) {
    console.log('Agent Show');
  },
  // 智能体从前台进入后台时触发
  onHide() {
    console.log('Agent Hide');
  },
  // 全局共享数据
  globalData: {
    userInfo: null
  }
}
```

### Lifecycle Callbacks

| Callback | Description | Trigger Timing |
| :--- | :--- | :--- |
| `onLaunch` | Listen for agent initialization | Triggered when agent initialization completes (only once globally) |
| `onShow` | Listen for the agent being shown | Triggered when the agent starts, or returns from background to foreground |
| `onHide` | Listen for the agent being hidden | Triggered when the agent moves from foreground to background |
| `onError` | Error listener | Triggered when the agent encounters a script error or an API call fails |

## Register a Page (Page)

Each page is defined by a page configuration object in its logic file (`.js` or `.ink`). In a `.js` file, the page is registered through `export default`; in a `.ink` file, the logic is defined directly inside `<script setup>` and required modules are imported there. This object defines the page's initial data, lifecycle callbacks, event handlers, and more. In practice, page logic is where user intent is translated into state transitions and UI updates.

### Example Code

```javascript
// pages/index/index.js
export default {
  // 页面的初始数据
  data: {
    title: 'Hello AIUI',
    count: 0
  },
  // 页面加载时触发
  onLoad(query) {
    console.log('Page Load', query);
  },
  // 页面显示时触发
  onShow() {
    console.log('Page Show');
  },
  // 页面初次渲染完成时触发
  onReady() {
    console.log('Page Ready');
  },
  // 页面隐藏时触发
  onHide() {
    console.log('Page Hide');
  },
  // 页面卸载时触发
  onUnload() {
    console.log('Page Unload');
  },
  // 事件处理函数
  handleIncrement() {
    this.setData({
      count: this.data.count + 1
    });
  }
}
```

### Lifecycle Callbacks

| Callback | Description | Trigger Timing |
| :--- | :--- | :--- |
| `onLoad` | Listen for page loading | Triggered when the page loads (only once globally) |
| `onShow` | Listen for the page being shown | Triggered when the page is shown or enters the foreground |
| `onReady` | Listen for the page's first render completion | Triggered when the page finishes its first render (only once globally) |
| `onHide` | Listen for the page being hidden | Triggered when the page is hidden or enters the background |
| `onUnload` | Listen for page unload | Triggered when the page is unloaded |

## Write Widget Logic

Widget logic lives in the `<script setup>` block of its `.ink` file. Widgets also update their interface through `data` and `setData()`, but use their own display-state callbacks:

```javascript
export default {
  data: { status: 'Ready' },
  onCreate() {
    this.setData({ status: 'Created' });
  },
  onAttach() {
    this.setData({ status: 'Visible' });
  },
  onDetach() {
    console.log('Widget hidden');
  },
  onDestroy() {
    console.log('Widget destroyed');
  },
};
```

`onAttach()` and `onDetach()` can run more than once. For declarations, sizes, and the complete file structure, see [Widget Development](/AIUI/framework/open-agent-format-widget).

## Write Agent Worker Logic

An Agent Worker does not render an interface. Each time a Page or Widget opens successfully, the runtime calls `onOpen(event)`. Register asynchronous work immediately with `event.waitUntil()`:

```javascript
export default {
  onOpen(event) {
    event.waitUntil(this.prepare());
  },
  async prepare() {
    await new Promise((resolve) => setTimeout(resolve, 100));
    this.ready = true;
  },
};
```

The same running Agent Worker retains data on its object, which is useful for one shared initialization task or Bluetooth service. For complete configuration, see [Agent Worker Development](/AIUI/framework/open-agent-format-agent-worker).

## Page and Widget Data Methods

In Page or Widget logic, use `this` to access the current instance:

- **`this.setData(Object data, Function callback)`**: Updates data and the affected interface content.
- **`this.data`**: Gets the current Page or Widget data.
