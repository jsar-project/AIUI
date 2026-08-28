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

## Select a Voice

Both `speechSynthesis.speak()` and `speechSynthesis.synthesize()` use `SpeechSynthesisUtterance` as the speech-synthesis request. See the API Reference below for the support status of each property. Set a voice ID through `voice`, then pass the same `utterance` to the method you need:

```javascript
const utterance = new SpeechSynthesisUtterance('Welcome to AIUI');
utterance.voice = 'English_radiant_girl';

speechSynthesis.speak(utterance, 'enqueue');

// Or generate streaming audio and subtitles
const task = await speechSynthesis.synthesize(utterance, {
  subtitles: 'word',
});
```

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
- [x] Properties on `SpeechSynthesisUtterance` are used by both `speak()` and `synthesize()`.
- [x] `pitch` supports values from `-12.0` to `12.0`; `rate` controls the speech-generation speed and supports values from `0.5` to `2.0`; `volume` supports values from `0.0` to `1.0`.
- [ ] `lang` is not currently supported. Setting it does not change the language used for speech generation.
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

### `SpeechSynthesisUtterance`

`SpeechSynthesisUtterance` is a mutable speech-synthesis request object. Both `speechSynthesis.speak()` and `speechSynthesis.synthesize()` accept this object and handle its currently supported properties consistently.

#### `new SpeechSynthesisUtterance(text?)`

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `text` | `string` | No | Initial text to speak. Defaults to an empty string. |

#### Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `string` | `''` | Text to synthesize. |
| `lang` | `string` | `'en-US'` | Speech-generation language. This property is not currently supported. |
| `pitch` | `number` | `1.0` | Pitch, ranging from `-12.0` to `12.0`. |
| `rate` | `number` | `1.0` | Converted to the speech-generation speed, ranging from `0.5` to `2.0`. |
| `voice` | `string \| null` | `null` | Voice ID to use. When set to `null`, the default voice is used. |
| `volume` | `number` | `1.0` | Volume, ranging from `0.0` to `1.0`. |

#### Available `voice` Values

| Voice ID | Voice type | Recommended use |
| --- | --- | --- |
| `female-tianmei` | Sweet Mandarin female voice | Short Mandarin text with `tts_streaming` |
| `English_radiant_girl` | Energetic English female voice | Short English text with `tts_streaming` |
| `English_expressive_narrator` | Expressive English narrator | Long English text with `tts_streaming` |
| `male-qn-qingse` | Young Mandarin male voice | Ink's current default voice and general conversation |
| `male-qn-jingying` | Mature Mandarin male voice | Business content and assistant announcements |
| `female-yujie` | Mature Mandarin female voice | Brand introductions and content narration |
| `Chinese (Mandarin)_News_Anchor` | Mandarin female news voice | News and informational announcements |
| `Chinese (Mandarin)_Radio_Host` | Mandarin male radio voice | Long-form text and stories |
| `clever_boy` | Mandarin boy voice | Children's content |
| `lovely_girl` | Mandarin girl voice | Children's content |
| `Cantonese_ProfessionalHost（F)` | Cantonese female host | Cantonese scenarios |
| `English_Trustworthy_Man` | Trustworthy English male voice | English assistants and business content |

### Methods

#### `speechSynthesis.speak(utterance, mode?)`

`speak()` plays the speech using the current properties of `utterance`.

- `utterance`: A `SpeechSynthesisUtterance` instance. At present, playback is mainly initiated using its text content.
- `mode`: Optional playback mode. Supported values are:
  - `'enqueue'`: Append the current playback request to the queue.
  - `'immediate'`: Play the current utterance immediately.

If `mode` is omitted, it defaults to `'enqueue'`, which appends the current playback request to the queue.

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
| `audioConfig` | `SpeechSynthesisAudioConfig` | Actual generated format, sample rate, channels, sample format, and MIME type. |
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
