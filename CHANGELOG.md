# Changelog

All notable changes to myubuntu will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- **Uninstall script** (`uninstall.sh`) - Revert myubuntu customizations
  - Restores settings from backups when available
  - Resets all settings to Ubuntu defaults
  - Supports `--only`, `--skip`, `--dry-run` flags (same as installer)
  - Optional package removal with `--remove-packages`
  - Disables GNOME extensions (doesn't remove them)

### Fixed
- **Ulauncher positioning issue** - Ulauncher now starts as daemon immediately after install, fixing centering issues on Wayland
- **Wallpaper not applied** - Fixed theming script exiting early when accent-color setting failed (Ubuntu 24.04 doesn't have this key). Added `|| true` to allow script to continue to wallpaper section.
- **Theme download script** - Changed from `bash` to `source` to fix return statement errors, added graceful failure handling

### Known Issues
- Tokyo Night theme download fails - "Tokyonight-Dark-BL" variant not found in upstream repository. Theme installation is skipped gracefully.

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
