# Speech Synthesis

Speech synthesis converts text into spoken output. It is well suited for welcome messages, spoken replies, navigation prompts, status reminders, and similar scenarios.

In AIUI, speech synthesis is typically used at the output stage of a workflow: once a large language model or business logic has produced a text result, the synthesis capability reads it aloud to the user.

## Speak a Text Response

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const utterance = new SpeechSynthesisUtterance('欢迎使用 AIUI');
speechSynthesis.speak(utterance, 'enqueue');
```

**wx**

```javascript api-style=wx
wx.speech.playTTS('欢迎使用 AIUI');
```

<!-- /aiui-api-style -->

## Generate Audio and Synchronized Subtitles

To separate generation from playback, create a task with `synthesize()` and play it through `SpeechAudioPlayer`:

```javascript
const utterance = new SpeechSynthesisUtterance('Welcome to AIUI');
const task = await speechSynthesis.synthesize(utterance, {
  subtitles: 'word',
  audio: { preferredFormat: 'mp3' },
});

console.log('actual format:', task.audioConfig.format);

const player = new SpeechAudioPlayer(task);
player.textTrack.addEventListener('cuechange', () => {
  const cue = player.textTrack.activeCues.item(0);
  console.log(cue?.text ?? '');
});
player.play();
```

`preferredFormat` is only a preference hint. Always use `task.audioConfig.format` as the actual format.

## Recommendations

- Keep spoken text short enough to be understood in a single listen, rather than reading long paragraphs directly.
- For multiple consecutive replies, control the playback rhythm at the business layer to avoid overwhelming users with too much simultaneous voice output.
- Use different wording lengths and tones for important prompts versus ordinary prompts.

## Current Capability Scope

- [x] Start playback through `speechSynthesis.speak()` and control queueing or immediate playback with `mode`.
- [x] Generate audio chunks and subtitle cues with `speechSynthesis.synthesize()` and play them through `SpeechAudioPlayer`.
- [ ] Parameters on `SpeechSynthesisUtterance` such as `lang`, `pitch`, `rate`, `volume`, and `voice` are not effective yet.
- [ ] `cancel()`, `pause()`, `resume()`, `getVoices()`, and the full utterance lifecycle events are not exposed yet.

## Read Next

- **[Speech Recognition](/AIUI/api/ai-speech-recognition)**: Learn how to convert user speech into text.
- **[Large Language Model](/AIUI/api/ai-language-model)**: Learn how to generate reply content that can be spoken aloud.

## API Reference

### Entry Point

Speech synthesis is based on the global `speechSynthesis` object and `SpeechSynthesisUtterance`:

```javascript
const utterance = new SpeechSynthesisUtterance('欢迎使用 AIUI');
speechSynthesis.speak(utterance);
speechSynthesis.speak(utterance, 'enqueue');
speechSynthesis.speak(utterance, 'immediate');
```

`SpeechSynthesisUtterance` can also be used through the built-in `speech` module.

### Methods

#### `speechSynthesis.speak(utterance, mode?)`

`speak()` forwards the current `utterance` state to the host runtime for playback.

- `utterance`: A `SpeechSynthesisUtterance` instance. At present, playback is mainly initiated using its text content.
- `mode`: Optional playback mode. Supported values are:
  - `'enqueue'`: Append the current playback request to the queue.
  - `'immediate'`: Ask the host to play the current utterance immediately.

If `mode` is omitted, it defaults to `'enqueue'`, which means it will try not to interrupt current playback. The final behavior still depends on the host implementation.

#### `speechSynthesis.synthesize(utterance, options?)`

Creates a streaming speech-generation task without starting playback automatically. Returns `Promise<SpeechSynthesisTask>`.

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `utterance` | `SpeechSynthesisUtterance` | Yes | Speech request to synthesize. |
| `options.subtitles` | `'none' \| 'sentence' \| 'word'` | No | Subtitle-cue granularity. |
| `options.audio.preferredFormat` | `'pcm' \| 'mp3' \| 'ogg_opus'` | No | Preferred output audio format. |
| `options.audio.sampleRate` | `number` | No | Preferred sample rate. |
| `options.audio.channels` | `1 \| 2` | No | Preferred channel count. |
| `options.audio.bitrate` | `number` | No | Preferred bitrate. |
| `options.signal` | `AbortSignal` | No | Signal used to cancel generation. |

### `SpeechSynthesisTask`

| Member | Type | Description |
| --- | --- | --- |
| `id` | `string` | Task identifier. |
| `state` | `'running' \| 'completed' \| 'aborted' \| 'errored'` | Current task state. |
| `audioConfig` | `SpeechSynthesisAudioConfig` | Actual host-returned format, sample rate, channels, sample format, and MIME type. |
| `language` | `string` | Actual language. |
| `granularity` | `'none' \| 'sentence' \| 'word'` | Actual subtitle granularity. |
| `finished` | `Promise<{ duration: number }>` | Resolves when the task finishes. |
| `abort()` | `void` | Aborts generation. |

The task dispatches `chunk`, `end`, `error`, and `abort` events and exposes the matching `onchunk`, `onend`, `onerror`, and `onabort` properties. A `chunk` event contains `audio: Uint8Array` and `cues: readonly SpeechSynthesisCue[]`.

### `new SpeechAudioPlayer(task, options?)`

Creates a player that consumes a `SpeechSynthesisTask`. `options.trackMode` can be `'hidden'` or `'showing'`.

| Member | Type | Description |
| --- | --- | --- |
| `audioPlayer` | `AudioPlayer` | Underlying audio player. |
| `textTrack` | `TextTrack` | Subtitle track updated from generated cues. |
| `activeCue` | `VTTCue \| null` | Currently active subtitle cue. |
| `currentTime` / `duration` | `number` | Current playback time and duration. |
| `paused` | `boolean` | Whether playback is paused. |
| `play()` / `pause()` / `stop()` | `void` | Controls playback state. |
| `seek(position)` | `void` | Seeks to a time in seconds. |
| `destroy()` | `void` | Releases player resources. |
