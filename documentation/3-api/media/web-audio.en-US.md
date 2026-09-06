# Web Audio

Use the Web Audio API to generate sounds, process PCM audio, adjust volume, apply filters, and inspect waveform or frequency data. It is intended for real-time audio processing.

For ordinary MP3, Ogg, or other file playback, prefer [`AudioPlayer`](/AIUI/api/media-audio-player). It is usually easier to use and more power efficient.

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

## API Reference

### `new AudioContext(options?)`

Creates an audio processing context. `options.sampleRate` sets the sample rate. `latencyHint` accepts `interactive`, `balanced`, `playback`, or a number.

| Member | Description |
| --- | --- |
| `state` | `suspended`, `running`, or `closed`. |
| `currentTime` | Current audio timeline time in seconds. |
| `sampleRate` | Current sample rate. |
| `destination` | Final audio output node. |
| `resume()` | Resumes processing. |
| `suspend()` | Suspends processing. |
| `close()` | Closes the context and releases resources. |
| `decodeAudioData(data)` | Decodes an encoded audio `ArrayBuffer` into an `AudioBuffer`. |

### Create Nodes

| Method | Return value | Use |
| --- | --- | --- |
| `createBufferSource()` | `AudioBufferSourceNode` | Plays an `AudioBuffer`. |
| `createOscillator()` | `OscillatorNode` | Generates a sine, square, sawtooth, or triangle wave. |
| `createGain()` | `GainNode` | Adjusts volume. |
| `createBiquadFilter()` | `BiquadFilterNode` | Filters sound. |
| `createAnalyser()` | `AnalyserNode` | Reads waveform and frequency data. |
| `createBuffer(channels, length, sampleRate)` | `AudioBuffer` | Creates a PCM audio buffer. |

### `AudioParam`

Changing values such as volume and frequency are controlled through `AudioParam`. In addition to assigning `value`, use `setValueAtTime()`, `linearRampToValueAtTime()`, `exponentialRampToValueAtTime()`, `setTargetAtTime()`, and `setValueCurveAtTime()` to schedule changes over time.
