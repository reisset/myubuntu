#!/bin/bash

# myubuntu - Theming Installer
# Applies Yaru-purple GTK theme, Orchis shell theme, icons, and wallpaper

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
WALLPAPER="$SCRIPT_DIR/background.jpg"
BACKUP_DIR="$HOME/.myubuntu-backup"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Installing theming configuration..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Yaru theme and icons are built into Ubuntu - no installation needed
log_info "Using Yaru-purple theme (built into Ubuntu)"

# Apply dark mode
log_info "Enabling dark mode..."
safe_gsettings org.gnome.desktop.interface color-scheme 'prefer-dark'

# Set accent color (purple - matches Omakub Tokyo Night aesthetic)
log_info "Setting accent color to purple..."
safe_gsettings org.gnome.desktop.interface accent-color 'purple' || true

# Apply Yaru-purple GTK theme
log_info "Applying Yaru-purple-dark GTK theme..."
safe_gsettings org.gnome.desktop.interface gtk-theme 'Yaru-purple-dark'

# Apply Yaru-purple icon theme
log_info "Applying Yaru-purple icon theme..."
safe_gsettings org.gnome.desktop.interface icon-theme 'Yaru-purple'

# Set cursor theme
log_info "Setting cursor theme..."
safe_gsettings org.gnome.desktop.interface cursor-theme 'Yaru'

# Install Orchis shell theme
SHELL_THEME_NAME="Orchis-Purple-Dark"
THEME_DIR="$HOME/.local/share/themes"
ORCHIS_REPO="https://github.com/vinceliuice/Orchis-theme.git"
TEMP_DIR="/tmp/orchis-theme-$$"

# Pre-install sassc to avoid interactive prompts from Orchis installer
if ! command -v sassc &>/dev/null; then
    log_info "Installing sassc (required for Orchis theme)..."
    sudo apt-get install -y sassc
fi

if [ ! -d "$THEME_DIR/$SHELL_THEME_NAME" ]; then
    log_info "Orchis shell theme not found, downloading..."

    if git clone --depth 1 "$ORCHIS_REPO" "$TEMP_DIR" 2>/dev/null; then
        log_info "Installing Orchis-Purple-Dark shell theme..."
        cd "$TEMP_DIR"

        # Install only purple dark variant with solid tweaks
        if ./install.sh -t purple -c dark --tweaks solid 2>/dev/null; then
            log_info "Orchis shell theme installed successfully"
        else
            log_warn "Orchis installation script failed, continuing..."
        fi

        cd - > /dev/null
        rm -rf "$TEMP_DIR"
    else
        log_warn "Failed to clone Orchis theme repository, continuing..."
        rm -rf "$TEMP_DIR"
    fi
else
    log_info "Orchis shell theme already installed"
fi

# Apply Orchis Shell theme (requires User Themes extension)
if [ -d "$THEME_DIR/$SHELL_THEME_NAME" ]; then
    if gnome-extensions list --enabled 2>/dev/null | grep -q "user-theme@gnome-shell-extensions.gcampax.github.com"; then
        log_info "Applying Orchis shell theme..."
        if safe_gsettings org.gnome.shell.extensions.user-theme name "$SHELL_THEME_NAME"; then
            log_info "Shell theme applied successfully"
        else
            log_warn "Could not apply shell theme (User Themes extension may not be enabled)"
        fi
    else
        log_warn "User Themes extension installed but not yet active"
        log_info "Shell theme ($SHELL_THEME_NAME) will apply automatically after logout/login"
    fi
else
    log_warn "Orchis shell theme not found - skipping shell theme application"
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
log_info "  - Accent color: Purple"
log_info "  - GTK theme: Yaru-purple-dark (built into Ubuntu)"
log_info "  - Shell theme: Orchis-Purple-Dark (requires User Themes extension)"
log_info "  - Icon theme: Yaru-purple (built into Ubuntu)"
log_info "  - Cursor theme: Yaru"
log_info "  - Wallpaper: $(basename "$WALLPAPER")"
log_info ""
log_info "Notes:"
log_info "  - Shell theme requires User Themes extension to be enabled"
log_info "  - Changes may require logging out and back in to take full effect"
