# myubuntu

> Lightweight, modular Ubuntu GNOME desktop bootstrap script

Transforms a fresh Ubuntu install into a personalized, Omakub-inspired desktop. Part of my Linux toolkit alongside [mybash](https://github.com/reisset/mybash) (terminal) and myscreensavers (idle art).

## Features

- **Omakub-style Desktop** - Dock only in overview (press Super), 7 GNOME extensions, UI refinements
- **Orchis Purple Theme** - Dark mode, Yaru-purple GTK + Orchis shell theme, custom wallpaper
- **Ulauncher** - Fast launcher (Super+Space) with Wayland support
- **Webapps** - Brave browser + PWA webapps (YouTube, Claude, X, Grok, GitHub) as desktop applications
- **Window Tiling** - Tactile grid-based tiling (Super+T), close with Super+Q
- **Nerd Fonts** - JetBrains Mono Nerd Font installed globally (VS Code, terminal, all apps)
- **Quality of Life** - Centered windows, night light, pinned apps, Nautilus tweaks
- **myubuntu CLI** - Health check (`myubuntu doctor`) and shortcuts reference (`myubuntu keys`)

## Quick Start

```bash
git clone https://github.com/reisset/myubuntu.git
cd myubuntu
./install.sh
```

Log out and back in to see all changes.

**Requirements:** Ubuntu 24.04+ with GNOME desktop and sudo privileges

## Components

| Component | What it installs |
|-----------|------------------|
| **shortcuts** | Super+Space for Ulauncher, Super+Q to close windows, workspace switching |
| **extensions** | 7 GNOME Shell extensions (Just Perfection, Tactile, Blur my Shell, Space Bar, User Themes, AppIndicator, Alphabetical App Grid). Disables ubuntu-dock for Omakub-style behavior. |
| **ulauncher** | Ulauncher from PPA with Wayland support, auto-start daemon |
| **webapps** | Brave browser from official apt repo + 5 PWA webapps (YouTube, Claude, X, Grok, GitHub) as desktop applications with icons |
| **theming** | Yaru-purple GTK theme (built-in), Orchis-Purple-Dark shell theme, wallpaper, dark mode, purple accent |
| **qol** | Pinned apps (Brave, VS Code, Spotify, Files, Obsidian), center windows, night light, Nautilus list view |
| **fonts** | JetBrains Mono Nerd Font installed globally (available system-wide in VS Code, terminal, all apps) |

## Usage

```bash
# Install everything
./install.sh

# Uninstall (revert to defaults and remove packages)
./uninstall.sh

# Check system health
myubuntu doctor

# View keyboard shortcuts
myubuntu keys
```

**Note:** To customize which components to install, simply comment out lines in `install.sh`. The installer is transparent and easy to read.

## Customization

**Pinned Apps:** Edit `install/qol/install.sh`, modify the `favorite-apps` line. Find desktop files in `/usr/share/applications/` or `~/.local/share/applications/`.

**Shortcuts:** Configure in GNOME Settings, then export with `./install/shortcuts/export.sh` and commit.

**Wallpaper:** Replace `install/theming/background.jpg` with your own image.

## Project Structure

```
myubuntu/
├── install.sh                  # Main installer
├── uninstall.sh                # Revert to defaults
├── bin/myubuntu                # CLI tool (doctor, keys)
├── scripts/helpers.sh          # Shared utilities
└── install/
    ├── shortcuts/              # Keyboard shortcuts (dconf)
    ├── extensions/             # GNOME extensions + config
    ├── ulauncher/              # Ulauncher setup
    ├── webapps/                # Brave browser + PWA webapps
    ├── theming/                # Yaru + Orchis theming
    ├── spotify/                # Spotify (Snap)
    ├── obsidian/               # Obsidian (AppImage)
    ├── qol/                    # Quality of life tweaks
    └── fonts/                  # JetBrains Mono Nerd Font
```

## Philosophy

Emulates [Omakub](https://omakub.org/)'s GNOME setup without pre-configured apps. Adopts Omakub's extensions, dock behavior (hidden on desktop, visible in overview), and UI refinements, while customizing apps, theme, and shortcuts.

**Design principles:** Modular · Transparent · Idempotent · Learnable · Non-invasive

## Safety

- **Backups:** Settings saved to `~/.myubuntu-backup/` before changes
- **Idempotent:** Safe to run multiple times
- **Reversible:** Uninstaller restores Ubuntu defaults
- **Manifest:** Installation log at `~/.myubuntu-manifest.txt`

## Related

- [mybash](https://github.com/reisset/mybash) - Terminal environment (Starship, modern CLI tools, Kitty)
- myscreensavers - ASCII art screensavers

## License

MIT License - See LICENSE file

---

**Made with ❤️ for Ubuntu GNOME**
