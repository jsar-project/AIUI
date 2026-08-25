<template>
  <map-gpx
    data="{{gpxData}}"
    stroke-color="{{strokeColor}}"
    stroke-width="{{strokeWidth}}"
    point-radius="{{pointRadius}}"
    waypoint-color="{{waypointColor}}"
    start-color="{{startColor}}"
    end-color="{{endColor}}"
    label-visible="{{labelVisible}}"
  />
</template>

<script setup>
export default {
  properties: {
    gpxData: {
      type: String,
      value: '',
    },
    strokeColor: {
      type: String,
      value: '#2563eb',
    },
    strokeWidth: {
      type: Number,
      value: 4,
    },
    pointRadius: {
      type: Number,
      value: 4,
    },
    waypointColor: {
      type: String,
      value: '#0f172a',
    },
    startColor: {
      type: String,
      value: '#16a34a',
    },
    endColor: {
      type: String,
      value: '#dc2626',
    },
    labelVisible: {
      type: Boolean,
      value: true,
    },
  },
};
</script>
