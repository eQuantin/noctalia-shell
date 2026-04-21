import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services.System
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginM

  // Properties to receive data from parent
  property var screen: null
  property var widgetData: null
  property var widgetMetadata: null

  signal settingsChanged(var settings)

  readonly property string barPosition: Settings.getBarPositionForScreen(screen?.name)
  readonly property bool isVerticalBar: barPosition === "left" || barPosition === "right"

  // Local, editable state for checkboxes
  property bool valueCompactMode: widgetData.compactMode !== undefined ? widgetData.compactMode : widgetMetadata.compactMode
  property string valueIconColor: widgetData.iconColor !== undefined ? widgetData.iconColor : widgetMetadata.iconColor
  property string valueTextColor: widgetData.textColor !== undefined ? widgetData.textColor : widgetMetadata.textColor
  property bool valueUseMonospaceFont: widgetData.useMonospaceFont !== undefined ? widgetData.useMonospaceFont : widgetMetadata.useMonospaceFont
  property bool valueUsePadding: widgetData.usePadding !== undefined ? widgetData.usePadding : widgetMetadata.usePadding
  property bool valueShowCpuUsage: widgetData.showCpuUsage !== undefined ? widgetData.showCpuUsage : widgetMetadata.showCpuUsage
  property bool valueShowCpuCores: widgetData.showCpuCores !== undefined ? widgetData.showCpuCores : widgetMetadata.showCpuCores
  property bool valueShowCpuFreq: widgetData.showCpuFreq !== undefined ? widgetData.showCpuFreq : widgetMetadata.showCpuFreq
  property bool valueShowCpuTemp: widgetData.showCpuTemp !== undefined ? widgetData.showCpuTemp : widgetMetadata.showCpuTemp
  property bool valueShowGpuTemp: widgetData.showGpuTemp !== undefined ? widgetData.showGpuTemp : widgetMetadata.showGpuTemp
  property bool valueShowGpuUsage: widgetData.showGpuUsage !== undefined ? widgetData.showGpuUsage : widgetMetadata.showGpuUsage
  property bool valueShowGpuVram: widgetData.showGpuVram !== undefined ? widgetData.showGpuVram : widgetMetadata.showGpuVram
  property bool valueShowLoadAverage: widgetData.showLoadAverage !== undefined ? widgetData.showLoadAverage : widgetMetadata.showLoadAverage
  property bool valueShowMemoryUsage: widgetData.showMemoryUsage !== undefined ? widgetData.showMemoryUsage : widgetMetadata.showMemoryUsage
  property bool valueShowMemoryAsPercent: widgetData.showMemoryAsPercent !== undefined ? widgetData.showMemoryAsPercent : widgetMetadata.showMemoryAsPercent
  property bool valueShowSwapUsage: widgetData.showSwapUsage !== undefined ? widgetData.showSwapUsage : widgetMetadata.showSwapUsage
  property bool valueShowNetworkStats: widgetData.showNetworkStats !== undefined ? widgetData.showNetworkStats : widgetMetadata.showNetworkStats
  property bool valueShowDiskUsage: widgetData.showDiskUsage !== undefined ? widgetData.showDiskUsage : widgetMetadata.showDiskUsage
  property bool valueShowDiskUsageAsPercent: widgetData.showDiskUsageAsPercent !== undefined ? widgetData.showDiskUsageAsPercent : widgetMetadata.showDiskUsageAsPercent
  property bool valueShowDiskAvailable: widgetData.showDiskAvailable !== undefined ? widgetData.showDiskAvailable : widgetMetadata.showDiskAvailable
  property string valueDiskPath: widgetData.diskPath !== undefined ? widgetData.diskPath : widgetMetadata.diskPath

  property bool valueTooltipShowCpuUsage: widgetData.tooltipShowCpuUsage !== undefined ? widgetData.tooltipShowCpuUsage : widgetMetadata.tooltipShowCpuUsage
  property bool valueTooltipShowCpuCores: widgetData.tooltipShowCpuCores !== undefined ? widgetData.tooltipShowCpuCores : widgetMetadata.tooltipShowCpuCores
  property bool valueTooltipShowCpuTemp: widgetData.tooltipShowCpuTemp !== undefined ? widgetData.tooltipShowCpuTemp : widgetMetadata.tooltipShowCpuTemp
  property bool valueTooltipShowGpuTemp: widgetData.tooltipShowGpuTemp !== undefined ? widgetData.tooltipShowGpuTemp : widgetMetadata.tooltipShowGpuTemp
  property bool valueTooltipShowGpuUsage: widgetData.tooltipShowGpuUsage !== undefined ? widgetData.tooltipShowGpuUsage : widgetMetadata.tooltipShowGpuUsage
  property bool valueTooltipShowGpuVram: widgetData.tooltipShowGpuVram !== undefined ? widgetData.tooltipShowGpuVram : widgetMetadata.tooltipShowGpuVram
  property bool valueTooltipShowLoadAverage: widgetData.tooltipShowLoadAverage !== undefined ? widgetData.tooltipShowLoadAverage : widgetMetadata.tooltipShowLoadAverage
  property bool valueTooltipShowMemory: widgetData.tooltipShowMemory !== undefined ? widgetData.tooltipShowMemory : widgetMetadata.tooltipShowMemory
  property bool valueTooltipShowSwap: widgetData.tooltipShowSwap !== undefined ? widgetData.tooltipShowSwap : widgetMetadata.tooltipShowSwap
  property bool valueTooltipShowNetwork: widgetData.tooltipShowNetwork !== undefined ? widgetData.tooltipShowNetwork : widgetMetadata.tooltipShowNetwork
  property bool valueTooltipShowDisk: widgetData.tooltipShowDisk !== undefined ? widgetData.tooltipShowDisk : widgetMetadata.tooltipShowDisk

  function saveSettings() {
    var settings = Object.assign({}, widgetData || {});
    settings.compactMode = valueCompactMode;
    settings.iconColor = valueIconColor;
    settings.textColor = valueTextColor;
    settings.useMonospaceFont = valueUseMonospaceFont;
    settings.usePadding = valueUsePadding;
    settings.showCpuUsage = valueShowCpuUsage;
    settings.showCpuCores = valueShowCpuCores;
    settings.showCpuFreq = valueShowCpuFreq;
    settings.showCpuTemp = valueShowCpuTemp;
    settings.showGpuTemp = valueShowGpuTemp;
    settings.showGpuUsage = valueShowGpuUsage;
    settings.showGpuVram = valueShowGpuVram;
    settings.showLoadAverage = valueShowLoadAverage;
    settings.showMemoryUsage = valueShowMemoryUsage;
    settings.showMemoryAsPercent = valueShowMemoryAsPercent;
    settings.showSwapUsage = valueShowSwapUsage;
    settings.showNetworkStats = valueShowNetworkStats;
    settings.showDiskUsage = valueShowDiskUsage;
    settings.showDiskUsageAsPercent = valueShowDiskUsageAsPercent;
    settings.showDiskAvailable = valueShowDiskAvailable;
    settings.diskPath = valueDiskPath;

    settings.tooltipShowCpuUsage = valueTooltipShowCpuUsage;
    settings.tooltipShowCpuCores = valueTooltipShowCpuCores;
    settings.tooltipShowCpuTemp = valueTooltipShowCpuTemp;
    settings.tooltipShowGpuTemp = valueTooltipShowGpuTemp;
    settings.tooltipShowGpuUsage = valueTooltipShowGpuUsage;
    settings.tooltipShowGpuVram = valueTooltipShowGpuVram;
    settings.tooltipShowLoadAverage = valueTooltipShowLoadAverage;
    settings.tooltipShowMemory = valueTooltipShowMemory;
    settings.tooltipShowSwap = valueTooltipShowSwap;
    settings.tooltipShowNetwork = valueTooltipShowNetwork;
    settings.tooltipShowDisk = valueTooltipShowDisk;

    settingsChanged(settings);
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.compact-mode-label")
    description: I18n.tr("bar.system-monitor.compact-mode-description")
    checked: valueCompactMode
    onToggled: checked => {
                 valueCompactMode = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.compactMode
  }

  NColorChoice {
    label: I18n.tr("common.select-icon-color")
    currentKey: valueIconColor
    onSelected: key => {
                  valueIconColor = key;
                  saveSettings();
                }
    defaultValue: widgetMetadata.iconColor
  }

  NColorChoice {
    currentKey: valueTextColor
    onSelected: key => {
                  valueTextColor = key;
                  saveSettings();
                }
    visible: !valueCompactMode
    defaultValue: widgetMetadata.textColor
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.use-monospace-font-label")
    description: I18n.tr("bar.system-monitor.use-monospace-font-description")
    checked: valueUseMonospaceFont
    onToggled: checked => {
                 valueUseMonospaceFont = checked;
                 saveSettings();
               }
    visible: !valueCompactMode
    defaultValue: widgetMetadata.useMonospaceFont
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.use-padding-label")
    description: isVerticalBar ? I18n.tr("bar.system-monitor.use-padding-description-disabled-vertical") : !valueUseMonospaceFont ? I18n.tr("bar.system-monitor.use-padding-description-disabled-monospace-font") : I18n.tr("bar.system-monitor.use-padding-description")
    checked: valueUsePadding && !isVerticalBar && valueUseMonospaceFont
    onToggled: checked => {
                 valueUsePadding = checked;
                 saveSettings();
               }
    visible: !valueCompactMode
    enabled: !isVerticalBar && valueUseMonospaceFont
    defaultValue: widgetMetadata.usePadding
  }

  NDivider {
    Layout.fillWidth: true
  }

  NToggle {
    id: showCpuUsage
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.cpu-usage-label")
    description: I18n.tr("bar.system-monitor.cpu-usage-description")
    checked: valueShowCpuUsage
    onToggled: checked => {
                 valueShowCpuUsage = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showCpuUsage
  }

  NToggle {
    id: showCpuCores
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.cpu-cores-label")
    description: I18n.tr("bar.system-monitor.cpu-cores-description")
    checked: valueShowCpuCores
    onToggled: checked => {
                 valueShowCpuCores = checked;
                 saveSettings();
               }
    visible: valueCompactMode
  }

  NToggle {
    id: showCpuFreq
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.cpu-frequency-label")
    description: I18n.tr("bar.system-monitor.cpu-frequency-description")
    checked: valueShowCpuFreq
    onToggled: checked => {
                 valueShowCpuFreq = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showCpuFreq
  }

  NToggle {
    id: showCpuTemp
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.cpu-temperature-label")
    description: I18n.tr("bar.system-monitor.cpu-temperature-description")
    checked: valueShowCpuTemp
    onToggled: checked => {
                 valueShowCpuTemp = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showCpuTemp
  }

  NToggle {
    id: showLoadAverage
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.load-average-label")
    description: I18n.tr("bar.system-monitor.load-average-description")
    checked: valueShowLoadAverage
    onToggled: checked => {
                 valueShowLoadAverage = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showLoadAverage
  }

  NToggle {
    id: showGpuTemp
    Layout.fillWidth: true
    label: I18n.tr("panels.system-monitor.gpu-section-label")
    description: I18n.tr("bar.system-monitor.gpu-temperature-description")
    checked: valueShowGpuTemp
    onToggled: checked => {
                 valueShowGpuTemp = checked;
                 saveSettings();
               }
    visible: SystemStatService.gpuAvailable
    defaultValue: widgetMetadata.showGpuTemp
  }

  NToggle {
    id: showGpuUsage
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.gpu-usage-label")
    description: I18n.tr("bar.system-monitor.gpu-usage-description")
    checked: valueShowGpuUsage
    onToggled: checked => {
                 valueShowGpuUsage = checked;
                 saveSettings();
               }
    visible: SystemStatService.gpuAvailable && SystemStatService.gpuUsageAvailable
    defaultValue: widgetMetadata.showGpuUsage
  }

  NToggle {
    id: showGpuVram
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.gpu-vram-label")
    description: I18n.tr("bar.system-monitor.gpu-vram-description")
    checked: valueShowGpuVram
    onToggled: checked => {
                 valueShowGpuVram = checked;
                 saveSettings();
               }
    visible: SystemStatService.gpuAvailable && SystemStatService.gpuVramAvailable
    defaultValue: widgetMetadata.showGpuVram
  }

  NToggle {
    id: showMemoryUsage
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.memory-usage-label")
    description: I18n.tr("bar.system-monitor.memory-usage-description")
    checked: valueShowMemoryUsage
    onToggled: checked => {
                 valueShowMemoryUsage = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showMemoryUsage
  }

  NToggle {
    id: showMemoryAsPercent
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.memory-percentage-label")
    description: I18n.tr("bar.system-monitor.memory-percentage-description")
    checked: valueShowMemoryAsPercent
    onToggled: checked => {
                 valueShowMemoryAsPercent = checked;
                 saveSettings();
               }
    visible: valueShowMemoryUsage
    defaultValue: widgetMetadata.showMemoryAsPercent
  }

  NToggle {
    id: showSwapUsage
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.swap-usage-label")
    description: I18n.tr("bar.system-monitor.swap-usage-description")
    checked: valueShowSwapUsage
    onToggled: checked => {
                 valueShowSwapUsage = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showSwapUsage
  }

  NToggle {
    id: showNetworkStats
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.network-traffic-label")
    description: I18n.tr("bar.system-monitor.network-traffic-description")
    checked: valueShowNetworkStats
    onToggled: checked => {
                 valueShowNetworkStats = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showNetworkStats
  }

  NDivider {
    Layout.fillWidth: true
  }

  NToggle {
    id: showDiskUsage
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.storage-usage-label")
    description: I18n.tr("bar.system-monitor.storage-usage-description")
    checked: valueShowDiskUsage
    onToggled: checked => {
                 valueShowDiskUsage = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showDiskUsage
  }

  NToggle {
    id: showDiskUsageAsPercent
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.storage-as-percentage-label")
    description: I18n.tr("bar.system-monitor.storage-as-percentage-description")
    checked: valueShowDiskUsageAsPercent
    onToggled: checked => {
                 valueShowDiskUsageAsPercent = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showDiskUsageAsPercent
  }

  NToggle {
    id: showDiskAvailable
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.storage-available-label")
    description: I18n.tr("bar.system-monitor.storage-available-description")
    checked: valueShowDiskAvailable
    onToggled: checked => {
                 valueShowDiskAvailable = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showDiskAvailable
  }

  NComboBox {
    id: diskPathComboBox
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.disk-path-label")
    description: I18n.tr("bar.system-monitor.disk-path-description")
    model: {
      const paths = Object.keys(SystemStatService.diskPercents).sort();
      return paths.map(path => ({
                                  key: path,
                                  name: path
                                }));
    }
    currentKey: valueDiskPath
    onSelected: key => {
                  valueDiskPath = key;
                  saveSettings();
                }
    defaultValue: widgetMetadata.diskPath
  }

  NDivider {
    Layout.fillWidth: true
  }

  NLabel {
    label: I18n.tr("bar.system-monitor.tooltip-section-label")
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-cpu-usage-label")
    description: I18n.tr("bar.system-monitor.tooltip-cpu-usage-description")
    checked: valueTooltipShowCpuUsage
    onToggled: checked => {
                 valueTooltipShowCpuUsage = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.tooltipShowCpuUsage
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-cpu-cores-label")
    description: I18n.tr("bar.system-monitor.tooltip-cpu-cores-description")
    checked: valueTooltipShowCpuCores
    onToggled: checked => {
                 valueTooltipShowCpuCores = checked;
                 saveSettings();
               }
    visible: valueTooltipShowCpuUsage
    defaultValue: widgetMetadata.tooltipShowCpuCores
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-cpu-temp-label")
    description: I18n.tr("bar.system-monitor.tooltip-cpu-temp-description")
    checked: valueTooltipShowCpuTemp
    onToggled: checked => {
                 valueTooltipShowCpuTemp = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.tooltipShowCpuTemp
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-gpu-temp-label")
    description: I18n.tr("bar.system-monitor.tooltip-gpu-temp-description")
    checked: valueTooltipShowGpuTemp
    onToggled: checked => {
                 valueTooltipShowGpuTemp = checked;
                 saveSettings();
               }
    visible: SystemStatService.gpuAvailable
    defaultValue: widgetMetadata.tooltipShowGpuTemp
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-gpu-usage-label")
    description: I18n.tr("bar.system-monitor.tooltip-gpu-usage-description")
    checked: valueTooltipShowGpuUsage
    onToggled: checked => {
                 valueTooltipShowGpuUsage = checked;
                 saveSettings();
               }
    visible: SystemStatService.gpuAvailable && SystemStatService.gpuUsageAvailable
    defaultValue: widgetMetadata.tooltipShowGpuUsage
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-gpu-vram-label")
    description: I18n.tr("bar.system-monitor.tooltip-gpu-vram-description")
    checked: valueTooltipShowGpuVram
    onToggled: checked => {
                 valueTooltipShowGpuVram = checked;
                 saveSettings();
               }
    visible: SystemStatService.gpuAvailable && SystemStatService.gpuVramAvailable
    defaultValue: widgetMetadata.tooltipShowGpuVram
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-load-average-label")
    description: I18n.tr("bar.system-monitor.tooltip-load-average-description")
    checked: valueTooltipShowLoadAverage
    onToggled: checked => {
                 valueTooltipShowLoadAverage = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.tooltipShowLoadAverage
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-memory-label")
    description: I18n.tr("bar.system-monitor.tooltip-memory-description")
    checked: valueTooltipShowMemory
    onToggled: checked => {
                 valueTooltipShowMemory = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.tooltipShowMemory
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-swap-label")
    description: I18n.tr("bar.system-monitor.tooltip-swap-description")
    checked: valueTooltipShowSwap
    onToggled: checked => {
                 valueTooltipShowSwap = checked;
                 saveSettings();
               }
    visible: SystemStatService.swapTotalGb > 0
    defaultValue: widgetMetadata.tooltipShowSwap
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-network-label")
    description: I18n.tr("bar.system-monitor.tooltip-network-description")
    checked: valueTooltipShowNetwork
    onToggled: checked => {
                 valueTooltipShowNetwork = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.tooltipShowNetwork
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.system-monitor.tooltip-disk-label")
    description: I18n.tr("bar.system-monitor.tooltip-disk-description")
    checked: valueTooltipShowDisk
    onToggled: checked => {
                 valueTooltipShowDisk = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.tooltipShowDisk
  }
}
