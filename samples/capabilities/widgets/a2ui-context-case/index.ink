<script type="application/json" def>{ "widget": { "family": "1x2" } }</script>

<script setup>
export default {
  data: {
    status: 'checking',
    commands: `[
      {
        "type": "createSurface",
        "surfaceId": "widget-a2ui-surface"
      },
      {
        "type": "updateComponents",
        "surfaceId": "widget-a2ui-surface",
        "components": [
          {
            "id": "root",
            "component": "Column",
            "props": {
              "width": "100%",
              "padding": 10,
              "gap": 6,
              "borderRadius": 8
            },
            "children": ["a2ui-title", "a2ui-copy"]
          },
          {
            "id": "a2ui-title",
            "component": "text",
            "props": {
              "content": "A2UI rendered",
              "style": "font-size: 14px; font-weight: bold;"
            }
          },
          {
            "id": "a2ui-copy",
            "component": "text",
            "props": {
              "content": "Component tree from widget commands",
              "style": "font-size: 11px;"
            }
          }
        ]
      }
    ]`,
  },
  onAttach() {
    const context = a2ui.createA2UIContext('widgetA2uiContext');
    this.setData({ status: context ? 'available' : 'missing' });
  },
};
</script>

<widget>
  <view class="case">
    <text class="title">A2UI context widget</text>
    <text class="copy">createA2UIContext: {{status}}</text>
    <a2ui id="widgetA2uiContext" commands="{{commands}}" class="a2ui" />
  </view>
</widget>

<style>
.case { display: flex; flex-direction: column; gap: 8px; width: 100%; box-sizing: border-box; padding: 12px; }
.title { font-size: 16px; font-weight: bold; }
.copy { font-size: 11px; }
.a2ui { width: 100%; height: 96px; }
</style>
