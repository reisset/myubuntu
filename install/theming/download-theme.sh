#!/bin/bash

# myubuntu - Tokyo Night Theme Downloader
# Downloads Tokyo Night GTK theme from GitHub

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

THEME_NAME="Tokyonight-Dark-BL"
THEME_REPO="https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git"
THEME_DIR="$HOME/.local/share/themes"
TEMP_DIR="/tmp/tokyo-night-theme-$$"

log_info "Downloading Tokyo Night theme..."

# Create theme directory
mkdir -p "$THEME_DIR"

# Check if theme already exists
if [ -d "$THEME_DIR/$THEME_NAME" ]; then
    log_info "Tokyo Night theme already exists at $THEME_DIR/$THEME_NAME"
    if ! confirm "Re-download and overwrite?"; then
        log_info "Skipping theme download"
        return 0
    fi
    rm -rf "$THEME_DIR/$THEME_NAME"
fi

# Clone the theme repository
log_info "Cloning Tokyo Night GTK Theme repository..."
if git clone --depth 1 "$THEME_REPO" "$TEMP_DIR"; then
    log_info "Repository cloned successfully"

    # Copy the theme variant we want
    if [ -d "$TEMP_DIR/themes/$THEME_NAME" ]; then
        log_info "Installing $THEME_NAME..."
        cp -r "$TEMP_DIR/themes/$THEME_NAME" "$THEME_DIR/"
        log_info "Theme installed to $THEME_DIR/$THEME_NAME"

        # Clean up
        rm -rf "$TEMP_DIR"

        log_info "Tokyo Night theme downloaded successfully!"
        return 0
    else
        log_error "Theme variant $THEME_NAME not found in repository"
        rm -rf "$TEMP_DIR"
        return 1
    fi
else
    log_error "Failed to clone Tokyo Night theme repository"
    rm -rf "$TEMP_DIR"
    return 1
fi
