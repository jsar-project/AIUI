# localStorage

AIUI 提供了一套遵循 Web Storage API 标准的本地存储接口。开发者最常用的是 `localStorage`，可以用它在用户设备上持久化存储数据。

## 存储与读取数据

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
// 存储数据
localStorage.setItem('username', 'Rokid Agent');
localStorage.setItem('version', '1.0.0');

// 读取数据
const name = localStorage.getItem('username');
console.log(name); // "Rokid Agent"

// 读取不存在的键
const theme = localStorage.getItem('theme');
console.log(theme); // null
```

**wx**

```javascript api-style=wx
wx.setStorageSync('username', 'Rokid Agent');
wx.setStorageSync('version', '1.0.0');

const name = wx.getStorageSync('username');
console.log(name); // "Rokid Agent"

const theme = wx.getStorageSync('theme');
console.log(theme); // undefined
```

<!-- /aiui-api-style -->

## 移除与清空数据

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
// 移除特定项
localStorage.removeItem('version');

// 清空所有存储
localStorage.clear();
```

**wx**

```javascript api-style=wx
wx.removeStorageSync('version');
wx.clearStorageSync();
```

<!-- /aiui-api-style -->

## 存储对象数据

由于 `Storage` 仅支持存储字符串，存储对象前需要进行序列化。

```javascript
const user = { id: 1, name: 'Admin' };

// 序列化后存储
localStorage.setItem('userInfo', JSON.stringify(user));

// 读取并反序列化
const savedUser = JSON.parse(localStorage.getItem('userInfo'));
console.log(savedUser.name); // "Admin"
```

## 注意事项

- **数据类型**: `setItem` 的 `value` 参数必须是字符串。如果传入其他类型，系统会自动将其转换为字符串。建议在存储复杂对象前手动调用 `JSON.stringify()`。
- **隔离性**: 存储空间是按智能体（Agent）隔离的，不同智能体之间无法访问彼此的存储数据。

完整的 wx 兼容接口见[微信小程序兼容 API](/AIUI/api/weixin-compatible-apis)。

## API Reference

### 接口说明

#### localStorage

`localStorage` 允许你在智能体中存储键值对数据。存储在 `localStorage` 中的数据没有过期时间。

#### 方法

- **`getItem(key)`**: 获取指定键名对应的值。
    - `key`: `String`，要获取的键名。
    - 返回值: `String` 或 `null`（如果键名不存在）。
- **`setItem(key, value)`**: 设置指定键名对应的值。如果键名已存在，则更新其值。
    - `key`: `String`，要设置的键名。
    - `value`: `String`，要设置的值。
- **`removeItem(key)`**: 移除指定键名的数据项。
    - `key`: `String`，要移除的键名。
- **`clear()`**: 清除当前智能体存储的所有数据。
