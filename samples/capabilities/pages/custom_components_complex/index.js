function createPanels(variant) {
  const prefix = variant === 'Alpha' ? 'Alpha' : 'Beta';
  const statusLabel = variant === 'Alpha' ? 'stable' : 'handoff';

  return [
    {
      panelId: 'intake-lane',
      title: `${prefix} Intake Lane`,
      subtitle: 'Covers nested props and child event forwarding.',
      owner: variant === 'Alpha' ? 'Rhea' : 'Mika',
      statusLabel,
      itemId: 'node-speaker',
      itemLabel: `${prefix} Speaker QA`,
      itemOwner: variant === 'Alpha' ? 'Tao' : 'Nia',
      itemPriority: 'high',
      itemState: 'active',
      itemNote: `${prefix} variant refreshes both panel copy and nested node copy.`,
      archived: false,
    },
    {
      panelId: 'followup-lane',
      title: `${prefix} Follow-up Lane`,
      subtitle: 'Keeps list-driven instances isolated from each other.',
      owner: variant === 'Alpha' ? 'Jules' : 'Iris',
      statusLabel: variant === 'Alpha' ? 'watch' : 'ready',
      itemId: 'node-battery',
      itemLabel: `${prefix} Battery Review`,
      itemOwner: variant === 'Alpha' ? 'Omar' : 'Lena',
      itemPriority: 'medium',
      itemState: 'idle',
      itemNote: 'Use the page switches to remount this card with the latest props.',
      archived: false,
    },
    {
      panelId: 'archive-lane',
      title: `${prefix} Archive Lane`,
      subtitle: 'Only appears when the archived switch is enabled.',
      owner: variant === 'Alpha' ? 'Bea' : 'Kian',
      statusLabel: 'archived',
      itemId: 'node-retro',
      itemLabel: `${prefix} Retro Notes`,
      itemOwner: variant === 'Alpha' ? 'Sol' : 'Ava',
      itemPriority: 'low',
      itemState: 'idle',
      itemNote: 'This row verifies add/remove list behavior for custom components.',
      archived: true,
    },
  ];
}

function buildVisiblePanels(variant, showArchived) {
  const allPanels = createPanels(variant);
  return allPanels.filter((panel) => showArchived || !panel.archived);
}

const gpxData = `<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Ink Capabilities Demo">
  <wpt lat="47.2690" lon="11.4036">
    <name>Start</name>
  </wpt>
  <wpt lat="47.2704" lon="11.4092">
    <name>Summit View</name>
  </wpt>
  <trk>
    <name>Custom Component Overlay</name>
    <trkseg>
      <trkpt lat="47.2690" lon="11.4036" />
      <trkpt lat="47.2692" lon="11.4044" />
      <trkpt lat="47.2695" lon="11.4058" />
      <trkpt lat="47.2699" lon="11.4071" />
      <trkpt lat="47.2704" lon="11.4092" />
      <trkpt lat="47.2698" lon="11.4099" />
      <trkpt lat="47.2689" lon="11.4087" />
      <trkpt lat="47.2685" lon="11.4068" />
      <trkpt lat="47.2686" lon="11.4052" />
      <trkpt lat="47.2690" lon="11.4036" />
    </trkseg>
  </trk>
</gpx>`;

export default {
  data: {
    variant: 'Alpha',
    detailExpanded: true,
    detailMode: 'expanded',
    showArchived: false,
    showPanels: true,
    panels: buildVisiblePanels('Alpha', false),
    panelCount: buildVisiblePanels('Alpha', false).length,
    lastEvent: 'none',
    selectedPath: 'none',
    lastMutation: 'boot',
    gpxData,
    slotPanelTitle: 'Daily Summary',
    slotSummary: '12 devices online across 3 rooms.',
    slotActionEvent: 'none',
  },

  toggleVariant() {
    const variant = this.data.variant === 'Alpha' ? 'Beta' : 'Alpha';
    const panels = buildVisiblePanels(variant, this.data.showArchived);
    this.setData({
      variant,
      panels,
      panelCount: panels.length,
      lastMutation: `variant:${variant}`,
    });
  },

  resetScenario() {
    const panels = buildVisiblePanels('Alpha', false);
    this.setData({
      variant: 'Alpha',
      detailExpanded: true,
      detailMode: 'expanded',
      showArchived: false,
      showPanels: true,
      panels,
      panelCount: panels.length,
      lastEvent: 'none',
      selectedPath: 'none',
      lastMutation: 'reset',
    });
  },

  onDetailModeChange(event) {
    const detailExpanded = event.detail.value;
    this.setData({
      detailExpanded,
      detailMode: detailExpanded ? 'expanded' : 'compact',
      lastMutation: detailExpanded ? 'detail:expanded' : 'detail:compact',
    });
  },

  onShowArchivedChange(event) {
    const showArchived = event.detail.value;
    const panels = buildVisiblePanels(this.data.variant, showArchived);
    this.setData({
      showArchived,
      panels,
      panelCount: panels.length,
      lastMutation: showArchived ? 'archived:on' : 'archived:off',
    });
  },

  onShowPanelsChange(event) {
    this.setData({
      showPanels: event.detail.value,
      lastMutation: event.detail.value ? 'panels:shown' : 'panels:hidden',
    });
  },

  onPanelSelect(event) {
    const detail = event.detail || {};
    const item = detail.item || {};
    this.setData({
      lastEvent: `select:${detail.panelId}:${item.itemId || item.label || 'unknown'}`,
      selectedPath: `${detail.panelTitle || 'panel'} -> ${item.label || 'item'}`,
    });
  },

  onPanelPromote(event) {
    const detail = event.detail || {};
    this.setData({
      lastEvent: `promote:${detail.panelId}:${detail.promoteCount || 0}`,
      selectedPath: `${detail.title || 'panel'} -> ${detail.itemId || 'item'}`,
    });
  },

  handleSlotActionPress(event) {
    const detail = event.detail || {};
    this.setData({
      slotActionEvent: `${detail.source || 'panel-action'}:${detail.label || 'unknown'}`,
    });
  },
};
