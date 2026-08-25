<script type="application/json" def>{ "widget": { "family": "1x2" } }</script>

<script setup>
export default {};
</script>

<widget>
  <view class="case">
    <text class="title">Custom component widget</text>
    <text class="copy">Lifecycle, setData and nested component rendering</text>
    <workflow-panel
      panelId="widget-component-case"
      title="Widget component"
      subtitle="Rendered from widget entry"
      owner="widget"
      statusLabel="ready"
      detailMode="compact"
      itemLabel="Nested workflow node"
      itemOwner="widget"
      itemState="ready"
      itemNote="Custom component case"
    />
  </view>
</widget>

<style>
.case { display: flex; flex-direction: column; gap: 8px; width: 100%; box-sizing: border-box; padding: 12px; }
.title { font-size: 16px; font-weight: bold; }
.copy { font-size: 11px; }
</style>
