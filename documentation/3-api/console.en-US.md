# Console

AIUI provides a set of console logging APIs that follow Web standards. Developers can output information during debugging through the global `console` object.

## Print Variables of Different Types

`console` automatically formats complex types such as objects, arrays, functions, and Promises.

```javascript
console.log("Hello AIUI");
console.info({ id: 1, name: "Agent" });
console.warn(["apple", "banana", "cherry"]);
console.error(new Error("Something went wrong"));

// 打印 Promise 状态
const p = Promise.resolve(42);
console.log(p); // Promise { <resolved> }
```

## Use Log Groups

```javascript
console.group("初始化阶段");
console.log("加载配置...");
console.log("连接服务器...");
console.groupEnd();

console.log("主流程继续执行");
```

## Notes

- **Object depth**: When printing deeply nested objects, the console shows up to 4 levels by default. Anything deeper is displayed as `[Object]`.
- **Inspector support**: If Inspector is enabled, log messages are also sent to Chrome DevTools or other compatible debugging tools.

## API Reference

### API Description

#### Logging

These methods print log messages at different levels to the console.

- **`console.log(...args)`**: Prints a normal log message (Info level).
- **`console.info(...args)`**: Prints an informational message (Info level).
- **`console.warn(...args)`**: Prints a warning message (Warn level).
- **`console.error(...args)`**: Prints an error message (Error level).
- **`console.debug(...args)`**: Prints a debug message (Debug level).

#### Grouping

Used to create hierarchical groups in console output.

- **`console.group(...args)`**: Creates a new log group. Subsequent log output is indented.
- **`console.groupEnd()`**: Ends the current log group and reduces the indentation level.
