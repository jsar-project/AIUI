# 路由

AIUI 的路由能力用于在不同页面之间完成跳转、返回、重定向与页面栈管理。这里不展开接口细节，主要帮助你快速找到与页面导航相关的具体文档。

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

## API Reference

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
