# 性能测量

`performance` 用于测量代码运行时间和记录关键时间点。它适合定位“哪一步比较慢”，不用于获取当前日期或 Unix 时间戳。

## 测量一段代码

简单场景可以直接比较两次 `performance.now()`：

```javascript
const start = performance.now();
await loadData();
const duration = performance.now() - start;

console.log(`加载耗时 ${duration.toFixed(2)} ms`);
```

## 记录跨步骤耗时

使用 `mark()` 标记开始和结束位置，再用 `measure()` 生成一条测量记录：

```javascript
performance.mark('load-start');
await loadData();
performance.mark('load-end');

const measure = performance.measure('load-data', 'load-start', 'load-end');
console.log(measure.duration);

performance.clearMarks();
performance.clearMeasures();
```

如果需要稍后统一分析，可以通过 `getEntriesByType('measure')` 读取所有测量记录。

## 查看应用内存估算

```javascript
const result = await performance.measureUserAgentSpecificMemory();
console.log(`当前估算内存：${result.bytes} bytes`);
```

返回值是运行时对当前应用内存的估算，适合观察变化趋势，不应当视为设备的全部内存占用。

## API Reference

### `performance.now()`

返回相对于当前运行时高精度时间源的毫秒数。

### `performance.timeOrigin`

当前性能时间线的起始时间，单位为毫秒。

### `performance.mark(name, options?)`

添加并返回一个 `PerformanceMark`。`options.startTime` 可以指定时间，`options.detail` 可以附带自定义数据。

### `performance.measure(name, startOrOptions?, endMark?)`

添加并返回一个 `PerformanceMeasure`。可以传入开始、结束标记名，也可以通过对象形式设置 `start`、`end`、`duration` 和 `detail`。

### 查询和清理记录

| 方法 | 说明 |
| --- | --- |
| `getEntries()` | 返回时间线中的全部记录。 |
| `getEntriesByType(type)` | 按 `entryType` 查询记录，例如 `mark` 或 `measure`。 |
| `getEntriesByName(name, type?)` | 按名称和可选类型查询记录。 |
| `clearMarks(name?)` | 清除指定名称或全部标记。 |
| `clearMeasures(name?)` | 清除指定名称或全部测量记录。 |

### `PerformanceEntry`

每条记录都包含 `name`、`entryType`、`startTime`、`duration`，并支持 `toJSON()`。`PerformanceMark` 还包含 `detail`，其 `duration` 固定为 `0`；`PerformanceMeasure` 也可以包含 `detail`。

### `performance.measureUserAgentSpecificMemory()`

返回 `Promise<MemoryMeasurement>`。结果包含总字节数 `bytes` 和分项信息 `breakdown`。
