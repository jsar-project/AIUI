# Large Language Model

Large language models are used for tasks such as question answering, summarization, extraction, rewriting, generation, and reasoning. In AIUI, they typically serve as the core understanding and generation capability of an agent.

If your application needs to generate replies based on context, or perform more complex semantic processing on user input, `LanguageModel` is usually a good place to start.

## Check Availability First

```javascript
const status = await LanguageModel.availability();

if (status !== 'available') {
  throw new Error('LanguageModel 当前不可用');
}
```

## Create a Session

```javascript
const session = await LanguageModel.create({
  initialPrompts: [
    { role: 'system', content: '请用简洁中文回答。' },
  ],
});
```

## One-Off Request

```javascript
const text = await session.prompt('请用一句话介绍 AIUI');
console.log(text);
```

## Upload an Image to the Model

To let the model understand a local image, import it as a `Blob`, convert it to a Data URL, and place it alongside the question in the user message's `content` array:

```javascript
import productPhoto, { mimeType } from '../../assets/product.jpg';

async function blobToDataUrl(blob, type) {
  const bytes = new Uint8Array(await blob.arrayBuffer());
  const chunkSize = 0x8000;
  let binary = '';

  for (let offset = 0; offset < bytes.length; offset += chunkSize) {
    binary += String.fromCharCode(
      ...bytes.subarray(offset, offset + chunkSize)
    );
  }

  return `data:${type};base64,${btoa(binary)}`;
}

const session = await LanguageModel.create();
const imageUrl = await blobToDataUrl(productPhoto, mimeType);
const answer = await session.prompt([
  {
    role: 'user',
    content: [
      {
        type: 'text',
        text: 'Describe the product and list its main colors.',
      },
      {
        type: 'image_url',
        image_url: { url: imageUrl },
      },
    ],
  },
]);

console.log(answer);
session.destroy();
```

Images captured from a camera work the same way. `ImageCapture.takePhoto()` returns a `Blob` that can be passed to `blobToDataUrl()`.

If the image already has a publicly accessible HTTPS URL, no Base64 conversion is needed. Assign the URL directly to `image_url.url`:

```javascript
const answer = await session.prompt([
  {
    role: 'user',
    content: [
      { type: 'text', text: 'What is shown in this image?' },
      {
        type: 'image_url',
        image_url: { url: 'https://example.com/photos/product.jpg' },
      },
    ],
  },
]);
```

The selected model must support image input. Resize and compress images before uploading so a large Data URL does not slow the request or exceed model limits.

## Streaming Output

```javascript
const stream = session.promptStreaming('请分点总结这段内容');

while (true) {
  const { done, value } = await stream.read();
  if (done) break;
  if (value !== undefined) {
    console.log(value);
  }
}
```

## Example: Tool Calls

If your model request needs to declare available tools, you can pass function declarations through `tools` when creating the session. When the model decides a tool should be called, it triggers the `toolcall` event.

### Declare Tools and Listen for Callbacks

```javascript
const session = await LanguageModel.create({
  initialPrompts: [
    { role: 'system', content: '你是一个天气助手，请优先使用已声明的工具。' },
  ],
  tools: [
    {
      type: 'function',
      function: {
        name: 'get_weather',
        description: '查询某个城市的天气',
        parameters: {
          type: 'object',
          properties: {
            city: { type: 'string' },
          },
          required: ['city'],
        },
      },
    },
  ],
});

// Listen for tool call events
session.addEventListener('toolcall', (event) => {
  console.log('收到工具调用请求:', event.functionName);
  console.log('参数:', event.arguments);

  if (event.functionName === 'get_weather') {
    // Handle weather query logic
    const { city } = event.arguments;
    console.log(`正在查询 ${city} 的天气...`);
  }
});

const result = await session.prompt('帮我查询一下杭州今天天气');
```

## Current Capability Boundaries

- [x] Declare available functions and their parameter structures to the model.
- [x] Receive structured tool call requests through `session.addEventListener('toolcall', ...)`.
- [x] Plain text or text deltas returned by the backend are exposed to the frontend through `prompt()` or `promptStreaming()`.

## Use Cases

- Conversational question answering
- Content summarization and rewriting
- Information extraction and structured output
- Streaming reply generation
- Multi-turn interactions with context

## Recommendations

- Treat a session as one contextual interaction unit rather than a global singleton.
- Prefer `promptStreaming()` for long text output, as it is better for incremental display and synchronized speech playback.
- Call `destroy()` promptly when leaving the page, ending the session, or no longer needing the context.
- If your business logic needs to declare tool capabilities, pass function declarations through `tools` in `create()`.

## Notes

- Only one active request should run at a time within the same session.
- `initialPrompts` are better suited for system constraints and initial context. It is not recommended to put every user input into them.
- If `model` is not explicitly provided, the runtime environment must supply a default model configuration.
- Streaming output returns a polling-style reader object, suitable for consuming text deltas chunk by chunk.

## Read Next

- **[Speech Recognition](/AIUI/api/ai-speech-recognition)**: Learn how to pass user voice input to the model.
- **[Speech Synthesis](/AIUI/api/ai-speech-synthesis)**: Learn how to speak model replies to the user.

## API Reference

### Entry Point

`LanguageModel` can be used directly or imported from the built-in module:

```javascript
const status = await LanguageModel.availability();
```

```javascript
import { LanguageModel } from 'language-model';
```

### Common Methods

#### `availability()`
- **Return value**: `Promise<'available' | 'unavailable'>`
- **Description**: Checks whether the current runtime environment can provide large language model capabilities.

#### `create(options?)`
- **Return value**: `Promise<LanguageModelSession>`
- **Description**: Creates a new model session.

#### `prompt(input)`
- **Return value**: `Promise<string>`
- **Description**: Sends a single request and returns the final text after completion. `input` can be a string or `LanguageModelMessage[]`.

#### `promptStreaming(input)`
- **Return value**: `LanguageModelTextStream`
- **Description**: Starts a streaming request and reads model output incrementally.

#### `clone()`
- **Description**: Clones the current session context and creates a new independent session.

#### `destroy()`
- **Description**: Destroys the current session and releases the session resources needed for later use.

### Image Input Messages

Image input is only allowed in a structured message with `role: 'user'`. `content` is an array that can contain text and one or more images.

| Content type | Shape | Description |
| --- | --- | --- |
| Text | `{ type: 'text', text: string }` | `text` must not be empty. |
| Image | `{ type: 'image_url', image_url: { url: string } }` | `url` can be an image URL accessible to the model or an image Data URL. It must not be empty. |

`system` and `assistant` messages only support string `content`; they cannot use an image content array. An empty content array, empty text, or empty image URL causes the call to fail.

### `toolcall` Event Object

The `toolcall` event object contains the following properties:

- `callId`: A unique identifier for the tool call.
- `functionName`: The function name to be called.
- `arguments`: Parsed function arguments, typically a JavaScript object.
- `toolType`: The tool type, currently always `"function"`.
- `index`: The index of this tool call in the current request.
- `isComplete`: Indicates whether this tool call is complete. It is currently always `true`.
