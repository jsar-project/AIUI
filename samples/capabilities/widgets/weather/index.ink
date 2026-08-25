<script type="application/json" def>
{ "widget": { "family": "1x2" } }
</script>

<script setup>
const forecasts = [
  { city: 'Hangzhou', temperature: 24, condition: 'Clear', range: '19 / 27 C' },
  { city: 'Shanghai', temperature: 22, condition: 'Cloudy', range: '18 / 25 C' },
];
export default {
  data: { ...forecasts[0], index: 0 },
  nextCity() {
    const index = (this.data.index + 1) % forecasts.length;
    this.setData({ ...forecasts[index], index });
  },
};
</script>

<widget>
  <button class="weather" bindtap="nextCity">
    <view class="sun"><view class="sun-core"></view></view>
    <view class="weather-copy">
      <text class="city">{{city}}</text>
      <text class="condition">{{condition}} · {{range}}</text>
    </view>
    <text class="temperature">{{temperature}}°</text>
  </button>
</widget>

<style>
  .weather { width: 100%; height: 100%; box-sizing: border-box; display: flex; flex-direction: row; align-items: center; gap: 14px; padding: 18px; color: #172554; background-color: #dbeafe; }
  .sun { width: 54px; height: 54px; display: flex; align-items: center; justify-content: center; border: 2px solid #f59e0b; border-radius: 50%; }
  .sun-core { width: 34px; height: 34px; border-radius: 50%; background-color: #fbbf24; }
  .weather-copy { flex: 1; display: flex; flex-direction: column; align-items: flex-start; gap: 5px; }
  .city { font-size: 18px; font-weight: 700; }
  .condition { font-size: 11px; color: #475569; }
  .temperature { font-size: 36px; font-weight: 700; }
</style>
