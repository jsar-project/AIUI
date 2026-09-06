# Entity

`Entity` 表示 AIUI 页面实体树中暴露出来的节点包装对象。

当你需要读取某个节点的属性、访问它的 `dataset`，或者继续在该节点子树内做查询时，就会用到 `Entity`。

## 如何拿到 `Entity`

`Entity` 不能直接通过构造函数创建，通常来自页面级或实体级查询。

```javascript
const title = page.querySelector('.title');
const items = page.querySelectorAll('.item');
const first = items.item(0);
```

当前行为：

- `new Entity()` 会直接抛错
- `page.querySelector(selector)` 返回 `Entity` 或 `null`
- `page.querySelectorAll(selector)` 返回 `EntityList`
- `entity.querySelector(selector)` 只在当前实体的子树内继续查询

## 控制滚动位置

查询到 `scroll-view` 后，可以读取当前位置和内容尺寸，也可以立即或平滑滚动：

```javascript
const list = page.querySelector('#results');

console.log(list.scrollTop, list.scrollHeight);

const result = await list.scrollTo({
  top: list.scrollHeight,
  behavior: 'smooth'
});

if (result.interrupted) {
  console.log('滚动被新的操作打断');
}
```

`scrollTo()` 移动到指定位置，`scrollBy()` 在当前位置基础上移动一段距离。用户操作或后续滚动命令可能打断平滑滚动，此时返回结果的 `interrupted` 为 `true`。

## API Reference

### 实例成员

| 成员 | 类型 | 说明 |
| :--- | :--- | :--- |
| `entity.entityId` | `number` | 运行时实体 id |
| `entity.tagName` | `string` | 当前实体的标签名 |
| `entity.attributes` | `Object` | 当前实体属性的快照对象 |
| `entity.dataset` | `DOMStringMap` | 基于 `data-*` 属性的映射视图 |
| `entity.scrollTop` / `scrollLeft` | `number` | 当前纵向或横向滚动位置，可读写 |
| `entity.scrollWidth` / `scrollHeight` | `number` | 可滚动内容的宽度或高度，只读 |
| `entity.clientWidth` / `clientHeight` | `number` | 当前可视区域的宽度或高度，只读 |
| `entity.scrollBottom` | `number` | 距离内容底部的剩余距离，只读 |
| `entity.isAtBottom` | `boolean` | 是否已经滚动到底部，只读 |
| `entity.scrollTo(x, y)` | `Promise<EntityScrollResult>` | 滚动到指定坐标 |
| `entity.scrollTo(options?)` | `Promise<EntityScrollResult>` | 使用坐标和动画方式滚动到指定位置 |
| `entity.scrollBy(x, y)` | `Promise<EntityScrollResult>` | 在当前位置基础上滚动 |
| `entity.scrollBy(options?)` | `Promise<EntityScrollResult>` | 使用坐标和动画方式滚动一段距离 |
| `entity.querySelector(selector)` | `Entity \| null` | 在当前实体子树内继续查询 |
| `entity.querySelectorAll(selector)` | `EntityList` | 在当前实体子树内查询全部匹配项 |

### 滚动方法参数

对象形式支持 `left`、`top` 和 `behavior`。`behavior` 可以是 `auto`、`instant` 或 `smooth`。方法返回的 Promise 会得到 `{ interrupted: boolean }`。

设置 `scrollTop` 或 `scrollLeft` 会立即滚动，并把超出范围的值限制在有效滚动区域内。普通的非滚动节点会保持在 `0`。

### `entity.attributes`

`attributes` 返回当前实体属性表的快照对象。

```javascript
const title = page.querySelector('.title');

console.log(title.attributes.role);
```

它适合用于读取节点当前已经解析好的属性值。

### `entity.dataset`

`dataset` 会把实体上的 `data-*` 属性映射成可读写视图。

```javascript
const item = page.querySelectorAll('.item').item(1);

console.log(item.dataset.userId);
item.dataset.count = 7;
delete item.dataset.index;
```

当前行为：

- `data-user-id` 会映射成 `dataset.userId`
- 对 `dataset` 的写入会回写到底层实体属性
- 删除 `dataset` 字段时，会同步删除对应的 `data-*` 属性

### `entity.querySelector(String selector)`

`querySelector()` 用于在当前实体的子树范围内查找第一个匹配节点。

- 非法 selector 会直接抛错
- 没有命中时返回 `null`

### `entity.querySelectorAll(String selector)`

`querySelectorAll()` 用于在当前实体的子树范围内查询所有匹配节点。

- 返回值是 `EntityList`
- 查询范围只限当前实体子树

```javascript
const container = page.querySelector('#container');
const title = container.querySelector('.title');
const items = container.querySelectorAll('[selected]');
```

### `EntityList`

`EntityList` 是 `querySelectorAll()` 返回的可迭代结果容器。

常见成员包括：

- `length`
- `item(index)`
- `at(index)`，支持负索引
- 可用于 `for...of` 和 `Array.from(...)`

```javascript
const items = page.querySelectorAll('.item');

console.log(items.length);
console.log(items.item(0)?.tagName);
console.log(items.at(-1)?.attributes['data-index']);
```
