# OPFS

`navigator.storage` 提供当前 Agent 私有的 Origin Private File System（OPFS）。适合保存文件、二进制资源、离线缓存和体积超过简单键值数据的持久化内容。

## 写入文件

```javascript
const root = await navigator.storage.getDirectory();
const cache = await root.getDirectoryHandle('cache', { create: true });
const file = await cache.getFileHandle('draft.txt', { create: true });

const writable = await file.createWritable();
await writable.write(new Blob(['hello AIUI'], { type: 'text/plain' }));
await writable.close();
```

写入内容先保存在可写流缓冲区中，调用 `close()` 后才会提交到文件后端。

## 读取文件

```javascript
const snapshot = await file.getFile();
const bytes = await snapshot.arrayBuffer();

console.log(snapshot.name, snapshot.type, snapshot.lastModified);
console.log(bytes.byteLength);
```

`getFile()` 返回带有 `name`、`lastModified`、`size`、`type` 和 `arrayBuffer()` 的 `Blob` 快照。

## 遍历与删除目录内容

```javascript
for (const [name, handle] of root) {
  console.log(name, handle.kind);
}

await root.removeEntry('cache', { recursive: true });
```

## 可用性与当前行为

- 每个 Agent 使用独立的 OPFS 文件树，与 `localStorage` 和 wx 存储相互独立。
- 宿主未提供 OPFS 后端时，`navigator.storage` 方法会以 `NotSupportedError` 失败。
- 当前提供实用型 OPFS 子集，并非完整浏览器 File System Access API。
- `StorageManager` 与各种句柄不能通过构造函数直接创建。

## API Reference

### `navigator.storage`

| 方法 | 返回值 | 说明 |
| --- | --- | --- |
| `estimate()` | `Promise<{ usage: number, quota: number }>` | 获取当前用量与配额。 |
| `persisted()` | `Promise<boolean>` | 查询存储是否已持久化。 |
| `persist()` | `Promise<boolean>` | 请求持久化存储。 |
| `getDirectory()` | `Promise<FileSystemDirectoryHandle>` | 获取 Agent 私有根目录。 |

### `FileSystemDirectoryHandle`

| 成员 | 返回值或类型 | 说明 |
| --- | --- | --- |
| `kind` | `'directory'` | 句柄类型。 |
| `name` | `string` | 目录名称。 |
| `getDirectoryHandle(name, { create? })` | `Promise<FileSystemDirectoryHandle>` | 获取或创建子目录。 |
| `getFileHandle(name, { create? })` | `Promise<FileSystemFileHandle>` | 获取或创建文件。 |
| `removeEntry(name, { recursive? })` | `Promise<void>` | 删除目录项。 |
| `keys()` / `values()` / `entries()` | `Iterator` | 遍历当前目录；句柄本身也可迭代。 |

### `FileSystemFileHandle`

| 成员 | 返回值或类型 | 说明 |
| --- | --- | --- |
| `kind` | `'file'` | 句柄类型。 |
| `name` | `string` | 文件名称。 |
| `getFile()` | `Promise<Blob>` | 获取当前文件内容快照。 |
| `createWritable()` | `Promise<FileSystemWritableFileStream>` | 创建缓冲写入流。 |

### `FileSystemWritableFileStream`

| 方法 | 返回值 | 说明 |
| --- | --- | --- |
| `write(value)` | `Promise<void>` | 在当前位置写入 `string`、`Blob` 或二进制数据。 |
| `seek(position)` | `Promise<void>` | 设置下一次写入的字节位置。 |
| `truncate(size)` | `Promise<void>` | 调整缓冲区大小。 |
| `close()` | `Promise<void>` | 提交缓冲区并关闭写入流。 |
