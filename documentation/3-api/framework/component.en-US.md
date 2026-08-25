# Component

`Component` represents the runtime instance object exposed by an AIUI custom component.

When you access `this` inside component `methods`, `lifetimes`, or event handlers, you are working with the `Component` capability surface.

## Define and Use a Component

```javascript
export default {
  data: {
    count: 0
  },
  properties: {
    title: {
      type: String,
      value: 'Untitled'
    }
  },
  methods: {
    increment() {
      const nextCount = this.data.count + 1;

      this.setData({
        count: nextCount
      });

      this.triggerEvent('change', {
        value: nextCount
      });
    }
  }
}
```

## `this` in Lifecycles

Component lifecycle callbacks also run with the current component instance as `this`.

Common lifecycle callbacks currently include:

- `created`
- `attached`
- `ready`
- `moved`
- `detached`

```javascript
export default {
  lifetimes: {
    ready() {
      console.log(this.data);
    }
  }
}
```

## Inspect Named Slots

The runtime exposes a snapshot of host-provided named slots through `this.$slots`. Use `hasSlot()` to check whether a slot contains content:

```javascript
export default {
  lifetimes: {
    ready() {
      if (this.hasSlot('actions')) {
        console.log(this.$slots.actions);
      }
    },
  },
};
```

## API Reference

### Instance Members

| Member | Type | Description |
| :--- | :--- | :--- |
| `this.data` | `Object` | The local state object of the current component |
| `this.properties` | `Object` | The resolved input properties of the current component |
| `this.setData(data, callback?)` | `Function` | Updates component state and triggers a view refresh |
| `this.triggerEvent(name, detail?)` | `Function` | Dispatches a custom event to the parent |
| `this.$slots` | `Readonly<Record<string, readonly ComponentSlotEntry[]>>` | Snapshot of host-provided named slots |
| `this.hasSlot(name)` | `Function` | Reports whether a named slot contains content |

Methods declared in `methods` are attached directly to the component instance and run with the current component instance as `this`.

### `this.data`

`data` stores the component's own mutable state.

- If the component definition does not explicitly declare `data`, the runtime initializes it as an empty object
- After `setData()` runs, `this.data` reflects the latest state
- Path-style updates are supported, such as `'profile.name': 'AIUI'`

### `this.properties`

`properties` stores the current input property values of the component.

- Property declarations are defined in the `properties` option
- The runtime merges default values with values passed from the parent
- `this.properties` reflects the effective values currently in use

```javascript
export default {
  properties: {
    title: {
      type: String,
      value: 'Untitled'
    }
  },
  lifetimes: {
    created() {
      console.log(this.properties.title);
    }
  }
}
```

### `this.$slots` and `this.hasSlot(name)`

Each item in `this.$slots[name]` contains these fields:

| Field | Type | Description |
| --- | --- | --- |
| `tagName` | `string` | Resolved concrete tag name. |
| `attributes` | `Record<string, string>` | Rendered attributes from the source node. |
| `textContent` | `string` | Optional text content. |
| `sourceComponentId` | `string` | Optional source custom-component identifier. |

`this.hasSlot(name)` returns a `boolean` indicating whether the host provided content for that named slot.

### `this.setData(Object data, Function? callback)`

`setData()` merges a data patch from the logic layer into the current component state.

- `data` must be an object
- Top-level keys are written directly into `data`
- Dot-path keys create intermediate objects when needed
- `callback` runs after the update completes

```javascript
export default {
  data: {
    profile: {
      name: 'AIUI'
    }
  },
  methods: {
    updateProfile() {
      this.setData({
        'profile.name': 'AIUI Agent'
      }, () => {
        console.log('component state updated');
      });
    }
  }
}
```

### `this.triggerEvent(String name, Object? detail)`

`triggerEvent()` dispatches a custom event from the current component to its parent.

- `name` is the event name
- `detail` is the optional event payload
- Parent pages or parent components can listen through `bind<event>`

```javascript
export default {
  methods: {
    handleSelect() {
      this.triggerEvent('select', {
        id: this.properties.itemId
      });
    }
  }
}
```
