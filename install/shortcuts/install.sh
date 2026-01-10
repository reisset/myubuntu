#!/bin/bash

# myubuntu - Keyboard Shortcuts Installer
# Applies custom GNOME keyboard shortcuts from dconf configs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"
BACKUP_DIR="$HOME/.myubuntu-backup"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Installing keyboard shortcuts..."

# Check if dconf is available
if ! command -v dconf &> /dev/null; then
    log_error "dconf not found. Please install: sudo apt install dconf-cli"
    return 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup current shortcuts before making changes
log_info "Backing up current shortcuts..."
backup_dconf "/org/gnome/desktop/wm/keybindings/" "$BACKUP_DIR/wm-keybindings.conf.backup"
backup_dconf "/org/gnome/settings-daemon/plugins/media-keys/" "$BACKUP_DIR/media-keys.conf.backup"
backup_dconf "/org/gnome/shell/keybindings/" "$BACKUP_DIR/shell-keybindings.conf.backup"

# Apply new shortcuts
log_info "Applying keyboard shortcuts from configs..."

if [ -f "$CONFIGS_DIR/wm-keybindings.conf" ]; then
    dconf load /org/gnome/desktop/wm/keybindings/ < "$CONFIGS_DIR/wm-keybindings.conf"
    log_info "Applied window manager keybindings"
fi

if [ -f "$CONFIGS_DIR/media-keys.conf" ]; then
    dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$CONFIGS_DIR/media-keys.conf"
    log_info "Applied media keys (including Super+Space for Ulauncher)"
fi

if [ -f "$CONFIGS_DIR/shell-keybindings.conf" ]; then
    dconf load /org/gnome/shell/keybindings/ < "$CONFIGS_DIR/shell-keybindings.conf"
    log_info "Applied shell keybindings"
fi

log_info "Keyboard shortcuts installed successfully!"
log_info "Backups saved to $BACKUP_DIR"
