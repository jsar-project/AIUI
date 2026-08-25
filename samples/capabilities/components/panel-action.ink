<script def>{ "component": true }</script>

<template>
  <button class="panel-action" bindtap="emitPress">{{label}}</button>
</template>

<style>
.panel-action {
  width: 100%;
}
</style>

<script setup>
export default {
  properties: {
    label: {
      type: String,
      value: 'Action',
    },
  },

  methods: {
    emitPress() {
      this.triggerEvent('press', {
        label: this.properties.label,
        source: 'panel-action',
      });
    },
  },
};
</script>
