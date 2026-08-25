# OPFS

`navigator.storage` exposes an Origin Private File System (OPFS) private to the current Agent. Use it for files, binary assets, offline caches, and persistent content that does not fit simple key-value storage.

## Write a File

```javascript
const root = await navigator.storage.getDirectory();
const cache = await root.getDirectoryHandle('cache', { create: true });
const file = await cache.getFileHandle('draft.txt', { create: true });

const writable = await file.createWritable();
await writable.write(new Blob(['hello AIUI'], { type: 'text/plain' }));
await writable.close();
```

Writes are buffered by the writable stream and committed to the file backend when `close()` runs.

## Read a File

```javascript
const snapshot = await file.getFile();
const bytes = await snapshot.arrayBuffer();

console.log(snapshot.name, snapshot.type, snapshot.lastModified);
console.log(bytes.byteLength);
```

`getFile()` returns a `Blob` snapshot with `name`, `lastModified`, `size`, `type`, and `arrayBuffer()`.

## Iterate and Remove Directory Entries

```javascript
for (const [name, handle] of root) {
  console.log(name, handle.kind);
}

await root.removeEntry('cache', { recursive: true });
```

## Availability and Current Behavior

- Each Agent has an isolated OPFS tree, separate from `localStorage` and wx storage.
- When the host provides no OPFS backend, `navigator.storage` methods fail with `NotSupportedError`.
- AIUI currently exposes a practical OPFS subset, not the complete browser File System Access API.
- `StorageManager` and the handle classes cannot be constructed directly.

## API Reference

### `navigator.storage`

| Method | Return Value | Description |
| --- | --- | --- |
| `estimate()` | `Promise<{ usage: number, quota: number }>` | Returns current usage and quota. |
| `persisted()` | `Promise<boolean>` | Reports whether storage is persistent. |
| `persist()` | `Promise<boolean>` | Requests persistent storage. |
| `getDirectory()` | `Promise<FileSystemDirectoryHandle>` | Returns the Agent-private root directory. |

### `FileSystemDirectoryHandle`

| Member | Return Value or Type | Description |
| --- | --- | --- |
| `kind` | `'directory'` | Handle kind. |
| `name` | `string` | Directory name. |
| `getDirectoryHandle(name, { create? })` | `Promise<FileSystemDirectoryHandle>` | Gets or creates a child directory. |
| `getFileHandle(name, { create? })` | `Promise<FileSystemFileHandle>` | Gets or creates a file. |
| `removeEntry(name, { recursive? })` | `Promise<void>` | Removes a directory entry. |
| `keys()` / `values()` / `entries()` | `Iterator` | Iterates the directory; the handle itself is also iterable. |

### `FileSystemFileHandle`

| Member | Return Value or Type | Description |
| --- | --- | --- |
| `kind` | `'file'` | Handle kind. |
| `name` | `string` | File name. |
| `getFile()` | `Promise<Blob>` | Returns a snapshot of the current file. |
| `createWritable()` | `Promise<FileSystemWritableFileStream>` | Creates a buffered writable stream. |

### `FileSystemWritableFileStream`

| Method | Return Value | Description |
| --- | --- | --- |
| `write(value)` | `Promise<void>` | Writes a `string`, `Blob`, or binary value at the current position. |
| `seek(position)` | `Promise<void>` | Sets the byte position for the next write. |
| `truncate(size)` | `Promise<void>` | Resizes the buffered content. |
| `close()` | `Promise<void>` | Commits buffered content and closes the stream. |
