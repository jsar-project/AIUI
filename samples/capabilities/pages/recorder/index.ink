<script type="application/json" def>
{
  "navigationBarTitleText": "Recorder"
}
</script>

<script setup>
import wx from 'wx';
import { AudioPlayer } from 'audio';

function formatTime(value) {
  const seconds = Math.max(0, Math.floor(Number(value) || 0));
  return `${String(Math.floor(seconds / 60)).padStart(2, '0')}:${String(seconds % 60).padStart(2, '0')}`;
}

export default {
  data: {
    currentFormat: 'pcm',
    state: 'idle',
    actionLabel: 'Start',
    elapsed: '00:00',
    playbackSrc: '',
    playbackState: 'idle',
    error: '',
  },

  onLoad() {
    this.recorder = null;
    this.player = null;
    this.recordingStartedAt = 0;
    this.elapsedTimer = null;
    this.playbackTimer = null;
    this.recordingDurationSeconds = 0;
    this.header = null;
    this.frames = [];
    this.bindRecorder();
  },

  onUnload() {
    this.stopRecordingSilently();
    this.destroyPlayer();
    this.revokePlaybackUrl();
  },

  bindRecorder() {
    try {
      this.recorder = wx.media.getRecorderManager();
      if (!this.recorder) throw new Error('RecorderManager is unavailable');
      this.recorder.onStart(() => {
        this.recordingStartedAt = Date.now();
        this.startClock();
        this.setData({ state: 'recording', actionLabel: 'Pause', error: '' });
      });
      this.recorder.onPause(() => this.setData({ state: 'paused', actionLabel: 'Resume' }));
      this.recorder.onResume(() => {
        this.recordingStartedAt = Date.now() - this.elapsedSeconds * 1000;
        this.startClock();
        this.setData({ state: 'recording', actionLabel: 'Pause' });
      });
      this.recorder.onHeader((_format, buffer) => {
        this.header = buffer;
      });
      this.recorder.onFrameRecorded(({ frameBuffer } = {}) => {
        if (frameBuffer) this.frames.push(frameBuffer);
      });
      this.recorder.onStop(async () => {
        this.stopClock();
        this.recordingDurationSeconds = this.elapsedSeconds;
        await this.buildPlayback();
        this.setData({ state: 'idle', actionLabel: 'Start' });
      });
      this.recorder.onError(({ errMsg } = {}) => {
        this.stopClock();
        this.setData({ state: 'idle', actionLabel: 'Start', error: errMsg || 'Recording failed' });
      });
    } catch (error) {
      this.setData({ error: String(error) });
    }
  },

  setFormat(format) {
    if (this.data.state !== 'idle') return;
    this.setData({ currentFormat: format, error: '' });
  },

  usePCM() { this.setFormat('pcm'); },
  useOpus() { this.setFormat('opus'); },

  toggleRecording() {
    if (!this.recorder) return;
    if (this.data.state === 'idle') return this.startRecording();
    if (this.data.state === 'paused') return this.resumeRecording();
    return this.pauseRecording();
  },

  async startRecording() {
    try {
      this.revokePlaybackUrl();
      this.header = null;
      this.frames = [];
      this.elapsedSeconds = 0;
      this.setData({ elapsed: '00:00', playbackState: 'idle', error: '', state: 'starting' });
      await this.recorder.start({
        sampleRate: 16000,
        numberOfChannels: 1,
        format: this.data.currentFormat,
      });
    } catch (error) {
      this.setData({ state: 'idle', actionLabel: 'Start', error: String(error) });
    }
  },

  async pauseRecording() {
    try { await this.recorder.pause(); } catch (error) { this.setData({ error: String(error) }); }
  },

  async resumeRecording() {
    try { await this.recorder.resume(); } catch (error) { this.setData({ error: String(error) }); }
  },

  onKeyDown(event) {
    if (event && event.code === 'Enter') {
      if (this.data.state === 'idle') this.toggleRecording();
      else this.stopRecording();
    }
  },

  async stopRecording() {
    try { await this.recorder.stop(); } catch (error) { this.setData({ error: String(error) }); }
  },

  stopRecordingSilently() {
    if (this.recorder && (this.data.state === 'recording' || this.data.state === 'paused')) {
      this.recorder.stop().catch(() => {});
    }
    this.stopClock();
  },

  startClock() {
    this.stopClock();
    this.elapsedTimer = setInterval(() => {
      this.elapsedSeconds = Math.floor((Date.now() - this.recordingStartedAt) / 1000);
      this.setData({ elapsed: formatTime(this.elapsedSeconds) });
    }, 250);
  },

  stopClock() {
    if (this.elapsedTimer) clearInterval(this.elapsedTimer);
    this.elapsedTimer = null;
  },

  startPlaybackClock() {
    this.stopPlaybackClock();
    const startedAt = Date.now();
    this.setData({ elapsed: '00:00' });
    this.playbackTimer = setInterval(() => {
      this.setData({ elapsed: formatTime(Math.floor((Date.now() - startedAt) / 1000)) });
    }, 250);
  },

  stopPlaybackClock() {
    if (this.playbackTimer) clearInterval(this.playbackTimer);
    this.playbackTimer = null;
  },

  async buildPlayback() {
    const parts = [this.header, ...this.frames].filter(Boolean);
    if (!parts.length || typeof URL === 'undefined' || typeof URL.createObjectURL !== 'function') return;
    const mimeType = this.data.currentFormat === 'opus' ? 'audio/ogg;codecs=opus' : 'audio/wav';
    this.revokePlaybackUrl();
    let blob;
    if (this.data.currentFormat === 'pcm') {
      const payloads = [];
      for (const part of parts) {
        const buffer = part instanceof Blob ? await part.arrayBuffer() : part;
        const bytes = new Uint8Array(buffer);
        const offset = bytes.length >= 44 && String.fromCharCode(...bytes.subarray(0, 4)) === 'RIFF' ? 44 : 0;
        payloads.push(bytes.subarray(offset));
      }
      const payloadSize = payloads.reduce((total, payload) => total + payload.byteLength, 0);
      const wav = new Uint8Array(44 + payloadSize);
      const view = new DataView(wav.buffer);
      const writeText = (offset, value) => [...value].forEach((char, index) => wav[offset + index] = char.charCodeAt(0));
      writeText(0, 'RIFF');
      view.setUint32(4, 36 + payloadSize, true);
      writeText(8, 'WAVEfmt ');
      view.setUint32(16, 16, true);
      view.setUint16(20, 1, true);
      view.setUint16(22, 1, true);
      view.setUint32(24, 16000, true);
      view.setUint32(28, 32000, true);
      view.setUint16(32, 2, true);
      view.setUint16(34, 16, true);
      writeText(36, 'data');
      view.setUint32(40, payloadSize, true);
      let cursor = 44;
      payloads.forEach((payload) => { wav.set(payload, cursor); cursor += payload.byteLength; });
      blob = new Blob([wav], { type: mimeType });
    } else {
      blob = new Blob(parts, { type: mimeType });
    }
    this.playbackBlob = blob;
    this.playbackMimeType = mimeType;
    this.setData({ playbackSrc: URL.createObjectURL(blob) });
  },

  revokePlaybackUrl() {
    if (this.data.playbackSrc && typeof URL !== 'undefined' && typeof URL.revokeObjectURL === 'function') {
      URL.revokeObjectURL(this.data.playbackSrc);
    }
    this.setData({ playbackSrc: '' });
  },

  playRecording() {
    if (!this.playbackBlob) {
      this.setData({ error: 'Recording audio is unavailable' });
      return;
    }
    this.destroyPlayer();
    try {
      const player = new AudioPlayer();
      this.player = player;
      player.onCanplay(() => this.setData({ playbackState: 'ready' }));
      player.onPlay(() => {
        this.startPlaybackClock();
        this.setData({ playbackState: 'playing', error: '' });
      });
      player.onEnded(() => {
        this.stopPlaybackClock();
        this.setData({ playbackState: 'idle', elapsed: formatTime(this.recordingDurationSeconds) });
      });
      player.onError((error) => {
        this.stopPlaybackClock();
        this.setData({ playbackState: 'idle', elapsed: formatTime(this.recordingDurationSeconds), error: `Playback failed: ${String(error)}` });
      });
      this.playbackBlob.arrayBuffer().then((buffer) => {
        if (this.player !== player) return;
        player.setBuffer(buffer, this.playbackMimeType);
        player.play();
      }).catch((error) => {
        this.setData({ playbackState: 'idle', error: `Playback failed: ${String(error)}` });
      });
    } catch (error) {
      this.setData({ playbackState: 'idle', error: `Playback failed: ${String(error)}` });
    }
  },

  destroyPlayer() {
    this.stopPlaybackClock();
    if (this.player) {
      try { this.player.destroy(); } catch (_) {}
    }
    this.player = null;
  },
};
</script>

<page>
  <view class="container" bindkeydown="onKeyDown">
    <view class="format-row">
      <button class="format-button {{currentFormat === 'pcm' ? 'selected' : ''}}" bindtap="usePCM">PCM</button>
      <button class="format-button {{currentFormat === 'opus' ? 'selected' : ''}}" bindtap="useOpus">Opus</button>
    </view>
    <text class="timer">{{elapsed}}</text>
    <view class="control-row">
      <button class="control-button" bindtap="toggleRecording">{{actionLabel}}</button>
      <button class="control-button end-button" bindtap="stopRecording">End</button>
    </view>
    <button class="play-button" ink:if="{{playbackSrc}}" bindtap="playRecording">
      {{playbackState === 'playing' ? 'Playing' : 'Play recording'}}
    </button>
    <text class="error" ink:if="{{error}}">{{error}}</text>
  </view>
</page>

<style>
  .container { display: flex; flex-direction: column; align-items: center; gap: 20px; padding: 32px 24px; background-color: var(--color-background, #f5f7fa); }
  .format-row { display: flex; flex-direction: row; gap: 10px; }
  .format-button, .play-button { min-width: 110px; min-height: 40px; color: var(--color-primary, #2563eb); background-color: transparent; border: 1px solid var(--color-primary, #2563eb); }
  .format-button.selected { color: var(--color-primary, #2563eb); background-color: transparent; border-width: 2px; }
  .timer { font-size: 48px; font-family: monospace; color: var(--color-text-primary, #0f172a); }
  .control-row { display: flex; flex-direction: row; gap: 12px; width: 100%; justify-content: center; }
  .control-button { flex: 1; max-width: 220px; min-height: 56px; font-size: 20px; font-weight: 700; color: var(--color-primary, #2563eb); background-color: transparent; border: 2px solid var(--color-primary, #2563eb); }
  .end-button { color: var(--color-danger, #dc2626); border-color: var(--color-danger, #dc2626); }
  .error { font-size: 13px; color: var(--color-danger, #dc2626); }
</style>
