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

## API Reference

### 实例成员

| 成员 | 类型 | 说明 |
| :--- | :--- | :--- |
| `entity.entityId` | `number` | 运行时实体 id |
| `entity.tagName` | `string` | 当前实体的标签名 |
| `entity.attributes` | `Object` | 当前实体属性的快照对象 |
| `entity.dataset` | `DOMStringMap` | 基于 `data-*` 属性的映射视图 |
| `entity.querySelector(selector)` | `Entity \| null` | 在当前实体子树内继续查询 |
| `entity.querySelectorAll(selector)` | `EntityList` | 在当前实体子树内查询全部匹配项 |

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
