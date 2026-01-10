#!/bin/bash

# myubuntu - Quality of Life Installer
# Applies dock configuration, Nautilus settings, and misc tweaks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Applying quality of life settings..."

# Dock Configuration (Omakub-style: auto-hide, bottom position)
log_info "Configuring dock..."
safe_gsettings org.gnome.shell.extensions.dash-to-dock dock-fixed 'false'
safe_gsettings org.gnome.shell.extensions.dash-to-dock autohide 'true'
safe_gsettings org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
safe_gsettings org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'

# Set pinned apps: Brave, VS Code, Spotify, Files, Obsidian
log_info "Setting pinned dock applications..."
safe_gsettings org.gnome.shell favorite-apps "['brave-browser.desktop', 'code.desktop', 'spotify.desktop', 'org.gnome.Nautilus.desktop', 'obsidian.desktop']"

# Battery percentage (if laptop)
log_info "Enabling battery percentage..."
safe_gsettings org.gnome.desktop.interface show-battery-percentage 'true'

# Night light
log_info "Enabling night light..."
safe_gsettings org.gnome.settings-daemon.plugins.color night-light-enabled 'true'

# Nautilus (Files) settings
log_info "Configuring Nautilus (Files)..."
safe_gsettings org.gnome.nautilus.preferences default-folder-viewer 'list-view'
safe_gsettings org.gnome.nautilus.preferences show-hidden-files 'false'

# Additional tweaks
log_info "Applying additional tweaks..."

# Enable window buttons
safe_gsettings org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# Clock settings
safe_gsettings org.gnome.desktop.interface clock-show-weekday 'true'

log_info "Quality of life settings applied!"
log_info ""
log_info "Applied settings:"
log_info "  - Dock: Auto-hide, bottom position, 5 pinned apps"
log_info "  - Battery percentage: Enabled"
log_info "  - Night light: Enabled"
log_info "  - Nautilus: List view by default"
log_info ""
log_info "Note: Press Super to show the dock and Activities overview"
