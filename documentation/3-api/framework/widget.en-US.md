# Widget

The Widget API manages a Widget's data, dimensions, and display state. The runtime creates a Widget instance from its `app.json` declaration and `.ink` entry. Use these capabilities through `this` in the entry script.

## Update Widget Data

Provide initial content with `data` and update the interface with `setData()`. A dotted path updates one field inside a nested object.

```javascript
export default {
  data: {
    count: 0,
    status: { label: 'Idle' },
  },
  increment() {
    this.setData(
      {
        count: this.data.count + 1,
        'status.label': 'Updated',
      },
      () => console.log('Widget updated'),
    );
  },
};
```

The first argument to `setData()` must be an object. Top-level fields replace values with the same name. Dotted paths create intermediate objects when needed. The optional callback runs after the data is synchronized with the interface.

## Adapt to the Available Size

`family` describes the Widget size category. `hostWidth` and `hostHeight` provide the currently available dimensions in logical pixels. Read them in `onAttach()` when content decisions depend on the actual size.

```javascript
export default {
  data: { compact: false },
  onAttach() {
    this.setData({ compact: this.hostWidth < 240 });
  },
};
```

Prefer responsive WXSS layouts in most cases. Read exact dimensions only when the content logic requires them.

## Respond to Display State

```javascript
export default {
  onCreate() {
    console.log(this.widgetId, this.family);
  },
  onAttach() {
    console.log('Widget shown');
  },
  onDetach() {
    console.log('Widget hidden');
  },
  onDestroy() {
    console.log('Widget destroyed');
  },
};
```

`isAttached` reports whether the Widget is currently shown. `interactive` reports whether user input is currently allowed. These properties and the dimension properties are read-only.

## Current Limits

- Widgets use their own four callbacks and do not receive Page lifecycle callbacks.
- `onAttach()` and `onDetach()` may run more than once, so related work must be safe to repeat.
- `onDestroy()` is final; release resources that are no longer needed there.
- Widgets do not provide Page-only routing, world-awareness, or `finish()` features.

For declaration, file structure, and a complete example, see [Widget Development](/AIUI/framework/open-agent-format-widget).

## API Reference

### Instance Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| `data` | `object` | Current Widget data; defaults to `{}` when omitted |
| `widgetId` | `string` | Stable identifier for the current Widget instance |
| `family` | `'1x1' \| '1x2'` | Size category declared in `app.json` and the `.ink` file |
| `target` | `'_widget'` | Presentation target used by Widgets |
| `isAttached` | `boolean` | Whether the Widget is currently shown |
| `interactive` | `boolean` | Whether user input is currently allowed |
| `hostWidth` | `number` | Available width in logical pixels |
| `hostHeight` | `number` | Available height in logical pixels |

All properties except `data` are read-only.

### `setData(patch, callback?)`

Updates Widget data and refreshes affected interface content.

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `patch` | `object` | Yes | Data to update; supports dotted paths such as `'status.label'` |
| `callback` | `function` | No | Runs after the data is synchronized with the interface |

Returns `undefined`. An error is thrown when `patch` is not an object.

### State Callbacks

| Callback | When it runs |
| :--- | :--- |
| `onCreate()` | Once after the Widget is created and its initial state is ready |
| `onAttach()` | When the Widget is shown or shown again |
| `onDetach()` | When the Widget is hidden or is about to be destroyed |
| `onDestroy()` | Once during final Widget destruction |
