# Textarea 多行输入框

`textarea` 用于编辑包含换行的多行文本，并在获得焦点后显示输入光标。

## 编辑多行内容

```xml
<textarea value="{{notes}}" placeholder="填写备注" maxLength="500" bindinput="handleInput" />
```

```javascript
Page({
  data: { notes: '' },
  handleInput(event) {
    this.setData({ notes: event.detail.value });
  },
});
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `value` | String | `""` | 当前文本，可以包含换行符。 |
| `placeholder` | String | `""` | 输入框为空且未聚焦时显示的提示。 |
| `disabled` | Boolean | `false` | 是否忽略键盘输入。 |
| `maxLength` | Number | - | 允许输入的最大字符数。 |

组件使用 `white-space: pre-wrap` 显示换行。占位文字颜色规则与 `input` 一致。

## 事件

| 事件 | 事件数据 | 说明 |
| --- | --- | --- |
| `bindinput` | `{ detail: { value: string } }` | 每次文本变化时触发。 |
