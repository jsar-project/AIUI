# Performance

Provides Web-standard APIs related to performance monitoring and measurement.

## Measure a Block of Code

Use `performance.now()` to obtain high-resolution timestamps and measure the duration of a synchronous operation:

```javascript
const start = performance.now();

runTask();

const duration = performance.now() - start;
console.log(`Task duration: ${duration.toFixed(2)} ms`);
```

## API Reference

### `performance.now()`

Returns the current high-resolution runtime timestamp in milliseconds. Use it to measure intervals within the same runtime, not as a date or Unix timestamp.

**Returns:** `number`, in milliseconds.

### `Performance`

The interface type of the global `performance` object, which exposes runtime performance measurement capabilities.
