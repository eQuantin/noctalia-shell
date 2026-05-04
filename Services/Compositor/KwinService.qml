import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.WindowManager
import qs.Commons

// KWin (KDE Plasma Wayland) backend.
// Reuses ext-workspace-v1 + wlr-foreign-toplevel for workspace/window state,
// overrides session/monitor/keyboard/scale helpers with KDE-native D-Bus/CLI.
Item {
  id: root

  property ListModel workspaces: ListModel {}
  property var windows: []
  property int focusedWindowIndex: -1
  property var trackedToplevels: new Set()

  property bool globalWorkspaces: false

  property var nativeWorkspaceMap: ({})
  property var connectedWorkspaces: ({})

  signal workspaceChanged
  signal activeWindowChanged
  signal windowListChanged
  signal displayScalesChanged

  function initialize() {
    updateWindows();
    connectWorkspaceSignals();
    syncWorkspaces();
    queryDisplayScales();
    Logger.i("KwinService", "Service started (KWin via ext-workspace-v1)");
  }

  Connections {
    target: WindowManager

    function onWindowsetsChanged() {
      root.connectWorkspaceSignals();
      Qt.callLater(root.syncWorkspaces);
    }

    function onWindowsetProjectionsChanged() {
      Qt.callLater(root.syncWorkspaces);
    }
  }

  Timer {
    interval: 500
    running: true
    repeat: false
    onTriggered: {
      if (WindowManager.windowsets.length > 0) {
        root.connectWorkspaceSignals();
        root.syncWorkspaces();
      }
    }
  }

  function connectWorkspaceSignals() {
    const nativeWs = WindowManager.windowsets;
    const newConnected = {};

    for (const ws of nativeWs) {
      const key = ws.id || ws.toString();
      newConnected[key] = true;

      if (connectedWorkspaces[key])
        continue;

      ws.activeChanged.connect(() => {
                                 Qt.callLater(root.syncWorkspaces);
                               });

      ws.urgentChanged.connect(() => {
                                 Qt.callLater(root.syncWorkspaces);
                               });

      ws.shouldDisplayChanged.connect(() => {
                                        Qt.callLater(root.syncWorkspaces);
                                      });

      ws.nameChanged.connect(() => {
                               Qt.callLater(root.syncWorkspaces);
                             });
    }

    connectedWorkspaces = newConnected;
  }

  function syncWorkspaces() {
    const nativeWs = WindowManager.windowsets;

    workspaces.clear();
    nativeWorkspaceMap = {};

    const perOutputNextIdx = {};

    for (const ws of nativeWs) {
      if (!ws.shouldDisplay) {
        continue;
      }

      let outputName = "";
      if (ws.projection) {
        const projScreens = ws.projection.screens;
        if (projScreens && projScreens.length > 0) {
          outputName = projScreens[0].name || "";
        }
      }

      const groupKey = outputName || "_";
      let idx;
      const numericName = ws.name && /^\d+$/.test(String(ws.name)) ? parseInt(ws.name, 10) : NaN;
      if (!isNaN(numericName) && numericName >= 1) {
        idx = numericName;
      } else {
        if (perOutputNextIdx[groupKey] === undefined) {
          perOutputNextIdx[groupKey] = 1;
        }
        idx = perOutputNextIdx[groupKey]++;
      }

      const wsEntry = {
        "id": ws.id || idx.toString(),
        "idx": idx,
        "name": ws.name || ("Workspace " + idx),
        "output": outputName,
        "isFocused": ws.active,
        "isActive": true,
        "isUrgent": ws.urgent,
        "isOccupied": false,
        "oid": ws.id || idx.toString()
      };

      workspaces.append(wsEntry);
      nativeWorkspaceMap[wsEntry.id] = ws;
    }

    updateWindowWorkspaces();
    workspaceChanged();
  }

  function updateWindowWorkspaces() {
    let activeId = "";
    for (let i = 0; i < workspaces.count; i++) {
      const ws = workspaces.get(i);
      if (ws.isFocused) {
        activeId = ws.id;
        break;
      }
    }

    for (let i = 0; i < windows.length; i++) {
      if (activeId) {
        windows[i].workspaceId = activeId;
      }
    }
    windowListChanged();
  }

  Connections {
    target: ToplevelManager.toplevels
    function onValuesChanged() {
      updateWindows();
    }
  }

  function connectToToplevel(toplevel) {
    if (!toplevel)
      return;

    toplevel.activatedChanged.connect(() => {
                                        Qt.callLater(onToplevelActivationChanged);
                                      });

    toplevel.titleChanged.connect(() => {
                                    Qt.callLater(updateWindows);
                                  });
  }

  function onToplevelActivationChanged() {
    updateWindows();
    activeWindowChanged();
  }

  function updateWindows() {
    const newWindows = [];
    const toplevels = ToplevelManager.toplevels?.values || [];

    let focusedIdx = -1;
    let idx = 0;

    let activeId = "";
    for (let i = 0; i < workspaces.count; i++) {
      const ws = workspaces.get(i);
      if (ws.isFocused) {
        activeId = ws.id;
        break;
      }
    }

    for (const toplevel of toplevels) {
      if (!toplevel)
        continue;

      if (!trackedToplevels.has(toplevel)) {
        connectToToplevel(toplevel);
        trackedToplevels.add(toplevel);
      }

      const output = (toplevel.screens && toplevel.screens.length > 0) ? (toplevel.screens[0].name || "") : "";

      const windowId = (toplevel.appId || "") + ":" + idx;

      newWindows.push({
                        "id": windowId,
                        "appId": toplevel.appId || "",
                        "title": toplevel.title || "",
                        "output": output,
                        "workspaceId": activeId || "1",
                        "isFocused": toplevel.activated || false,
                        "toplevel": toplevel
                      });

      if (toplevel.activated) {
        focusedIdx = idx;
      }
      idx++;
    }
    windows = newWindows;
    focusedWindowIndex = focusedIdx;

    windowListChanged();
  }

  function focusWindow(window) {
    if (window.toplevel && typeof window.toplevel.activate === "function") {
      window.toplevel.activate();
    }
  }

  function closeWindow(window) {
    if (window.toplevel && typeof window.toplevel.close === "function") {
      window.toplevel.close();
    }
  }

  function switchToWorkspace(workspace) {
    const nativeWs = nativeWorkspaceMap[workspace.id] || nativeWorkspaceMap[workspace.oid];
    if (nativeWs && nativeWs.canActivate) {
      nativeWs.activate();
    } else {
      Logger.w("KwinService", "Cannot activate workspace: " + (workspace.name || workspace.id));
    }
  }

  // KWin DPMS via universal wlopm, then KDE-specific kscreen-doctor, then wlroots fallback.
  function turnOffMonitors() {
    try {
      Quickshell.execDetached(["sh", "-c", "wlopm --off '*' 2>/dev/null || kscreen-doctor --dpms off 2>/dev/null || wlr-randr --off"]);
    } catch (e) {
      Logger.e("KwinService", "Failed to turn off monitors:", e);
    }
  }

  function turnOnMonitors() {
    try {
      Quickshell.execDetached(["sh", "-c", "wlopm --on '*' 2>/dev/null || kscreen-doctor --dpms on 2>/dev/null || wlr-randr --on"]);
    } catch (e) {
      Logger.e("KwinService", "Failed to turn on monitors:", e);
    }
  }

  // Primary: ask the systemd user manager to exit cleanly. This cascades through
  // the dependency graph: plasma-workspace.target stops, kwin_wayland exits 0,
  // startplasma-wayland exits 0, sddm-helper exits 0, and SDDM then respawns the
  // greeter. `loginctl terminate-session` is a nuclear SIGTERM that leaves
  // sddm-helper exiting non-zero, which SDDM treats as a crash and refuses to
  // respawn the greeter — the exact failure mode we saw in journal -b -1.
  // LogoutPrompt is intentionally not used — Noctalia already runs its own countdown.
  function logout() {
    try {
      Quickshell.execDetached(["sh", "-c", "systemctl --user exit 2>/dev/null " + "|| qdbus6 org.kde.Shutdown /Shutdown logout 2>/dev/null " + "|| qdbus-qt6 org.kde.Shutdown /Shutdown logout 2>/dev/null " + "|| qdbus org.kde.ksmserver /KSMServer logout 0 0 0 2>/dev/null " + "|| loginctl terminate-session \"$XDG_SESSION_ID\""]);
    } catch (e) {
      Logger.e("KwinService", "Failed to logout:", e);
    }
  }

  function cycleKeyboardLayout() {
    try {
      Quickshell.execDetached(["sh", "-c", "qdbus6 org.kde.keyboard /Layouts org.kde.KeyboardLayouts.switchToNextLayout 2>/dev/null " + "|| qdbus-qt6 org.kde.keyboard /Layouts org.kde.KeyboardLayouts.switchToNextLayout"]);
    } catch (e) {
      Logger.e("KwinService", "Failed to cycle keyboard layout:", e);
    }
  }

  Process {
    id: kscreenDoctorProcess
    running: false
    command: ["kscreen-doctor", "--json"]

    property string accumulatedOutput: ""

    stdout: SplitParser {
      onRead: function (line) {
        kscreenDoctorProcess.accumulatedOutput += line;
      }
    }

    onExited: function (exitCode) {
      const raw = accumulatedOutput;
      accumulatedOutput = "";
      if (exitCode !== 0 || !raw) {
        Logger.d("KwinService", "kscreen-doctor unavailable or returned no data; leaving display scales at defaults");
        return;
      }
      try {
        const data = JSON.parse(raw);
        const outputs = (data && data.outputs) || [];
        const scales = {};
        for (const o of outputs) {
          if (!o || o.enabled === false || !o.name)
            continue;
          // libkscreen exposes modes in `modes[]` and references the active one
          // via `currentModeId`; older schemas embedded it as `currentMode` / `mode`.
          let size = {};
          if (o.currentModeId && Array.isArray(o.modes)) {
            const m = o.modes.find(x => x && x.id === o.currentModeId);
            if (m && m.size)
              size = m.size;
          }
          if (!size.width && (o.currentMode || o.mode)) {
            size = (o.currentMode || o.mode).size || {};
          }
          scales[o.name] = {
            "name": o.name,
            "scale": (typeof o.scale === "number") ? o.scale : 1.0,
            "width": size.width || 0,
            "height": size.height || 0
          };
        }
        if (Object.keys(scales).length > 0) {
          if (CompositorService && CompositorService.onDisplayScalesUpdated) {
            CompositorService.onDisplayScalesUpdated(scales);
          }
          displayScalesChanged();
        }
      } catch (e) {
        Logger.w("KwinService", "Failed to parse kscreen-doctor --json output:", e);
      }
    }
  }

  function queryDisplayScales() {
    kscreenDoctorProcess.accumulatedOutput = "";
    kscreenDoctorProcess.running = true;
  }

  function getFocusedScreen() {
    const toplevels = ToplevelManager.toplevels?.values || [];
    for (const t of toplevels) {
      if (t && t.activated && t.screens && t.screens.length > 0) {
        const name = t.screens[0].name;
        for (let i = 0; i < Quickshell.screens.length; i++) {
          if (Quickshell.screens[i].name === name) {
            return Quickshell.screens[i];
          }
        }
      }
    }
    return null;
  }
}
