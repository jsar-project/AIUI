# View 视图容器

`view` 组件是用户界面的基础构建块。它类似于 HTML 中的 `div` 元素。

## 组织页面内容

```xml
<view class="container">
  <view class="item">项目 1</view>
  <view class="item">项目 2</view>
</view>
```

## 功能特性

- 支持 Flexbox 弹性盒布局。
- 可以包含其他组件。
- 支持背景色、边框以及标准的盒模型属性。

`row`、`column`、`swiper`、`swiper-item` 与 `fragment` 当前复用 `view` 的组件实现，可通过相同的子节点和 CSS 布局能力组织内容。其中标签名本身不会额外提供轮播行为。
