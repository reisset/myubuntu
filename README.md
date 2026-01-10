# myubuntu

> Lightweight, modular Ubuntu GNOME desktop bootstrap script

Transforms a fresh Ubuntu install into a personalized, Omakub-inspired desktop. Part of my Linux toolkit alongside [mybash](https://github.com/reisset/mybash) (terminal) and myscreensavers (idle art).

## Features

- **Omakub-style Desktop** - Dock only in overview (press Super), 7 GNOME extensions, UI refinements
- **Tokyo Night Theme** - Dark mode, GTK + Shell theme, Papirus icons, custom wallpaper
- **Ulauncher** - Fast launcher (Super+Space) with Wayland support
- **Window Tiling** - Tactile grid-based tiling (Super+T)
- **Quality of Life** - Centered windows, night light, pinned apps, Nautilus tweaks

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
| **shortcuts** | Super+Space for Ulauncher, custom GNOME keybindings |
| **extensions** | 7 GNOME Shell extensions (Just Perfection, Tactile, Blur my Shell, Space Bar, User Themes, AppIndicator, Alphabetical App Grid). Disables ubuntu-dock for Omakub-style behavior. |
| **ulauncher** | Ulauncher from PPA with Wayland support, auto-start daemon |
| **theming** | Tokyo Night GTK + Shell theme, Papirus-Dark icons, wallpaper, dark mode |
| **qol** | Pinned apps (Brave, VS Code, Spotify, Files, Obsidian), center windows, night light, Nautilus list view |

## Usage

```bash
# Install everything
./install.sh

# Install specific components
./install.sh --only=extensions,theming

# Skip components
./install.sh --skip=ulauncher

# Preview changes
./install.sh --dry-run

# Uninstall (revert to defaults)
./uninstall.sh

# Uninstall and remove packages
./uninstall.sh --remove-packages
```

## Customization

**Pinned Apps:** Edit `install/qol/install.sh`, modify the `favorite-apps` line. Find desktop files in `/usr/share/applications/` or `~/.local/share/applications/`.

**Shortcuts:** Configure in GNOME Settings, then export with `./install/shortcuts/export.sh` and commit.

**Wallpaper:** Replace `install/theming/background.jpg` with your own image.

## Project Structure

```
myubuntu/
├── install.sh                  # Main installer
├── uninstall.sh                # Revert to defaults
├── scripts/helpers.sh          # Shared utilities
└── install/
    ├── shortcuts/              # Keyboard shortcuts (dconf)
    ├── extensions/             # GNOME extensions + config
    ├── ulauncher/              # Ulauncher setup
    ├── theming/                # Tokyo Night theme
    └── qol/                    # Quality of life tweaks
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
