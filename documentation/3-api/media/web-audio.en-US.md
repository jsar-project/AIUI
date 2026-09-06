# Audio Processing (Web Audio)

Audio processing is intended for scenarios that generate, capture, or modify sound in real time. AIUI uses the Web Audio API to generate sounds, process PCM audio, connect microphone input, adjust volume, apply filters, and inspect waveform or frequency data.

For ordinary MP3, Ogg, or other complete file playback, prefer [Audio Playback](/AIUI/api/media-audio-player). It is usually easier to use and more power efficient.

## Generate a Short Tone

```javascript
const context = new AudioContext();
await context.resume();

const oscillator = context.createOscillator();
oscillator.frequency.value = 440;
oscillator.connect(context.destination);
oscillator.start();
oscillator.stop(context.currentTime + 0.2);
```

An `AudioContext` may start in the `suspended` state. Call `resume()` before playback.

## Adjust Volume and Tone

Connect audio nodes in the order in which they should process the sound:

```javascript
const context = new AudioContext();
await context.resume();

const oscillator = context.createOscillator();
const filter = context.createBiquadFilter();
const gain = context.createGain();

filter.type = 'lowpass';
filter.frequency.value = 1200;
gain.gain.value = 0.25;

oscillator.connect(filter);
filter.connect(gain);
gain.connect(context.destination);

oscillator.start();
oscillator.stop(context.currentTime + 0.5);
```

`connect()` defines the processing order. Here the sound passes through a low-pass filter, has its volume reduced, and then reaches the output.

## Play PCM Data

```javascript
const context = new AudioContext({ sampleRate: 16000 });
const buffer = context.createBuffer(1, pcmSamples.length, 16000);
buffer.copyToChannel(pcmSamples, 0);

const source = context.createBufferSource();
source.buffer = buffer;
source.connect(context.destination);

await context.resume();
source.start();
```

`pcmSamples` is a `Float32Array`, with samples normally ranging from `-1` to `1`.

## Inspect Waveform and Frequency Data

```javascript
const analyser = context.createAnalyser();
analyser.fftSize = 2048;
source.connect(analyser);
analyser.connect(context.destination);

const waveform = new Uint8Array(analyser.fftSize);
analyser.getByteTimeDomainData(waveform);

const spectrum = new Uint8Array(analyser.frequencyBinCount);
analyser.getByteFrequencyData(spectrum);
```

Call `context.close()` when the context is no longer needed to release audio resources.

## Analyse Microphone Input

You can connect a microphone stream returned by `getUserMedia()` to Web Audio. This is useful for volume animations, live waveforms, and interfaces controlled by sound.

First declare microphone permission in `app.json`:

```json
{
  "permissions": ["RECORD_AUDIO"]
}
```

The following page example starts measuring microphone volume after a user action and releases its resources when the page unloads:

```javascript
export default {
  async startMicrophoneAnalysis() {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    const context = new AudioContext();
    const source = context.createMediaStreamSource(stream);
    const analyser = context.createAnalyser();
    const waveform = new Float32Array(analyser.fftSize);

    source.connect(analyser);
    await context.resume();

    this.microphone = { stream, context, source };
    this.volumeTimer = setInterval(() => {
      analyser.getFloatTimeDomainData(waveform);
      let energy = 0;
      for (const sample of waveform) energy += sample * sample;
      const volume = Math.sqrt(energy / waveform.length);
      console.log('Current volume:', volume);
    }, 50);
  },

  async stopMicrophoneAnalysis() {
    clearInterval(this.volumeTimer);
    if (!this.microphone) return;

    const { stream, context, source } = this.microphone;
    source.disconnect();
    for (const track of stream.getTracks()) track.stop();
    await context.close();
    this.microphone = null;
  },

  onUnload() {
    return this.stopMicrophoneAnalysis();
  },
};
```

Call `startMicrophoneAnalysis()` from a user action such as a button `bindtap`. Volume analysis does not require a connection to `context.destination`; connecting it would play the microphone through the speaker and may cause feedback.

## API Reference

### `new AudioContext(options?)`

`AudioContext` is the entry point for Web Audio and the only context you create directly. `options.sampleRate` sets the sample rate. `latencyHint` accepts `interactive`, `balanced`, `playback`, or a number.

| Member | Description |
| --- | --- |
| `state` | `suspended`, `running`, or `closed`. |
| `currentTime` | Current audio timeline time in seconds. |
| `sampleRate` | Current sample rate. |
| `destination` | Final audio output node. |
| `onstatechange` | Called when the context state changes. |
| `resume()` | Resumes processing. |
| `suspend()` | Suspends processing. |
| `close()` | Closes the context and releases resources. |
| `decodeAudioData(data)` | Decodes an encoded audio `ArrayBuffer` into an `AudioBuffer`. |
| `createMediaStreamSource(mediaStream)` | Creates a `MediaStreamAudioSourceNode` that reads an audio track from the media stream. Throws `InvalidStateError` if the stream has no audio track. |

`AudioContext` inherits all properties and creation methods from `BaseAudioContext`.

### `BaseAudioContext`

`BaseAudioContext` defines the shared capabilities of audio contexts. It cannot be created with `new BaseAudioContext()`.

| Method | Return value | Use |
| --- | --- | --- |
| `createBufferSource()` | `AudioBufferSourceNode` | Plays an `AudioBuffer`. |
| `createOscillator()` | `OscillatorNode` | Generates a sine, square, sawtooth, or triangle wave. |
| `createGain()` | `GainNode` | Adjusts volume. |
| `createBiquadFilter()` | `BiquadFilterNode` | Filters sound. |
| `createAnalyser()` | `AnalyserNode` | Reads waveform and frequency data. |
| `createBuffer(channels, length, sampleRate)` | `AudioBuffer` | Creates a PCM audio buffer. |
| `decodeAudioData(data, success?, error?)` | `Promise<AudioBuffer>` | Decodes encoded audio, with optional success and error callbacks. |

It also provides the read-only `sampleRate`, `currentTime`, `state`, and `destination` properties, plus `onstatechange`.

### `AudioNode`

`AudioNode` is the base class for every processing node and cannot be constructed directly. Use `connect()` to build a processing chain and `disconnect()` to remove connections.

| Member | Description |
| --- | --- |
| `context` | The `BaseAudioContext` that owns the node. |
| `numberOfInputs` / `numberOfOutputs` | Number of inputs and outputs. |
| `channelCount` | Number of channels processed by the node. |
| `channelCountMode` | `max`, `clamped-max`, or `explicit`. |
| `channelInterpretation` | `speakers` or `discrete`. |
| `connect(destination, output?, input?)` | Connects to another `AudioNode` or an `AudioParam`. |
| `disconnect(...)` | Removes all connections or a selected output, node, or parameter connection. |

### `AudioDestinationNode`

`AudioDestinationNode` represents the final audio output. Obtain it from `context.destination`; it cannot be constructed directly. Its read-only `maxChannelCount` is the maximum supported output channel count.

### `AudioScheduledSourceNode`

`AudioScheduledSourceNode` is the base class for sources that can start and stop on the audio timeline. It cannot be constructed directly.

| Member | Description |
| --- | --- |
| `start(when?)` | Starts at an audio time, or immediately when omitted. |
| `stop(when?)` | Stops at an audio time, or immediately when omitted. |
| `onended` | Called when the source finishes. |

`OscillatorNode` and `AudioBufferSourceNode` inherit these capabilities.

### `new AudioBuffer(options)`

`AudioBuffer` stores PCM samples in memory. It can also be created with `context.createBuffer()`.

| Member | Description |
| --- | --- |
| `sampleRate` | Sample rate. |
| `length` | Number of samples in each channel. |
| `duration` | Audio duration in seconds. |
| `numberOfChannels` | Number of channels. |
| `getChannelData(channel)` | Returns the channel as a `Float32Array`. |
| `copyToChannel(source, channel, start?)` | Copies samples into a channel. |
| `copyFromChannel(destination, channel, start?)` | Copies samples out of a channel. |

Constructor options require `length` and `sampleRate`; `numberOfChannels` is optional.

### `new AudioBufferSourceNode(context, options?)`

`AudioBufferSourceNode` plays an `AudioBuffer`. It can also be created with `context.createBufferSource()`.

| Member | Description |
| --- | --- |
| `buffer` | The `AudioBuffer` to play, or `null`. |
| `playbackRate` | An `AudioParam` controlling playback speed. |
| `detune` | An `AudioParam` shifting pitch in cents. |
| `loop` | Whether playback loops. |
| `loopStart` / `loopEnd` | Loop range in seconds. |
| `start(when?, offset?, duration?)` | Schedules playback with an optional offset and duration. |

A source can only be started once. Create a new `AudioBufferSourceNode` to play the same `AudioBuffer` again.

### `AudioParam`

`AudioParam` represents a value such as volume or frequency that can change over time. It cannot be constructed directly and is exposed through properties such as `gain`, `frequency`, and `detune`.

| Member | Description |
| --- | --- |
| `value` | Current parameter value. |
| `automationRate` | `a-rate` or `k-rate`. |
| `defaultValue` / `minValue` / `maxValue` | Read-only default and range. |
| `setValueAtTime(value, time)` | Sets a value at a time. |
| `linearRampToValueAtTime(value, endTime)` | Ramps linearly to a value. |
| `exponentialRampToValueAtTime(value, endTime)` | Ramps exponentially to a value. |
| `setTargetAtTime(target, startTime, timeConstant)` | Approaches a target from a time. |
| `setValueCurveAtTime(values, startTime, duration)` | Follows a value curve. |
| `cancelScheduledValues(time)` | Cancels changes after a time. |
| `cancelAndHoldAtTime(time)` | Cancels later changes and holds the value at that time. |

All setting and scheduling methods return the same `AudioParam` for chaining.

### `new GainNode(context, options?)`

`GainNode` adjusts input volume and can also be created with `context.createGain()`. Its read-only `gain` property is an `AudioParam`; the constructor's `gain` option sets its initial value.

### `new OscillatorNode(context, options?)`

`OscillatorNode` generates a continuous waveform and can also be created with `context.createOscillator()`.

| Member | Description |
| --- | --- |
| `type` | `sine`, `square`, `sawtooth`, or `triangle`. |
| `frequency` | Frequency `AudioParam` in Hz. |
| `detune` | Pitch offset `AudioParam` in cents. |

Constructor options can set `type`, `frequency`, and `detune`.

### `new BiquadFilterNode(context, options?)`

`BiquadFilterNode` applies common audio filters and can also be created with `context.createBiquadFilter()`.

| Member | Description |
| --- | --- |
| `type` | `lowpass`, `highpass`, `bandpass`, `lowshelf`, `highshelf`, `peaking`, `notch`, or `allpass`. |
| `frequency` | Cutoff or center frequency. |
| `detune` | Frequency offset. |
| `Q` | Quality factor. |
| `gain` | Gain used by selected filter types. |
| `getFrequencyResponse(frequencies, magnitudes, phases)` | Calculates magnitude and phase responses for a frequency array. |

`frequency`, `detune`, `Q`, and `gain` are all `AudioParam` objects.

### `new AnalyserNode(context, options?)`

`AnalyserNode` reads waveform and frequency data from passing audio and can also be created with `context.createAnalyser()`. It does not change the sound.

| Member | Description |
| --- | --- |
| `fftSize` | Analysis window size. |
| `frequencyBinCount` | Frequency data length, equal to `fftSize / 2`. |
| `minDecibels` / `maxDecibels` | Decibel range for frequency data. |
| `smoothingTimeConstant` | Smoothing between consecutive analyses. |
| `getFloatTimeDomainData(array)` | Writes floating-point waveform data. |
| `getByteTimeDomainData(array)` | Writes waveform data from 0 to 255. |
| `getFloatFrequencyData(array)` | Writes floating-point decibel data. |
| `getByteFrequencyData(array)` | Writes frequency data from 0 to 255. |

### `new MediaStreamAudioSourceNode(context, options)`

`MediaStreamAudioSourceNode` connects audio tracks from a microphone or another `MediaStream` to Web Audio. It can also be created with `context.createMediaStreamSource(mediaStream)`.

```javascript
const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
const context = new AudioContext();
const microphone = context.createMediaStreamSource(stream);
const analyser = context.createAnalyser();

microphone.connect(analyser);
```

| Member | Description |
| --- | --- |
| `new MediaStreamAudioSourceNode(context, { mediaStream })` | Creates a node for the specified stream. `mediaStream` is required and must contain an audio track. |
| `mediaStream` | Read-only. Returns the stream used to create the node. |
| `numberOfInputs` | Always `0`, because audio comes from the media stream instead of another audio node. |

The node uses an audio track from the media stream. Set the track's `enabled` property to `false` to mute it temporarily and back to `true` to resume input. After `track.stop()` ends the track, the node outputs silence.

When finished, call `source.disconnect()`, stop the stream tracks, and call `context.close()`. The constructor and `createMediaStreamSource()` throw `TypeError` when the supplied value is not a `MediaStream`.
