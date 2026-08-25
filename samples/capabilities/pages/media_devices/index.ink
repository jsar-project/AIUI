<script type="application/json" def>
{
  "navigationBarTitleText": "Media Devices"
}
</script>

<script setup>
const LOG_LIMIT = 80;
const MIME_TYPES = [
  'audio/wav',
  'audio/ogg;codecs=opus',
  'video/mp4',
  'video/webm;codecs=vp8,opus',
];

function nowLabel() {
  return new Date().toISOString().slice(11, 19);
}

function formatBytes(value) {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    return '0 B';
  }
  if (value < 1024) {
    return `${value} B`;
  }
  if (value < 1024 * 1024) {
    return `${(value / 1024).toFixed(2)} KB`;
  }
  return `${(value / (1024 * 1024)).toFixed(2)} MB`;
}

function summarizeConstraints(constraints) {
  if (!constraints || typeof constraints !== 'object') {
    return [];
  }

  const orderedKeys = [
    'deviceId',
    'sampleRate',
    'channelCount',
    'echoCancellation',
    'facingMode',
    'width',
    'height',
    'frameRate',
  ];

  return orderedKeys.map((key) => ({
    key,
    value: constraints[key] ? 'supported' : 'unsupported',
  }));
}

function summarizeMimeSupport() {
  if (typeof MediaRecorder === 'undefined' || typeof MediaRecorder.isTypeSupported !== 'function') {
    return MIME_TYPES.map((mimeType) => ({
      mimeType,
      value: 'MediaRecorder unavailable',
    }));
  }

  return MIME_TYPES.map((mimeType) => ({
    mimeType,
    value: MediaRecorder.isTypeSupported(mimeType) ? 'supported' : 'unsupported',
  }));
}

function describeDevice(device, index) {
  const label = device && device.label ? device.label : '(empty label)';
  const kind = device && device.kind ? device.kind : 'unknown';
  const deviceId = device && device.deviceId ? device.deviceId : '(no deviceId)';
  return `${index + 1}. ${kind} · ${label} · ${deviceId}`;
}

function choosePreferredMime(preferVideo = false) {
  if (typeof MediaRecorder === 'undefined' || typeof MediaRecorder.isTypeSupported !== 'function') {
    return preferVideo ? 'video/mp4' : 'audio/ogg;codecs=opus';
  }

  const orderedMimeTypes = preferVideo
    ? ['video/mp4', 'video/webm;codecs=vp8,opus', 'audio/ogg;codecs=opus', 'audio/wav']
    : ['audio/wav', 'audio/ogg;codecs=opus', 'video/mp4', 'video/webm;codecs=vp8,opus'];

  for (const mimeType of orderedMimeTypes) {
    if (MediaRecorder.isTypeSupported(mimeType)) {
      return mimeType;
    }
  }

  return preferVideo ? 'video/mp4' : 'audio/ogg;codecs=opus';
}

async function blobSize(blobLike) {
  if (!blobLike) {
    return 0;
  }
  if (typeof blobLike.size === 'number') {
    return blobLike.size;
  }
  if (typeof blobLike.byteLength === 'number') {
    return blobLike.byteLength;
  }
  if (typeof blobLike.arrayBuffer === 'function') {
    const buffer = await blobLike.arrayBuffer();
    return buffer.byteLength || 0;
  }
  return 0;
}

export default {
  data: {
    mediaDevicesAvailable: false,
    mediaRecorderAvailable: false,
    streamActive: false,
    streamTrackKinds: 'none',
    recorderState: 'idle',
    currentMimeType: choosePreferredMime(false),
    lastChunkSize: '0 B',
    chunkCount: 0,
    lastError: '',
    constraintsSummary: [],
    mimeSummary: [],
    deviceLines: ['No devices enumerated yet'],
    logs: ['Media Devices page ready'],
  },

  onLoad() {
    this.stream = null;
    this.recorder = null;
    this.captureKinds = 'none';
    this.refreshCapabilitySnapshot();
  },

  onUnload() {
    this.disposeRecorder({ silent: true });
    this.stopStream({ silent: true });
  },

  log(message) {
    const nextLogs = [`${nowLabel()} ${message}`, ...(this.data.logs || [])].slice(0, LOG_LIMIT);
    this.setData({ logs: nextLogs });
  },

  setError(error) {
    const message = String(error);
    this.setData({ lastError: message });
    this.log(`Error: ${message}`);
  },

  clearError() {
    if (this.data.lastError) {
      this.setData({ lastError: '' });
    }
  },

  refreshCapabilitySnapshot() {
    const mediaDevices =
      typeof navigator !== 'undefined' && navigator ? navigator.mediaDevices : null;
    const mediaDevicesAvailable =
      !!mediaDevices &&
      typeof mediaDevices.getSupportedConstraints === 'function' &&
      typeof mediaDevices.enumerateDevices === 'function' &&
      typeof mediaDevices.getUserMedia === 'function';
    const mediaRecorderAvailable = typeof MediaRecorder !== 'undefined';
    const constraintsSummary = mediaDevicesAvailable
      ? summarizeConstraints(mediaDevices.getSupportedConstraints())
      : [];
    const mimeSummary = summarizeMimeSupport();

    this.setData({
      mediaDevicesAvailable,
      mediaRecorderAvailable,
      constraintsSummary,
      mimeSummary,
      currentMimeType: choosePreferredMime(false),
    });

    this.log(`navigator.mediaDevices ${mediaDevicesAvailable ? 'available' : 'unavailable'}`);
    this.log(`MediaRecorder ${mediaRecorderAvailable ? 'available' : 'unavailable'}`);
  },

  async enumerateDevices() {
    if (!this.data.mediaDevicesAvailable) {
      this.setError('navigator.mediaDevices is unavailable');
      return;
    }

    try {
      this.clearError();
      this.log('Enumerate devices requested');
      const devices = await navigator.mediaDevices.enumerateDevices();
      const deviceLines = Array.isArray(devices) && devices.length
        ? devices.map((device, index) => describeDevice(device, index))
        : ['No media devices returned'];
      this.setData({ deviceLines });
      this.log(`Enumerate devices resolved (${deviceLines.length})`);
    } catch (error) {
      this.setError(error);
    }
  },

  async openAudioStream() {
    await this.openStream({ audio: true });
  },

  async openAudioVideoStream() {
    await this.openStream({ audio: true, video: true });
  },

  async openStream(constraints) {
    if (!this.data.mediaDevicesAvailable) {
      this.setError('navigator.mediaDevices is unavailable');
      return;
    }

    try {
      this.clearError();
      this.disposeRecorder({ silent: true });
      this.stopStream({ silent: true });
      this.log(`getUserMedia requested ${JSON.stringify(constraints)}`);
      const stream = await navigator.mediaDevices.getUserMedia(constraints);
      this.stream = stream;
      this.captureKinds = constraints.video ? 'audio + video' : 'audio';
      const tracks = typeof stream.getTracks === 'function' ? stream.getTracks() : [];
      const kinds = tracks.length ? tracks.map((track) => track.kind).join(', ') : 'none';
      this.setData({
        streamActive: true,
        streamTrackKinds: kinds,
        recorderState: 'idle',
        chunkCount: 0,
        lastChunkSize: '0 B',
        currentMimeType: choosePreferredMime(!!constraints.video),
      });
      this.log(`getUserMedia resolved (${this.captureKinds})`);
    } catch (error) {
      this.setError(error);
    }
  },

  stopStream(options = {}) {
    const { silent = false } = options;
    if (!this.stream) {
      return;
    }

    const stream = this.stream;
    this.stream = null;
    this.captureKinds = 'none';

    try {
      const tracks = typeof stream.getTracks === 'function' ? stream.getTracks() : [];
      tracks.forEach((track) => {
        if (track && typeof track.stop === 'function') {
          track.stop();
        }
      });
      this.setData({
        streamActive: false,
        streamTrackKinds: 'none',
        recorderState: 'idle',
      });
      if (!silent) {
        this.log('MediaStream stopped');
      }
    } catch (error) {
      if (!silent) {
        this.setError(error);
      }
    }
  },

  async createRecorder() {
    if (!this.stream) {
      this.setError('Open a MediaStream first');
      return;
    }
    if (typeof MediaRecorder === 'undefined') {
      this.setError('MediaRecorder is unavailable');
      return;
    }

    try {
      this.clearError();
      this.disposeRecorder({ silent: true });

      const recorder = new MediaRecorder(this.stream, {
        mimeType: this.data.currentMimeType,
      });
      this.recorder = recorder;

      recorder.onstart = () => {
        this.setData({ recorderState: recorder.state || 'recording' });
        this.log(`Recorder started (${this.data.currentMimeType})`);
      };

      recorder.onpause = () => {
        this.setData({ recorderState: recorder.state || 'paused' });
        this.log('Recorder paused');
      };

      recorder.onresume = () => {
        this.setData({ recorderState: recorder.state || 'recording' });
        this.log('Recorder resumed');
      };

      recorder.onstop = () => {
        this.setData({ recorderState: recorder.state || 'inactive' });
        this.log('Recorder stopped');
      };

      recorder.onerror = (event) => {
        const error = event && event.error ? event.error : 'Unknown MediaRecorder error';
        this.setError(error);
      };

      recorder.ondataavailable = async (event) => {
        const size = await blobSize(event && event.data);
        this.setData({
          chunkCount: this.data.chunkCount + 1,
          lastChunkSize: formatBytes(size),
        });
        this.log(`Chunk #${this.data.chunkCount + 1} size=${formatBytes(size)}`);
      };

      this.setData({
        recorderState: recorder.state || 'inactive',
        chunkCount: 0,
        lastChunkSize: '0 B',
      });
      this.log(`Recorder created (${this.data.currentMimeType})`);
    } catch (error) {
      this.setError(error);
    }
  },

  disposeRecorder(options = {}) {
    const { silent = false } = options;
    if (!this.recorder) {
      return;
    }

    const recorder = this.recorder;
    this.recorder = null;

    try {
      if (recorder.state && recorder.state !== 'inactive') {
        recorder.stop();
      }
    } catch (error) {
      if (!silent) {
        this.log(`Recorder dispose ignored: ${String(error)}`);
      }
    }

    recorder.onstart = null;
    recorder.onpause = null;
    recorder.onresume = null;
    recorder.onstop = null;
    recorder.onerror = null;
    recorder.ondataavailable = null;

    this.setData({ recorderState: 'idle' });
  },

  async startRecorder() {
    if (!this.recorder) {
      await this.createRecorder();
    }
    if (!this.recorder) {
      return;
    }

    try {
      this.clearError();
      this.log('Recorder start requested');
      this.recorder.start(500);
      this.setData({ recorderState: this.recorder.state || 'starting' });
    } catch (error) {
      this.setError(error);
    }
  },

  async pauseRecorder() {
    if (!this.recorder) {
      this.setError('Create a MediaRecorder first');
      return;
    }
    try {
      this.clearError();
      this.log('Recorder pause requested');
      this.recorder.pause();
      this.setData({ recorderState: this.recorder.state || 'paused' });
    } catch (error) {
      this.setError(error);
    }
  },

  async resumeRecorder() {
    if (!this.recorder) {
      this.setError('Create a MediaRecorder first');
      return;
    }
    try {
      this.clearError();
      this.log('Recorder resume requested');
      this.recorder.resume();
      this.setData({ recorderState: this.recorder.state || 'recording' });
    } catch (error) {
      this.setError(error);
    }
  },

  async requestRecorderData() {
    if (!this.recorder) {
      this.setError('Create a MediaRecorder first');
      return;
    }
    try {
      this.clearError();
      this.log('Recorder requestData requested');
      this.recorder.requestData();
    } catch (error) {
      this.setError(error);
    }
  },

  async stopRecorder() {
    if (!this.recorder) {
      this.setError('Create a MediaRecorder first');
      return;
    }
    try {
      this.clearError();
      this.log('Recorder stop requested');
      this.recorder.stop();
      this.setData({ recorderState: this.recorder.state || 'inactive' });
    } catch (error) {
      this.setError(error);
    }
  },
};
</script>

<page>
  <view class="container">
    <view class="page-title">Media Devices</view>
    <view class="subtitle">
      Manual regression page for standard MediaDevices, MediaStream, and MediaRecorder APIs.
    </view>

    <view class="card">
      <text class="section-title">Summary</text>
      <text class="meta-line">navigator.mediaDevices: {{mediaDevicesAvailable}}</text>
      <text class="meta-line">MediaRecorder: {{mediaRecorderAvailable}}</text>
      <text class="meta-line">Stream Active: {{streamActive}}</text>
      <text class="meta-line">Track Kinds: {{streamTrackKinds}}</text>
      <text class="meta-line">Recorder State: {{recorderState}}</text>
      <text class="meta-line">Current MIME: {{currentMimeType}}</text>
      <text class="meta-line">Last Error: {{lastError || 'None'}}</text>
    </view>

    <view class="card">
      <text class="section-title">Constraint Support</text>
      <view class="log-list">
        <view class="log-item" ink:for="{{constraintsSummary}}" ink:key="key">
          <text class="log-text">{{item.key}}: {{item.value}}</text>
        </view>
      </view>
    </view>

    <view class="card">
      <text class="section-title">MIME Support</text>
      <view class="log-list">
        <view class="log-item" ink:for="{{mimeSummary}}" ink:key="mimeType">
          <text class="log-text">{{item.mimeType}}: {{item.value}}</text>
        </view>
      </view>
    </view>

    <view class="card">
      <text class="section-title">Device Controls</text>
      <view class="button-grid" role="navigation">
        <button class="btn" bindtap="enumerateDevices">Enumerate Devices</button>
        <button class="btn btn-secondary" bindtap="openAudioStream">Open Audio Stream</button>
        <button class="btn btn-secondary" bindtap="openAudioVideoStream">Open Audio + Video</button>
        <button class="btn btn-danger" bindtap="stopStream">Stop Stream</button>
      </view>
    </view>

    <view class="card">
      <text class="section-title">Devices</text>
      <view class="log-list">
        <view class="log-item" ink:for="{{deviceLines}}">
          <text class="log-text">{{item}}</text>
        </view>
      </view>
    </view>

    <view class="card">
      <text class="section-title">Recorder Controls</text>
      <text class="meta-line">Chunk Count: {{chunkCount}}</text>
      <text class="meta-line">Last Chunk Size: {{lastChunkSize}}</text>
      <view class="button-grid" role="navigation">
        <button class="btn" bindtap="createRecorder">Create Recorder</button>
        <button class="btn btn-secondary" bindtap="startRecorder">Start</button>
        <button class="btn btn-secondary" bindtap="pauseRecorder">Pause</button>
        <button class="btn btn-secondary" bindtap="resumeRecorder">Resume</button>
        <button class="btn btn-secondary" bindtap="requestRecorderData">Request Data</button>
        <button class="btn btn-danger" bindtap="stopRecorder">Stop</button>
      </view>
    </view>

    <view class="card log-card">
      <text class="section-title">Event Log</text>
      <view class="log-list">
        <view class="log-item" ink:for="{{logs}}">
          <text class="log-text">{{item}}</text>
        </view>
      </view>
    </view>
  </view>
</page>

<style>
  .container {
    --media-page-background: var(--color-background);
    --media-surface-background: var(--color-surface);
    --media-surface-muted-background: var(--color-surface-highlight);
    --media-text-color: var(--color-text-primary);
    --media-muted-text-color: var(--color-text-secondary);
    display: flex;
    flex-direction: column;
    padding: 24px;
    gap: 16px;
    background-color: var(--media-page-background);
  }

  .page-title {
    font-size: 28px;
    font-weight: bold;
    color: var(--media-text-color);
  }

  .subtitle {
    font-size: 14px;
    color: var(--media-muted-text-color);
    margin-bottom: 4px;
  }

  .card {
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding: var(--spacing-md, 16px);
    border-radius: var(--radius-md, 12px);
    background-color: var(--media-surface-background);
    border: var(--border-width-thin, 1px) solid var(--border-color-default, #e5e7eb);
  }

  .section-title {
    font-size: 18px;
    font-weight: bold;
    color: var(--media-text-color);
    margin-bottom: 4px;
  }

  .meta-line {
    font-size: 14px;
    color: var(--media-text-color);
    font-family: monospace;
  }

  .button-grid {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    gap: 12px;
  }

  .btn {
    min-width: 150px;
    font-size: 14px;
    font-weight: 600;
    padding: 12px 14px;
  }

  .log-card {
    min-height: 280px;
  }

  .log-list {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .log-item {
    padding: 8px 10px;
    border-radius: var(--radius-sm, 8px);
    background-color: var(--media-surface-muted-background, #f7fafc);
  }

  .log-text {
    font-size: 12px;
    color: var(--media-text-color);
    font-family: monospace;
  }
</style>
