# GNOME Extensions Component

Installs essential GNOME Shell extensions for enhanced desktop functionality.

## Installed Extensions

### User Themes
- **Purpose:** Allows custom GNOME Shell themes (top panel, Activities overview)
- **Required For:** Tokyo Night shell theming
- **URL:** https://extensions.gnome.org/extension/19/user-themes/

### Blur my Shell
- **Purpose:** Adds blur effects to GNOME Shell elements (overview, panel, dash)
- **Benefits:** Modern, polished aesthetic
- **URL:** https://extensions.gnome.org/extension/3193/blur-my-shell/

### AppIndicator Support
- **Purpose:** System tray icons for applications
- **Benefits:** Support for apps like Slack, Discord, Dropbox
- **URL:** https://extensions.gnome.org/extension/615/appindicator-support/

## Installation Method

This component uses multiple approaches to ensure reliability:

1. **Extension Manager (flatpak)** - Graphical tool for managing extensions
2. **gnome-extensions CLI** - Command-line extension management
3. **Direct download** - Downloads extension zips from extensions.gnome.org

If automatic installation fails, the script provides URLs for manual installation.

## Managing Extensions

### Via CLI
```bash
# List installed extensions
gnome-extensions list

# Enable/disable an extension
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions disable user-theme@gnome-shell-extensions.gcampax.github.com

# Show extension info
gnome-extensions info user-theme@gnome-shell-extensions.gcampax.github.com
```

### Via GUI
```bash
# Open GNOME Extensions app
gnome-extensions-app

# Or use Extension Manager (flatpak)
flatpak run com.mattjakeman.ExtensionManager
```

## Compatibility

Extensions are tied to GNOME Shell versions. This component:
- Detects your GNOME Shell version automatically
- Downloads the correct version for your system
- Falls back to manual installation if automatic install fails

## Notes

- Extensions may require logging out and back in to take effect
- Some extensions provide settings accessible via Extensions app
- Extensions can occasionally break on GNOME updates - this is expected behavior
- You can always disable problematic extensions via the Extensions app

## Troubleshooting

### Extensions not appearing
1. Log out and log back in
2. Check if extensions are enabled: `gnome-extensions list --enabled`
3. Restart GNOME Shell: Press Alt+F2, type `r`, press Enter (X11 only)

### Extension Manager not opening
```bash
flatpak run com.mattjakeman.ExtensionManager
```

### Manual installation
If automatic installation fails, install via Extension Manager or visit:
- https://extensions.gnome.org
