<script type="application/json" def>
{
  "widget": {
    "family": "1x2"
  }
}
</script>

<script setup>
import wx from 'wx';

export default {
  data: {
    status: 'Waiting for canvas',
    canvasWidth: 240,
    canvasHeight: 104,
  },

  onAttach() {
    const canvasWidth = Math.max(1, this.hostWidth - 20);
    this.setData({
      canvasWidth,
      status: `Canvas ${canvasWidth} x ${this.data.canvasHeight}`,
    }, () => {
      this.drawAttempts = 0;
      this.drawTimer = setInterval(() => {
        this.drawCanvas(0);
        this.drawAttempts += 1;
        if (this.drawAttempts >= 5) {
          clearInterval(this.drawTimer);
          this.drawTimer = null;
          this.startAnimation();
        }
      }, 100);
    });
  },

  onDetach() {
    this.stopAnimation();
  },

  onDestroy() {
    this.stopAnimation();
  },

  stopAnimation() {
    if (this.drawTimer) {
      clearInterval(this.drawTimer);
      this.drawTimer = null;
    }
    if (this.animationFrameId !== null && this.animationFrameId !== undefined) {
      cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = null;
    }
  },

  startAnimation() {
    if (this.animationFrameId !== null && this.animationFrameId !== undefined) {
      cancelAnimationFrame(this.animationFrameId);
    }
    this.animationStartTime = null;

    const renderFrame = (timestamp) => {
      if (this.animationStartTime === null) {
        this.animationStartTime = timestamp;
      }
      if (!this.drawCanvas(timestamp - this.animationStartTime)) {
        this.animationFrameId = null;
        return;
      }
      this.animationFrameId = requestAnimationFrame(renderFrame);
    };

    this.animationFrameId = requestAnimationFrame(renderFrame);
  },

  drawCanvas(elapsedMs = 0) {
    const ctx = wx.createCanvasContext('widgetCanvas');
    if (!ctx) {
      this.setData({ status: 'Canvas context unavailable' });
      return false;
    }

    const width = this.data.canvasWidth;
    const height = this.data.canvasHeight;
    const time = elapsedMs / 1000;
    const squareY = 14 + Math.sin(time * 2.4) * 8;
    const circleX = width / 2 + Math.sin(time * 1.6) * 42;
    const circleRadius = 28 + Math.sin(time * 3.2) * 4;
    const chevronPeakY = 20 + Math.cos(time * 2.2) * 8;

    ctx.clearRect(0, 0, width, height);
    ctx.fillStyle = '#0f172a';
    ctx.fillRect(0, 0, width, height);

    ctx.fillStyle = '#38bdf8';
    ctx.fillRect(14, squareY, 64, 64);

    ctx.beginPath();
    ctx.fillStyle = '#fbbf24';
    ctx.arc(circleX, 46, circleRadius, 0, Math.PI * 2);
    ctx.fill();

    ctx.beginPath();
    ctx.strokeStyle = '#fb7185';
    ctx.lineWidth = 8;
    ctx.moveTo(width - 78, 74);
    ctx.lineTo(width - 52, chevronPeakY);
    ctx.lineTo(width - 20, 74);
    ctx.stroke();

    ctx.flush();
    return true;
  },
};
</script>

<widget>
  <view class="canvas-widget">
    <canvas
      id="widgetCanvas"
      class="canvas"
      width="{{canvasWidth}}"
      height="{{canvasHeight}}"
      bindtap="startAnimation"
    ></canvas>
    <view class="label-row">
      <text class="label">Canvas Widget</text>
      <text class="status">{{status}}</text>
    </view>
  </view>
</widget>

<style>
  .canvas-widget {
    width: 100%;
    height: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 6px;
    padding: 10px;
    color: #f8fafc;
    background-color: #020617;
  }

  .canvas {
    width: 100%;
    height: 104px;
    border-radius: 8px;
    background-color: #0f172a;
  }

  .label-row {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
  }

  .label {
    font-size: 11px;
    font-weight: 700;
  }

  .status {
    font-size: 9px;
    color: #94a3b8;
  }
</style>
