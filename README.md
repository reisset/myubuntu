# myubuntu

> Lightweight, modular Ubuntu desktop bootstrap script

A simple, transparent script to apply personal customizations to a fresh Ubuntu install. Part of my personal Linux toolkit alongside [mybash](https://github.com/reisset/mybash) (terminal environment) and myscreensavers (idle-time ASCII art).

## What It Does

**myubuntu** transforms a fresh Ubuntu GNOME installation into a personalized, productive desktop environment by applying:

- **Keyboard Shortcuts** - Custom keybindings including Super+Space for Ulauncher
- **Ulauncher** - Fast application launcher with Wayland support
- **Theming** - Dark mode, Papirus icons, custom wallpaper
- **Quality of Life** - Auto-hide dock, pinned apps, night light, Nautilus tweaks

## Quick Start

```bash
# Clone the repository
git clone https://github.com/reisset/myubuntu.git
cd myubuntu

# Run the installer
./install.sh
```

That's it! Log out and back in to see all changes.

## Requirements

- Ubuntu 24.04 LTS or newer
- GNOME desktop environment
- Sudo privileges

## Components

### Keyboard Shortcuts

Applies custom GNOME keybindings from dconf config files. Includes Super+Space for Ulauncher (custom shortcut via media-keys).

```bash
# Install only shortcuts
./install.sh --only=shortcuts

# Export your current shortcuts
./install/shortcuts/export.sh
```

### Ulauncher

Installs Ulauncher from official PPA with Wayland support (wmctrl) and file preview support (gnome-sushi).

- Bound to Super+Space
- Auto-starts on login
- Dark theme by default

### Theming

- Enables system-wide dark mode
- Installs and sets Papirus-Dark icon theme
- Sets custom wallpaper (bundled)
- Blue accent color

### Quality of Life

- **Dock**: Auto-hide, bottom position, Omakub-style behavior
- **Pinned Apps**: Brave, VS Code, Spotify, Files, Obsidian
- **Battery**: Show percentage in top bar
- **Night Light**: Enabled by default
- **Nautilus**: List view, sensible defaults

## Usage

```bash
# Install everything (default)
./install.sh

# Install specific components
./install.sh --only=shortcuts,theming

# Skip components
./install.sh --skip=ulauncher

# Preview what would be installed
./install.sh --dry-run

# Skip confirmation prompts
./install.sh --no-confirm
```

## Uninstalling

```bash
# Uninstall everything (revert to Ubuntu defaults)
./uninstall.sh

# Uninstall specific components
./uninstall.sh --only=shortcuts,theming

# Preview what would be uninstalled
./uninstall.sh --dry-run

# Uninstall and remove packages (Ulauncher, Papirus, etc.)
./uninstall.sh --remove-packages
```

The uninstall script:
- Restores settings from `~/.myubuntu-backup/` when available
- Resets other settings to Ubuntu defaults
- Disables GNOME extensions (doesn't remove them)
- Optionally removes installed packages with `--remove-packages`
- Preserves config directories (`~/.config/ulauncher`, etc.) for manual cleanup

## Customization

### Changing Pinned Apps

Edit `install/qol/install.sh` and modify the `favorite-apps` line:

```bash
safe_gsettings org.gnome.shell favorite-apps "['app1.desktop', 'app2.desktop']"
```

Desktop file names can be found in `/usr/share/applications/` or `~/.local/share/applications/`.

### Changing Keyboard Shortcuts

1. Configure shortcuts manually in GNOME Settings
2. Export them: `./install/shortcuts/export.sh`
3. Commit the updated config files to git

### Changing Theme/Wallpaper

Replace `install/theming/background.jpg` with your own image, or modify `install/theming/install.sh` to change theme preferences.

## Project Structure

```
myubuntu/
├── install.sh              # Main entry point
├── README.md
├── MYUBUNTU_SPEC.md        # Detailed specification
├── scripts/
│   └── helpers.sh          # Shared functions
├── install/
│   ├── shortcuts/          # Keyboard shortcuts
│   ├── ulauncher/          # Ulauncher setup
│   ├── theming/            # Dark mode, icons, wallpaper
│   └── qol/                # Dock and misc tweaks
└── configs/                # Exportable dconf backups
```

## Safety & Idempotency

- **Backups**: Current settings are backed up to `~/.myubuntu-backup/` before applying changes
- **Idempotent**: Safe to run multiple times - checks if already installed
- **Transparent**: Simple bash scripts, no magic
- **Manifest**: Installation manifest saved to `~/.myubuntu-manifest.txt`

## Philosophy

- **Modular**: Each component is independent and optional
- **Learnable**: Simple shell scripts, easy to understand and modify
- **Portable**: Config files can be synced across machines via git
- **Focused**: Does one thing well - desktop environment setup
- **Non-invasive**: Doesn't touch terminal configs (mybash handles that)

## Future Plans

- Webapp pinning to dock
- Ulauncher extensions bundling
- Cross-machine config sync workflow
- Additional GNOME extensions (optional)

## Related Projects

- [mybash](https://github.com/reisset/mybash) - Terminal environment (Starship, modern CLI tools, Kitty)
- myscreensavers - Idle-time ASCII art screensavers

## License

MIT License - See LICENSE file for details

## Contributing

This is a personal configuration project, but feel free to fork and adapt it to your needs!

---

**Made with ❤️ for Ubuntu GNOME**
