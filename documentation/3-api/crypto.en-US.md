# Crypto

AIUI provides encryption APIs that follow the Web Crypto API standard. You can access these capabilities through the global `crypto` object or with `import crypto from 'crypto'`.

## Generate a Random UUID

```javascript
const uuid = crypto.randomUUID();
console.log(uuid); // 例如: "550e8400-e29b-41d4-a716-446655440000"
```

## Calculate a SHA-256 Digest

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

## Sign with HMAC

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

### API Description

#### Crypto

`Crypto` is the main entry point for cryptographic functionality.

#### Methods

- **`randomUUID()`**: Returns a randomly generated v4 UUID string.
- **`subtle`**: Returns a `SubtleCrypto` object for low-level cryptographic operations.
- **`getRandomValues(typedArray)`**: Fills the given TypedArray with random values. *(In the current implementation, this mainly serves as a placeholder.)*

---

#### SubtleCrypto

The `SubtleCrypto` interface provides a number of low-level cryptographic primitives. All methods return a `Promise`.

#### Methods

- **`digest(algorithm, data)`**: Generates a digest (hash) for the given data.
    - `algorithm`: Supports `"SHA-1"`, `"SHA-256"`, `"SHA-384"`, and `"SHA-512"`.
    - `data`: Supports `String`, `ArrayBuffer`, and `Uint8Array`.
- **`importKey(format, keyData, algorithm, extractable, keyUsages)`**: Imports external key data as a `CryptoKey`.
    - `format`: Currently only supports `"raw"`.
    - `algorithm`: Can be a string such as `"HMAC"` or an object such as `{ name: "HMAC", hash: "SHA-256" }`.
- **`sign(algorithm, key, data)`**: Generates a signature using the given key and algorithm.
    - Currently supports the `HMAC` algorithm with `SHA-1`, `SHA-256`, `SHA-384`, and `SHA-512`.

---

#### CryptoKey

Represents a key object imported through `SubtleCrypto.importKey()`.

#### Properties

- **`algorithm`**: Returns an object describing the key algorithm.
- **`type`**: Always returns `"secret"`.
- **`extractable`**: Always returns `false`.
- **`usages`**: Always returns `["sign", "verify"]`.
