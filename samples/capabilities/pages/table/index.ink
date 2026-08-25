<script type="application/json" def>
{
  "navigationBarTitleText": "Table"
}
</script>

<script setup>
const scoreColumns = JSON.stringify([
  { key: 'name', title: 'Name', align: 'left' },
  { key: 'score', title: 'Score', align: 'right' },
  { key: 'status', title: 'Status', align: 'center' },
]);

const scoreRows = JSON.stringify([
  { name: 'Alice', score: 98, status: 'Ready' },
  { name: 'Bob', score: 87, status: 'Review' },
  { name: 'Charlie', score: 91, status: 'Locked' },
]);

const alignmentColumns = JSON.stringify([
  { key: 'metric', title: 'Metric', align: 'left' },
  { key: 'target', title: 'Target', align: 'center' },
  { key: 'actual', title: 'Actual', align: 'right' },
]);

const alignmentRows = JSON.stringify([
  { metric: 'Latency', target: '< 30 ms', actual: '24 ms' },
  { metric: 'FPS', target: '60', actual: '58' },
  { metric: 'Memory', target: '< 64 MB', actual: '48 MB' },
]);

const emptyColumns = JSON.stringify([
  { key: 'task', title: 'Task', align: 'left' },
  { key: 'owner', title: 'Owner', align: 'left' },
]);

const emptyRows = JSON.stringify([]);

export default {
  data: {
    scoreColumns,
    scoreRows,
    alignmentColumns,
    alignmentRows,
    emptyColumns,
    emptyRows,
  },

  onLoad() {
    console.log('Table component test page loaded');
  },
};
</script>

<page>
  <view class="page">
    <view class="hero">
      <text class="page-title">Table</text>
      <text class="page-subtitle">
        Data-driven table demos for shared native table rendering, column alignment, and empty
        state behavior.
      </text>
    </view>

    <card class="section-card" title="Basic Data Table">
      <text class="section-copy">
        The table below uses `columns` and `rows` JSON strings to render a simple score board with
        left, right, and center aligned columns in one layout.
      </text>
      <table
        class="demo-table"
        caption="Leaderboard"
        columns="{{scoreColumns}}"
        rows="{{scoreRows}}"
        empty-text="No entries yet"
      />
      <text class="caption">
        Props: caption=Leaderboard, columns=Name/Score/Status, rows=3
      </text>
    </card>

    <card class="section-card" title="Column Alignment">
      <text class="section-copy">
        This case verifies that each column keeps its own alignment semantics while still sharing
        one equal-width native table layout.
      </text>
      <table
        class="demo-table"
        caption="Alignment Matrix"
        columns="{{alignmentColumns}}"
        rows="{{alignmentRows}}"
        empty-text="No alignment samples"
      />
      <text class="caption">
        Metric stays left aligned, Target is centered, and Actual is right aligned.
      </text>
    </card>

    <card class="section-card" title="Empty State">
      <text class="section-copy">
        When `rows` is empty, the component keeps the header row visible and shows the configured
        empty placeholder below it.
      </text>
      <table
        class="demo-table"
        caption="Pending Tasks"
        columns="{{emptyColumns}}"
        rows="{{emptyRows}}"
        empty-text="No tasks assigned"
      />
      <text class="caption">
        Props: rows=[], empty-text=No tasks assigned
      </text>
    </card>
  </view>
</page>

<style>
  .page {
    --table-page-background: var(--color-background);
    --table-surface-background: var(--color-surface);
    --table-text-color: var(--color-text-primary);
    --table-muted-text-color: var(--color-text-secondary);
    --table-border-color: var(--border-color-default);
    padding: var(--spacing-lg, 20px);
    display: flex;
    flex-direction: column;
    gap: var(--spacing-lg, 20px);
    background-color: var(--table-page-background);
  }

  .hero {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .page-title {
    font-size: 28px;
    font-weight: 700;
    color: var(--table-text-color);
  }

  .page-subtitle {
    font-size: 14px;
    line-height: 20px;
    color: var(--table-muted-text-color);
  }

  .section-card {
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding: var(--spacing-md, 16px);
    border-radius: var(--radius-md, 12px);
    border: 1px solid var(--table-border-color);
    background-color: var(--table-surface-background);
  }

  .section-copy {
    font-size: 14px;
    line-height: 20px;
    color: var(--table-muted-text-color);
  }

  .demo-table {
    width: 100%;
  }

  .caption {
    font-size: 12px;
    line-height: 18px;
    color: var(--table-muted-text-color);
  }
</style>
