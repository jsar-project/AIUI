# ErrorState 状态提示

`error-state` 用于在页面无法正常展示内容时，告诉用户发生了什么。例如网络加载失败、没有搜索结果，或者暂时没有可显示的数据。

## 显示一条提示

使用 `text` 设置提示内容：

```xml
<error-state text="加载失败，请稍后重试"></error-state>
```

## 添加提示图标

使用 `icon` 可以在文字左侧显示一张图片。它接受本地图片路径或网络图片地址。

```xml
<error-state
  icon="/assets/network-error.png"
  text="网络连接失败，请检查网络后重试"
></error-state>
```

如果不设置 `icon`，组件只显示文字。你也可以把它和按钮放在同一个容器中，为用户提供重试操作：

```xml
<view class="error-panel">
  <error-state text="内容加载失败"></error-state>
  <button bindtap="retry">重新加载</button>
</view>
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `text` | String | `""` | 要显示的提示文字。 |
| `icon` | String | - | 显示在文字左侧的图片路径或 URL。 |

`error-state` 不支持 `title` 和 `description` 属性。如果需要分别展示标题和说明，可以使用 `view` 和 `text` 自行组合。
