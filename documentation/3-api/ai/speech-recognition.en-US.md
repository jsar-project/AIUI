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
