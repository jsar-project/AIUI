<script type="application/json" def>
{ "widget": { "family": "1x2" } }
</script>

<script setup>
export default {
  data: { playing: false, action: 'Play' },
  togglePlayback() {
    const playing = !this.data.playing;
    this.setData({ playing, action: playing ? 'Pause' : 'Play' });
  },
};
</script>

<widget>
  <view class="player">
    <view class="cover"><text class="note">♪</text></view>
    <view class="track">
      <text class="eyebrow">NOW PLAYING</text>
      <text class="title">Night Drive</text>
      <text class="artist">Ink Radio</text>
    </view>
    <button class="play" bindtap="togglePlayback">{{action}}</button>
  </view>
</widget>

<style>
  .player { width: 100%; height: 100%; box-sizing: border-box; display: flex; flex-direction: row; align-items: center; gap: 14px; padding: 16px; color: #f8fafc; background-color: #27272a; }
  .cover { width: 66px; height: 66px; display: flex; align-items: center; justify-content: center; border-radius: 6px; background-color: #be123c; }
  .note { font-size: 32px; color: #ffe4e6; }
  .track { flex: 1; display: flex; flex-direction: column; gap: 3px; }
  .eyebrow { font-size: 9px; color: #fda4af; }
  .title { font-size: 18px; font-weight: 700; }
  .artist { font-size: 11px; color: #a1a1aa; }
  .play { min-width: 66px; min-height: 36px; border: 1px solid #fda4af; color: #fff1f2; background-color: #881337; font-size: 11px; font-weight: 700; }
</style>
