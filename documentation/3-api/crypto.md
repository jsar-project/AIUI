# 加密 (Crypto)

AIUI 提供了一套遵循 Web Crypto API 标准的加密接口。你可以通过全局 `crypto` 对象或 `import crypto from 'crypto'` 来访问这些功能。

## 生成随机 UUID

```javascript
const uuid = crypto.randomUUID();
console.log(uuid); // 例如: "550e8400-e29b-41d4-a716-446655440000"
```

## 计算 SHA-256 摘要

```javascript
async function calculateHash(message) {
  const encoder = new TextEncoder();
  const data = encoder.encode(message);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  
  // 将 ArrayBuffer 转换为十六进制字符串
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  return hashHex;
}

calculateHash('Hello AIUI').then(console.log);
```

## 使用 HMAC 签名

```javascript
async function signMessage(keyText, message) {
  const encoder = new TextEncoder();
  const keyData = encoder.encode(keyText);
  const data = encoder.encode(message);

  // 1. 导入密钥
  const key = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );

  // 2. 生成签名
  const signature = await crypto.subtle.sign(
    'HMAC',
    key,
    data
  );

  return signature; // 返回 ArrayBuffer
}
```

## API Reference

### 接口说明

#### Crypto

`Crypto` 是加密功能的主要入口点。

#### 方法

- **`randomUUID()`**: 返回一个随机生成的 v4 UUID 字符串。
- **`subtle`**: 返回一个 `SubtleCrypto` 对象，用于执行底层的加密操作。
- **`getRandomValues(typedArray)`**: 用随机值填充给定的 TypedArray。*(当前实现中主要作为占位符)*

---

#### SubtleCrypto

`SubtleCrypto` 接口提供了许多低级加密原语。所有方法都返回一个 `Promise`。

#### 方法

- **`digest(algorithm, data)`**: 生成给定数据的摘要（Hash）。
    - `algorithm`: 支持 `"SHA-1"`, `"SHA-256"`, `"SHA-384"`, `"SHA-512"`。
    - `data`: 支持 `String`, `ArrayBuffer`, `Uint8Array`。
- **`importKey(format, keyData, algorithm, extractable, keyUsages)`**: 将外部密钥数据导入为 `CryptoKey`。
    - `format`: 目前仅支持 `"raw"`。
    - `algorithm`: 可以是字符串（如 `"HMAC"`）或对象（如 `{ name: "HMAC", hash: "SHA-256" }`）。
- **`sign(algorithm, key, data)`**: 使用给定的密钥和算法生成签名。
    - 目前支持 `HMAC` 算法配合 `SHA-1`, `SHA-256`, `SHA-384`, `SHA-512`。

---

#### CryptoKey

表示通过 `SubtleCrypto.importKey()` 导入的密钥对象。

#### 属性

- **`algorithm`**: 返回描述密钥算法的对象。
- **`type`**: 始终返回 `"secret"`。
- **`extractable`**: 始终返回 `false`。
- **`usages`**: 始终返回 `["sign", "verify"]`。
