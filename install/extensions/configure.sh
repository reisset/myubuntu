#!/bin/bash

# myubuntu - Extension Configuration
# Configures GNOME extensions with Omakub-style settings

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Configuring GNOME extensions..."

# Helper function for extension gsettings
ext_gsettings() {
    local ext_uuid=$1
    local schema=$2
    local key=$3
    local value=$4
    local schemadir="$HOME/.local/share/gnome-shell/extensions/$ext_uuid/schemas"

    if [ -d "$schemadir" ]; then
        gsettings --schemadir "$schemadir" set "$schema" "$key" "$value" 2>/dev/null || true
    else
        log_warn "Extension $ext_uuid not found, skipping configuration"
    fi
}

# Just Perfection - UI refinements
log_info "Configuring Just Perfection..."
ext_gsettings "just-perfection-desktop@just-perfection" \
    "org.gnome.shell.extensions.just-perfection" "animation" "2"
ext_gsettings "just-perfection-desktop@just-perfection" \
    "org.gnome.shell.extensions.just-perfection" "dash-app-running" "true"
ext_gsettings "just-perfection-desktop@just-perfection" \
    "org.gnome.shell.extensions.just-perfection" "workspace" "true"
ext_gsettings "just-perfection-desktop@just-perfection" \
    "org.gnome.shell.extensions.just-perfection" "workspace-popup" "false"

# Tactile - Window tiling
log_info "Configuring Tactile (window tiling)..."
ext_gsettings "tactile@lundal.io" \
    "org.gnome.shell.extensions.tactile" "col-0" "1"
ext_gsettings "tactile@lundal.io" \
    "org.gnome.shell.extensions.tactile" "col-1" "2"
ext_gsettings "tactile@lundal.io" \
    "org.gnome.shell.extensions.tactile" "col-2" "1"
ext_gsettings "tactile@lundal.io" \
    "org.gnome.shell.extensions.tactile" "col-3" "0"
ext_gsettings "tactile@lundal.io" \
    "org.gnome.shell.extensions.tactile" "row-0" "1"
ext_gsettings "tactile@lundal.io" \
    "org.gnome.shell.extensions.tactile" "row-1" "1"
ext_gsettings "tactile@lundal.io" \
    "org.gnome.shell.extensions.tactile" "gap-size" "32"

# Blur my Shell - Visual effects
log_info "Configuring Blur my Shell..."
ext_gsettings "blur-my-shell@aunetx" \
    "org.gnome.shell.extensions.blur-my-shell.dash-to-dock" "blur" "true"
ext_gsettings "blur-my-shell@aunetx" \
    "org.gnome.shell.extensions.blur-my-shell.dash-to-dock" "sigma" "30"
ext_gsettings "blur-my-shell@aunetx" \
    "org.gnome.shell.extensions.blur-my-shell.dash-to-dock" "brightness" "0.6"
ext_gsettings "blur-my-shell@aunetx" \
    "org.gnome.shell.extensions.blur-my-shell.dash-to-dock" "static-blur" "true"
ext_gsettings "blur-my-shell@aunetx" \
    "org.gnome.shell.extensions.blur-my-shell.panel" "blur" "false"

# Space Bar - Workspace indicators
log_info "Configuring Space Bar..."
ext_gsettings "space-bar@luchrioh" \
    "org.gnome.shell.extensions.space-bar.behavior" "smart-workspace-names" "false"

# Alphabetical App Grid - Sort apps A-Z
log_info "Configuring Alphabetical App Grid..."
ext_gsettings "AlphabeticalAppGrid@stuarthayhurst" \
    "org.gnome.shell.extensions.AlphabeticalAppGrid" "folder-order-position" "'end'"

log_info "Extension configuration complete!"
log_info ""
log_info "Notes:"
log_info "  - Tactile: Press Super+T to activate window tiling grid"
log_info "  - Just Perfection: Animation speed set to 2x"
log_info "  - Changes may require logging out and back in to take effect"
