# Chart Data Visualization

The `chart` component renders line, area, bar, scatter, pie, radar, and funnel charts with dynamically bound data.

## Usage

```xml
<chart
  type="line"
  series="value"
  data="{{chartData}}"
  width="350"
  height="150"
  animate="true"
  color="#007AFF"
  smooth="true"
  show-average="true"
></chart>
```

```javascript
Page({
  data: {
    chartData: [
      { label: 'Mon', value: 120 },
      { label: 'Tue', value: 168 },
      { label: 'Wed', value: 142 },
      { label: 'Thu', value: 196 },
      { label: 'Fri', value: 210 }
    ]
  }
});
```

## Data Format

The `data` property accepts an array, where each item represents a data point. In most cases, it is recommended that each item contain at least:

- A field used to describe the category or dimension, such as `label`.
- A field used to represent the numeric value, with the field name specified through `series`, such as `value`.

For example:

```javascript
const chartData = [
  { label: 'Voice', value: 72 },
  { label: 'Vision', value: 86 },
  { label: 'Interaction', value: 64 }
];
```

When the component is set to `series="value"`, the chart reads the `value` field in each data item as the value to render.

## Properties

| Property | Type | Description | Default |
| :--- | :--- | :--- | :--- |
| `type` | String | Chart type: `line`, `area`, `bar`, `scatter`, `pie`, `radar`, or `funnel`. | `line` |
| `series` | String | The key in the data object that represents the numeric value. | `value` |
| `data` | Array | The array of data points to render. | `[]` |
| `width` | Number | The pixel width of the chart. | `300` |
| `height` | Number | The pixel height of the chart. | `150` |
| `animate` | Boolean | Whether to enable animation on first render and data updates. | `false` |
| `color` | String | The theme color of the chart (Hex, RGB, or color name). | `#00FF7F` |
| `show-average` | Boolean | Whether to display a dashed line representing the average value (line/area charts only). | `false` |
| `smooth` | Boolean | Whether to use smooth curves instead of straight lines (line/area charts only). | `true` |

## Chart Types

### line

Line charts are suitable for showing trends over time or across a set of continuous dimensions, such as daily active users, response time, or completed tasks.

### area

Area charts are suitable for further emphasizing magnitude on top of trend presentation, and are commonly used to show cumulative effects or the overall fluctuation range.

### bar

Bar charts compare categories and support horizontal and vertical orientations.

### scatter

Scatter charts reveal distributions between two continuous variables.

### pie

Pie charts are suitable for showing the proportional relationship of parts within a whole, such as traffic source distribution or feature usage share.

### radar

Radar charts are suitable for side-by-side comparison of multiple dimensions, such as evaluation results across several capability dimensions.

### funnel

Funnel charts show quantities and conversions across process stages.

## Features

- Supports binding the data source and numeric field through templates.
- Supports enabling animations on first render or when data updates.
- Supports customizing the chart theme color with `color`.
- Supports enabling smooth curves and average guide lines in line and area charts.
- Supports controlling chart size through `width` and `height`.

## Usage Recommendations

- If you want to display changing trends, prefer `line` or `area`.
- If you want to highlight proportions, prefer `pie`.
- If you want to compare multiple capability dimensions, prefer `radar`.
- In smaller chart areas, it is recommended to limit the number of data points to avoid visual crowding.
- It is recommended to keep `width` and `height` consistent with the page layout to avoid excessive compression or empty space in the chart.
