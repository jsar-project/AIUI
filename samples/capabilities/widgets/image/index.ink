<script type="application/json" def>
{
  "widget": {
    "family": "1x2"
  }
}
</script>

<script setup>
export default {
  data: {
    avatarSrc: '../../assets/avatar.jpg',
    badgeSrc: '../../assets/clear-day.svg',
  },
};
</script>

<widget>
  <view class="image-widget">
    <view class="pattern"></view>
    <image class="avatar" src="{{avatarSrc}}" mode="aspectFill" />
    <view class="copy">
      <text class="eyebrow">Image Widget</text>
      <text class="title">Local assets</text>
      <text class="caption">JPG, SVG and CSS background</text>
    </view>
    <view class="badge-frame">
      <image class="badge" src="{{badgeSrc}}" mode="aspectFit" />
    </view>
  </view>
</widget>

<style>
  .image-widget {
    position: relative;
    width: 100%;
    height: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 12px;
    padding: 16px;
    overflow: hidden;
    color: #f8fafc;
    background-color: #172554;
  }

  .pattern {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    opacity: 0.18;
    background-image: url('../../assets/dot_pattern.png');
  }

  .avatar {
    width: 72px;
    height: 72px;
    flex-shrink: 0;
    border: 2px solid #93c5fd;
    border-radius: 16px;
  }

  .copy {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .eyebrow {
    font-size: 10px;
    color: #93c5fd;
  }

  .title {
    font-size: 18px;
    font-weight: 700;
  }

  .caption {
    font-size: 10px;
    color: #cbd5e1;
  }

  .badge-frame {
    width: 44px;
    height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    border-radius: 22px;
    background-color: #dbeafe;
  }

  .badge {
    width: 30px;
    height: 30px;
  }
</style>
