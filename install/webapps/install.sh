#!/bin/bash

# myubuntu - Webapps Installer
# Installs Brave browser and pre-configured PWA webapps (YouTube, Claude, X, Grok)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Installing webapps component..."

# Check if webapps already installed
if [ -f "$HOME/.local/share/applications/brave-agimnkijcaahngcdmfeangaknmldooml-Default.desktop" ]; then
    log_info "Webapps are already installed"
    if ! confirm "Reinstall webapps?"; then
        log_info "Skipping webapps installation"
        exit 0
    fi
fi

# Install Brave browser if not present
if ! command -v brave-browser &>/dev/null; then
    log_info "Brave browser not found, installing..."

    # Install dependencies
    log_info "Installing dependencies..."
    sudo apt install -y curl

    # Add GPG key
    log_info "Adding Brave GPG key..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

    # Add repository
    if ! grep -q "brave-browser-apt-release" /etc/apt/sources.list.d/* 2>/dev/null; then
        log_info "Adding Brave repository..."
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
            sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        sudo apt update
    fi

    # Install Brave
    log_info "Installing Brave browser..."
    sudo apt install -y brave-browser
    log_info "Brave browser installed successfully!"
else
    log_info "Brave browser is already installed ($(brave-browser --version 2>/dev/null | head -1))"
fi

# Install webapp desktop files
log_info "Installing webapp desktop files..."
mkdir -p "$HOME/.local/share/applications"
cp "$SCRIPT_DIR/apps/"*.desktop "$HOME/.local/share/applications/"

# Install webapp icons
log_info "Installing webapp icons..."
for size in 32 48 128 256 512; do
    mkdir -p "$HOME/.local/share/icons/hicolor/${size}x${size}/apps/"
    # Use || true because not all apps have 512x512 icons
    cp "$SCRIPT_DIR/icons/${size}x${size}/"*.png \
        "$HOME/.local/share/icons/hicolor/${size}x${size}/apps/" 2>/dev/null || true
done

# Update icon cache
log_info "Updating icon cache..."
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor/" 2>/dev/null || true

log_info "Webapps installed successfully!"
log_info ""
log_info "Installed webapps:"
log_info "  - YouTube"
log_info "  - Claude AI"
log_info "  - X (Twitter)"
log_info "  - Grok"
log_info ""
log_info "Notes:"
log_info "  - Webapps are searchable in Ulauncher and visible in app grid"
log_info "  - Webapps open in Brave browser app mode (no browser UI)"
log_info "  - Some webapps have quick actions (right-click to access)"
