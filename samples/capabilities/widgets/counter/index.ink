<script type="application/json" def>
{
  "widget": {
    "family": "1x1"
  }
}
</script>

<script setup>
export default {
  data: {
    count: 0,
    lifecycle: 'Created',
  },

  onCreate() {
    console.log('Counter widget created', this.widgetId, this.family);
  },

  onAttach() {
    this.setData({ lifecycle: 'Attached' });
  },

  onDetach() {
    console.log('Counter widget detached', this.widgetId);
  },

  onDestroy() {
    console.log('Counter widget destroyed', this.widgetId);
  },

  increment() {
    this.setData({ count: this.data.count + 1 });
  },
};
</script>

<widget>
  <button class="counter" bindtap="increment">
    <text class="label">Counter</text>
    <text class="value">{{count}}</text>
    <text class="status">{{lifecycle}}</text>
  </button>
</widget>

<style>
  .counter {
    width: 100%;
    height: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 4px;
    padding: 12px;
    color: #111827;
    background-color: #f3f4f6;
    border: 1px solid #d1d5db;
  }

  .label {
    font-size: 13px;
    color: #4b5563;
  }

  .value {
    font-size: 30px;
    font-weight: 700;
  }

  .status {
    font-size: 11px;
    color: #047857;
  }
</style>
