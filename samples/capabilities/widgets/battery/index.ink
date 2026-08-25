<script type="application/json" def>
{ "widget": { "family": "1x1" } }
</script>

<script setup>
export default {
  data: { level: 76, levelStyle: 'height: 76%;', charging: false },
  toggleCharging() {
    const charging = !this.data.charging;
    this.setData({ charging });
  },
};
</script>

<widget>
  <button class="battery-widget" bindtap="toggleCharging">
    <view class="battery">
      <view class="battery-fill" style="{{levelStyle}}"></view>
    </view>
    <text class="level">{{level}}%</text>
    <text class="hint">{{charging ? 'Charging' : 'All day'}}</text>
  </button>
</widget>

<style>
  .battery-widget { width: 100%; height: 100%; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 5px; background-color: #052e16; color: #dcfce7; }
  .battery { position: relative; width: 38px; height: 62px; padding: 3px; border: 3px solid #86efac; border-radius: 7px; display: flex; flex-direction: column; justify-content: flex-end; overflow: hidden; }
  .battery-fill { width: 100%; border-radius: 3px; background-color: #22c55e; }
  .level { font-size: 20px; font-weight: 700; }
  .hint { font-size: 10px; color: #86efac; }
</style>
