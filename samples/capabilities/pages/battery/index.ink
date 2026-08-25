<script type="application/json" def>
{
  "navigationBarTitleText": "Battery"
}
</script>

<script setup>
const LOG_LIMIT = 40;

function nowLabel() {
  return new Date().toISOString().slice(11, 19);
}

function hasBatteryApi() {
  return (
    typeof navigator !== 'undefined' &&
    navigator &&
    typeof navigator.getBattery === 'function'
  );
}

function formatLevel(value) {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    return '--';
  }
  return `${(Math.max(0, Math.min(1, value)) * 100).toFixed(1)}%`;
}

function formatDuration(value) {
  if (typeof value !== 'number') {
    return '--';
  }
  if (!Number.isFinite(value)) {
    return 'Infinity';
  }
  return `${Math.max(0, value).toFixed(0)} s`;
}

function boolLabel(value) {
  return value ? 'true' : 'false';
}

export default {
  data: {
    available: false,
    initialized: false,
    chargingText: '--',
    chargingTimeText: '--',
    dischargingTimeText: '--',
    levelText: '--',
    statusText: 'Waiting for battery capability',
    lastError: '',
    logCount: 1,
    logs: ['Battery demo ready'],
  },

  onLoad() {
    this.batteryManager = null;
    this.boundStatusChange = null;
    this.batteryInitToken = 0;
    const available = hasBatteryApi();
    this.setData({
      available,
      statusText: available
        ? 'Battery capability is ready to resolve BatteryManager'
        : 'Battery API is unavailable in this runtime or host configuration',
    });
    if (available) {
      this.initializeBattery();
    } else {
      this.log('Battery API is not available in this runtime');
    }
  },

  onUnload() {
    this.batteryInitToken += 1;
    this.detachBatteryListeners();
  },

  log(message) {
    const nextLogs = [`${nowLabel()} ${message}`, ...(this.data.logs || [])].slice(0, LOG_LIMIT);
    this.setData({
      logs: nextLogs,
      logCount: nextLogs.length,
    });
  },

  setError(message) {
    this.setData({
      lastError: message,
      statusText: message,
    });
    this.log(`Error: ${message}`);
  },

  clearError() {
    if (!this.data.lastError) {
      return;
    }
    this.setData({ lastError: '' });
  },

  applyBatteryStatus(source) {
    const battery = this.batteryManager;
    if (!battery) {
      return;
    }
    this.clearError();
    this.setData({
      initialized: true,
      chargingText: boolLabel(battery.charging),
      chargingTimeText: formatDuration(battery.chargingTime),
      dischargingTimeText: formatDuration(battery.dischargingTime),
      levelText: formatLevel(battery.level),
      statusText:
        source === 'event' ? 'Received battery status update' : 'BatteryManager resolved successfully',
    });
    this.log(
      `${source === 'event' ? 'Battery event' : 'Initial battery'}: charging=${battery.charging} level=${formatLevel(battery.level)}`
    );
  },

  detachBatteryListeners() {
    if (!this.batteryManager || !this.boundStatusChange) {
      return;
    }
    this.batteryManager.removeEventListener('chargingchange', this.boundStatusChange);
    this.batteryManager.removeEventListener('chargingtimechange', this.boundStatusChange);
    this.batteryManager.removeEventListener('dischargingtimechange', this.boundStatusChange);
    this.batteryManager.removeEventListener('levelchange', this.boundStatusChange);
    this.boundStatusChange = null;
  },

  async initializeBattery() {
    if (!hasBatteryApi()) {
      this.setError('Battery API is unavailable');
      return;
    }

    this.setData({
      statusText: 'Resolving navigator.getBattery()...',
    });
    this.log('Calling navigator.getBattery()');

    try {
      const token = (this.batteryInitToken || 0) + 1;
      this.batteryInitToken = token;
      this.detachBatteryListeners();
      const batteryManager = await navigator.getBattery();
      if (this.batteryInitToken !== token) {
        return;
      }
      this.batteryManager = batteryManager;
      this.boundStatusChange = (event) => {
        const type = (event && event.type) || 'statuschange';
        this.log(`Received ${type}`);
        this.applyBatteryStatus('event');
      };
      this.batteryManager.addEventListener('chargingchange', this.boundStatusChange);
      this.batteryManager.addEventListener('chargingtimechange', this.boundStatusChange);
      this.batteryManager.addEventListener('dischargingtimechange', this.boundStatusChange);
      this.batteryManager.addEventListener('levelchange', this.boundStatusChange);
      this.applyBatteryStatus('initial');
    } catch (error) {
      this.setError(String(error));
    }
  },

  refreshBattery() {
    this.initializeBattery();
  },

  clearLogs() {
    this.setData({
      logs: ['Logs cleared'],
      logCount: 1,
    });
  },
};
</script>

<page>
  <view class="page">
    <view class="section">
      <text class="title">BatteryManager Demo</text>
      <text class="subtitle">Reads battery status from `navigator.getBattery()` and listens for change events.</text>
    </view>

    <view class="card">
      <text class="label">Available</text>
      <text class="value">{{ available ? 'Yes' : 'No' }}</text>
      <text class="label">Initialized</text>
      <text class="value">{{ initialized ? 'Yes' : 'No' }}</text>
      <text class="label">Charging</text>
      <text class="value">{{ chargingText }}</text>
      <text class="label">Charging Time</text>
      <text class="value">{{ chargingTimeText }}</text>
      <text class="label">Discharging Time</text>
      <text class="value">{{ dischargingTimeText }}</text>
      <text class="label">Level</text>
      <text class="value">{{ levelText }}</text>
      <text class="status">{{ statusText }}</text>
      <text wx:if="{{ lastError }}" class="error">{{ lastError }}</text>
    </view>

    <view class="actions">
      <button bindtap="refreshBattery">Refresh Battery</button>
      <button bindtap="clearLogs">Clear Logs</button>
    </view>

    <view class="section">
      <text class="title">Event Log ({{ logCount }})</text>
      <view class="log-list">
        <text wx:for="{{ logs }}" wx:key="*this" class="log-line">{{ item }}</text>
      </view>
    </view>
  </view>
</page>

<style>
.page {
  --battery-page-background: var(--color-background);
  --battery-surface-background: var(--color-surface);
  --battery-surface-muted-background: var(--color-surface-highlight);
  --battery-text-color: var(--color-text-primary);
  --battery-muted-text-color: var(--color-text-secondary);
  --battery-danger-text-color: var(--color-danger);
  --battery-border-color: var(--border-color-default);
  padding: var(--spacing-lg, 20px);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg, 20px);
  background-color: var(--battery-page-background);
}

.section {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-sm, 10px);
}

.title {
  font-size: 24px;
  font-weight: 700;
  color: var(--battery-text-color);
}

.subtitle {
  font-size: 14px;
  line-height: 20px;
  color: var(--battery-muted-text-color);
}

.card {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: var(--spacing-md, 16px);
  border-radius: var(--radius-md, 12px);
  background-color: var(--battery-surface-background);
  border: 1px solid var(--battery-border-color);
}

.label {
  font-size: 13px;
  color: var(--battery-muted-text-color);
}

.value {
  font-size: 18px;
  color: var(--battery-text-color);
}

.status {
  margin-top: 8px;
  font-size: 14px;
  line-height: 20px;
  color: var(--battery-text-color);
}

.error {
  color: var(--battery-danger-text-color);
  font-size: 14px;
  line-height: 20px;
}

.actions {
  display: flex;
  gap: var(--spacing-md, 16px);
}

.log-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: var(--spacing-md, 16px);
  border-radius: var(--radius-md, 12px);
  background-color: var(--battery-surface-muted-background);
  border: 1px solid var(--battery-border-color);
}

.log-line {
  color: var(--battery-text-color);
  font-size: 13px;
  line-height: 18px;
}
</style>
