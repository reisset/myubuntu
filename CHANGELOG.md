# Changelog

All notable changes to myubuntu will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- **Orchis-Purple-Dark shell theme** - Differentiates from Omakub with polished r/unixporn aesthetic
- **Extension retry logic** - 2 download attempts per extension with proper error handling
- **Theme switcher (planned)** - Future Omakub-style theme switching between Orchis, Graphite, Marble

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
  - Removed Tokyo Night GTK theme download (variant didn't exist in upstream repo)
- **Documentation** - Updated CLAUDE.md to reflect new theming approach

### Fixed
- **Extension installation failures** - All 7 extensions now install correctly (was 0/7, now 7/7)
- **Tokyo Night theme not found** - Replaced with working Yaru-purple + Orchis combination

### Removed
- `install/theming/download-theme.sh` - No longer needed with Yaru built-in themes
- Flatpak/Extension Manager installation - Simplified to CLI-only approach
- Papirus icon theme dependency - Using built-in Yaru-purple instead

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

[0.2.0]: https://github.com/reisset/myubuntu/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/reisset/myubuntu/releases/tag/v0.1.0
