# Changelog

All notable changes to myubuntu will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### 🔮 Future Plans
- **Theme switcher** - Omakub-style theme switching between Orchis, Graphite, Marble shell themes
- Webapp pinning to dock
- Ulauncher extensions bundling
- Additional GNOME extensions (optional)
- Cross-machine config sync workflow

## [0.4.0] - 2026-01-11

### Added
- **myubuntu CLI tool** - New command-line interface with health check and shortcuts reference
  - `myubuntu doctor` - Comprehensive system health check (extensions, themes, shortcuts, fonts)
  - `myubuntu keys` - Keyboard shortcuts cheatsheet
  - Symlinked to `~/.local/bin/myubuntu` for easy access
- **Fonts component** - JetBrains Mono Nerd Font global installation
  - Installs font system-wide (available in VS Code, terminal, all apps)
  - Complements mybash's Kitty-specific font installation
- **Super+Q shortcut** - Close windows with Super+Q (macOS Cmd+Q muscle memory)

### Changed
- **Simplified installers** - Removed all CLI flags for cleaner, straightforward usage
  - `./install.sh` now just installs everything (no --only, --skip, --dry-run, --no-confirm)
  - `./uninstall.sh` now fully uninstalls including packages (no --remove-packages flag)
  - Reduced install.sh by ~100 lines of argument parsing code
  - Philosophy: "Either you're installing or you're not" - keep it simple

### Removed
- **CLI flags** - Removed --only=, --skip=, --dry-run, --no-confirm from install.sh
- **--remove-packages flag** - Uninstaller now always removes packages (Ulauncher, themes, fonts)

## [0.3.3] - 2026-01-10

### Changed
- **Cleaner banners** - Removed version numbers from install.sh and uninstall.sh banners
  - Banners now display just "myubuntu" and "myubuntu - Uninstaller" without version
  - Fixed centering alignment in uninstall.sh banner
  - Help text (`--help`) also updated to remove version numbers
  - Provides cleaner, less cluttered terminal output
- **Ulauncher prompt clarification** - Changed "Reinstall/reconfigure" to "Install/configure"
  - More accurate wording when Ulauncher is already installed
  - Avoids confusion about what the prompt does

## [0.3.2] - 2026-01-10

### Changed
- **Enhanced installer UX** - Polished intro and completion banners with Unicode box styling
  - Added CYAN color to helpers.sh for banner styling
  - Updated install.sh banners with cyan-colored Unicode boxes
  - Updated uninstall.sh banners to match new style
  - Green completion boxes with checkmark (✓) for success feedback
  - More professional and visually appealing terminal output

## [0.3.1] - 2026-01-10

### Fixed
- **CRITICAL: Uninstaller freeze/crash** - Fixed rapid-fire extension operations overwhelming GNOME Shell
  - Added 0.5s delays between extension enable operations in uninstaller
  - Added 0.3s delays between extension disable operations
  - Added warning message before extension changes
  - Prevents GNOME Shell crash and session restart (appeared as "reboot")
- **Installer extension delays** - Added 0.3s delays between all extension operations in installer
  - Prevents same freeze issue during installation
  - Improves stability when enabling/disabling extensions
- **Broken dock icons** - Fixed favorites list to only include installed applications
  - Added desktop file validation before pinning apps to dock
  - Warns about skipped apps (e.g., "Skipping spotify.desktop (not installed)")
  - No more empty/broken dock icons
- **Backup overwrites on re-install** - Fixed shortcuts installer preserving original backups
  - Checks if backups exist before creating new ones
  - Prevents myubuntu settings from replacing original system backups
  - Uninstall now correctly restores original Ubuntu settings
- **Stale theme references** - Fixed uninstaller referencing old "Tokyonight-Dark-BL" theme
  - Updated to "Orchis-Purple-Dark" to match current installer
  - Fixed help text and cleanup operations
- **Orchis shell theme not applying** - Fixed theming/install.sh to use `dconf write` instead of `safe_gsettings` for extension schemas
  - Extension schemas are not in system gsettings, causing silent failure
  - Now writes directly to `/org/gnome/shell/extensions/user-theme/name`
  - Theme now applies correctly after installation
- **Keyboard shortcut conflict** - Super+1,2,3... now exclusively launches pinned apps (no workspace switching)
  - Space Bar extension's workspace shortcuts (`enable-activate-workspace-shortcuts`) disabled by default
  - Eliminates conflict between pinned app launching and workspace switching
  - Added explicit `switch-to-application-1` through `-5` shortcuts in shell-keybindings.conf

### Added
- **Dependency checking** - Added `check_dependency()` helper function to helpers.sh
  - Extensions installer now checks for curl and python3
  - Theming installer now checks for git (graceful fallback if missing)
  - Clear error messages with installation instructions
- **Desktop file validation** - Added `desktop_file_exists()` function to qol installer
  - Checks common locations (/usr/share, .local, snap, flatpak)
  - Dynamically builds dock favorites based on installed apps
- **Workspace switching shortcuts** - Ctrl+Alt+1-4 for direct workspace navigation
  - Provides dedicated workspace shortcuts without conflicts
  - Configured in wm-keybindings.conf
  - Space Bar still provides visual indicators and click navigation

### Changed
- **Version sync** - Updated installer and uninstaller versions to 0.3.1
  - Both scripts now report consistent version numbers
  - Improves user experience and version tracking
- **Shortcut configuration** - Made pinned app shortcuts explicit rather than relying on GNOME defaults
  - shell-keybindings.conf now explicitly defines Super+1-5 for apps
  - wm-keybindings.conf now includes Ctrl+Alt+1-4 for workspaces

## [0.3.0] - 2026-01-10

### Added
- **Orchis-Purple-Dark shell theme** - Polished r/unixporn aesthetic, differentiates from Omakub
- **Extension retry logic** - 2 download attempts per extension with proper error handling
- **sassc pre-installation** - Prevents interactive prompts during Orchis theme installation

### Changed
- **Extension downloads** - Fixed API URL format, now queries extension-info endpoint first
  - Removed flatpak dependency entirely (uses gnome-extensions CLI only)
  - Uses Python3 for JSON parsing (guaranteed on Ubuntu)
  - Manual install instructions now reference gnome-extensions-app (built-in)
- **Theming overhaul** - Switched from Tokyo Night to Yaru + Orchis
  - GTK theme: Yaru-purple-dark (built into Ubuntu, no download needed)
  - Icon theme: Yaru-purple (built into Ubuntu, replaces Papirus)
  - Shell theme: Orchis-Purple-Dark (downloaded from vinceliuice/Orchis-theme)
  - Accent color: Purple (matches Omakub Tokyo Night aesthetic)
  - Cursor theme: Yaru
- **User Themes detection** - Now uses `--enabled` flag to correctly detect active extensions
- **Installation flow** - Ulauncher no longer starts during install, only on next login
- **Post-install messaging** - Clearer explanation of what activates after logout/login

### Fixed
- **Ulauncher focus steal** - Removed daemon start during installation to prevent focus stealing from terminal
- **Interactive sassc prompt** - Pre-installs sassc with `-y` flag before Orchis installer runs
- **Extension installation failures** - All 7 extensions now install correctly (was 0/7, now 7/7)
- **Shell theme not applying** - Fixed User Themes extension detection to check enabled status
- **Tokyo Night theme not found** - Replaced with working Yaru-purple + Orchis combination

### Removed
- `install/theming/download-theme.sh` - No longer needed with Yaru built-in themes
- Flatpak/Extension Manager installation - Simplified to CLI-only approach
- Papirus icon theme dependency - Using built-in Yaru-purple instead
- Ulauncher daemon start during installation - Now only starts on login via autostart

## [0.2.0] - 2026-01-10

### Added
- **Extensions component** - GNOME Shell extensions installer
  - User Themes extension (required for shell theming)
  - Blur my Shell (blur effects on overview/panel)
  - AppIndicator (system tray support)
  - Extension Manager flatpak for GUI management
- **Tokyo Night theme** - Full GTK + Shell theming
  - Download script for Tokyo Night from GitHub
  - Tokyonight-Dark-BL variant (borderless)
  - Shell theme support (requires User Themes extension)

### Changed
- Theming component now installs Tokyo Night GTK theme
- Component install order: shortcuts → extensions → ulauncher → theming → qol
- Help text updated with extensions description

## [0.1.0] - 2026-01-10

### Added
- Initial MVP release
- Modular installer with `--all`, `--only`, `--skip`, `--dry-run` flags
- **Shortcuts component** - Keyboard shortcuts via dconf
  - Super+Space for Ulauncher
  - Export utility for backing up shortcuts
- **Ulauncher component** - Application launcher
  - Wayland support (wmctrl)
  - File preview support (gnome-sushi)
  - Auto-start on login
- **Theming component** - Basic theming
  - System-wide dark mode
  - Papirus-Dark icon theme
  - Custom wallpaper support
  - Blue accent color
- **QoL component** - Quality of life tweaks
  - Auto-hide dock (Omakub-style)
  - 5 pinned apps (Brave, Code, Spotify, Files, Obsidian)
  - Night light enabled
  - Nautilus list view
  - Battery percentage
- Project structure and helper scripts
- Backup system for dconf settings
- Installation manifest generation

[0.3.0]: https://github.com/reisset/myubuntu/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/reisset/myubuntu/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/reisset/myubuntu/releases/tag/v0.1.0
