# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Noctalia is a Wayland desktop shell written in QML and run by [Quickshell](https://quickshell.outfoxxed.me/). The entry point is `shell.qml`; there is no compiled binary — Quickshell loads the QML tree at runtime. Native support targets Niri, Hyprland, Sway, Scroll, Labwc and MangoWC.

## Commands

Noctalia has no build step for normal development — edits to `.qml` files are picked up on Quickshell reload.

- Run the shell locally: `qs -p shell.qml` (point `QS_CONFIG_PATH` at the repo root, or run from it). Set `NOCTALIA_DEBUG=1` to enable verbose logging and regeneration of `Assets/settings-default.json` on start (see `Commons/Settings.qml`).
- Format QML (also run by the pre-commit hook): `./Scripts/dev/qmlfmt.sh`. Uses `qmlformat` with width=2, max-line=360; auto-detects Qt ≥6.10 for the `--semicolon-rule` flag. Requires `qt6-declarative-tools` (or `kdePackages.qtdeclarative`).
- Rebuild the settings search index (also run by the pre-commit hook): `python3 Scripts/dev/build-settings-search-index.py` — parses `Modules/Panels/Settings/Tabs/**/*.qml` and writes `Assets/settings-search-index.json`. The index must be committed; CI and the hook keep it in sync.
- Compile fragment shaders: `./Scripts/dev/shaders-compile.sh [file.frag]` — reads `Shaders/frag/`, writes `Shaders/qsb/`, requires `qsb` from Qt6.
- Nix: `nix build .` (produces `noctalia-shell` wrapper), `nix develop` (dev shell with `quickshell`, `kdePackages.qtdeclarative`, `lefthook`, linters/formatters for nix/shell/json).
- Install git hooks: `lefthook install` (config in `lefthook.yml`). The pre-commit job runs `qmlfmt.sh` and rebuilds the search index, then `git update-index --again` / `git add` so formatted files and the regenerated index stay in the commit.
- i18n: `Scripts/dev/i18n-pull.sh` / `i18n-push.sh` sync translation strings (stored in `Assets/Translations/`).

There is no test suite; verification is manual (reload Quickshell and exercise the feature).

## Architecture

### Runtime shape
`shell.qml` is the `ShellRoot`. It waits on three gates — `I18n`, `Settings`, and `ShellState` — before instantiating the UI tree via a `Loader`. Once gated, it initialises **critical services synchronously** (wallpaper, image cache, theming/dark-mode) and defers the rest via `Qt.callLater` (location, idle, power, hooks, IPC, etc.). A 1.5s timer runs `HooksService`/`FontService`/`UpdateService` and shows the setup wizard, telemetry wizard, or changelog. Plugins are registered very early via `PluginRegistry.init()` so Settings can validate plugin-owned widgets.

### Directory layout (top-level)
- `Commons/` — shared QML singletons: `Settings.qml` (JSON-backed user config with versioned migrations), `ShellState.qml`, `I18n.qml`, `Style.qml`, `Logger.qml`, `Color.qml`, `Icons*.qml`, and `Commons/Migrations/` (one `MigrationN.qml` per settings version, registered in `MigrationRegistry.qml`).
- `Modules/` — user-visible UI: `Bar/` (status bar with per-widget modules in `Bar/Widgets/`), `Panels/` (Launcher, ControlCenter, Settings, Wallpaper, SetupWizard, etc.), `LockScreen/`, `Dock/`, `DesktopWidgets/`, `Notification/`, `OSD/`, `Toast/`, `Background/`, `MainScreen/`, `Cards/`, `Tooltip/`.
- `Services/` — non-UI singletons, grouped by domain: `Compositor/` (one service per supported WM: Niri, Hyprland, Sway, Labwc, Mango + `CompositorService` dispatcher), `Hardware/`, `Keyboard/`, `Location/`, `Media/`, `Networking/`, `Power/`, `System/`, `Theming/` (`AppThemeService`, `ColorSchemeService`, `TemplateProcessor`, `TemplateRegistry`), `UI/` (panel/widget registries, `WallpaperService`, `ImageCacheService`, `SettingsSearchService`, `ToastService`), `Noctalia/` (`PluginRegistry`, `PluginService`, `UpdateService`, `TelemetryService`, `GitHubService`, `SupporterService`), `Control/` (`IPCService`, `HooksService`, `CurrentScreenDetector`, `CustomButtonIPCService`).
- `Widgets/` — reusable QML controls prefixed `N…` (e.g. `NButton.qml`, `NToggle.qml`, `NValueSlider.qml`). These are the building blocks used throughout Modules and the Settings panel; new UI should reuse them before introducing bespoke controls.
- `Helpers/` — plain JavaScript utilities (`ColorsConvert.js`, `FuzzySort.qml`, `sha256.js`, `QtObj2JS.js`, `AdvancedMath.js`, `Debug.js`).
- `Assets/` — runtime data: default settings (`settings-default.json`, `settings-widgets-default.json`), generated search index (`settings-search-index.json`), fonts, icons, sounds, wallpapers, translations, color schemes, templates (for app theming).
- `Shaders/frag/` → `Shaders/qsb/` — GLSL fragment shaders compiled to Qt Shader Bakery files.
- `Scripts/` — `dev/` (formatting, index build, shader compile, i18n, notification-test helpers), `bash/template-apply.sh`, `python/src/{calendar,network,theming}` (helper programs invoked from QML, e.g. the optional calendar integration via Evolution Data Server).
- `nix/` — Nix packaging (`package.nix`, `home-module.nix`, `nixos-module.nix`, dev `shell.nix`). `flake.nix` pins `noctalia-qs` (a companion repo that builds the Quickshell runtime used to run this shell).

### Settings and migrations
`Commons/Settings.qml` owns `~/.config/noctalia/settings.json` (overridable via `NOCTALIA_CONFIG_DIR` / `NOCTALIA_SETTINGS_FILE`) using a Quickshell `FileView` with an `adapter` for typed access (`Settings.data.xxx`). The current schema version is `settingsVersion` in that file. **When you add or rename a settings field that requires transforming existing user data, bump `settingsVersion`, add `Commons/Migrations/MigrationN.qml`, register it in `MigrationRegistry.qml`, and update `Assets/settings-default.json`.** Saves are debounced by 500 ms; external file changes (including atomic replacement under declarative setups) are debounced by 200 ms via `scheduleExternalReload`.

### Settings panel ↔ search index
The Settings UI lives in `Modules/Panels/Settings/Tabs/**`. `Scripts/dev/build-settings-search-index.py` scans those tabs for specific widget types (`NToggle`, `NComboBox`, `NValueSlider`, `NSpinBox`, `NSearchableComboBox`, `NTextInputButton`, `NTextInput`, `NCheckbox`, `NLabel`, `NColorChoice`, `HookRow`) and emits `Assets/settings-search-index.json`, consumed at runtime by `Services/UI/SettingsSearchService.qml`. The pre-commit hook regenerates and stages this file; keep it committed.

### Compositor abstraction
`Services/Compositor/CompositorService.qml` dispatches to one of the per-WM services (`NiriService`, `HyprlandService`, `SwayService`, `LabwcService`, `MangoService`) based on the detected environment. Code that touches workspaces, window lists, or IPC should go through `CompositorService`, not a specific implementation — anything compositor-specific belongs in the dedicated file.

### Plugins
The plugin system (`Services/Noctalia/PluginRegistry.qml`, `PluginService.qml`) loads third-party widgets into `Modules/Panels/Plugins/` and the hidden `pluginContainer` `Item` in `shell.qml` (plugins with graphics need a parent in the scene graph). Plugin-contributed bar widgets, panels, desktop widgets and launcher providers register through the `*Registry` singletons in `Services/UI/`. Project scope (see README) is deliberately narrow — features that don't belong in the core shell should be implemented as plugins.

### Theming
`Services/Theming/ColorSchemeService` selects a palette from `Assets/ColorScheme/`, and `AppThemeService` + `TemplateProcessor` + `TemplateRegistry` apply that palette to external application config files via templates under `Assets/Templates/`. `Commons/Style.qml` exposes palette tokens to QML; prefer those over literal colors.

### IPC and external integration
`IPCService` (exposed via Quickshell's IPC) is the entry point for command-line control (`qs ipc call …`). `CustomButtonIPCService` and `HooksService` let users bind external commands; notifications, power profile, idle inhibit, night light, GitHub, telemetry, and updates each have dedicated services under `Services/`.

## Conventions

- QML formatting is enforced by `qmlfmt.sh` (2-space indent, soft limit 360). Run it (or let the pre-commit hook run it) before committing.
- Reusable UI goes under `Widgets/` with the `N` prefix; feature-specific UI lives under `Modules/…`.
- Non-UI logic lives in `Services/` as singletons; favour initialising them from `shell.qml` (critical vs deferred) rather than on first use.
- Keep Services/Compositor implementations isolated — only `CompositorService` should know which WM is active.
- Bar widgets go in `Modules/Bar/Widgets/` and register with `Services/UI/BarWidgetRegistry.qml`.
- CI: `.github/workflows/cachix.yml` does `nix build .` on every push to `main`; `update-flake.yml` auto-updates `flake.lock`; `release.yml` cuts releases; `update-aur-package.yml` syncs the AUR package.
