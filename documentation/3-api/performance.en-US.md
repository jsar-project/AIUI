# Performance Measurement

Use `performance` to measure code execution time and record important points on a timeline. It helps identify which step is slow; it is not a clock for the current date or Unix timestamp.

## Measure One Operation

For a simple operation, compare two calls to `performance.now()`:

```javascript
const start = performance.now();
await loadData();
const duration = performance.now() - start;

console.log(`Loaded in ${duration.toFixed(2)} ms`);
```

## Measure Work Across Several Steps

Use `mark()` for the start and end points, then create a measurement with `measure()`:

```javascript
performance.mark('load-start');
await loadData();
performance.mark('load-end');

const measure = performance.measure('load-data', 'load-start', 'load-end');
console.log(measure.duration);

performance.clearMarks();
performance.clearMeasures();
```

To inspect measurements later, read them with `getEntriesByType('measure')`.

## Inspect an Application Memory Estimate

```javascript
const result = await performance.measureUserAgentSpecificMemory();
console.log(`Estimated memory: ${result.bytes} bytes`);
```

The result is a runtime estimate for the current application. Use it to observe trends rather than as the total memory usage of the device.

## API Reference

### `performance.now()`

Returns milliseconds from the runtime's high-resolution time source.

### `performance.timeOrigin`

The starting time of the current performance timeline, in milliseconds.

### `performance.mark(name, options?)`

Adds and returns a `PerformanceMark`. Use `options.startTime` to provide a time and `options.detail` to attach custom data.

### `performance.measure(name, startOrOptions?, endMark?)`

Adds and returns a `PerformanceMeasure`. Pass start and end mark names, or an object containing `start`, `end`, `duration`, and `detail`.

### Query and Clear Entries

| Method | Description |
| --- | --- |
| `getEntries()` | Returns every retained timeline entry. |
| `getEntriesByType(type)` | Returns entries with an `entryType`, such as `mark` or `measure`. |
| `getEntriesByName(name, type?)` | Returns entries with a name and optional type. |
| `clearMarks(name?)` | Clears marks with a name, or all marks. |
| `clearMeasures(name?)` | Clears measures with a name, or all measures. |

### `PerformanceEntry`

Every entry contains `name`, `entryType`, `startTime`, and `duration`, and supports `toJSON()`. `PerformanceMark` also has `detail` and always has a duration of `0`. `PerformanceMeasure` may also contain `detail`.

### `performance.measureUserAgentSpecificMemory()`

Returns a `Promise<MemoryMeasurement>`. The result contains total bytes in `bytes` and detailed parts in `breakdown`.
