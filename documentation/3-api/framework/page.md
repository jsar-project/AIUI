# Page

`Page` 用于注册智能体中的一个页面。每个页面的逻辑通过 `export default` 导出一个配置对象。

运行时会把默认导出对象上的可枚举属性挂到页面实例上，同时补充页面内建能力，例如 `data`、`setData()`、`postMessage()`、`querySelector()` 和环境感知相关 API。

此外，`Page` 继承事件目标能力，因此也可以使用标准事件方法，例如 `addEventListener()`、`removeEventListener()` 和 `dispatchEvent()`。

## 定义页面并更新状态

```javascript
export default {
  data: {
    text: "This is page data.",
    user: {
      name: 'Rokid'
    }
  },
  onLoad(options) {
    // 页面加载
    const title = this.querySelector('.title');
    console.log(title?.tagName);
  },
  handleUpdate() {
    // 更新数据
    this.setData({
      text: 'Updated Text',
      'user.name': 'New Name' // 支持路径式更新
    }, () => {
      console.log('Data updated');
    });
  },
  handleNotifyHost() {
    this.postMessage({
      type: 'page.ready',
      payload: {
        text: this.data.text
      }
    });
  },
  handleComplete() {
    // 完成当前页面任务
    this.finish();
  },
}
```

## API Reference

### 实例属性与方法

在页面逻辑中，可以通过 `this` 访问页面实例，并使用以下属性和方法。

#### `this.data`

`data` 表示当前页面的状态对象。

- 如果默认导出里提供了 `data`，运行时会把它作为当前页面状态
- 如果没有提供 `data`，运行时会自动初始化成空对象 `{}`
- 直接给 `this.data` 赋一个新对象时，会替换当前保存的状态对象

#### `this.setData(Object data, Function? callback)`

用于将数据从逻辑层发送到视图层（异步），同时改变对应的 `this.data` 的值。

- **参数**:
  - `data`: 包含需要更新的数据键值对。支持以数据路径的形式给出，例如 `'a.b.c': 1`
  - `callback`: 可选。数据更新完成后的回调函数

当前运行时行为：

- 第一个参数必须是对象，否则会抛错
- 普通顶层 key 会直接写入 `this.data`
- 点路径 key 会在需要时自动创建中间对象
- 如果传入 `callback`，会在数据更新并完成同步后执行

#### `this.postMessage(any data, Object? options)`

向承载当前页面的外部宿主发送一条 JSON 兼容消息。

- **参数**:
  - `data`: 要发送的 JSON 兼容数据
  - `options`: 可选的消息元信息对象
    - `origin?: string`: 消息来源标识，默认值为 `"ink-js"`
    - `lastEventId?: string`: 可选事件 id，会原样透传

```javascript
this.postMessage(
  {
    type: 'summary.refresh',
    payload: { force: true }
  },
  {
    origin: 'ink-js',
    lastEventId: 'page-msg-1'
  }
);
```

#### `this.querySelector(String selector)`

用于在当前页面实体树中查找第一个匹配的实体。

- 返回首个命中的 `Entity`
- 如果没有命中，则返回 `null`
- 非法 selector 会直接抛错

#### `this.querySelectorAll(String selector)`

用于在当前页面实体树中查询所有匹配的实体。

- 返回 `EntityList`
- 查询范围仅限当前页面
- 非法 selector 会直接抛错

### 环境感知

`World Awareness` 是页面级的环境感知能力，用来让当前页面直接接入空间朝向、稳定性变化和头部手势等环境感知信息。

启用后，运行时会把感知能力限制在当前页面内部。这意味着：

- 页面可以拥有私有的 `orientationSensor`
- 页面可以接收 `headgesture` 事件
- 页面可以接收 `orientationstabilitychange` 事件
- 页面卸载时，运行时会自动关闭这一组能力

当前运行时行为：

- `enableWorldAwareness()` 会创建或复用页面私有的 `orientationSensor`
- 原生页面逻辑会启动页面级 `AbsoluteOrientationSensor`
- `disableWorldAwareness()` 会停止当前页面级传感器会话并关闭相关回调
- 运行时会在 `onUnload()` 完成前自动调用 `disableWorldAwareness()`

如果你需要页面感知空间姿态或环境变化，通常应先启用 world awareness，再通过页面回调或 `this.orientationSensor` 读取相关信息。

#### `this.enableWorldAwareness(Object? options)`

将当前页面切换到页面级环境感知模式，用于启用环境感知相关能力。

- 当前运行时会创建或复用页面私有的 `orientationSensor`
- 运行时会从原生页面逻辑中启动页面级 `AbsoluteOrientationSensor`
- 启用后，页面可接收 `headgesture` 和 `orientationstabilitychange` 的回调投递
- 传感器实例保持为当前页面私有，而不是挂载到 `navigator` 上

- **参数**:
  - `options`: 可选配置对象
    - `mode?: "normal" | "micro"`: 头部手势模式。默认是 `"normal"`；传入 `"micro"` 时，会降低手势阈值，更适合轻微头部动作；其他值当前按 `"normal"` 处理

#### `this.disableWorldAwareness()`

停止当前页面级传感器会话，并关闭相关页面回调。

- 运行时会在 `onUnload()` 完成前自动调用它，因此页面通常不需要在卸载清理里手动关闭 world awareness

#### `this.orientationSensor`

当 world awareness 启用后，页面实例会通过 `this.orientationSensor` 暴露当前页面私有的 `AbsoluteOrientationSensor` 实例。

- 在 `enableWorldAwareness()` 执行前，它的值是 `undefined`
- 可用于读取 `quaternion`、`timestamp`、`stable` 和 `stabilityThreshold`
- 页面通常通过 `onOrientationStabilityChange(event)` 接收稳定性变化；如果需要，也可以直接给该传感器实例注册事件监听器

#### `this.finish()`

通知系统当前页面任务已完成。

- 对于 **Cut (快切)** 智能体，调用此方法将主动交回焦点并退出当前展示状态
- 对于 **Scene (场景)** 智能体，通常用于结束当前特定交互流程

### 生命周期回调

| 回调函数 | 说明 | 触发时机 |
| :--- | :--- | :--- |
| `onLoad` | 监听页面加载 | 页面加载时触发（全局只触发一次） |
| `onShow` | 监听页面显示 | 页面显示/切入前台时触发 |
| `onReady` | 监听页面初次渲染完成 | 页面初次渲染完成时触发（全局只触发一次） |
| `onHide` | 监听页面隐藏 | 页面隐藏/切入后台时触发 |
| `onUnload` | 监听页面卸载 | 页面卸载时触发。运行时会在该阶段结束前自动关闭 world awareness。 |
| `onHeadGesture` | 监听页面级头部手势 | 启用 `enableWorldAwareness()` 后，在页面收到 `headgesture` 时触发 |
| `onHeadGestureStateChange` | 监听头部手势状态 | 启用 `enableWorldAwareness()` 后，在手势进入 `start`、`update`、`end` 或 `cancel` 状态时触发 |
| `onOrientationStabilityChange` | 监听页面级方向稳定性变化 | 启用 `enableWorldAwareness()` 后，在页面收到 `orientationstabilitychange` 时触发 |
| `onMessage` | 接收宿主消息 | 宿主向当前页面发送一次性数据或流式消息时触发；数据位于 `event.data` |
