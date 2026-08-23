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

## Use Cases

- Agent reply playback
- Spoken text after system prompt tones
- Navigation and status reminders
- Voice output in hands-free scenarios

## Recommendations

- Keep spoken text short enough to be understood in a single listen, rather than reading long paragraphs directly.
- For multiple consecutive replies, control the playback rhythm at the business layer to avoid overwhelming users with too much simultaneous voice output.
- Use different wording lengths and tones for important prompts versus ordinary prompts.

## Current Capability Scope

- [x] Start playback through `speechSynthesis.speak()` and control queueing or immediate playback with `mode`.
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
