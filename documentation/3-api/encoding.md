# 编码 (Encoding)

AIUI 提供了一套遵循 Web 标准的文本编码与解码接口，主要用于在字符串和字节数据之间完成转换。最常见的场景包括：

- 把字符串编码成 `Uint8Array`，用于加密、签名、网络传输或二进制存储。
- 把接口返回的字节数据解码为可读文本。
- 在处理 `ArrayBuffer`、`Uint8Array`、流式数据时，明确区分“文本”和“二进制”。

## 把字符串编码为 UTF-8 字节数组

```javascript
const encoder = new TextEncoder();
const bytes = encoder.encode('你好，AIUI');

console.log(bytes); // Uint8Array(...)
console.log(bytes.length); // UTF-8 编码后的字节长度
```

## 把字节数组解码为字符串

```javascript
const bytes = new Uint8Array([72, 101, 108, 108, 111]);
const decoder = new TextDecoder();

const text = decoder.decode(bytes);
console.log(text); // "Hello"
```

## 使用 encodeInto 写入已有缓冲区

```javascript
const encoder = new TextEncoder();
const target = new Uint8Array(32);

const result = encoder.encodeInto('AIUI', target);

console.log(result.read);    // 已读取的字符数
console.log(result.written); // 已写入的字节数
console.log(target.slice(0, result.written)); // 编码后的有效内容
```

## 解码接口返回的 ArrayBuffer

```javascript
async function loadText(url) {
  const response = await fetch(url);
  const buffer = await response.arrayBuffer();

  const decoder = new TextDecoder('utf-8');
  return decoder.decode(buffer);
}
```

## 严格模式下处理非法字节

```javascript
const invalidBytes = new Uint8Array([0xff, 0xfe, 0xfd]);
const decoder = new TextDecoder('utf-8', { fatal: true });

try {
  const text = decoder.decode(invalidBytes);
  console.log(text);
} catch (error) {
  console.error('解码失败:', error);
}
```

## 分段解码流式文本

```javascript
const response = await fetch('https://example.com/stream');
const reader = response.body.getReader();
const decoder = new TextDecoder('utf-8');

let text = '';

while (true) {
  const { value, done } = await reader.read();
  if (done) {
    break;
  }

  text += decoder.decode(value, { stream: true });
}

text += decoder.decode(); // 结束流式解码并刷新剩余字节

console.log(text); // "Hello"
```

## 注意事项

- **`TextEncoder` 始终输出 UTF-8**: 如果你的目标场景不是 UTF-8，就不能通过 `TextEncoder` 切换到其他编码。
- **字符串长度不等于字节长度**: 中文、表情符号等字符在 UTF-8 下通常会占用多个字节，不能用 `string.length` 直接代替字节数。
- **文本和二进制要分清**: `TextEncoder` / `TextDecoder` 适合处理“文本内容”，不适合把任意二进制数据强行当作字符串来回转换。
- **严格模式更适合校验输入**: 如果你希望在输入数据损坏时立即发现问题，可以优先使用 `new TextDecoder('utf-8', { fatal: true })`。
- **BOM 只影响部分文本场景**: 当你在处理文件头或跨工具导出的文本内容时，`ignoreBOM` 选项会更有意义。

## API Reference

### 接口说明

#### TextEncoder

`TextEncoder` 用于把 JavaScript 字符串编码成 UTF-8 字节数组。它适合在需要原始字节内容的场景中使用，例如计算摘要、生成签名、写入二进制缓冲区等。

需要注意的是，`TextEncoder` 始终输出 UTF-8 编码结果，不需要也不能通过构造参数切换到其他编码。

#### 属性

- **`encoding`**: 始终返回 `"utf-8"`。

#### 方法

- **`encode(input?)`**: 把字符串编码为一个新的 `Uint8Array`。
  - `input`: `String?`，要编码的文本。省略时等价于空字符串。
  - 返回值: `Uint8Array`。
- **`encodeInto(source, destination)`**: 直接把字符串编码结果写入已有的目标缓冲区。
  - `source`: `String`，要编码的文本。
  - `destination`: `Uint8Array`，用于接收编码结果的目标缓冲区。
  - 返回值: 一个对象，包含：
    - `read`: 已读取的源字符串长度。
    - `written`: 已写入目标缓冲区的字节数。

`encodeInto()` 适合在你已经有可复用缓冲区时使用，可以减少额外分配，尤其适合大文本或高频编码场景。

---

#### TextDecoder

`TextDecoder` 用于把字节数据解码成字符串。它适合读取接口返回的二进制文本内容、解析文件字节流，或把 `ArrayBuffer` / `Uint8Array` 还原为可读文本。

#### 构造函数

- **`new TextDecoder(label?, options?)`**: 创建一个解码器实例。
  - `label`: `String?`，编码名称，默认是 `"utf-8"`。
  - `options`: `Object?`，可选配置项：
    - `fatal`: `Boolean`，是否在遇到非法字节序列时直接抛错，默认 `false`。
    - `ignoreBOM`: `Boolean`，是否忽略字节顺序标记（BOM），默认 `false`。

#### 属性

- **`encoding`**: 当前解码器使用的编码名称。
- **`fatal`**: 当前是否启用严格解码模式。
- **`ignoreBOM`**: 当前是否忽略 BOM。

#### 方法

- **`decode(input?, options?)`**: 把字节数据解码成字符串。
  - `input`: `ArrayBuffer | Uint8Array | DataView?`，要解码的数据。省略时可用于结束一次流式解码。
  - `options`: `Object?`，可选配置项：
    - `stream`: `Boolean`，是否按流式方式继续解码，默认 `false`。
  - 返回值: `String`。

当 `fatal` 为 `false` 时，非法字节通常会被替换为替代字符；当 `fatal` 为 `true` 时，遇到非法字节会抛出异常，适合对输入质量要求更严格的场景。

#### 增量解码

`decode(input, { stream: true })` 支持按块增量解码流式文本。当 UTF-8 字符可能跨越多个数据块时，应使用 `stream: true` 保留解码器的内部状态，并在所有数据读取完成后再额外调用一次 `decode()`，把剩余字节刷新为最终文本。

```javascript
const decoder = new TextDecoder('utf-8');
let text = '';

text += decoder.decode(chunk1, { stream: true });
text += decoder.decode(chunk2, { stream: true });
text += decoder.decode(); // 结束流式解码并刷新剩余字节
```
