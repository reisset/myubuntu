#!/bin/bash

# myubuntu - Theming Installer
# Applies dark mode, icon theme, and wallpaper

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
WALLPAPER="$SCRIPT_DIR/background.jpg"
BACKUP_DIR="$HOME/.myubuntu-backup"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Installing theming configuration..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Install Papirus icon theme
if ! dpkg -l | grep -q papirus-icon-theme; then
    log_info "Installing Papirus icon theme..."
    sudo apt install -y papirus-icon-theme
else
    log_info "Papirus icon theme already installed"
fi

# Apply dark mode
log_info "Enabling dark mode..."
safe_gsettings org.gnome.desktop.interface color-scheme 'prefer-dark'

# Set accent color (blue)
log_info "Setting accent color..."
safe_gsettings org.gnome.desktop.interface accent-color 'blue'

# Set icon theme
log_info "Setting Papirus-Dark icon theme..."
safe_gsettings org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Install Tokyo Night GTK theme
THEME_NAME="Tokyonight-Dark-BL"
THEME_DIR="$HOME/.local/share/themes"

if [ ! -d "$THEME_DIR/$THEME_NAME" ]; then
    log_info "Tokyo Night theme not found, downloading..."
    bash "$SCRIPT_DIR/download-theme.sh"
else
    log_info "Tokyo Night theme already installed"
fi

# Apply Tokyo Night GTK theme (legacy GTK3 apps)
if [ -d "$THEME_DIR/$THEME_NAME" ]; then
    log_info "Applying Tokyo Night GTK theme..."
    safe_gsettings org.gnome.desktop.interface gtk-theme "$THEME_NAME"

    # Apply Tokyo Night Shell theme (requires User Themes extension)
    if gnome-extensions list 2>/dev/null | grep -q "user-theme@gnome-shell-extensions.gcampax.github.com"; then
        log_info "Applying Tokyo Night Shell theme..."
        if safe_gsettings org.gnome.shell.extensions.user-theme name "$THEME_NAME"; then
            log_info "Shell theme applied successfully"
        else
            log_warn "Could not apply shell theme (User Themes extension may not be enabled)"
        fi
    else
        log_warn "User Themes extension not installed - shell theme skipped"
        log_info "Install extensions component to enable shell theming"
    fi
else
    log_warn "Tokyo Night theme not found - skipping theme application"
fi

# Set wallpaper
if [ -f "$WALLPAPER" ]; then
    log_info "Setting wallpaper..."
    WALLPAPER_URI="file://$(realpath "$WALLPAPER")"

    safe_gsettings org.gnome.desktop.background picture-uri "$WALLPAPER_URI"
    safe_gsettings org.gnome.desktop.background picture-uri-dark "$WALLPAPER_URI"
    safe_gsettings org.gnome.desktop.background picture-options 'zoom'

    log_info "Wallpaper set to: $WALLPAPER"
else
    log_warn "Wallpaper not found at $WALLPAPER, skipping"
fi

log_info "Theming configuration complete!"
log_info ""
log_info "Applied settings:"
log_info "  - Dark mode enabled"
log_info "  - Accent color: Blue"
log_info "  - GTK theme: Tokyo Night ($THEME_NAME)"
log_info "  - Shell theme: Tokyo Night (if User Themes extension installed)"
log_info "  - Icon theme: Papirus-Dark"
log_info "  - Wallpaper: $(basename "$WALLPAPER")"
log_info ""
log_info "Note: Shell theme requires User Themes extension to be enabled"
