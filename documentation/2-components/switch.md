# Switch 开关

`switch` 用于切换布尔状态，也可以显示为复选框。

## 切换设置状态

```xml
<switch checked="{{enabled}}" color="#04C160" bindchange="handleChange" />
```

```javascript
Page({
  data: { enabled: false },
  handleChange(event) {
    this.setData({ enabled: event.detail.value });
  },
});
```

## 显示复选框

```xml
<switch type="checkbox" checked="{{accepted}}" bindchange="handleAccept" />
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `checked` | Boolean | `false` | 当前是否选中。`true` 和 `1` 均会被识别为选中。 |
| `disabled` | Boolean | `false` | 是否禁止切换。 |
| `type` | String | `switch` | 设置为 `checkbox` 时使用复选框外观。 |
| `color` | String | `#04C160` | 选中状态的颜色，支持 CSS 颜色与自定义属性。 |

## 事件

| 事件 | 事件数据 | 说明 |
| --- | --- | --- |
| `bindchange` | `{ detail: { value: boolean } }` | 用户完成点击或触摸后触发。禁用时不会触发。 |
