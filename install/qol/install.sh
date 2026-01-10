#!/bin/bash

# myubuntu - Quality of Life Installer
# Applies dock configuration, Nautilus settings, and misc tweaks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Applying quality of life settings..."

# Set pinned apps: Brave, VS Code, Spotify, Files, Obsidian
# Note: Dock only appears in overview (ubuntu-dock is disabled by extensions component)
log_info "Setting pinned dock applications..."

# Function to check if a desktop file exists
desktop_file_exists() {
    local desktop_file=$1
    # Check in common locations
    [ -f "/usr/share/applications/$desktop_file" ] || \
    [ -f "$HOME/.local/share/applications/$desktop_file" ] || \
    [ -f "/var/lib/snapd/desktop/applications/$desktop_file" ] || \
    [ -f "/var/lib/flatpak/exports/share/applications/$desktop_file" ] || \
    [ -f "$HOME/.local/share/flatpak/exports/share/applications/$desktop_file" ]
}

# Build list of favorite apps (only include installed apps)
FAVORITE_APPS=()
DESIRED_APPS=(
    "brave-browser.desktop"
    "code.desktop"
    "spotify.desktop"
    "org.gnome.Nautilus.desktop"
    "obsidian.desktop"
)

for app in "${DESIRED_APPS[@]}"; do
    if desktop_file_exists "$app"; then
        FAVORITE_APPS+=("$app")
    else
        log_warn "Skipping $app (not installed)"
    fi
done

# Convert array to gsettings format
if [ ${#FAVORITE_APPS[@]} -gt 0 ]; then
    FAVORITES_STRING="["
    for i in "${!FAVORITE_APPS[@]}"; do
        FAVORITES_STRING+="'${FAVORITE_APPS[$i]}'"
        if [ $i -lt $((${#FAVORITE_APPS[@]} - 1)) ]; then
            FAVORITES_STRING+=", "
        fi
    done
    FAVORITES_STRING+="]"

    safe_gsettings org.gnome.shell favorite-apps "$FAVORITES_STRING"
    log_info "Pinned ${#FAVORITE_APPS[@]} application(s) to dock"
else
    log_warn "No favorite apps to pin (none of the desired apps are installed)"
fi

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

# Center new windows (Omakub-style)
safe_gsettings org.gnome.mutter center-new-windows 'true'

# Enable window buttons
safe_gsettings org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# Clock settings
safe_gsettings org.gnome.desktop.interface clock-show-weekday 'true'

log_info "Quality of life settings applied!"
log_info ""
log_info "Applied settings:"
log_info "  - Dock: Only visible in overview (press Super), 5 pinned apps"
log_info "  - Battery percentage: Enabled"
log_info "  - Night light: Enabled"
log_info "  - Center new windows: Enabled"
log_info "  - Nautilus: List view by default"
log_info ""
log_info "Note: Press Super to show Activities overview with dock"
