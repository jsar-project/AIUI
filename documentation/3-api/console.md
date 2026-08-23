# 控制台 (Console)

AIUI 提供了一套遵循 Web 标准的控制台日志输出接口。开发者可以通过全局 `console` 对象在调试过程中输出信息。

## 打印各种类型的变量

`console` 会自动格式化对象、数组、函数和 Promise 等复杂类型。

```javascript
console.log("Hello AIUI");
console.info({ id: 1, name: "Agent" });
console.warn(["apple", "banana", "cherry"]);
console.error(new Error("Something went wrong"));

// 打印 Promise 状态
const p = Promise.resolve(42);
console.log(p); // Promise { <resolved> }
```

## 使用日志分组

```javascript
console.group("初始化阶段");
console.log("加载配置...");
console.log("连接服务器...");
console.groupEnd();

console.log("主流程继续执行");
```

## 注意事项

- **对象深度**: 在打印深度嵌套的对象时，控制台默认支持展示最多 4 层深度的内容，超出部分会显示为 `[Object]`。
- **Inspector 支持**: 如果开启了 Inspector 功能，日志信息会同步发送到 Chrome DevTools 或其他兼容的调试工具中。

## API Reference

### 接口说明

#### 日志输出

这些方法用于向控制台打印不同级别的日志信息。

- **`console.log(...args)`**: 打印普通日志信息（Info 级别）。
- **`console.info(...args)`**: 打印提示信息（Info 级别）。
- **`console.warn(...args)`**: 打印警告信息（Warn 级别）。
- **`console.error(...args)`**: 打印错误信息（Error 级别）。
- **`console.debug(...args)`**: 打印调试信息（Debug 级别）。

#### 分组管理

用于在控制台输出中创建层级化的分组。

- **`console.group(...args)`**: 创建一个新的日志分组，后续的日志输出将会增加缩进。
- **`console.groupEnd()`**: 结束当前日志分组，减少缩进层级。
