# URL

AIUI 提供了一套遵循 Web 标准的 URL 解析和处理接口。你可以使用这些接口方便地解析、构造和修改 URL 及其查询参数。

## 解析 URL

```javascript
const url = new URL('https://user:pass@example.com:8080/path/to/page?id=123#section');

console.log(url.protocol); // "https:"
console.log(url.hostname); // "example.com"
console.log(url.port);     // "8080"
console.log(url.pathname); // "/path/to/page"
console.log(url.search);   // "?id=123"
console.log(url.hash);     // "#section"
```

## 修改 URL 参数

```javascript
const url = new URL('https://example.com/search');
url.searchParams.set('q', 'aiui');
url.searchParams.append('page', '1');

console.log(url.href); // "https://example.com/search?q=aiui&page=1"
```

## 构造相对 URL

```javascript
const base = 'https://rokid.com/docs/';
const url = new URL('aiui/start.html', base);

console.log(url.href); // "https://rokid.com/docs/aiui/start.html"
```

## API Reference

### 接口说明

#### URL

`URL` 接口用于解析、构造、规范化和编码 URL。

#### 构造函数

- **`new URL(url, base?)`**: 创建并返回一个 `URL` 对象。
    - `url`: `String`，表示绝对或相对 URL 的字符串。
    - `base`: `String?`，如果 `url` 是相对的，则以此作为基准 URL。

#### 属性

- **`href`**: `String`，完整的 URL 字符串。
- **`origin`**: `String`，URL 的源（协议 + 域名 + 端口），只读。
- **`protocol`**: `String`，URL 的协议（包含末尾的 `:`）。
- **`username`**: `String`，URL 中的用户名。
- **`password`**: `String`，URL 中的密码。
- **`host`**: `String`，URL 的主机名和端口。
- **`hostname`**: `String`，URL 的主机名（不含端口）。
- **`port`**: `String`，URL 的端口号。
- **`pathname`**: `String`，URL 的路径部分（以 `/` 开头）。
- **`search`**: `String`，URL 的查询字符串（以 `?` 开头）。
- **`hash`**: `String`，URL 的片段标识符（以 `#` 开头）。
- **`searchParams`**: `URLSearchParams`，用于处理查询参数的只读对象。

#### 方法

- **`toString()` / `toJSON()`**: 返回完整的 URL 字符串。

---

#### URLSearchParams

`URLSearchParams` 接口定义了一些处理 URL 查询参数的方法。

#### 构造函数

- **`new URLSearchParams(init?)`**: 返回一个 `URLSearchParams` 对象实例。
    - `init`: 可以是查询字符串（如 `"a=1&b=2"`）、键值对数组（如 `[['a', '1']]`）或普通对象（如 `{ a: '1' }`）。

#### 方法

- **`append(name, value)`**: 追加一个新的键值对。
- **`delete(name)`**: 删除指定名称的所有键值对。
- **`get(name)`**: 获取指定名称的第一个值，不存在则返回 `null`。
- **`getAll(name)`**: 获取指定名称的所有值，返回数组。
- **`has(name)`**: 判断是否存在指定名称的键。
- **`set(name, value)`**: 设置指定名称的值。如果已存在，则替换第一个并删除其余同名项。
- **`sort()`**: 按键名对查询参数进行排序。
- **`toString()`**: 返回序列化后的查询字符串。
