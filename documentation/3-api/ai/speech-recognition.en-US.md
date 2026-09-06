# Speech Recognition

Speech recognition converts what the user says in real time into text. It is suitable for voice input, voice commands, hands-free input, and conversational interaction.

In AIUI, speech recognition is usually the first step in a voice interaction pipeline: user speech is recognized into text first, and then the text is passed to business logic or a large language model for further processing.

## Recognize a Voice Input

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
const recognition = new SpeechRecognition();

recognition.onresult = (event) => {
  const best = event.results[0][0];
  console.log(best.transcript, best.confidence);
};

recognition.onerror = (event) => {
  console.error(event.error, event.message);
};

recognition.start();
```

**wx**

```javascript api-style=wx
const sessionId = wx.speech.startRecognition();
console.log('Recognition session:', sessionId);
```

<!-- /aiui-api-style -->

## Recognize Existing or Incremental Audio

`SpeechRecognitionSession` does not open the microphone itself. Write a recording, an existing audio file, or incoming audio chunks to its `audio` stream:

```javascript
const session = new SpeechRecognitionSession({
  lang: 'en-US',
  interimResults: true
});

session.onresult = (event) => {
  const result = event.results[event.resultIndex][0];
  console.log(result.transcript);
};

session.onerror = (event) => {
  console.error(event.error, event.message);
};

const audio = await fetch('/assets/question.wav').then(response => response.blob());
const writer = session.audio.getWriter();
await writer.write(audio);
await writer.close();
```

Each `write()` accepts a `Blob`, `ArrayBuffer`, or typed array. Calling `close()` means all audio has been written and allows recognition to produce its final result. Call `writer.abort()` to cancel.

Raw PCM input requires an explicit format:

```javascript
const session = new SpeechRecognitionSession({
  audio: {
    mimeType: 'audio/pcm',
    sampleRate: 16000,
    channelCount: 1,
    sampleFormat: 's16'
  }
});
```

## Add Custom Phrases

Custom phrases help the recognition service understand product names, people, places, and domain-specific vocabulary. Check `getCapabilities()` first, then pass `phrases` when creating the session:

```javascript
const capabilities = await SpeechRecognitionSession.getCapabilities();

const options = {
  lang: 'en-US',
  interimResults: true,
};

if (capabilities.phrases) {
  options.phrases = [
    { phrase: 'Rokid', boost: 5 },
    { phrase: 'AIUI', boost: 5 },
    { phrase: 'Lingban', boost: 3 },
  ];
}

const session = new SpeechRecognitionSession(options);
const writer = session.audio.getWriter();
const audio = await fetch('/assets/product-intro.wav')
  .then((response) => response.blob());

await writer.write(audio);
await writer.close();
```

`phrase` is the term to prioritize and must not be empty. `boost` is an optional weight that defaults to `1`; a higher value asks the recognition service to give the phrase more consideration. Support is reported by `capabilities.phrases`.

## Update ASR Context

Context tells the recognition service what the current conversation is about. Set initial context before the first audio write, or replace it during recognition with `updateContext()`:

```javascript
const capabilities = await SpeechRecognitionSession.getCapabilities();
const session = new SpeechRecognitionSession({
  lang: 'en-US',
  audio: {
    mimeType: 'audio/pcm',
    sampleRate: 16000,
    channelCount: 1,
    sampleFormat: 's16',
  },
});

if (capabilities.contextUpdates) {
  await session.updateContext([
    { role: 'user', text: 'I am asking about tomorrow’s weather in Hangzhou.' },
    { role: 'assistant', text: 'I will focus on Hangzhou and tomorrow.' },
  ]);
}

const writer = session.audio.getWriter();
const firstPart = await fetch('/assets/question-1.pcm')
  .then((response) => response.arrayBuffer());
await writer.write(firstPart);

// Replace the context when the conversation changes.
if (capabilities.contextUpdates) {
  await session.updateContext([
    { role: 'user', text: 'Now I want to check flights from Shanghai.' },
    { role: 'assistant', text: 'What is your departure date?' },
  ]);
}

const secondPart = await fetch('/assets/question-2.pcm')
  .then((response) => response.arrayBuffer());
await writer.write(secondPart);
await writer.close();
```

Each message must use `user` or `assistant` as its `role`, and `text` must not be empty. Do not call this method when the current service does not support context updates.

## Use Cases

- Voice input fields
- Voice Q&A
- Voice control commands
- Interaction flows that need to listen and process at the same time

## Event Handling Recommendations

- Use `onresult` to receive recognition results.
- Use `onerror` to handle exceptions such as permission issues, device problems, or recognition failures.
- Use `onend` to know when the current recognition session has ended and update the UI state in time.

## Recommendations

- Before starting recognition, make sure the current screen is ready for interaction.
- Clearly present states such as "listening", "recognizing", "recognition complete", and "recognition failed" to users.
- Do not start multiple recognition sessions concurrently on the same instance.

## Read Next

- **[Speech Synthesis](/AIUI/api/ai-speech-synthesis)**: Learn how to speak text results to the user.
- **[Large Language Model](/AIUI/api/ai-language-model)**: Learn how to pass recognized text to the model for further processing.

## API Reference

### Entry Point

Speech recognition is based on `SpeechRecognition`:

```javascript
const recognition = new SpeechRecognition();
```

### Common Methods

#### `start()`
- Starts a recognition session.

#### `stop()`
- Requests the current recognition session to end and produce a final result if possible.

#### `abort()`
- Immediately aborts the current recognition session without waiting for a normal final result.

### `new SpeechRecognitionSession(options?)`

Creates a recognition session with a writable audio stream. Common options include:

| Option | Type | Description |
| --- | --- | --- |
| `lang` | `string` | Recognition language, such as `en-US`. |
| `interimResults` | `boolean` | Whether unconfirmed interim results are reported. Defaults to `false`. |
| `maxAlternatives` | `number` | Maximum alternatives returned for each result. The default and minimum are `1`. |
| `phrases` | `SpeechRecognitionPhrase[]` | Custom phrases and optional weights. Check `capabilities.phrases` first. |
| `segmentation` | `string` | `auto`, `vad`, or `semantic`. Check `segmentationModes` first. |
| `audio` | `SpeechRecognitionAudioOptions` | Input audio format. |

**`SpeechRecognitionPhrase`**

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `phrase` | `string` | Yes | Phrase text; it must not be empty. |
| `boost` | `number` | No | Phrase weight. Defaults to `1`. |

**`SpeechRecognitionAudioOptions`**

| Field | Type | Description |
| --- | --- | --- |
| `mimeType` | `string` | Audio MIME type, such as `audio/pcm`. |
| `sampleRate` | `number` | Sample rate, such as `16000`. |
| `channelCount` | `number` | Channel count; use `1` for mono. |
| `sampleFormat` | `'s16' \| 'f32'` | PCM sample format. |

The instance provides a read-only writable stream in `audio` and a read-only `state`. In the current implementation, `state` can be `idle`, `opening`, `streaming`, `closing`, or `closed`. The instance also supports `onstart`, `onaudiostart`, `onresult`, `onerror`, `onaudioend`, and `onend`.

### `SpeechRecognitionSession.getCapabilities()`

```javascript
const capabilities = await SpeechRecognitionSession.getCapabilities();
```

Returns `Promise<SpeechRecognitionCapabilities>`. Call it before creating a session to choose supported audio, phrase, context, and segmentation options. The Promise rejects if capabilities cannot be queried.

| Property | Type | Description |
| --- | --- | --- |
| `audioFormats` | `SpeechRecognitionAudioFormatCapability[]` | Supported audio formats and their sample rates, channel counts, and sample formats. |
| `maxChunkBytes` | `number` | Maximum bytes in each transmitted part. Larger writes are split automatically. |
| `interimResults` | `boolean` | Whether interim recognition results are supported. |
| `maxAlternatives` | `number` | Maximum alternatives supported for each result. |
| `phrases` | `boolean` | Whether custom `phrases` are supported. |
| `contextUpdates` | `boolean` | Whether ASR context can be set and updated. |
| `segmentationModes` | `Array<'auto' \| 'vad' \| 'semantic'>` | Supported audio segmentation modes. |

Each item in `audioFormats` contains:

| Property | Type | Description |
| --- | --- | --- |
| `mimeType` | `string` | Supported audio MIME type. |
| `sampleRates` | `number[]` | Supported sample rates; an empty array means unrestricted. |
| `channelCounts` | `number[]` | Supported channel counts; an empty array means unrestricted. |
| `sampleFormats` | `Array<'s16' \| 'f32'>` | Supported PCM sample formats; an empty array means unrestricted. |

### `session.updateContext(messages)`

Replaces the current ASR context with a new list of messages and returns `Promise<void>`.

| Parameter | Type | Description |
| --- | --- | --- |
| `messages` | `SpeechRecognitionContextMessage[]` | Context messages in conversation order. |

| Message field | Type | Description |
| --- | --- | --- |
| `role` | `'user' \| 'assistant'` | Message role. No other values are accepted. |
| `text` | `string` | Message text. It must not be empty. |

- Before the first audio write, the context is included when the session starts.
- During recognition, the active context is replaced immediately.
- A non-array value, unsupported role, or empty text throws a `TypeError`.
- Before the session starts, the method stores the context first. If context is unsupported, the first `writer.write()` rejects.
- During recognition, the Promise returned by `updateContext()` rejects when the update fails. Check `contextUpdates` from `getCapabilities()` first.
