# 数据流

Streams API 用于分段处理持续到达的数据。它可以让你在完整内容下载结束前就开始读取、转换或写入，适合大文件、实时文本和语音数据。

如果只需要一次读取完整结果，直接使用 `response.json()`、`response.text()` 或 `response.arrayBuffer()` 会更简单。

## 逐段读取响应

`fetch()` 的 `response.body` 是一个 `ReadableStream`：

```javascript
const response = await fetch('https://example.com/stream');
const reader = response.body.getReader();

try {
  while (true) {
    const { value, done } = await reader.read();
    if (done) break;
    console.log('收到一段数据', value);
  }
} finally {
  reader.releaseLock();
}
```

一个流同时只能被一个 reader 锁定。读取结束后调用 `releaseLock()`，其他代码才能继续获取 reader。

## 创建并转换数据流

```javascript
const source = new ReadableStream({
  start(controller) {
    controller.enqueue('hello');
    controller.enqueue('aiui');
    controller.close();
  }
});

const upperCase = new TransformStream({
  transform(chunk, controller) {
    controller.enqueue(chunk.toUpperCase());
  }
});

const reader = source.pipeThrough(upperCase).getReader();
console.log(await reader.read());
```

`ReadableStream` 可以传递字符串、对象或二进制数据，不限于网络字节。

## 写入目标

```javascript
const destination = new WritableStream({
  async write(chunk) {
    await saveChunk(chunk);
  },
  close() {
    console.log('全部写入完成');
  }
});

const writer = destination.getWriter();
await writer.write('first');
await writer.write('second');
await writer.close();
```

连续写入时应等待 `write()` 返回的 Promise，避免写入速度超过目标的处理速度。

## 当前限制

- `ReadableStream.tee()` 当前不支持，调用时会抛出异常。
- 使用 reader 或 writer 后，应在不再需要时调用 `releaseLock()`。
- `pipeTo()` 支持 `preventClose`、`preventAbort`、`preventCancel` 和 `signal` 选项。

## API Reference

### `ReadableStream`

构造函数接受可选的 `underlyingSource` 和队列策略。数据源可以实现 `start(controller)`、`pull(controller)`、`cancel(reason)`。

| 成员 | 说明 |
| --- | --- |
| `locked` | 流当前是否已被 reader 锁定。 |
| `getReader()` | 获取 reader。 |
| `cancel(reason?)` | 取消读取。 |
| `pipeThrough(transform, options?)` | 经过转换流后返回新的可读流。 |
| `pipeTo(destination, options?)` | 把数据写入目标流。 |

reader 提供 `read()`、`cancel()`、`releaseLock()` 和 `closed`。

### `WritableStream`

构造函数接受可选的 `underlyingSink` 和队列策略。目标可以实现 `start()`、`write()`、`close()`、`abort()`。

实例提供 `locked`、`getWriter()`、`close()` 和 `abort()`。writer 提供 `write()`、`close()`、`abort()`、`releaseLock()`、`ready`、`closed` 和 `desiredSize`。

### `TransformStream`

构造函数接受实现 `start()`、`transform()`、`flush()` 的转换器。实例通过 `writable` 接收输入，通过 `readable` 输出转换结果。

### 队列策略

`CountQueueingStrategy` 按数据段数量计算队列大小；`ByteLengthQueueingStrategy` 按 `byteLength` 计算。两者都通过构造参数中的 `highWaterMark` 设置期望的队列容量。
