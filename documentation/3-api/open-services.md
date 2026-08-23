# 开放服务

AIUI 允许开发者通过 `createOpenAPI` 调用 Rokid 云平台提供的多种智能服务，以增强智能体的能力。

## 使用默认 Open Service

```javascript
import { createOpenAPI } from 'open';

createOpenAPI().then((openapi) => {
  // 使用默认 Open Service 对应的 SDK 实例
}).catch((err) => {
  console.error('创建开放服务实例失败：', err);
});
```

## 指定 service

```javascript
import { createOpenAPI } from 'open';

createOpenAPI('my-service').then((openapi) => {
  // 使用指定 service 对应的 Open Service 实例
}).catch((err) => {
  console.error('创建指定 Open Service 实例失败：', err);
});
```

## 每次调用都会返回新实例

```javascript
import { createOpenAPI } from 'open';

const defaultAPI = await createOpenAPI();
const customAPI = await createOpenAPI('my-service');
const anotherDefaultAPI = await createOpenAPI();

console.log(defaultAPI === anotherDefaultAPI); // false
console.log(defaultAPI === customAPI); // false
```


## API Reference

### 基础接口

#### createOpenAPI

创建一个开放服务实例。通过此实例，你可以访问宿主暴露的 Open Service 能力。

#### 函数签名

```typescript
createOpenAPI(service?: string): Promise<any>
```

`createOpenAPI(service?)` 会通过宿主桥接获取对应 Open Service 的 OpenAPI manifest 和相关头信息，然后返回一个基于该 manifest 生成的 JavaScript SDK 对象。

需要特别注意的是：

- **每次调用 `createOpenAPI()` 都会创建一个新的实例**
- 如果你连续调用两次 `createOpenAPI()`，得到的是两个独立实例，而不是同一个缓存对象
- 你可以通过可选的 `service` 参数指定要连接的 Open Service
- 不同的 `service` 可以指向不同的 Open Service 后端

#### 参数

| 参数 | 类型 | 必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `service` | `string` | 否 | 指定要连接的 Open Service 名称。未传入时由宿主选择默认 Open Service。传入后可显式选择不同的 Open Service。具体可用值以宿主实际暴露的 service 为准。 |

#### 导入

```javascript
import { createOpenAPI } from 'open';
```

#### 返回值

返回一个 Promise。Promise resolve 后得到一个 JavaScript SDK 对象，开发者可以通过这个对象调用对应 Open Service 暴露出来的能力接口。

#### 行为说明

- `createOpenAPI()` 默认连接宿主选择的默认 Open Service
- `createOpenAPI(service)` 会尝试连接指定名称的 Open Service
- 每次调用都会重新创建实例，因此如果你需要复用某个 Open Service 实例，应该把返回值保存下来并在后续重复使用
