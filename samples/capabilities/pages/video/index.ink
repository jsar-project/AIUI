<script type="application/json" def>
{
  "navigationBarTitleText": "Video"
}
</script>

<script setup>
const LOCAL_SRC = '/assets/video-progressive.mp4';
const POSTER_SRC = '/assets/video-poster.png';
const NETWORK_SRC =
  'https://ar.rokidcdn.com/web-assets/pages/aiui/resources/trailer.mp4';
const RATE_OPTIONS = [0.5, 1, 1.5, 2];

export default {
  data: {
    videoSrc: LOCAL_SRC,
    posterSrc: POSTER_SRC,
    sourceKind: 'Local package',
    renderMode: 'wireframe',
    muted: true,
    loopEnabled: false,
    playbackRate: 1,
    isPlaying: true,
    hasEnded: false,
    durationSeconds: 0,
    progressPercent: 0,
    lastError: 'None',
  },

  onHide() {
    this.setData({ isPlaying: false });
  },

  loadSource(src, sourceKind) {
    const isCurrentSource = this.data.videoSrc === src;
    this.setData({
      videoSrc: src,
      sourceKind,
      isPlaying: true,
      hasEnded: false,
      durationSeconds: 0,
      progressPercent: 0,
      lastError: 'None',
    });

    if (isCurrentSource) {
      this.reloadVideo();
    }
  },

  reloadVideo() {
    const video = wx.createVideoContext('progressiveVideo');
    if (!video) {
      this.setData({
        isPlaying: false,
        lastError: 'Video context is unavailable',
      });
      return;
    }
    video.load();
  },

  togglePlayback() {
    const video = wx.createVideoContext('progressiveVideo');
    if (!video) {
      this.setData({
        isPlaying: false,
        lastError: 'Video context is unavailable',
      });
      return;
    }
    if (this.data.isPlaying) {
      video.pause();
      this.setData({ isPlaying: false });
    } else {
      if (this.data.hasEnded) {
        video.seek(0);
        this.setData({
          hasEnded: false,
          progressPercent: 0,
        });
      }
      video.play();
      this.setData({ isPlaying: true });
    }
  },

  selectLocal() {
    this.loadSource(LOCAL_SRC, 'Local package');
  },

  selectNetwork() {
    this.loadSource(NETWORK_SRC, 'HTTPS network');
  },

  toggleRenderMode() {
    const renderMode =
      this.data.renderMode === 'wireframe' ? 'normal' : 'wireframe';
    this.setData({ renderMode });
  },

  reload() {
    this.setData({
      isPlaying: true,
      hasEnded: false,
      durationSeconds: 0,
      progressPercent: 0,
      lastError: 'None',
    });
    this.reloadVideo();
  },

  toggleMuted() {
    const muted = !this.data.muted;
    this.setData({ muted });
  },

  toggleLoop() {
    const loopEnabled = !this.data.loopEnabled;
    this.setData({ loopEnabled });
  },

  cyclePlaybackRate() {
    const currentIndex = RATE_OPTIONS.indexOf(this.data.playbackRate);
    const playbackRate = RATE_OPTIONS[(currentIndex + 1) % RATE_OPTIONS.length];
    this.setData({ playbackRate });
  },

  onLoadedMetadata() {
    const video = wx.createVideoContext('progressiveVideo');
    const durationSeconds = video ? video.getDuration() : 0;
    if (Number.isFinite(durationSeconds) && durationSeconds > 0) {
      this.setData({ durationSeconds });
    }
  },

  onTimeUpdate(event) {
    const currentTime = Number(event?.detail?.currentTime) || 0;
    const progressPercent =
      this.data.durationSeconds > 0
        ? Math.min(100, Math.max(0, (currentTime / this.data.durationSeconds) * 100))
        : 0;
    this.setData({ progressPercent });
  },

  onEnded() {
    this.setData({
      isPlaying: false,
      hasEnded: true,
      progressPercent: 100,
    });
  },
};
</script>

<page>
  <view class="container">
    <view class="page-header">
      <text class="page-title">Video Playback</text>
      <text class="page-subtitle">Progressive MP4 · H.264 + AAC-LC</text>
    </view>

    <view class="player-shell">
      <video
        id="progressiveVideo"
        class="video"
        src="{{videoSrc}}"
        poster="{{posterSrc}}"
        autoplay
        render-mode="{{renderMode}}"
        muted="{{muted}}"
        loop="{{loopEnabled}}"
        playback-rate="{{playbackRate}}"
        object-fit="contain"
        bindloadedmetadata="onLoadedMetadata"
        bindtimeupdate="onTimeUpdate"
        bindended="onEnded"
      />

      <view class="player-panel">
        <view class="player-progress-track">
          <view class="player-progress-fill" style="width: {{progressPercent}}%;"></view>
        </view>

        <view class="playback-summary">
          <text class="playback-status">
            {{renderMode === 'wireframe' ? 'Wireframe Playback' : 'Original Image Playback'}}
          </text>
          <text class="playback-source">{{sourceKind}}</text>
        </view>

        <view class="player-controls">
          <button
            class="player-icon-button"
            bindtap="reload"
            aria-label="Reload"
            title="Reload"
          >
            <icon class="player-control-icon">↺</icon>
          </button>
          <button
            class="player-icon-button play-button"
            bindtap="togglePlayback"
            aria-label="{{isPlaying ? 'Pause' : 'Play'}}"
            title="{{isPlaying ? 'Pause' : 'Play'}}"
          >
            <icon class="player-control-icon play-icon">{{isPlaying ? 'Ⅱ' : '▶'}}</icon>
          </button>
          <button
            class="player-icon-button {{muted ? 'player-icon-button-active' : ''}}"
            bindtap="toggleMuted"
            aria-label="{{muted ? 'Unmute' : 'Mute'}}"
            title="{{muted ? 'Unmute' : 'Mute'}}"
          >
            <icon class="player-control-icon">{{muted ? '🔇' : '🔊'}}</icon>
          </button>
          <button
            class="player-icon-button {{loopEnabled ? 'player-icon-button-active' : ''}}"
            bindtap="toggleLoop"
            aria-label="{{loopEnabled ? 'Disable loop' : 'Enable loop'}}"
            title="{{loopEnabled ? 'Disable loop' : 'Enable loop'}}"
          >
            <icon class="player-control-icon">🔁</icon>
          </button>
          <button class="rate-button" bindtap="cyclePlaybackRate">
            {{playbackRate}}x
          </button>
        </view>
      </view>
    </view>

    <view class="playback-options">
      <button class="mode-toggle" bindtap="toggleRenderMode">
        <text class="mode-label {{renderMode === 'wireframe' ? 'mode-label-active' : ''}}">
          Wireframe
        </text>
        <view class="mode-switch {{renderMode === 'normal' ? 'mode-switch-original' : ''}}">
          <view class="mode-switch-thumb"></view>
        </view>
        <text class="mode-label {{renderMode === 'normal' ? 'mode-label-active' : ''}}">
          Original
        </text>
      </button>

      <view class="source-control">
        <button
          class="source-button {{sourceKind === 'Local package' ? 'source-button-active' : ''}}"
          bindtap="selectLocal"
        >
          Local MP4
        </button>
        <button
          class="source-button {{sourceKind === 'HTTPS network' ? 'source-button-active' : ''}}"
          bindtap="selectNetwork"
        >
          Network MP4
        </button>
      </view>
    </view>

    <view class="error-line" ink:if="{{lastError !== 'None'}}">
      <text>Error: {{lastError}}</text>
    </view>
  </view>
</page>

<style>
  .container {
    display: flex;
    flex-direction: column;
    width: 100%;
    gap: var(--spacing-md, 16px);
    padding: var(--theme-padding, 20px);
    box-sizing: border-box;
    background-color: var(--color-background, #f5f7fa);
  }

  .page-header {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .page-title {
    font-size: 24px;
    font-weight: 700;
    color: var(--color-text-primary, #17212b);
  }

  .page-subtitle {
    font-size: 13px;
    color: var(--color-text-secondary, #66717d);
  }

  .player-shell {
    display: flex;
    flex-direction: column;
    width: 100%;
    overflow: clip;
    border: 1px solid var(--border-color-default, #cbd2d9);
    border-radius: var(--radius-sm, 6px);
    background-color: var(--color-surface, #ffffff);
  }

  .video {
    width: 100%;
    height: 240px;
    background-color: #000000;
  }

  .player-panel {
    display: flex;
    flex-direction: column;
  }

  .playback-summary {
    display: flex;
    flex-direction: column;
    min-width: 0;
    gap: 2px;
    padding: 10px 12px 6px;
  }

  .playback-status {
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary, #17212b);
  }

  .playback-source {
    font-size: 11px;
    color: var(--color-text-secondary, #66717d);
  }

  .player-controls {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 8px;
    padding: 6px 12px 12px;
  }

  .player-icon-button,
  .rate-button {
    min-width: 40px;
    height: 40px;
    padding: 0;
    border: 1px solid var(--border-color-default, #cbd2d9);
    border-radius: var(--radius-sm, 6px);
    background-color: var(--color-surface, #ffffff);
    color: var(--color-text-primary, #17212b);
  }

  .play-button {
    flex: 1;
    border-color: var(--color-primary, #1976d2);
    color: var(--color-primary, #1976d2);
  }

  .player-icon-button-active {
    border-color: var(--color-primary, #1976d2);
    color: var(--color-primary, #1976d2);
    background-color: transparent;
  }

  .player-control-icon {
    font-size: 20px;
    line-height: 20px;
  }

  .play-icon {
    font-size: 18px;
    font-weight: 700;
  }

  .rate-button {
    padding: 0 10px;
    font-size: 12px;
    font-weight: 700;
  }

  .playback-options {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .mode-toggle,
  .source-button {
    min-height: 40px;
    padding: 8px 12px;
    border: 1px solid var(--border-color-default, #cbd2d9);
    border-radius: var(--radius-sm, 6px);
    background-color: var(--color-surface, #ffffff);
    color: var(--color-text-primary, #17212b);
    font-size: 13px;
  }

  .mode-toggle {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 10px;
    width: 100%;
  }

  .mode-label {
    color: var(--color-text-secondary, #66717d);
    font-size: 12px;
  }

  .mode-label-active {
    color: var(--color-primary, #1976d2);
    font-weight: 700;
  }

  .mode-switch {
    display: flex;
    flex-direction: row;
    justify-content: flex-start;
    width: 36px;
    height: 20px;
    padding: 2px;
    box-sizing: border-box;
    border-radius: 10px;
    background-color: var(--color-primary, #1976d2);
  }

  .mode-switch-original {
    justify-content: flex-end;
  }

  .mode-switch-thumb {
    width: 16px;
    height: 16px;
    border-radius: 8px;
    background-color: var(--color-surface, #ffffff);
  }

  .source-control {
    display: flex;
    flex-direction: row;
    gap: 8px;
  }

  .source-button {
    flex: 1;
  }

  .source-button-active {
    border: 3px solid var(--color-primary, #1976d2);
    background-color: transparent;
    color: var(--color-primary, #1976d2);
    font-weight: 700;
  }

  .error-line {
    padding: 10px 12px;
    border-left: 3px solid #c62828;
    background-color: #ffebee;
    color: #8e1b1b;
    font-size: 12px;
  }

  .player-progress-track {
    width: 100%;
    height: 4px;
    overflow: clip;
    background-color: var(--border-color-subtle, #e5e9ed);
  }

  .player-progress-fill {
    height: 4px;
    background-color: var(--color-primary, #1976d2);
  }
</style>
