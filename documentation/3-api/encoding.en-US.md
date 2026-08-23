# Encoding

AIUI provides text encoding and decoding APIs that follow Web standards. They are mainly used to convert between strings and byte data. Common scenarios include:

- Encoding a string into `Uint8Array` for encryption, signing, network transmission, or binary storage.
- Decoding byte data returned by an API into readable text.
- Clearly distinguishing between text and binary data when working with `ArrayBuffer`, `Uint8Array`, or streaming data.

## Encode a String into a UTF-8 Byte Array

```javascript
const encoder = new TextEncoder();
const bytes = encoder.encode('你好，AIUI');

console.log(bytes); // Uint8Array(...)
console.log(bytes.length); // UTF-8 编码后的字节长度
```

## Decode a Byte Array into a String

```javascript
const bytes = new Uint8Array([72, 101, 108, 108, 111]);
const decoder = new TextDecoder();

const text = decoder.decode(bytes);
console.log(text); // "Hello"
```

## Use encodeInto to Write into an Existing Buffer

```javascript
const encoder = new TextEncoder();
const target = new Uint8Array(32);

const result = encoder.encodeInto('AIUI', target);

console.log(result.read);    // 已读取的字符数
console.log(result.written); // 已写入的字节数
console.log(target.slice(0, result.written)); // 编码后的有效内容
```

## Decode an ArrayBuffer Returned by an API

```javascript
async function loadText(url) {
  const response = await fetch(url);
  const buffer = await response.arrayBuffer();

  const decoder = new TextDecoder('utf-8');
  return decoder.decode(buffer);
}
```

## Handle Invalid Bytes in Strict Mode

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

## Decode Streaming Text in Chunks

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

text += decoder.decode(); // Finish streaming decode and flush remaining bytes

console.log(text); // "Hello"
```

## Notes

- **`TextEncoder` always outputs UTF-8**: If your target scenario is not UTF-8, you cannot switch encodings through `TextEncoder`.
- **String length is not byte length**: Characters such as Chinese text and emojis usually take multiple bytes in UTF-8, so `string.length` cannot directly replace the byte length.
- **Keep text and binary separate**: `TextEncoder` / `TextDecoder` are suitable for text content, not for forcing arbitrary binary data to round-trip through strings.
- **Strict mode is better for validating input**: If you want to detect corrupted input immediately, prefer `new TextDecoder('utf-8', { fatal: true })`.
- **BOM mainly matters in some text scenarios**: The `ignoreBOM` option is more meaningful when processing file headers or text exported from other tools.

## API Reference

### API Description

#### TextEncoder

`TextEncoder` is used to encode JavaScript strings into UTF-8 byte arrays. It is suitable for scenarios that require raw byte content, such as computing digests, generating signatures, or writing into binary buffers.

It is important to note that `TextEncoder` always outputs UTF-8 encoded results. You do not need to and cannot switch to another encoding through constructor arguments.

#### Properties

- **`encoding`**: Always returns `"utf-8"`.

#### Methods

- **`encode(input?)`**: Encodes a string into a new `Uint8Array`.
  - `input`: `String?`, the text to encode. If omitted, it is treated as an empty string.
  - Return value: `Uint8Array`.
- **`encodeInto(source, destination)`**: Writes the encoded result directly into an existing destination buffer.
  - `source`: `String`, the text to encode.
  - `destination`: `Uint8Array`, the target buffer that receives the encoded result.
  - Return value: an object containing:
    - `read`: the number of source characters that were read.
    - `written`: the number of bytes written into the destination buffer.

`encodeInto()` is suitable when you already have a reusable buffer and want to reduce extra allocations, especially for large text or high-frequency encoding scenarios.

---

#### TextDecoder

`TextDecoder` is used to decode byte data into strings. It is suitable for reading binary text returned by APIs, parsing file byte streams, or restoring `ArrayBuffer` / `Uint8Array` into readable text.

#### Constructor

- **`new TextDecoder(label?, options?)`**: Creates a decoder instance.
  - `label`: `String?`, the encoding name. Defaults to `"utf-8"`.
  - `options`: `Object?`, optional configuration:
    - `fatal`: `Boolean`, whether to throw immediately when an illegal byte sequence is encountered. Defaults to `false`.
    - `ignoreBOM`: `Boolean`, whether to ignore the byte order mark (BOM). Defaults to `false`.

#### Properties

- **`encoding`**: The name of the encoding used by the current decoder.
- **`fatal`**: Whether strict decoding mode is enabled.
- **`ignoreBOM`**: Whether BOM is ignored.

#### Methods

- **`decode(input?, options?)`**: Decodes byte data into a string.
  - `input`: `ArrayBuffer | Uint8Array | DataView?`, the data to decode. If omitted, it can be used to finish a streaming decode operation.
  - `options`: `Object?`, optional configuration:
    - `stream`: `Boolean`, whether to continue decoding in streaming mode. Defaults to `false`.
  - Return value: `String`.

When `fatal` is `false`, invalid bytes are typically replaced with replacement characters. When `fatal` is `true`, invalid bytes cause an exception, which is more suitable for scenarios with stricter input quality requirements.

#### Incremental Decoding

`decode(input, { stream: true })` supports incremental decoding for streamed text. When UTF-8 characters may cross chunk boundaries, use `stream: true` to preserve the decoder's internal state between chunks, then call `decode()` one final time after all data has been read to flush any remaining bytes.

```javascript
const decoder = new TextDecoder('utf-8');
let text = '';

text += decoder.decode(chunk1, { stream: true });
text += decoder.decode(chunk2, { stream: true });
text += decoder.decode(); // Finish streaming decode and flush remaining bytes
```
