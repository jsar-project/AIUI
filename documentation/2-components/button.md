# Button 按钮

`button` 用于创建可以点击的操作入口，例如提交表单、确认选择或重新加载内容。

## 响应点击

使用 `bindtap` 绑定页面中的处理函数：

```xml
<button bindtap="handleSubmit">提交</button>
```

```javascript
Page({
  handleSubmit() {
    console.log('用户点击了提交按钮');
  }
});
```

按钮会默认让子内容水平、垂直居中。你可以通过 CSS 设置背景、边框和文字颜色：

```css
button {
  padding: 12px 20px;
  color: #ffffff;
  background-color: #07c160;
  border-radius: 8px;
}
```

`button` 本身不提供特定的触摸动画。需要按下反馈时，请根据应用的视觉风格通过样式实现。
