# 性能 (Performance)

提供 Web 标准的性能监控和测量相关接口。

## 测量一段代码的执行时间

使用 `performance.now()` 获取高精度时间戳，并计算一段同步操作的耗时：

```javascript
const start = performance.now();

runTask();

const duration = performance.now() - start;
console.log(`任务耗时: ${duration.toFixed(2)} ms`);
```

## API Reference

### `performance.now()`

返回当前运行时高精度时间源的毫秒值。它适合测量同一运行过程中的时间间隔，不应当用作日期或 Unix 时间戳。

**返回值：** `number`，单位为毫秒。

### `Performance`

`performance` 全局对象的接口类型，提供运行时性能测量能力。
