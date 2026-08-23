# Open Services

AIUI allows developers to use `createOpenAPI` to call a variety of intelligent services provided by the Rokid cloud platform, extending the capabilities of an agent.

## Use the default Open Service

```javascript
import { createOpenAPI } from 'open';

createOpenAPI().then((openapi) => {
  // Use the SDK instance for the default Open Service
}).catch((err) => {
  console.error('Failed to create open service instance:', err);
});
```

## Specify a service

```javascript
import { createOpenAPI } from 'open';

createOpenAPI('my-service').then((openapi) => {
  // Use the Open Service instance for the specified service
}).catch((err) => {
  console.error('Failed to create the specified Open Service instance:', err);
});
```

## Each call returns a new instance

```javascript
import { createOpenAPI } from 'open';

const defaultAPI = await createOpenAPI();
const customAPI = await createOpenAPI('my-service');
const anotherDefaultAPI = await createOpenAPI();

console.log(defaultAPI === anotherDefaultAPI); // false
console.log(defaultAPI === customAPI); // false
```


## API Reference

### Basic API

#### createOpenAPI

Creates an open service instance. Through this instance, you can access Open Service capabilities exposed by the host.

#### Signature

```typescript
createOpenAPI(service?: string): Promise<any>
```

`createOpenAPI(service?)` contacts the host bridge, fetches the corresponding OpenAPI manifest and related headers, and resolves with a JavaScript SDK object derived from that manifest.

Important notes:

- **Every call to `createOpenAPI()` creates a new instance**
- If you call `createOpenAPI()` twice, you get two separate instances rather than the same cached object
- You can use the optional `service` argument to select which Open Service to connect to
- Different `service` values can point to different Open Service backends

#### Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `service` | `string` | No | The name of the Open Service to connect to. If omitted, the host selects the default Open Service. If provided, it can explicitly select a different Open Service. The actual available values depend on what the host exposes. |

#### Import

```javascript
import { createOpenAPI } from 'open';
```

#### Return Value

Returns a Promise that resolves to a JavaScript SDK object. You can use this object to call the capabilities exposed by the corresponding Open Service.

#### Behavior

- `createOpenAPI()` connects to the default Open Service selected by the host
- `createOpenAPI(service)` attempts to connect to the Open Service identified by that name
- Because each call creates a new instance, you should store and reuse the returned object if you want to keep using the same Open Service instance
