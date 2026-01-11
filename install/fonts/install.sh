#!/bin/bash

# Fonts installer
# Installs JetBrainsMono Nerd Font globally

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
FONT_VERSION="v3.2.1"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$FONT_VERSION/JetBrainsMono.zip"

# Check if already installed
if fc-list : family | grep -qi "JetBrainsMono Nerd Font"; then
    log_info "JetBrainsMono Nerd Font is already installed"
    if ! confirm "Reinstall JetBrainsMono Nerd Font?"; then
        return 0
    fi
fi

log_info "Installing JetBrainsMono Nerd Font..."

# Create font directory
mkdir -p "$FONT_DIR"

# Download font
FONT_ZIP="/tmp/JetBrainsMono.zip"
log_info "Downloading from GitHub releases..."

if curl -fL \
    --retry 5 \
    --retry-delay 3 \
    --connect-timeout 10 \
    -o "$FONT_ZIP" \
    "$FONT_URL"; then

    log_info "Extracting fonts..."
    unzip -o -q "$FONT_ZIP" -d "$FONT_DIR"
    rm -f "$FONT_ZIP"

    log_info "Rebuilding font cache..."
    fc-cache -fv > /dev/null 2>&1

    log_info "JetBrainsMono Nerd Font installed successfully!"
    log_info "Font is now available system-wide (VS Code, terminal, etc.)"
else
    log_error "Failed to download font"
    log_warn "You can manually download from: $FONT_URL"
    return 1
fi
