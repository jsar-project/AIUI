# Media

AIUI media capabilities cover sound effect playback, audio playback, and device media interaction. For local short sound effects such as button clicks and prompts, you can usually start with `Sound`; for taking photos, camera interaction, or voice capture, continue with the camera and recorder documents. This page does not expand on every API detail. Its main purpose is to help you quickly find the specific docs related to sound effects, audio, recording, and camera features.

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
- **[Camera](/AIUI/api/media-camera)**: See how to create a camera context and interact with the camera on a page.
- **[Recorder](/AIUI/api/media-recorder)**: See the recorder manager entry point and how to manage the recording flow.
- **[Audio](/AIUI/api/media-audio)**: See Web-standard audio-related APIs.
- **[WeChat Mini Program Compatible APIs](/AIUI/api/weixin-compatible-apis)**: See device media APIs such as camera and recording.
