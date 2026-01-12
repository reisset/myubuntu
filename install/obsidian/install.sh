#!/bin/bash

# myubuntu - Obsidian AppImage Installer
# Installs Obsidian note-taking app via AppImage

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Installing Obsidian..."

# Check dependencies
if ! check_dependency curl; then
    exit 1
fi

# Installation paths
INSTALL_DIR="$HOME/.local/bin"
APPIMAGE_NAME="Obsidian.AppImage"
APPIMAGE_PATH="$INSTALL_DIR/$APPIMAGE_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/obsidian.desktop"
ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"

# Check if already installed
if [ -f "$APPIMAGE_PATH" ]; then
    log_info "Obsidian is already installed at $APPIMAGE_PATH"
    exit 0
fi

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$ICON_DIR"
mkdir -p "$(dirname "$DESKTOP_FILE")"

# Get latest release URL from GitHub API
log_info "Fetching latest Obsidian release..."
RELEASE_INFO=$(curl -sf "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest")

if [ -z "$RELEASE_INFO" ]; then
    log_error "Failed to fetch Obsidian release info from GitHub"
    exit 1
fi

# Extract AppImage download URL (x86_64 - exclude arm64)
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -oP '"browser_download_url":\s*"\K[^"]+\.AppImage(?=")' | grep -v 'arm64' | head -1)

if [ -z "$DOWNLOAD_URL" ]; then
    log_error "Could not find AppImage download URL"
    exit 1
fi

# Download AppImage
log_info "Downloading Obsidian AppImage..."
if ! curl -Lf -o "$APPIMAGE_PATH" "$DOWNLOAD_URL"; then
    log_error "Failed to download Obsidian AppImage"
    rm -f "$APPIMAGE_PATH"
    exit 1
fi

# Make executable
chmod +x "$APPIMAGE_PATH"
log_info "Obsidian AppImage installed to $APPIMAGE_PATH"

# Download icon from Flathub (reliable source)
ICON_URL="https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/md.obsidian.Obsidian.png"
ICON_PATH="$ICON_DIR/obsidian.png"

log_info "Downloading Obsidian icon..."
if curl -Lfs -o "$ICON_PATH" "$ICON_URL"; then
    log_info "Icon installed"
else
    log_warn "Could not download icon"
fi

# Create desktop entry
log_info "Creating desktop entry..."
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Obsidian
Comment=Knowledge base and note-taking
Exec=$APPIMAGE_PATH %u
Icon=obsidian
Type=Application
Categories=Office;TextEditor;
MimeType=x-scheme-handler/obsidian;
StartupWMClass=obsidian
EOF

# Update desktop database
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

log_info "Obsidian installation complete!"
log_info ""
log_info "You can now:"
log_info "  - Launch Obsidian from the app grid"
log_info "  - Run from terminal: $APPIMAGE_PATH"
