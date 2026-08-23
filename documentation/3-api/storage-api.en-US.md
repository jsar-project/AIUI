# localStorage

AIUI provides a set of local storage APIs that follow the Web Storage API standard. The most commonly used one is `localStorage`, which you can use to persist data on the user's device.

## Store And Read Data

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
// Store data
localStorage.setItem('username', 'Rokid Agent');
localStorage.setItem('version', '1.0.0');

// Read data
const name = localStorage.getItem('username');
console.log(name); // "Rokid Agent"

// Read a missing key
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

## Remove And Clear Data

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
// Remove a specific item
localStorage.removeItem('version');

// Clear all storage
localStorage.clear();
```

**wx**

```javascript api-style=wx
wx.removeStorageSync('version');
wx.clearStorageSync();
```

<!-- /aiui-api-style -->

## Store Object Data

Since `Storage` only supports storing strings, you need to serialize objects before storing them.

```javascript
const user = { id: 1, name: 'Admin' };

// Serialize before storing
localStorage.setItem('userInfo', JSON.stringify(user));

// Read and deserialize
const savedUser = JSON.parse(localStorage.getItem('userInfo'));
console.log(savedUser.name); // "Admin"
```

## Notes

- **Data type**: The `value` argument of `setItem` must be a string. If you pass another type, the system automatically converts it to a string. For complex objects, call `JSON.stringify()` manually before storing.
- **Isolation**: Storage is isolated per agent. Different agents cannot access each other's stored data.

See [WeChat Mini Program Compatible APIs](/AIUI/api/weixin-compatible-apis) for the complete wx compatibility list.

## API Reference

### API Description

#### localStorage

`localStorage` lets you store key-value data in an agent. Data stored in `localStorage` does not expire.

#### Methods

- **`getItem(key)`**: Gets the value associated with the specified key.
    - `key`: `String`, the key to retrieve.
    - Return value: `String` or `null` if the key does not exist.
- **`setItem(key, value)`**: Sets the value associated with the specified key. If the key already exists, its value is updated.
    - `key`: `String`, the key to set.
    - `value`: `String`, the value to store.
- **`removeItem(key)`**: Removes the data item for the specified key.
    - `key`: `String`, the key to remove.
- **`clear()`**: Clears all data stored for the current agent.
