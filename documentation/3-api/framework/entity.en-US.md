# Entity

`Entity` represents the node wrapper object exposed from the AIUI page entity tree.

You use `Entity` when you need to read node attributes, access `dataset`, or continue querying within the subtree of a matched node.

## How To Get An `Entity`

`Entity` cannot be created directly with a constructor. It usually comes from page-level or entity-level queries.

```javascript
const title = page.querySelector('.title');
const items = page.querySelectorAll('.item');
const first = items.item(0);
```

Current behavior:

- `new Entity()` throws directly
- `page.querySelector(selector)` returns an `Entity` or `null`
- `page.querySelectorAll(selector)` returns an `EntityList`
- `entity.querySelector(selector)` continues querying only within the current entity subtree

## API Reference

### Instance Members

| Member | Type | Description |
| :--- | :--- | :--- |
| `entity.entityId` | `number` | The runtime entity id |
| `entity.tagName` | `string` | The tag name of the current entity |
| `entity.attributes` | `Object` | A snapshot object of the current entity attributes |
| `entity.dataset` | `DOMStringMap` | A mapped view based on `data-*` attributes |
| `entity.querySelector(selector)` | `Entity \| null` | Continues querying within the current entity subtree |
| `entity.querySelectorAll(selector)` | `EntityList` | Queries all matches within the current entity subtree |

### `entity.attributes`

`attributes` returns a snapshot object of the current entity attribute table.

```javascript
const title = page.querySelector('.title');

console.log(title.attributes.role);
```

It is suitable for reading the resolved attribute values currently present on the node.

### `entity.dataset`

`dataset` maps `data-*` attributes on the entity into a readable and writable view.

```javascript
const item = page.querySelectorAll('.item').item(1);

console.log(item.dataset.userId);
item.dataset.count = 7;
delete item.dataset.index;
```

Current behavior:

- `data-user-id` maps to `dataset.userId`
- Writing to `dataset` writes back to the underlying entity attributes
- Deleting a `dataset` field also removes the corresponding `data-*` attribute

### `entity.querySelector(String selector)`

`querySelector()` finds the first matching node within the subtree of the current entity.

- An invalid selector throws directly
- Returns `null` when nothing matches

### `entity.querySelectorAll(String selector)`

`querySelectorAll()` queries all matching nodes within the subtree of the current entity.

- The return value is an `EntityList`
- The query scope is limited to the current entity subtree

```javascript
const container = page.querySelector('#container');
const title = container.querySelector('.title');
const items = container.querySelectorAll('[selected]');
```

### `EntityList`

`EntityList` is the iterable result container returned by `querySelectorAll()`.

Common members include:

- `length`
- `item(index)`
- `at(index)`, with negative index support
- Usable with `for...of` and `Array.from(...)`

```javascript
const items = page.querySelectorAll('.item');

console.log(items.length);
console.log(items.item(0)?.tagName);
console.log(items.at(-1)?.attributes['data-index']);
```
