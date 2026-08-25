<script type="application/json" def>
{
  "navigationBarTitleText": "Streaming TTS"
}
</script>

<script setup>
const POLL_INTERVAL_MS = 100;
const PREFERRED_SYNTHESIS_FORMAT = 'mp3';
const SPEECH_SAMPLES = [
  {
    id: 'chinese',
    label: '中文',
    meta: '普通话 · 短文本',
    lang: 'zh-CN',
    text: '清晨的城市慢慢醒来，阳光穿过树叶，落在安静的人行道上。新的一天，从一句温柔的问候开始。',
  },
  {
    id: 'english',
    label: 'English',
    meta: 'English · Short',
    lang: 'en-US',
    text: 'A clear voice makes information easier to follow, especially when every spoken word is highlighted at exactly the right moment.',
  },
  {
    id: 'long-form',
    label: 'Long form',
    meta: 'English · Extended passage',
    lang: 'en-US',
    text: 'On a quiet afternoon, a small research team gathered around a table covered with sketches, notes, and early prototypes. They were building a new way for people to receive useful information without constantly looking down at a screen. The first version was simple, but every test revealed something important: speech needed to feel immediate, controls needed to remain predictable, and captions had to follow the voice with precision. By the end of the day, the team had turned those observations into a calmer and more natural experience.',
  },
];

function errorMessage(error) {
  return error && error.message ? error.message : String(error || 'Unknown error');
}

function formatTime(value) {
  const seconds = typeof value === 'number' && Number.isFinite(value) ? value : 0;
  return `${seconds.toFixed(1)} s`;
}

function sampleData() {
  return SPEECH_SAMPLES.map((sample) => ({
    ...sample,
    activeStart: 0,
    activeLength: 0,
  }));
}

function eventSampleId(event) {
  const target = event && event.currentTarget ? event.currentTarget : null;
  const dataset = target && target.dataset ? target.dataset : null;
  if (dataset && typeof dataset.sampleId === 'string') {
    return dataset.sampleId;
  }
  const attributes = target && target.attributes ? target.attributes : null;
  return attributes && typeof attributes['data-sample-id'] === 'string'
    ? attributes['data-sample-id']
    : '';
}

function cueSnapshot(cue, sourceText) {
  const charIndex = Number.isInteger(cue.charIndex) ? cue.charIndex : null;
  const charLength = Number.isInteger(cue.charLength) ? cue.charLength : null;
  return {
    id: cue.id,
    startTime: cue.startTime,
    endTime: cue.endTime,
    text: cue.text,
    charIndex,
    charLength,
    sourceText:
      charIndex == null || charLength == null
        ? null
        : sourceText.slice(charIndex, charIndex + charLength),
  };
}

function cueListSnapshot(cueList, sourceText) {
  const cues = [];
  for (let index = 0; index < cueList.length; index += 1) {
    const cue = cueList.item(index);
    if (cue) {
      cues.push(cueSnapshot(cue, sourceText));
    }
  }
  return cues;
}

function logTextTracks(player, sourceText, reason) {
  const trackList = player.audioPlayer.textTracks;
  console.log(
    '[tts_streaming] textTracks',
    JSON.stringify({ reason, currentTime: player.currentTime, length: trackList.length }),
  );
  for (let index = 0; index < trackList.length; index += 1) {
    const track = trackList.item(index);
    if (!track) {
      continue;
    }
    console.log(
      '[tts_streaming] textTrack',
      JSON.stringify({
        reason,
        index,
        currentTime: player.currentTime,
        id: track.id,
        kind: track.kind,
        label: track.label,
        language: track.language,
        mode: track.mode,
        cues: cueListSnapshot(track.cues, sourceText),
        activeCues: cueListSnapshot(track.activeCues, sourceText),
      }),
    );
  }
}

export default {
  data: {
    available: false,
    samples: sampleData(),
    activeSampleLabel: 'No sample selected',
    taskState: 'idle',
    playbackState: 'idle',
    chunkCount: 0,
    cueCount: 0,
    currentTime: '0.0 s',
    duration: '--',
    preferredFormat: PREFERRED_SYNTHESIS_FORMAT,
    actualFormat: '--',
    mimeType: '--',
    sampleFormat: '--',
    error: '',
  },

  onLoad() {
    this.task = null;
    this.player = null;
    this.activeSample = null;
    this.highlightEnd = 0;
    this.generation = 0;
    this.setData({
      available:
        typeof speechSynthesis !== 'undefined' &&
        typeof speechSynthesis.synthesize === 'function' &&
        typeof SpeechSynthesisUtterance !== 'undefined' &&
        typeof SpeechAudioPlayer !== 'undefined',
    });
    this.pollTimer = setInterval(() => this.refreshPlaybackTime(), POLL_INTERVAL_MS);
  },

  onUnload() {
    this.generation += 1;
    if (this.pollTimer) {
      clearInterval(this.pollTimer);
      this.pollTimer = null;
    }
    this.disposeSession(true);
  },

  resetTranscripts() {
    this.setData({ samples: sampleData() });
  },

  updateTranscript(activeCue, reset = false) {
    if (!this.activeSample) {
      return;
    }
    if (reset) {
      this.highlightEnd = 0;
    } else if (
      activeCue &&
      Number.isInteger(activeCue.charIndex) &&
      Number.isInteger(activeCue.charLength)
    ) {
      this.highlightEnd = Math.max(
        this.highlightEnd,
        activeCue.charIndex + activeCue.charLength,
      );
    }
    const sampleId = this.activeSample.id;
    this.setData({
      samples: this.data.samples.map((sample) =>
        sample.id === sampleId
          ? {
              ...sample,
              activeStart: 0,
              activeLength: this.highlightEnd,
            }
          : sample,
      ),
    });
  },

  disposeSession(abortTask) {
    if (abortTask && this.task && this.task.state === 'running') {
      try {
        this.task.abort();
      } catch (_) {}
    }
    if (this.player) {
      try {
        this.player.destroy();
      } catch (_) {}
    }
    this.task = null;
    this.player = null;
  },

  async playSample(event) {
    const sampleId = eventSampleId(event);
    const sample = SPEECH_SAMPLES.find((item) => item.id === sampleId);
    if (!sample) {
      return;
    }
    if (!this.data.available) {
      this.setData({ error: 'Streaming speech synthesis is unavailable.' });
      return;
    }

    const generation = ++this.generation;
    this.disposeSession(true);
    this.resetTranscripts();
    this.activeSample = sample;
    this.highlightEnd = 0;
    this.setData({
      activeSampleLabel: sample.label,
      taskState: 'creating',
      playbackState: 'buffering',
      chunkCount: 0,
      cueCount: 0,
      currentTime: '0.0 s',
      duration: '--',
      preferredFormat: PREFERRED_SYNTHESIS_FORMAT,
      actualFormat: '--',
      mimeType: '--',
      sampleFormat: '--',
      error: '',
    });

    try {
      const utterance = new SpeechSynthesisUtterance(sample.text);
      utterance.lang = sample.lang;
      utterance.rate = 1;
      utterance.pitch = 1;
      utterance.volume = 1;
      const task = await speechSynthesis.synthesize(utterance, {
        subtitles: 'word',
        audio: {
          preferredFormat: PREFERRED_SYNTHESIS_FORMAT,
          sampleRate: 24000,
          channels: 1,
        },
      });
      if (generation !== this.generation) {
        task.abort();
        return;
      }

      const player = new SpeechAudioPlayer(task, { trackMode: 'hidden' });
      this.task = task;
      this.player = player;
      const isCurrentSession = () =>
        generation === this.generation && this.task === task && this.player === player;
      this.setData({
        taskState: 'streaming',
        preferredFormat: PREFERRED_SYNTHESIS_FORMAT,
        actualFormat: task.audioConfig.format,
        mimeType: task.audioConfig.mimeType,
        sampleFormat: task.audioConfig.sampleFormat || 'null',
      });

      task.onchunk = (chunkEvent) => {
        if (!isCurrentSession()) {
          return;
        }
        const nextCues = [];
        for (let index = 0; index < chunkEvent.cues.length; index += 1) {
          const cue = chunkEvent.cues[index];
          nextCues.push({
            id: cue.id,
            text: cue.text,
            startTime: cue.startTime,
            endTime: cue.endTime,
            charIndex: cue.charIndex,
            charLength: cue.charLength,
          });
        }
        this.setData({
          chunkCount: this.data.chunkCount + 1,
          cueCount: this.data.cueCount + nextCues.length,
        });
        if (nextCues.length > 0) {
          logTextTracks(player, sample.text, 'chunk');
        }
      };
      task.onend = (endEvent) => {
        if (!isCurrentSession()) {
          return;
        }
        this.setData({
          taskState: 'completed',
          duration: formatTime(endEvent.duration),
        });
      };
      task.onerror = (errorEvent) => {
        if (!isCurrentSession()) {
          return;
        }
        this.setData({
          taskState: 'errored',
          playbackState: 'stopped',
          error: errorEvent.message || errorEvent.error,
        });
      };
      task.onabort = () => {
        if (!isCurrentSession()) {
          return;
        }
        this.updateTranscript(null, true);
        this.setData({ taskState: 'aborted', playbackState: 'stopped' });
      };

      player.textTrack.addEventListener('cuechange', () => {
        if (!isCurrentSession()) {
          return;
        }
        const cue = player.textTrack.activeCues.item(0);
        const cueLog = cue
          ? {
              currentTime: player.currentTime,
              startTime: cue.startTime,
              endTime: cue.endTime,
              text: cue.text,
              charIndex: cue.charIndex,
              charLength: cue.charLength,
              sourceText: sample.text.slice(
                cue.charIndex || 0,
                (cue.charIndex || 0) + (cue.charLength || 0),
              ),
            }
          : { currentTime: player.currentTime, cue: null };
        console.log('[tts_streaming] cuechange', JSON.stringify(cueLog));
        logTextTracks(player, sample.text, 'cuechange');
        if (!cue) {
          return;
        }
        this.updateTranscript(cue);
      });
      player.audioPlayer.onCanplay(() => {
        if (isCurrentSession() && this.data.playbackState === 'buffering') {
          player.play();
        }
      });
      player.audioPlayer.onPlay(() => {
        if (isCurrentSession()) {
          this.setData({ playbackState: 'playing' });
        }
      });
      player.audioPlayer.onPause(() => {
        if (isCurrentSession()) {
          this.setData({ playbackState: 'paused' });
        }
      });
      player.audioPlayer.onStop(() => {
        if (!isCurrentSession()) {
          return;
        }
        this.updateTranscript(null, true);
        this.setData({ playbackState: 'stopped' });
      });
      player.audioPlayer.onEnded(() => {
        if (!isCurrentSession()) {
          return;
        }
        this.highlightEnd = sample.text.length;
        this.updateTranscript(null);
        this.setData({ playbackState: 'ended' });
      });
    } catch (error) {
      if (generation === this.generation) {
        this.setData({
          taskState: 'errored',
          playbackState: 'stopped',
          error: errorMessage(error),
        });
      }
    }
  },

  togglePause() {
    if (!this.player) {
      return;
    }
    try {
      if (this.player.paused) {
        this.player.play();
      } else {
        this.player.pause();
      }
    } catch (error) {
      this.setData({ error: errorMessage(error) });
    }
  },

  stopPlayback() {
    if (!this.player) {
      return;
    }
    try {
      this.player.stop();
      this.updateTranscript(null, true);
    } catch (error) {
      this.setData({ error: errorMessage(error) });
    }
  },

  abortGeneration() {
    if (!this.task || this.task.state !== 'running') {
      return;
    }
    try {
      this.task.abort();
    } catch (error) {
      this.setData({ error: errorMessage(error) });
    }
  },

  refreshPlaybackTime() {
    if (!this.player) {
      return;
    }
    try {
      this.setData({ currentTime: formatTime(this.player.currentTime) });
    } catch (_) {}
  },
};
</script>

<page>
  <scroll-view class="content-scroll" scroll-y="true" scroll-direction="vertical">
    <view class="container">
      <view class="header">
        <view class="heading-copy">
          <text class="eyebrow">WORD-TIMED SPEECH</text>
          <text class="title">Streaming TTS</text>
        </view>
        <text class="availability availability-{{available ? 'ready' : 'offline'}}">
          {{available ? 'API ready' : 'Unavailable'}}
        </text>
      </view>

      <view class="sample-list">
        <view
          class="sample"
          ink:for="{{samples}}"
          ink:key="id"
        >
          <view class="sample-header">
            <view class="sample-heading">
              <text class="sample-title">{{item.label}}</text>
              <text class="sample-meta">{{item.meta}}</text>
            </view>
            <button class="play-button" bindtap="playSample" data-sample-id="{{item.id}}">
              Play
            </button>
          </view>
          <timed-text
            class="transcript"
            text="{{item.text}}"
            active-start="{{item.activeStart}}"
            active-length="{{item.activeLength}}"
          />
        </view>
      </view>
      <view class="player-spacer"></view>
    </view>
  </scroll-view>

  <view class="player-dock">
    <view class="player-status">
      <view class="player-copy">
        <text class="player-label">{{activeSampleLabel}}</text>
        <text class="player-meta">
          {{playbackState}} · {{currentTime}} / {{duration}} · {{cueCount}} cues · Returned: {{actualFormat}} · MIME: {{mimeType}}
        </text>
      </view>
      <text class="task-state">{{taskState}}</text>
    </view>
    <text class="error" ink:if="{{error}}">{{error}}</text>
    <view class="controls">
      <button class="control-button" bindtap="togglePause">
        {{playbackState === 'paused' ? 'Resume' : 'Pause'}}
      </button>
      <button class="control-button" bindtap="stopPlayback">Stop</button>
      <button class="control-button danger-button" bindtap="abortGeneration">Abort</button>
    </view>
  </view>
</page>

<style>
.content-scroll {
  width: 100%;
  height: 100%;
}

.container {
  display: flex;
  flex-direction: column;
  gap: 18px;
  min-height: 100%;
  padding: 20px;
  box-sizing: border-box;
  background-color: var(--color-background);
  color: var(--color-text-primary);
}

.player-spacer {
  flex-shrink: 0;
  height: 132px;
}

.header,
.sample-header,
.player-status,
.controls {
  display: flex;
  flex-direction: row;
  align-items: center;
}

.header,
.sample-header,
.player-status {
  justify-content: space-between;
}

.header {
  flex-shrink: 0;
  gap: 14px;
}

.heading-copy,
.sample-heading,
.player-copy {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.heading-copy {
  gap: 3px;
}

.eyebrow,
.sample-meta,
.player-meta,
.task-state {
  color: var(--color-text-secondary);
}

.eyebrow {
  font-size: 10px;
  line-height: 14px;
  font-weight: 700;
}

.title {
  font-size: 24px;
  line-height: 30px;
  font-weight: 700;
}

.availability {
  flex-shrink: 0;
  padding: 4px 7px;
  border: 1px solid var(--border-color-default);
  border-radius: 4px;
  font-size: 11px;
  line-height: 16px;
}

.availability-ready {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.sample-list {
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  gap: 12px;
}

.sample {
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  gap: 14px;
  padding: 16px;
  border: 1px solid var(--border-color-default);
  border-radius: 6px;
  background-color: var(--color-surface);
}

.sample-active {
  border-color: var(--color-primary);
}

.sample-header {
  gap: 12px;
}

.sample-heading {
  gap: 2px;
}

.sample-title {
  font-size: 16px;
  line-height: 22px;
  font-weight: 700;
  color: var(--color-text-primary);
}

.sample-meta {
  font-size: 11px;
  line-height: 16px;
}

.play-button,
.control-button {
  min-height: 36px;
  border: 1px solid var(--color-primary);
  border-radius: 5px;
  background-color: transparent;
  color: var(--color-primary);
  font-size: 13px;
  line-height: 18px;
  font-weight: 600;
}

.play-button {
  flex-shrink: 0;
  min-width: 70px;
  padding: 8px 12px;
}

.transcript {
  width: 100%;
  font-size: 16px;
  line-height: 27px;
  --timed-text-color: var(--color-text-secondary);
  --timed-text-active-color: var(--color-primary);
}

.player-dock {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 20;
  display: flex;
  flex-direction: column;
  gap: 9px;
  padding: 11px 16px 14px;
  border-top: 1px solid var(--border-color-default);
  box-sizing: border-box;
  background-color: var(--color-surface);
}

.player-status {
  gap: 12px;
}

.player-copy {
  flex: 1;
  gap: 1px;
}

.player-label {
  font-size: 13px;
  line-height: 18px;
  font-weight: 700;
  color: var(--color-text-primary);
}

.player-meta,
.task-state {
  font-size: 10px;
  line-height: 15px;
}

.task-state {
  flex-shrink: 0;
}

.controls {
  gap: 8px;
}

.control-button {
  flex: 1;
  min-width: 0;
}

.danger-button {
  border-color: var(--border-color-danger, #d92d20);
  color: var(--border-color-danger, #d92d20);
}

.error {
  padding-left: 8px;
  border-left: 2px solid var(--border-color-danger, #d92d20);
  color: var(--border-color-danger, #d92d20);
  font-size: 11px;
  line-height: 15px;
}
</style>
