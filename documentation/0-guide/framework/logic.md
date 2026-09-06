# 逻辑开发

在 AIUI 中，逻辑层是把用户意图转化为可执行行为的核心部分。它采用类似现代前端框架的模块化开发方式：你可以通过 `export default` 导出配置对象来注册智能体或页面，并围绕意图处理来组织生命周期、状态和事件处理函数。

## 注册智能体 (App)

每个智能体项目必须在根目录下有一个 `app.js` 或 `app.ink`（在 SFC 模式下）。在 `.js` 文件中，通过 `export default` 导出智能体实例以完成注册；而 `.ink` 文件作为 SFC 入口，本身不支持模块导出，只能通过脚本块定义智能体逻辑并导入其他 ESM 模块。智能体实例用于处理全局生命周期、协调智能体级意图流转，以及存储全局数据。

### 示例代码

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

### 生命周期回调

| 回调函数 | 说明 | 触发时机 |
| :--- | :--- | :--- |
| `onLaunch` | 监听智能体初始化 | 智能体初始化完成时（全局只触发一次） |
| `onShow` | 监听智能体显示 | 智能体启动，或从后台进入前台显示时 |
| `onHide` | 监听智能体隐藏 | 智能体从前台进入后台时 |
| `onError` | 错误监听函数 | 智能体发生脚本错误，或者 API 调用失败时 |

## 注册页面 (Page)

每个页面通过在其逻辑文件（`.js` 或 `.ink`）中定义页面配置对象。在 `.js` 文件中，通过 `export default` 注册页面；而 `.ink` 文件则直接在 `<script setup>` 中定义逻辑并引入所需模块。该对象定义了页面的初始数据、生命周期回调、事件处理函数等。实际开发中，页面逻辑正是把用户意图翻译成状态迁移和界面更新的地方。

### 示例代码

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

### 生命周期回调

| 回调函数 | 说明 | 触发时机 |
| :--- | :--- | :--- |
| `onLoad` | 监听页面加载 | 页面加载时触发（全局只触发一次） |
| `onShow` | 监听页面显示 | 页面显示/切入前台时触发 |
| `onReady` | 监听页面初次渲染完成 | 页面初次渲染完成时触发（全局只触发一次） |
| `onHide` | 监听页面隐藏 | 页面隐藏/切入后台时触发 |
| `onUnload` | 监听页面卸载 | 页面卸载时触发 |

## 编写 Widget 逻辑

Widget 的逻辑写在 `.ink` 文件的 `<script setup>` 中。它同样通过 `data` 和 `setData()` 更新界面，但使用自己的显示状态回调：

```javascript
export default {
  data: { status: '准备就绪' },
  onCreate() {
    this.setData({ status: '已创建' });
  },
  onAttach() {
    this.setData({ status: '正在显示' });
  },
  onDetach() {
    console.log('Widget 已隐藏');
  },
  onDestroy() {
    console.log('Widget 已销毁');
  },
};
```

`onAttach()` 和 `onDetach()` 可能多次调用。Widget 的声明、尺寸和完整结构请参阅 [Widget 开发](/AIUI/framework/open-agent-format-widget)。

## 编写 Agent Worker 逻辑

Agent Worker 不渲染界面。每次 Page 或 Widget 成功打开时，运行时调用 `onOpen(event)`。如果其中启动了异步任务，需要立即用 `event.waitUntil()` 登记：

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

同一个正在运行的 Agent Worker 会保留对象上的数据，适合管理多个入口共用的初始化任务或蓝牙服务。完整配置请参阅 [Agent Worker 开发](/AIUI/framework/open-agent-format-agent-worker)。

## Page 与 Widget 数据方法

在 Page 或 Widget 逻辑中，可以通过 `this` 访问当前实例：

- **`this.setData(Object data, Function callback)`**：更新数据和受影响的界面内容。
- **`this.data`**：获取当前 Page 或 Widget 的数据。
