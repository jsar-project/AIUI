<script def>
{
  "navigationBarTitleText": "Message To Host"
}
</script>

<script setup>
function buildPayload(channel, sequence) {
  return {
    type: 'capabilities.message_to_host',
    channel,
    sequence,
    timestamp: Date.now(),
    payload: {
      title: 'Page-to-host message',
      source: 'capabilities-agent',
      status: 'ok',
    },
  };
}

export default {
  data: {
    pageTitle: 'Message To Host',
    intro:
      'Use this page to verify Page.postMessage(...) and App.postMessage(...) from JavaScript to the embedding host. Check the host logs after tapping either button.',
    sendCount: 0,
    lastChannel: 'none',
    lastOrigin: 'ink-js',
    lastEventId: 'none',
    lastPayloadText: 'No message sent yet.',
    statusText: 'Ready to send a message to the host.',
  },

  sendPageMessage() {
    const nextCount = this.data.sendCount + 1;
    const lastEventId = `cap-page-${nextCount}`;
    const payload = buildPayload('page', nextCount);

    this.postMessage(payload, {
      origin: 'ink-js',
      lastEventId,
    });

    this.setData({
      sendCount: nextCount,
      lastChannel: 'page',
      lastOrigin: 'ink-js',
      lastEventId,
      lastPayloadText: JSON.stringify(payload, null, 2),
      statusText: `Sent Page.postMessage(...) #${nextCount}. Check host logs for ${lastEventId}.`,
    });
  },

  sendAppMessage() {
    const nextCount = this.data.sendCount + 1;
    const lastEventId = `cap-app-${nextCount}`;
    const payload = buildPayload('app', nextCount);

    getApp().postMessage(payload, {
      origin: 'ink-js',
      lastEventId,
    });

    this.setData({
      sendCount: nextCount,
      lastChannel: 'app',
      lastOrigin: 'ink-js',
      lastEventId,
      lastPayloadText: JSON.stringify(payload, null, 2),
      statusText: `Sent App.postMessage(...) #${nextCount}. Check host logs for ${lastEventId}.`,
    });
  },
};
</script>

<page>
  <view class="container">
    <view class="page-title">{{pageTitle}}</view>
    <text class="page-subtitle">{{intro}}</text>

    <view class="card">
      <text class="section-title">Send Message</text>
      <button class="action-button" bindtap="sendPageMessage">Send From Page</button>
      <button class="action-button secondary" bindtap="sendAppMessage">Send From App</button>
      <text class="status-line">{{statusText}}</text>
    </view>

    <view class="card">
      <text class="section-title">Last Message</text>
      <text class="detail-line">channel: {{lastChannel}}</text>
      <text class="detail-line">origin: {{lastOrigin}}</text>
      <text class="detail-line">lastEventId: {{lastEventId}}</text>
      <text class="detail-line">send count: {{sendCount}}</text>
    </view>

    <view class="card">
      <text class="section-title">Payload Preview</text>
      <text class="payload-preview">{{lastPayloadText}}</text>
    </view>
  </view>
</page>

<style>
  .container {
    display: flex;
    flex-direction: column;
    gap: 16px;
    padding: var(--spacing-lg, 20px);
    background-color: var(--color-background);
  }

  .page-title {
    font-size: 28px;
    font-weight: 700;
    color: var(--color-text-primary);
  }

  .page-subtitle {
    font-size: 14px;
    line-height: 20px;
    color: var(--color-text-secondary);
  }

  .card {
    display: flex;
    flex-direction: column;
    gap: 10px;
    padding: var(--spacing-md, 16px);
    border-radius: var(--radius-md, 12px);
    background-color: var(--color-surface);
    border: var(--border-width-thin, 1px) solid var(--border-color-default, #d1d1d6);
  }

  .section-title {
    font-size: 17px;
    font-weight: 700;
    color: var(--color-text-primary);
  }

  .action-button {
    width: 100%;
  }

  .secondary {
    background-color: rgba(10, 132, 255, 0.12);
    color: var(--color-primary, #0a84ff);
  }

  .status-line,
  .detail-line {
    font-size: 13px;
    line-height: 18px;
    color: var(--color-text-secondary);
  }

  .payload-preview {
    font-size: 12px;
    line-height: 18px;
    color: var(--color-text-primary);
    white-space: pre-wrap;
    font-family: monospace;
  }
</style>
