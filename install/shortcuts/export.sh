#!/bin/bash

# myubuntu - Keyboard Shortcuts Exporter
# Exports current GNOME keyboard shortcuts to config files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Exporting current keyboard shortcuts..."

# Check if dconf is available
if ! command -v dconf &> /dev/null; then
    log_error "dconf not found. Please install: sudo apt install dconf-cli"
    exit 1
fi

# Create configs directory if it doesn't exist
mkdir -p "$CONFIGS_DIR"

# Export shortcuts
log_info "Exporting window manager keybindings..."
dconf dump /org/gnome/desktop/wm/keybindings/ > "$CONFIGS_DIR/wm-keybindings.conf"

log_info "Exporting media keys..."
dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > "$CONFIGS_DIR/media-keys.conf"

log_info "Exporting shell keybindings..."
dconf dump /org/gnome/shell/keybindings/ > "$CONFIGS_DIR/shell-keybindings.conf"

log_info "Export complete!"
log_info "Shortcuts saved to: $CONFIGS_DIR"
log_info ""
log_info "To use these shortcuts on another machine:"
log_info "  1. Commit these config files to git"
log_info "  2. Run ./install.sh on the target machine"
