<script type="application/json" def>{ "widget": { "family": "1x2" } }</script>

<script setup>
export default {
  data: { playbackStatus: 'loading' },
  onPlaying() {
    this.setData({ playbackStatus: 'playing' });
  },
  onTimeUpdate(event) {
    this.setData({
      playbackStatus: `playing ${Number(event.detail.currentTime || 0).toFixed(1)}s`,
    });
  },
  onError(event) {
    this.setData({ playbackStatus: `error: ${event.detail.message}` });
  },
};
</script>

<widget>
  <view class="case">
    <text class="title">Relative media widget</text>
    <text class="copy">Relative source · {{playbackStatus}}</text>
    <video
      id="relativeMediaVideo"
      class="media"
      src="../../assets/video-progressive.mp4"
      poster="../../assets/video-poster.png"
      autoplay
      loop
      muted
      object-fit="contain"
      bindplaying="onPlaying"
      bindtimeupdate="onTimeUpdate"
      binderror="onError"
    />
  </view>
</widget>

<style>
.case { display: flex; flex-direction: column; gap: 8px; width: 100%; box-sizing: border-box; padding: 12px; }
.title { font-size: 16px; font-weight: bold; }
.copy { font-size: 11px; }
.media { width: 100%; height: 88px; }
</style>
