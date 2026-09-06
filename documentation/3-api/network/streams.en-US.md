# Streams

Use the Streams API to process data as it arrives. It lets an application read, transform, or write chunks before the complete content is available, which is useful for large files, live text, and audio data.

When the whole result is small and needed at once, `response.json()`, `response.text()`, or `response.arrayBuffer()` is simpler.

## Read a Response in Chunks

The `body` of a `fetch()` response is a `ReadableStream`:

```javascript
const response = await fetch('https://example.com/stream');
const reader = response.body.getReader();

try {
  while (true) {
    const { value, done } = await reader.read();
    if (done) break;
    console.log('Received a chunk', value);
  }
} finally {
  reader.releaseLock();
}
```

Only one reader can lock a stream at a time. Call `releaseLock()` when reading is complete before other code obtains a reader.

## Create and Transform a Stream

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

A `ReadableStream` can carry strings, objects, or binary values; it is not limited to network bytes.

## Write to a Destination

```javascript
const destination = new WritableStream({
  async write(chunk) {
    await saveChunk(chunk);
  },
  close() {
    console.log('All chunks saved');
  }
});

const writer = destination.getWriter();
await writer.write('first');
await writer.write('second');
await writer.close();
```

Await the Promise returned by `write()` so the destination has time to process each chunk.

## Current Limitations

- `ReadableStream.tee()` is not supported and throws when called.
- Call `releaseLock()` when a reader or writer is no longer needed.
- `pipeTo()` supports `preventClose`, `preventAbort`, `preventCancel`, and `signal` options.

## API Reference

### `ReadableStream`

The constructor accepts an optional `underlyingSource` and queuing strategy. A source can implement `start(controller)`, `pull(controller)`, and `cancel(reason)`.

| Member | Description |
| --- | --- |
| `locked` | Whether a reader currently locks the stream. |
| `getReader()` | Obtains a reader. |
| `cancel(reason?)` | Cancels reading. |
| `pipeThrough(transform, options?)` | Returns a readable stream passing through a transform. |
| `pipeTo(destination, options?)` | Writes the data to a destination stream. |

A reader provides `read()`, `cancel()`, `releaseLock()`, and `closed`.

### `WritableStream`

The constructor accepts an optional `underlyingSink` and queuing strategy. A sink can implement `start()`, `write()`, `close()`, and `abort()`.

An instance provides `locked`, `getWriter()`, `close()`, and `abort()`. A writer provides `write()`, `close()`, `abort()`, `releaseLock()`, `ready`, `closed`, and `desiredSize`.

### `TransformStream`

The constructor accepts a transformer implementing `start()`, `transform()`, and `flush()`. The instance receives input through `writable` and emits transformed output through `readable`.

### Queuing Strategies

`CountQueueingStrategy` measures the queue by chunk count. `ByteLengthQueueingStrategy` uses `byteLength`. Both accept a `highWaterMark` in their constructor options.
