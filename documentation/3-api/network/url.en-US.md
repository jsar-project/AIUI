# URL

AIUI provides a set of URL parsing and handling interfaces that follow Web standards. You can use these interfaces to conveniently parse, construct, and modify URLs and their query parameters.

## Parse a URL

```javascript
const url = new URL('https://user:pass@example.com:8080/path/to/page?id=123#section');

console.log(url.protocol); // "https:"
console.log(url.hostname); // "example.com"
console.log(url.port);     // "8080"
console.log(url.pathname); // "/path/to/page"
console.log(url.search);   // "?id=123"
console.log(url.hash);     // "#section"
```

## Modify URL Parameters

```javascript
const url = new URL('https://example.com/search');
url.searchParams.set('q', 'aiui');
url.searchParams.append('page', '1');

console.log(url.href); // "https://example.com/search?q=aiui&page=1"
```

## Construct a Relative URL

```javascript
const base = 'https://rokid.com/docs/';
const url = new URL('aiui/start.html', base);

console.log(url.href); // "https://rokid.com/docs/aiui/start.html"
```

## API Reference

### Interface Description

#### URL

The `URL` interface is used to parse, construct, normalize, and encode URLs.

#### Constructor

- **`new URL(url, base?)`**: Creates and returns a `URL` object.
    - `url`: `String`, a string representing an absolute or relative URL.
    - `base`: `String?`, used as the base URL if `url` is relative.

#### Properties

- **`href`**: `String`, the complete URL string.
- **`origin`**: `String`, the origin of the URL (protocol + host + port), read-only.
- **`protocol`**: `String`, the protocol of the URL, including the trailing `:`.
- **`username`**: `String`, the username in the URL.
- **`password`**: `String`, the password in the URL.
- **`host`**: `String`, the hostname and port of the URL.
- **`hostname`**: `String`, the hostname of the URL without the port.
- **`port`**: `String`, the port number of the URL.
- **`pathname`**: `String`, the path portion of the URL, beginning with `/`.
- **`search`**: `String`, the query string of the URL, beginning with `?`.
- **`hash`**: `String`, the fragment identifier of the URL, beginning with `#`.
- **`searchParams`**: `URLSearchParams`, a read-only object for handling query parameters.

#### Methods

- **`toString()` / `toJSON()`**: Returns the complete URL string.

---

#### URLSearchParams

The `URLSearchParams` interface defines methods for working with URL query parameters.

#### Constructor

- **`new URLSearchParams(init?)`**: Returns an instance of `URLSearchParams`.
    - `init`: Can be a query string such as `"a=1&b=2"`, an array of key-value pairs such as `[['a', '1']]`, or a plain object such as `{ a: '1' }`.

#### Methods

- **`append(name, value)`**: Appends a new key-value pair.
- **`delete(name)`**: Deletes all key-value pairs with the specified name.
- **`get(name)`**: Returns the first value with the specified name, or `null` if it does not exist.
- **`getAll(name)`**: Returns all values with the specified name as an array.
- **`has(name)`**: Checks whether a key with the specified name exists.
- **`set(name, value)`**: Sets the value for the specified name. If it already exists, the first one is replaced and the rest with the same name are removed.
- **`sort()`**: Sorts query parameters by key name.
- **`toString()`**: Returns the serialized query string.
