<script type="application/json" def>
{
  "widget": {
    "family": "1x2"
  }
}
</script>

<script setup>
function formatSize(width, height) {
  return `${Math.round(width)} x ${Math.round(height)}`;
}

export default {
  data: {
    lifecycle: 'Created',
    hostSize: '--',
    interaction: 'Disabled',
    activationCount: 0,
  },

  onCreate() {
    console.log('Runtime status widget created', this.widgetId, this.target);
  },

  onAttach() {
    this.setData({
      lifecycle: 'Attached',
      hostSize: formatSize(this.hostWidth, this.hostHeight),
      interaction: this.interactive ? 'Enabled' : 'Disabled',
    });
  },

  onDetach() {
    console.log('Runtime status widget detached', this.widgetId);
  },

  onDestroy() {
    console.log('Runtime status widget destroyed', this.widgetId);
  },

  activate() {
    this.setData({ activationCount: this.data.activationCount + 1 });
  },

  onKeyDown(event) {
    if (event.code === 'Enter') {
      this.activate();
    }
  },
};
</script>

<widget>
  <view class="panel">
    <view class="summary">
      <text class="eyebrow">Widget Runtime</text>
      <text class="title">{{lifecycle}}</text>
      <text class="meta">{{family}} / {{target}}</text>
    </view>
    <view class="details">
      <view class="row">
        <text class="key">Host</text>
        <text class="value">{{hostSize}}</text>
      </view>
      <view class="row">
        <text class="key">Input</text>
        <text class="value">{{interaction}}</text>
      </view>
      <button class="action" bindtap="activate">Activate {{activationCount}}</button>
    </view>
  </view>
</widget>

<style>
  .panel {
    width: 100%;
    height: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: row;
    align-items: stretch;
    color: #f9fafb;
    background-color: #111827;
  }

  .summary {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 5px;
    padding: 14px;
    background-color: #164e63;
  }

  .eyebrow,
  .key {
    font-size: 11px;
    color: #a5f3fc;
  }

  .title {
    font-size: 21px;
    font-weight: 700;
  }

  .meta {
    font-size: 12px;
    color: #cffafe;
  }

  .details {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 7px;
    padding: 14px;
  }

  .row {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    gap: 8px;
  }

  .value {
    font-size: 12px;
    color: #f9fafb;
  }

  .action {
    min-height: 30px;
    margin-top: 3px;
    color: #111827;
    background-color: #f9fafb;
    font-size: 12px;
    font-weight: 600;
  }
</style>
