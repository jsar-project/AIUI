# 路由

AIUI 的路由能力用于打开 Widget，以及在应用内完成页面跳转、返回、重定向与页面栈管理。

## 打开 Widget

使用 `window.open()` 打开在 `app.json` 中声明的 Widget。路径不包含 `.ink` 扩展名，可以在路径后携带查询参数：

```javascript
window.open('widgets/weather?city=hangzhou', '_widget');
```

`target` 可以省略，默认值为 `_widget`：

```javascript
window.open('widgets/weather?city=hangzhou');
```

当前只能通过 `window.open()` 打开 Widget，暂不支持打开其他 Page。调用会立即返回，不会返回 Widget 实例或打开结果。

## 跳转到详情页

例如，从首页跳转到详情页：

```javascript
wx.navigateTo({
  url: '/pages/detail/index?id=1'
});
```

继续阅读：

- **[微信小程序兼容 API](/AIUI/api/weixin-compatible-apis)**：查看 `wx.navigateTo`、`wx.redirectTo`、`wx.navigateBack` 等接口。
- **[App](/AIUI/api/framework-app)**：了解应用级配置与生命周期入口。
- **[Page](/AIUI/api/framework-page)**：了解页面的定义方式与页面级行为。
- **[Widget](/AIUI/api/framework-widget)**：了解 Widget 数据、状态和尺寸 API。
- **[AgentWorker](/AIUI/api/framework-agent-worker)**：了解后台任务的事件和实例 API。

## API Reference

### `window.open(url, target?)`

打开一个已声明的 Widget。也可以使用等价的全局函数 `open(url, target?)`。

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `url` | `string` | 是 | Widget 路径以及可选的查询参数，例如 `widgets/weather?city=hangzhou` |
| `target` | `'_widget'` | 否 | 打开目标，默认值为 `'_widget'`；当前仅支持该值 |

返回 `undefined`。如果 `url` 不是字符串或去除首尾空格后为空，会同步抛出 `TypeError`。

### wx APIs

#### `wx.navigateTo(options)`

保留当前页面并跳转到应用内的普通页面，不能跳转到 tabBar 页面。

#### `wx.redirectTo(options)`

关闭当前页面并跳转到应用内的普通页面，不能跳转到 tabBar 页面。

#### `wx.navigateBack(options?)`

关闭当前页面并返回上一页面或多级页面。

#### 路由参数

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `options.url` | `string` | `navigateTo`、`redirectTo` 必填 | 应用内目标页面路径，可携带查询参数。 |
| `options.delta` | `number` | 否 | `navigateBack` 返回的页面层级，默认为 `1`。 |
| `options.success` | `Function` | 否 | 调用成功回调。 |
| `options.fail` | `Function` | 否 | 调用失败回调。 |
| `options.complete` | `Function` | 否 | 调用完成回调。 |

以上方法返回 `undefined`。
