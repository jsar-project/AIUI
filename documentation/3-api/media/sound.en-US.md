# Sound Effect (Sound)

`Sound` is a dedicated playback entry for local short sound effects. It is suitable for scenarios that require frequent replay, such as button clicks, prompts, and status feedback sounds.

Compared with the general-purpose `AudioPlayer`, `Sound` offers a narrower feature set but a more direct API, making it suitable for local sound effect resources that should play immediately.

## Play a Sound Effect

```javascript
import { Sound } from 'audio';

const click = new Sound('/assets/click.wav');
click.volume = 0.8;
click.play();
```

## Behavior Notes

- `Sound` is only used for local sound effect files.
- Local sound effect paths support both relative paths and project-root absolute paths.
- `Sound` does not support changing `src`, seeking to a playback position, streaming appended data, or event listeners.
- Calling instance methods again after `destroy()` throws an error.

## Use Cases

- If you need a lighter local sound effect playback API, prefer `Sound`.
- If you need more complete playback control, use [Audio Player (AudioPlayer)](/AIUI/api/media-audio-player).
- For recording, camera, and other device media capabilities, continue with [WeChat Mini Program Compatible APIs](/AIUI/api/weixin-compatible-apis).

## API Reference

### Entry

`Sound` can be used directly as a global or imported from the built-in `audio` module:

```javascript
const click = new Sound('./click.wav');
```

```javascript
import { Sound } from 'audio';
```

### Constructor

```javascript
new Sound(src)
```

- `src`: The local path to the sound effect file. It must be a non-empty string. It supports both relative paths and project-root absolute paths such as `/assets/click.wav`.
- Only local files are supported. Remote URLs such as `http://` or `https://` are not supported.
- The audio source is bound during construction so it can be replayed quickly afterward.

### Properties

#### `volume`
- **Type**: `number`
- **Read/Write**: Readable and writable
- **Description**: Controls the playback volume of the current sound effect instance.

### Methods

#### `play()`
- **Description**: If the current instance is already playing, it stops the current playback first and then restarts from the beginning.

#### `stop()`
- **Description**: Stops the current sound effect playback.

#### `destroy()`
- **Description**: Releases the underlying player resources. The instance cannot continue to be used after this call.
