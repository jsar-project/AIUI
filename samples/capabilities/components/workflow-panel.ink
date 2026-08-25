<script def>{ "component": true, "usingComponents": { "workflow-node": "components/workflow-node" } }</script>

<template>
  <card class="panel">
    <view class="panel-header">
      <view class="panel-copy">
        <text class="panel-title">{{title}}</text>
        <text class="panel-subtitle">{{subtitle}}</text>
      </view>
      <view class="panel-badge">
        <text class="panel-phase">{{phase}}</text>
        <text class="panel-status">{{statusLabel}}</text>
      </view>
    </view>
    <view class="panel-summary">
      <text class="panel-line">panel: {{panelId}}</text>
      <text class="panel-line">owner: {{owner}}</text>
      <text class="panel-line">mode: {{detailMode}}</text>
    </view>
    <workflow-node
      itemId="{{itemId}}"
      label="{{itemLabel}}"
      owner="{{itemOwner}}"
      priority="{{itemPriority}}"
      state="{{itemState}}"
      note="{{itemNote}}"
      detailMode="{{detailMode}}"
      bindselect="handleNodeSelect"
    />
    <view class="panel-callout" wx:if="{{detailMode === 'expanded'}}">
      <text class="panel-callout-text">expanded summary: {{title}} keeps nested details visible.</text>
    </view>
    <button class="panel-action" bindtap="emitPromote">Send Parent Event</button>
  </card>
</template>

<style>
.panel {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 14px;
  border-radius: 2px;
}

.panel-header {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.panel-copy,
.panel-summary,
.panel-badge {
  display: flex;
  flex-direction: column;
}

.panel-copy {
  gap: 4px;
  flex: 1;
}

.panel-badge,
.panel-summary {
  gap: 4px;
}

.panel-title {
  font-size: 18px;
  font-weight: bold;
}

.panel-subtitle,
.panel-phase,
.panel-status,
.panel-line,
.panel-callout-text {
  font-size: 12px;
}

.panel-callout {
  display: flex;
  padding: 10px;
  border-width: 1px;
  border-radius: 10px;
}

.panel-action {
  width: 100%;
}
</style>
<script setup>
export default {
  data: {
    phase: 'created',
    promoteCount: 0,
  },

  properties: {
    panelId: {
      type: String,
      value: 'panel-0',
    },
    title: {
      type: String,
      value: 'Untitled panel',
    },
    subtitle: {
      type: String,
      value: 'No subtitle',
    },
    owner: {
      type: String,
      value: 'Unknown owner',
    },
    statusLabel: {
      type: String,
      value: 'idle',
    },
    detailMode: {
      type: String,
      value: 'expanded',
    },
    itemId: {
      type: String,
      value: 'node-0',
    },
    itemLabel: {
      type: String,
      value: 'Untitled node',
    },
    itemOwner: {
      type: String,
      value: 'Unknown owner',
    },
    itemPriority: {
      type: String,
      value: 'normal',
    },
    itemState: {
      type: String,
      value: 'idle',
    },
    itemNote: {
      type: String,
      value: 'No note',
    },
  },

  lifetimes: {
    created() {
      this.setData({
        phase: 'created',
      });
    },
    attached() {
      this.setData({
        phase: 'attached',
      });
    },
    ready() {
      this.setData({
        phase: 'ready',
      });
    },
    detached() {
      this.setData({
        phase: 'detached',
      });
    },
  },

  methods: {
    handleNodeSelect(event) {
      this.triggerEvent('select', {
        panelId: this.properties.panelId,
        panelTitle: this.properties.title,
        owner: this.properties.owner,
        statusLabel: this.properties.statusLabel,
        detailMode: this.properties.detailMode,
        item: event.detail,
        forwardedBy: 'workflow-panel',
      });
    },

    emitPromote() {
      const nextPromoteCount = this.data.promoteCount + 1;
      this.setData({
        promoteCount: nextPromoteCount,
      });
      this.triggerEvent('promote', {
        panelId: this.properties.panelId,
        title: this.properties.title,
        owner: this.properties.owner,
        detailMode: this.properties.detailMode,
        itemId: this.properties.itemId,
        promoteCount: nextPromoteCount,
        source: 'workflow-panel',
      });
    },
  },
};
</script>
