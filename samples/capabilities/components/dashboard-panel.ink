<script def>{ "component": true }</script>

<template>
  <view class="panel">
    <view class="panel-header">
      <view class="panel-title">
        <slot name="title" />
      </view>

      <view class="panel-actions" wx:if="{{showActions}}">
        <slot name="actions" />
      </view>
    </view>

    <view class="panel-slot-stats">
      <text class="panel-slot-line">title entries: {{titleSlotCount}}</text>
      <text class="panel-slot-line">action entries: {{actionSlotCount}}</text>
      <text class="panel-slot-line">content entries: {{contentSlotCount}}</text>
    </view>

    <view class="panel-body">
      <slot name="content" />
    </view>
  </view>
</template>

<style>
.panel {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 14px;
  border-width: 1px;
  border-radius: 14px;
}

.panel-header {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
}

.panel-title,
.panel-actions,
.panel-slot-stats,
.panel-body {
  display: flex;
}

.panel-title,
.panel-slot-stats,
.panel-body {
  flex-direction: column;
}

.panel-actions {
  flex-direction: row;
}

.panel-title,
.panel-body {
  flex: 1;
}

.panel-slot-stats {
  gap: 4px;
}

.panel-slot-line {
  font-size: 12px;
}
</style>

<script setup>
export default {
  data: {
    showActions: false,
    titleSlotCount: 0,
    actionSlotCount: 0,
    contentSlotCount: 0,
  },

  lifetimes: {
    attached() {
      const titleEntries = this.$slots.title || [];
      const actionEntries = this.$slots.actions || [];
      const contentEntries = this.$slots.content || [];

      this.setData({
        showActions: this.hasSlot('actions'),
        titleSlotCount: titleEntries.length,
        actionSlotCount: actionEntries.length,
        contentSlotCount: contentEntries.length,
      });
    },
  },
};
</script>
