# Map 地图

`map` 使用 MVT 矢量瓦片绘制地图，并可叠加 GPX 轨迹与航点。

## 显示指定区域

```xml
<map
  tile-url="https://tiles.example.com/{z}/{x}/{y}.mvt"
  longitude="116.397"
  latitude="39.908"
  zoom="12"
  style="width: 640px; height: 360px;"
></map>
```

瓦片地址必须包含 `{z}`、`{x}`、`{y}` 占位符。地图按最终布局尺寸绘制；布局尺寸不可用时使用 `300 × 200`。

## 叠加 GPX 轨迹

```xml
<map tile-url="https://tiles.example.com/{z}/{x}/{y}.mvt" style="width: 640px; height: 360px;">
  <map-gpx slot="overlays" src="https://example.com/route.gpx" stroke-color="#2563eb" />
</map>
```

未显式设置 `longitude`、`latitude` 或 `zoom` 时，组件会根据已加载 GPX 内容补全对应取景参数。`map-gpx` 也可以通过 `data` 提供内联 GPX XML。

## 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `tile-url` | String | `""` | MVT 瓦片模板；也支持别名 `url`、`src`。 |
| `longitude` | Number | 自动 | 中心经度，限制在 `-180` 至 `180`；别名为 `lng`、`center-longitude`。 |
| `latitude` | Number | 自动 | 中心纬度，限制在 Web Mercator 有效范围；别名为 `lat`、`center-latitude`。 |
| `zoom` | Number | 自动 | 缩放级别，取整并限制在 `0` 至 `22`。 |
| `pitch` | Number | `0` | 俯仰角，限制在 `0` 至 `60`。 |
| `bearing` | Number | `0` | 旋转角度；别名为 `rotation`。 |
| `map-style` | JSON String | 内置样式 | 地图颜色和线宽配置；别名为 `style-json`。 |

`map-style` 支持 `background`、`land`、`water`、`road`、`building`、`boundary`、`labelPoint`、`lineWidth` 和 `pointRadius`。地图样式也可通过 `--map-*` CSS 自定义属性设置。

没有可用于自动取景的 GPX 内容时，未设置的中心坐标和缩放级别回退为 `0`。

## `map-gpx` 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `src` | String | - | GPX 文件地址；别名为 `url`。 |
| `data` | String | - | 内联 GPX XML；别名为 `content`，并优先于 `src`。 |
| `visible` | Boolean | `true` | 是否显示覆盖层。 |
| `stroke-color` | String | `#2563eb` | 轨迹颜色。 |
| `stroke-width` | Number | `3` | 轨迹宽度，最小为 `1`。 |
| `waypoint-color` | String | `#0f172a` | 航点颜色。 |
| `start-color` | String | `#16a34a` | 起点颜色。 |
| `end-color` | String | `#dc2626` | 终点颜色。 |
| `point-radius` | Number | `4` | 点半径，最小为 `2`。 |
| `label-visible` | Boolean | `true` | 是否显示航点标签。 |
| `label-color` | String | `#0f172a` | 标签颜色。 |
