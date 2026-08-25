# Media

AIUI media capabilities cover sound effects, audio playback, media capture, and video playback. For local short sounds such as button clicks and prompts, start with `Sound`; for photography, audio recording, or video recording, use the unified media-capture documentation.

## Simple Example

For example, play a button click sound effect:

```javascript
const click = new Sound('./click.wav');
click.volume = 0.8;
click.play();
```

## Continue Reading

- **[Sound](/AIUI/api/media-sound)**: See the lightweight playback API for local short sound effects, suitable for frequently replayed sounds such as button clicks and prompts.
- **[AudioPlayer](/AIUI/api/media-audio-player)**: See the audio playback capability recommended by AIUI, suitable for local audio and streaming audio scenarios.
- **[Media Capture](/AIUI/api/media-media-capture)**: See `navigator.mediaDevices`, `ImageCapture`, `MediaRecorder`, and the wx-style camera and recorder APIs.
- **[Video Playback](/AIUI/api/media-video)**: See the `<video>` component and its `VideoContext` playback controls.
- **[Audio](/AIUI/api/media-audio)**: See Web-standard audio-related APIs.
- **[WeChat Mini Program Compatible APIs](/AIUI/api/weixin-compatible-apis)**: See device media APIs such as camera and recording.
