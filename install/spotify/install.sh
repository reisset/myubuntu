#!/bin/bash

# myubuntu - Spotify Installer
# Installs Spotify via Snap (officially supported method)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Installing Spotify..."

# Check if snap is available
if ! command -v snap &>/dev/null; then
    log_error "Snap is not installed. Snap is required for Spotify installation."
    log_info "Install snap with: sudo apt install snapd"
    return 1
fi

# Check if already installed
if snap list spotify &>/dev/null 2>&1; then
    log_info "Spotify is already installed via Snap"
    return 0
fi

# Install Spotify
log_info "Installing Spotify from Snap Store..."
if sudo snap install spotify; then
    log_info "Spotify installed successfully!"
else
    log_error "Failed to install Spotify"
    return 1
fi

log_info ""
log_info "You can now:"
log_info "  - Launch Spotify from the app grid"
log_info "  - Run from terminal: spotify"
