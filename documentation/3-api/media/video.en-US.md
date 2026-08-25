# Video Playback

Use `wx.createVideoContext()` to control a rendered `<video>` component from page script. The component displays media, while `VideoContext` controls playback, pause, seeking, and reload.

## Control a Video on the Page

First give the component a stable `id`:

```xml
<video
  id="briefing"
  src="https://example.com/briefing.mp4"
  controls
></video>
```

After the component is mounted, create its context on the current page:

```javascript
export default {
  onReady() {
    this.video = wx.createVideoContext('briefing');
    this.video?.play();
  },

  onUnload() {
    this.video = null;
  },
};
```

## Seek or Reload

```javascript
this.video?.pause();
this.video?.seek(12.5);
this.video?.play();

// Reload the current resource even if src has not changed.
this.video?.load();
```

## Current Limits

- Lookup is scoped to the current page. Keep the matching `<video>` component mounted while using its context.
- Current media support is progressive MP4 with H.264/AVC video and optional AAC audio.
- HLS, DASH, MSE, EME, DRM, subtitles, and multi-track selection are not currently supported.
- Playback progress and asynchronous errors are reported by `<video>` component events; `VideoContext` methods do not return Promises.

## API Reference

### wx APIs

#### `wx.createVideoContext(videoId)`

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `videoId` | `string` | Yes | `id` of the target `<video>` component on the current page. |

Returns `VideoContext | null`; it returns `null` when no matching mounted component exists.

#### `VideoContext`

| Method | Return Value | Description |
| --- | --- | --- |
| `load()` | `void` | Reloads the current `src`. |
| `play()` | `void` | Starts or resumes playback. |
| `pause()` | `void` | Pauses and preserves the current position. |
| `stop()` | `void` | Stops playback and resets the position to zero. |
| `seek(seconds)` | `void` | Seeks to a non-negative time in seconds. |
