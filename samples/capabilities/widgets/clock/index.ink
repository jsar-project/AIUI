<script type="application/json" def>
{
  "widget": {
    "family": "1x1"
  }
}
</script>

<script setup>
function timeParts() {
  const now = new Date();
  const seconds = now.getSeconds();
  const minutes = now.getMinutes() + seconds / 60;
  const hours = (now.getHours() % 12) + minutes / 60;
  return {
    time: now.toLocaleTimeString([], {
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
    }),
    date: now.toLocaleDateString([], {
      month: 'short',
      day: 'numeric',
    }),
    hourStyle: `transform: rotate(${hours * 30}deg);`,
    minuteStyle: `transform: rotate(${minutes * 6}deg);`,
    secondStyle: `transform: rotate(${seconds * 6}deg);`,
  };
}

export default {
  data: {
    ...timeParts(),
    lifecycle: 'Created',
  },

  onCreate() {
    this.clockTimer = setInterval(() => {
      this.setData(timeParts());
    }, 1000);
  },

  onAttach() {
    this.setData({
      ...timeParts(),
      lifecycle: 'Attached',
    });
  },

  onDetach() {
    this.setData({ lifecycle: 'Detached' });
  },

  onDestroy() {
    if (this.clockTimer) {
      clearInterval(this.clockTimer);
      this.clockTimer = null;
    }
  },
};
</script>

<widget>
  <view class="clock">
    <view class="dial">
      <view class="mark mark-12"></view>
      <view class="mark mark-3"></view>
      <view class="mark mark-6"></view>
      <view class="mark mark-9"></view>
      <view class="hand hour-hand" style="{{hourStyle}}"></view>
      <view class="hand minute-hand" style="{{minuteStyle}}"></view>
      <view class="hand second-hand" style="{{secondStyle}}"></view>
      <view class="pin"></view>
    </view>
    <text class="caption">{{time}} · {{date}}</text>
  </view>
</widget>

<style>
  .clock {
    width: 100%;
    height: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 8px;
    color: #f9fafb;
    background-color: #172554;
    border: 1px solid #3b82f6;
  }

  .dial {
    position: relative;
    width: 88px;
    height: 88px;
    border: 2px solid #bfdbfe;
    border-radius: 50%;
    background-color: #0f172a;
  }

  .mark {
    position: absolute;
    background-color: #93c5fd;
  }

  .mark-12,
  .mark-6 {
    left: 41px;
    width: 3px;
    height: 8px;
  }

  .mark-12 { top: 4px; }
  .mark-6 { bottom: 4px; }

  .mark-3,
  .mark-9 {
    top: 41px;
    width: 8px;
    height: 3px;
  }

  .mark-3 { right: 4px; }
  .mark-9 { left: 4px; }

  .hand {
    position: absolute;
    left: 42px;
    bottom: 42px;
    width: 2px;
    transform-origin: 50% 100%;
    background-color: #f8fafc;
  }

  .hour-hand {
    height: 24px;
    width: 4px;
    left: 41px;
  }

  .minute-hand { height: 32px; }

  .second-hand {
    height: 35px;
    width: 1px;
    background-color: #fb7185;
  }

  .pin {
    position: absolute;
    left: 39px;
    top: 39px;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background-color: #fb7185;
  }

  .caption {
    font-size: 10px;
    color: #bfdbfe;
  }
</style>
