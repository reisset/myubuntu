#!/bin/bash

# myubuntu - Ulauncher Installer
# Installs and configures Ulauncher application launcher

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Installing Ulauncher..."

# Check if already installed
if command -v ulauncher &> /dev/null; then
    log_info "Ulauncher is already installed ($(ulauncher --version 2>/dev/null || echo 'version unknown'))"
    if ! confirm "Install/configure Ulauncher?"; then
        log_info "Skipping Ulauncher installation"
        exit 0
    fi
fi

# Install dependencies
log_info "Installing dependencies (wmctrl, gnome-sushi)..."
sudo apt install -y wmctrl gnome-sushi

# Add Ulauncher PPA
if ! grep -q "^deb .*agornostal/ulauncher" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    log_info "Adding Ulauncher PPA..."
    sudo add-apt-repository -y ppa:agornostal/ulauncher
    sudo apt update
else
    log_info "Ulauncher PPA already added"
fi

# Install Ulauncher
log_info "Installing Ulauncher from PPA..."
sudo apt install -y ulauncher

# Configure Ulauncher
log_info "Configuring Ulauncher..."

# Create Ulauncher config directory
mkdir -p "$HOME/.config/ulauncher"

# Set Ulauncher's internal hotkey to something unused (Ctrl+PageDown)
# The actual Super+Space binding is handled via GNOME custom shortcut
if [ -f "$HOME/.config/ulauncher/settings.json" ]; then
    log_info "Ulauncher config already exists, preserving existing settings"
else
    log_info "Creating Ulauncher config with Ctrl+PageDown hotkey"
    cat > "$HOME/.config/ulauncher/settings.json" <<'EOF'
{
    "hotkey-show-app": "<Primary>Page_Down",
    "show-indicator-icon": true,
    "show-recent-apps": "5",
    "theme-name": "dark"
}
EOF
fi

# Set up autostart
log_info "Setting up Ulauncher autostart..."
mkdir -p "$HOME/.config/autostart"
cp /usr/share/applications/ulauncher.desktop "$HOME/.config/autostart/"

log_info "Ulauncher installed successfully!"
log_info ""
log_info "Notes:"
log_info "  - Ulauncher is set to start automatically on login"
log_info "  - Use Super+Space to open (configured via GNOME shortcuts)"
log_info "  - You can customize themes and extensions in Ulauncher preferences"
