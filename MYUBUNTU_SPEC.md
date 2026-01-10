# myubuntu - Project Specification

**Version:** MVP 0.1.0  
**Author:** reisset  
**Date:** January 2026

## Vision

A lightweight, modular Ubuntu bootstrap script that applies personal customizations to a fresh Ubuntu install. Inspired by Omakub's polish but built lean—no apps I don't use, no configs that fight my existing tooling.

This is the third piece of my personal Linux toolkit:
- **mybash** → Terminal environment (Starship, modern CLI tools, Kitty config)
- **myscreensavers** → Idle-time ASCII art screensavers
- **myubuntu** → Desktop environment (GNOME theming, shortcuts, Ulauncher, quality-of-life tweaks)

## Goals

1. **One-command fresh install enhancement** — Run a single script after Ubuntu install to apply all customizations
2. **Modular architecture** — Each component (theming, shortcuts, apps) is independent and can be skipped
3. **Cross-machine consistency** — Works identically on laptop, desktop, MacBook-with-Ubuntu
4. **Complement existing tools** — Does NOT touch terminal configs (mybash handles that)
5. **Transparent and learnable** — Simple shell scripts, no magic, easy to understand and modify

## Non-Goals

- No terminal emulator configs (mybash owns this)
- No development environment setup (IDE, languages, etc.)
- No app-specific theming coordination (Omakub's complexity for diminishing returns)
- No Neovim/Zed/VSCode configuration
- No browser installation or config

## Target Environment

- Ubuntu 24.04 LTS and newer
- GNOME desktop (default Ubuntu session)
- Fresh install assumed, but should be idempotent (safe to re-run)

---

## Components

### 1. GNOME Theming (`install/theming/`)

**What it does:**
- Install and apply a shell theme (Tokyo Night or similar dark theme)
- Set icon theme (Papirus or similar)
- Set cursor theme
- Configure accent color
- Enable dark mode system-wide

**Key files:**
```
install/theming/
├── install.sh          # Main theming installer
├── themes/             # Bundled themes if needed
└── README.md           # What this component does
```

**Technical notes:**
- Use `gnome-tweaks` and `gnome-shell-extension-prefs` packages
- Requires "User Themes" GNOME extension for shell theming
- libadwaita apps will ignore GTK themes (expected limitation)
- Store theme preferences in dconf, exportable for backup

**Relevant gsettings:**
```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Theme-Name'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Cursor-Name'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface accent-color 'blue'  # Ubuntu 24.04+
```

---

### 2. Keyboard Shortcuts (`install/shortcuts/`)

**What it does:**
- Apply custom keyboard shortcuts for window management
- Configure workspace navigation
- Set up app launcher shortcuts
- Export/import via dconf for portability

**Key files:**
```
install/shortcuts/
├── install.sh          # Apply shortcuts from config
├── export.sh           # Backup current shortcuts to config files
├── configs/
│   ├── wm-keybindings.conf
│   └── media-keys.conf
└── README.md
```

**Technical notes:**
```bash
# Export shortcuts (for building config)
dconf dump /org/gnome/desktop/wm/keybindings/ > wm-keybindings.conf
dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > media-keys.conf
dconf dump /org/gnome/shell/keybindings/ > shell-keybindings.conf

# Import shortcuts (during install)
dconf load /org/gnome/desktop/wm/keybindings/ < wm-keybindings.conf
```

**Suggested shortcuts to configure:**
- Super+1-9 → Switch to workspace / launch dock app
- Super+Shift+1-9 → Move window to workspace
- Super+Arrow keys → Tile windows
- Super+Enter → Open terminal (Kitty)
- Super+Space → Ulauncher (if installed)

---

### 3. Ulauncher (`install/ulauncher/`)

**What it does:**
- Install Ulauncher application launcher
- Apply custom theme (match system dark theme)
- Configure hotkey (Super+Space)
- Set up autostart

**Key files:**
```
install/ulauncher/
├── install.sh
├── config/              # Ulauncher config to copy to ~/.config/ulauncher/
│   ├── settings.json
│   └── user-themes/     # Custom theme if desired
└── README.md
```

**Technical notes:**
```bash
# Install
sudo add-apt-repository ppa:agornostal/ulauncher
sudo apt update
sudo apt install ulauncher

# Config location
~/.config/ulauncher/settings.json
~/.config/ulauncher/user-themes/

# Autostart
mkdir -p ~/.config/autostart
cp /usr/share/applications/ulauncher.desktop ~/.config/autostart/
```

---

### 4. GNOME Extensions (`install/extensions/`)

**What it does:**
- Install essential GNOME extensions
- Configure extension settings via dconf

**Suggested extensions (minimal set):**
- **User Themes** — Required for shell theming
- **Blur my Shell** — Aesthetic blur effects (optional)
- **AppIndicator** — System tray support for apps that need it

**Key files:**
```
install/extensions/
├── install.sh
├── configs/             # dconf dumps per extension
└── README.md
```

**Technical notes:**
- Extensions break on GNOME version upgrades (fragile component)
- Consider using `gnome-extensions-cli` or `gext` for installation
- Alternative: Install via Extension Manager flatpak

---

### 5. Quality of Life (`install/qol/`)

**What it does:**
- Apply misc GNOME settings tweaks
- Configure dock behavior
- Set default file associations
- Any other small preferences

**Examples:**
```bash
# Show battery percentage
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Dock settings
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

# Nautilus settings
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'

# Night light
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
```

---

## Project Structure

```
myubuntu/
├── install.sh              # Main entry point
├── uninstall.sh            # Reversal script
├── README.md
├── LICENSE
├── CHANGELOG.md
│
├── install/
│   ├── theming/
│   ├── shortcuts/
│   ├── ulauncher/
│   ├── extensions/
│   └── qol/
│
├── configs/                # Exportable dconf backups
│   ├── shortcuts/
│   └── gsettings/
│
├── scripts/
│   ├── backup.sh           # Export current settings
│   └── helpers.sh          # Shared functions (logging, confirmations)
│
└── docs/
    └── CUSTOMIZATION.md    # How to modify for personal use
```

---

## Main Install Script Behavior

```bash
#!/bin/bash
# install.sh - myubuntu main installer

# 1. Detect Ubuntu version, warn if unsupported
# 2. Show menu of components OR install all by default
# 3. Run each component's install.sh
# 4. Generate manifest of changes (for uninstall)
# 5. Print summary and next steps

# Flags:
#   --all           Install all components (default)
#   --only=X,Y      Install only specified components
#   --skip=X,Y      Install all except specified
#   --dry-run       Show what would be installed
#   --no-confirm    Skip confirmation prompts
```

---

## Uninstall Script Behavior

```bash
#!/bin/bash
# uninstall.sh

# 1. Read manifest from install
# 2. Revert dconf changes (if backups exist)
# 3. Remove installed packages (with confirmation)
# 4. Remove config files
# 5. Restore GNOME defaults where possible
```

---

## Implementation Notes

### Idempotency
Every script should be safe to run multiple times. Check if already installed/configured before making changes.

### Backups
Before changing any dconf setting, dump the current value to `~/.myubuntu-backup/`. This enables clean uninstall.

### Logging
Use consistent log functions:
```bash
log_info()  { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_warn()  { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }
```

### Cross-Machine Sync
The `configs/` directory should be the "source of truth" for settings. Users can:
1. Configure one machine manually
2. Run `scripts/backup.sh` to export settings
3. Commit to git
4. Run `install.sh` on other machines

---

## MVP Scope (v0.1.0)

For initial release, implement:

1. ✅ Project structure and helper scripts
2. ✅ Keyboard shortcuts component (most portable, immediate value)
3. ✅ Ulauncher component (simple, standalone)
4. ✅ Basic theming (dark mode, accent color, icon theme)
5. ✅ Main install.sh with component selection

Defer to later versions:
- GNOME extensions (fragile, needs more research)
- Complex shell theming (User Themes extension dependency)
- Uninstall script (nice-to-have for MVP)

---

## Reference: Omakub Components Worth Studying

These Omakub scripts are good reference material for gsettings values:

- `install/desktop/dock.sh` — Dock configuration
- `install/desktop/keybindings.sh` — Keyboard shortcuts approach
- `install/desktop/ulauncher.sh` — Ulauncher setup
- `install/desktop/night-light.sh` — Night light settings

GitHub: https://github.com/basecamp/omakub/tree/main/install/desktop

---

## Success Criteria

MVP is complete when:
1. Fresh Ubuntu 24.04 install + `./install.sh` produces a configured desktop
2. Keyboard shortcuts are applied and working
3. Ulauncher is installed, themed, and bound to Super+Space
4. Dark mode and icon theme are set
5. Script completes in under 5 minutes
6. Re-running script doesn't break anything (idempotent)
7. Settings can be exported and applied to another machine

---

## Getting Started with Claude Code

1. Create repo: `mkdir ~/myubuntu && cd ~/myubuntu && git init`
2. Start with project structure and `scripts/helpers.sh`
3. Build keyboard shortcuts component first (pure dconf, no packages)
4. Add Ulauncher component second (simple apt + config copy)
5. Add basic theming third
6. Wire up main `install.sh` last

Ask Claude Code to reference this spec and your mybash project structure for consistency.
