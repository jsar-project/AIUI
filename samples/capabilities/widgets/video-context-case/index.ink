<script type="application/json" def>{ "widget": { "family": "1x2" } }</script>

<script setup>
export default {
  data: { status: 'checking' },
  onAttach() {
    const context = wx.createVideoContext('widgetVideoContext');
    this.setData({ status: context ? 'available' : 'missing' });
  },
};
</script>

<widget>
  <view class="case">
    <text class="title">VideoContext widget</text>
    <text class="copy">wx.createVideoContext: {{status}}</text>
    <video id="widgetVideoContext" class="video" src="../../assets/video-progressive.mp4" muted object-fit="contain" />
  </view>
</widget>

<style>
.case { display: flex; flex-direction: column; gap: 8px; width: 100%; box-sizing: border-box; padding: 12px; }
.title { font-size: 16px; font-weight: bold; }
.copy { font-size: 11px; }
.video { width: 100%; height: 80px; }
</style>
