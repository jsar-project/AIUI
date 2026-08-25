<script type="application/json" def>
{
  "navigationBarTitleText": "Head Gesture"
}
</script>

<script setup>
function formatTimestamp(value) {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    return 'N/A';
  }
  return `${Math.round(value)} ms`;
}

function makeInitialData() {
  return {
    available: false,
    eventCount: 0,
    lastGesture: 'Waiting',
    lastState: '--',
    lastTimestampText: 'N/A',
    lastSource: 'page.onHeadGesture',
    statusChip: 'READY',
    statusText: 'World awareness is disabled until this page enables it.',
    lastError: '',
  };
}

export default {
  data: makeInitialData(),
  gestureResetTimer: null,

  onLoad() {
    this.setData(makeInitialData());
    this.enableWorldAwarenessOnPage();
  },

  onUnload() {
    this.clearGestureResetTimer();
  },

  onHeadGesture(event) {
    this.recordHeadGesture(event, 'page.onHeadGesture');
  },

  onHeadGestureStateChange(event) {
    const state = event && event.state ? event.state : 'unknown';
    const gesture = event && event.gesture ? event.gesture : 'pending';
    this.setData({
      lastState: state,
      lastSource: 'page.onHeadGestureStateChange',
      statusChip: state === 'cancel' ? 'CANCELLED' : 'TRACKING',
      statusText: `Detector ${state} for ${gesture}.`,
    });
  },

  enableWorldAwarenessOnPage() {
    try {
      if (typeof this.enableWorldAwareness !== 'function') {
        this.setError('enableWorldAwareness is unavailable on this page instance.');
        return;
      }
      this.enableWorldAwareness({
        mode: 'micro',
      });
      this.clearError();
      this.setData({
        available: true,
        statusChip: 'WAITING',
        statusText:
          'World awareness is active in micro mode. Waiting for runtime-detected nod or shake events.',
      });
    } catch (error) {
      this.setError(String(error));
    }
  },

  setError(message) {
    this.setData({
      lastError: message,
      statusText: message,
    });
  },

  clearError() {
    if (this.data.lastError) {
      this.setData({ lastError: '' });
    }
  },

  recordHeadGesture(event, source) {
    const gesture = event && event.gesture ? event.gesture : 'unknown';
    const timestamp =
      event && typeof event.timeStamp === 'number' && Number.isFinite(event.timeStamp)
        ? event.timeStamp
        : null;
    const eventCount = (this.data.eventCount || 0) + 1;

    this.clearError();
    this.setData({
      available: true,
      eventCount,
      lastGesture: gesture,
      lastState: 'end',
      lastTimestampText: formatTimestamp(timestamp),
      lastSource: source,
      statusChip: 'RECEIVED',
      statusText: `Received ${gesture} through ${source}.`,
    });
    this.scheduleGestureReset();
  },

  resetSnapshot() {
    this.clearGestureResetTimer();
    this.setData({
      eventCount: 0,
      lastGesture: 'Waiting',
      lastState: '--',
      lastTimestampText: 'N/A',
      lastSource: 'page.onHeadGesture',
      statusChip: this.data.available ? 'WAITING' : 'READY',
      statusText: this.data.available
        ? 'Snapshot cleared. Waiting for the next world-awareness head gesture.'
        : 'World awareness is disabled until this page enables it.',
    });
  },

  scheduleGestureReset() {
    this.clearGestureResetTimer();
    this.gestureResetTimer = setTimeout(() => {
      this.gestureResetTimer = null;
      this.setData({
        lastGesture: 'Waiting',
      });
    }, 3000);
  },

  clearGestureResetTimer() {
    if (this.gestureResetTimer) {
      clearTimeout(this.gestureResetTimer);
      this.gestureResetTimer = null;
    }
  },
};
</script>

<page>
  <view class="container">
    <view class="hero-card">
      <text class="page-kicker">Capability Regression Panel</text>
      <view class="hero-header">
        <text class="page-title">Head Gesture</text>
        <text class="hero-chip">{{statusChip}}</text>
      </view>
      <text class="subtitle">
        Validate runtime-detected headgesture and headgesturestatechange delivery after this page enables world awareness.
      </text>
      <text class="status-text">{{statusText}}</text>
      <text class="error-text" ink:if="{{lastError}}">{{lastError}}</text>
    </view>

    <scroll-view class="metrics-scroll" scroll-x="true" show-scrollbar="false">
      <view class="metrics-grid">
        <view class="metric-card">
          <text class="metric-label">Last Gesture</text>
          <text class="metric-value">{{lastGesture}}</text>
        </view>
        <view class="metric-card">
          <text class="metric-label">Event Count</text>
          <text class="metric-value">{{eventCount}}</text>
        </view>
        <view class="metric-card">
          <text class="metric-label">Last Timestamp</text>
          <text class="metric-value metric-value-small">{{lastTimestampText}}</text>
        </view>
        <view class="metric-card">
          <text class="metric-label">Last State</text>
          <text class="metric-value metric-value-small">{{lastState}}</text>
        </view>
        <view class="metric-card">
          <text class="metric-label">Last Source</text>
          <text class="metric-value metric-value-small">{{lastSource}}</text>
        </view>
      </view>
    </scroll-view>

    <view class="action-card">
      <text class="section-title">Local Actions</text>
      <view class="button-row" role="navigation">
        <button class="btn btn-secondary" bindtap="resetSnapshot">Reset Snapshot</button>
      </view>
    </view>
  </view>
</page>

<style>
.container {
  --page-background: var(--color-background);
  --surface-background: var(--color-surface);
  --surface-muted-background: var(--color-surface-highlight);
  --text-color: var(--color-text-primary);
  --muted-text-color: var(--color-text-secondary);
  --border-color: var(--border-color-default, #e5e7eb);
  --primary-background: var(--color-primary);
  --primary-text: #ffffff;
  display: flex;
  flex-direction: column;
  gap: 18px;
  padding: var(--spacing-lg, 20px);
  background-color: var(--page-background);
}

.hero-card,
.metric-card,
.action-card {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 18px;
  border-radius: 16px;
  border: var(--border-width-thin, 1px) solid var(--border-color);
  background-color: var(--surface-background);
  box-sizing: border-box;
}

.page-kicker {
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 1px;
  color: var(--muted-text-color);
}

.hero-header {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
}

.page-title {
  font-size: 30px;
  font-weight: 700;
  color: var(--text-color);
}

.hero-chip {
  padding: 6px 10px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 700;
  color: var(--primary-text);
  background-color: var(--primary-background);
}

.subtitle,
.status-text,
.error-text {
  font-size: 14px;
  line-height: 20px;
  color: var(--muted-text-color);
}

.error-text {
  color: #d14343;
}

.metrics-scroll {
  width: 100%;
}

.metrics-grid {
  display: flex;
  flex-direction: row;
  gap: 12px;
}

.metric-card {
  flex-shrink: 0;
  width: 150px;
  background-color: var(--surface-muted-background);
}

.metric-label,
.section-title {
  font-size: 13px;
  font-weight: 700;
  color: var(--muted-text-color);
}

.metric-value {
  font-size: 28px;
  font-weight: 700;
  color: var(--text-color);
}

.metric-value-small {
  font-size: 18px;
}

.button-row {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 12px;
}

.btn {
  min-width: 148px;
  padding: 12px 18px;
  border-radius: 999px;
  color: var(--primary-text);
  background-color: var(--primary-background);
}

.btn-secondary {
  color: var(--text-color);
  background-color: var(--surface-muted-background);
}
</style>
