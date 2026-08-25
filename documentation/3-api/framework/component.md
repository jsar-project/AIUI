# Component

`Component` 表示 AIUI 自定义组件在运行时暴露出来的实例对象。

当你在组件的 `methods`、`lifetimes` 或事件处理函数里通过 `this` 访问组件实例时，拿到的就是 `Component` 能力表面。

## 定义并使用组件

```javascript
export default {
  data: {
    count: 0
  },
  properties: {
    title: {
      type: String,
      value: 'Untitled'
    }
  },
  methods: {
    increment() {
      const nextCount = this.data.count + 1;

      this.setData({
        count: nextCount
      });

      this.triggerEvent('change', {
        value: nextCount
      });
    }
  }
}
```

## 生命周期中的 `this`

组件生命周期回调同样以当前组件实例作为 `this` 执行。

当前常见生命周期包括：

- `created`
- `attached`
- `ready`
- `moved`
- `detached`

```javascript
export default {
  lifetimes: {
    ready() {
      console.log(this.data);
    }
  }
}
```

## 检查具名插槽

运行时会把宿主提供的具名插槽快照放在 `this.$slots` 中，也可以用 `hasSlot()` 判断某个插槽是否有内容：

```javascript
export default {
  lifetimes: {
    ready() {
      if (this.hasSlot('actions')) {
        console.log(this.$slots.actions);
      }
    },
  },
};
```

## API Reference

### 实例成员

| 成员 | 类型 | 说明 |
| :--- | :--- | :--- |
| `this.data` | `Object` | 当前组件的本地状态对象 |
| `this.properties` | `Object` | 当前组件已解析的输入属性 |
| `this.setData(data, callback?)` | `Function` | 更新组件状态并触发视图刷新 |
| `this.triggerEvent(name, detail?)` | `Function` | 向父级派发自定义事件 |
| `this.$slots` | `Readonly<Record<string, readonly ComponentSlotEntry[]>>` | 宿主提供的具名插槽快照 |
| `this.hasSlot(name)` | `Function` | 判断指定具名插槽是否包含内容 |

写在 `methods` 里的方法会被直接挂到组件实例上，并以当前组件实例作为 `this` 执行。

### `this.data`

`data` 用来保存组件自己的可变状态。

- 如果组件定义里没有显式声明 `data`，运行时会初始化为空对象
- `setData()` 更新后，`this.data` 会同步反映最新状态
- 支持路径式更新，例如 `'profile.name': 'AIUI'`

### `this.properties`

`properties` 保存组件当前的输入属性值。

- 属性声明定义在 `properties` 配置项里
- 运行时会合并默认值和父级传入值
- `this.properties` 反映的是当前生效值

```javascript
export default {
  properties: {
    title: {
      type: String,
      value: 'Untitled'
    }
  },
  lifetimes: {
    created() {
      console.log(this.properties.title);
    }
  }
}
```

### `this.$slots` 与 `this.hasSlot(name)`

`this.$slots[name]` 中的条目包含以下字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `tagName` | `string` | 解析后的具体标签名。 |
| `attributes` | `Record<string, string>` | 来源节点的渲染属性。 |
| `textContent` | `string` | 可选的文本内容。 |
| `sourceComponentId` | `string` | 可选的来源自定义组件标识。 |

`this.hasSlot(name)` 返回 `boolean`，用于判断宿主是否向该具名插槽提供了内容。

### `this.setData(Object data, Function? callback)`

`setData()` 用于把逻辑层的数据补丁合并到当前组件状态中。

- `data` 必须是对象
- 顶层 key 会直接写入 `data`
- 点路径 key 会按需创建中间对象
- `callback` 会在更新完成后执行

```javascript
export default {
  data: {
    profile: {
      name: 'AIUI'
    }
  },
  methods: {
    updateProfile() {
      this.setData({
        'profile.name': 'AIUI Agent'
      }, () => {
        console.log('component state updated');
      });
    }
  }
}
```

### `this.triggerEvent(String name, Object? detail)`

`triggerEvent()` 用于从当前组件向父级派发自定义事件。

- `name` 是事件名
- `detail` 是可选的事件负载
- 父页面或父组件可以通过 `bind<event>` 监听

```javascript
export default {
  methods: {
    handleSelect() {
      this.triggerEvent('select', {
        id: this.properties.itemId
      });
    }
  }
}
```
