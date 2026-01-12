#!/bin/bash

# myubuntu - Main Installer
# Lightweight Ubuntu desktop bootstrap script
# https://github.com/reisset/myubuntu

set -e

VERSION="0.4.0"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_FILE="$HOME/.myubuntu-manifest.txt"

source "$REPO_DIR/scripts/helpers.sh"

# Show help if requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "myubuntu - Ubuntu Desktop Bootstrap"
    echo ""
    echo "Usage: ./install.sh"
    echo ""
    echo "Installs all components:"
    echo "  • shortcuts   - Keyboard shortcuts and keybindings"
    echo "  • extensions  - GNOME extensions (User Themes, Blur, AppIndicator)"
    echo "  • ulauncher   - Ulauncher application launcher"
    echo "  • webapps     - Brave browser + PWA webapps (YouTube, Claude, X, Grok)"
    echo "  • theming     - Orchis shell theme, Yaru-purple GTK, wallpaper"
    echo "  • qol         - Quality of life tweaks (dock, Nautilus, etc.)"
    echo "  • fonts       - JetBrains Mono Nerd Font (global install)"
    echo "  • spotify     - Spotify music player (via Snap)"
    echo "  • obsidian    - Obsidian note-taking app (AppImage)"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo ""
    exit 0
fi

# Show banner
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                               ║${NC}"
echo -e "${CYAN}║                           myubuntu                            ║${NC}"
echo -e "${CYAN}║           Lightweight Ubuntu Desktop Bootstrap                ║${NC}"
echo -e "${CYAN}║                                                               ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Environment checks
log_info "Checking environment..."

if ! check_ubuntu; then
    exit 1
fi

if ! check_ubuntu_version; then
    exit 1
fi

if ! check_gnome; then
    exit 1
fi

# Components to install (order matters: spotify/obsidian before qol so they can be pinned)
COMPONENTS=(shortcuts extensions ulauncher webapps theming spotify obsidian qol fonts)

# Show installation plan
echo ""
log_info "Installation plan:"
for component in "${COMPONENTS[@]}"; do
    echo "  ✓ $component"
done
echo ""

# Confirm installation
if ! confirm "Proceed with installation?"; then
    log_info "Installation cancelled"
    exit 0
fi

echo ""
log_info "Starting installation..."
echo ""

# Update package lists
log_info "Updating package lists..."
sudo apt update

# Install components
for component in "${COMPONENTS[@]}"; do
    if [ -n "$component" ] && [ -f "$REPO_DIR/install/$component/install.sh" ]; then
        echo ""
        log_info "=== Installing $component ==="
        bash "$REPO_DIR/install/$component/install.sh"
    fi
done

# Create CLI symlink
echo ""
log_info "Setting up myubuntu CLI..."
mkdir -p "$HOME/.local/bin"
ln -sf "$REPO_DIR/bin/myubuntu" "$HOME/.local/bin/myubuntu"
log_info "CLI symlink created at ~/.local/bin/myubuntu"

# Generate manifest
log_info "Generating installation manifest..."
rm -f "$MANIFEST_FILE"

echo "# myubuntu Installation Manifest" >> "$MANIFEST_FILE"
echo "# Generated: $(date)" >> "$MANIFEST_FILE"
echo "# Version: $VERSION" >> "$MANIFEST_FILE"
echo "" >> "$MANIFEST_FILE"

echo "# Installed Components" >> "$MANIFEST_FILE"
for component in "${COMPONENTS[@]}"; do
    if [ -n "$component" ]; then
        echo "component:$component" >> "$MANIFEST_FILE"
    fi
done

echo "" >> "$MANIFEST_FILE"
echo "# Backup Location" >> "$MANIFEST_FILE"
echo "backup_dir:$HOME/.myubuntu-backup" >> "$MANIFEST_FILE"

log_info "Manifest saved to $MANIFEST_FILE"

# Done!
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}║                  Installation Complete! ✓                     ║${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
log_info "Summary:"
log_info "  ✓ Installed ${#COMPONENTS[@]} component(s)"
log_info "  ✓ Backups saved to ~/.myubuntu-backup"
log_info "  ✓ Manifest saved to $MANIFEST_FILE"
echo ""
log_info "Next steps:"
log_info "  1. Log out and log back in for all changes to take effect"
log_info "  2. After login, the following will be active:"
log_info "     - GNOME extensions (Space Bar workspaces, Just Perfection, etc.)"
log_info "     - Shell theme (Orchis-Purple-Dark)"
log_info "     - Ulauncher launcher (Super+Space)"
log_info "     - Webapps (YouTube, Claude, X, Grok)"
log_info "     - Spotify and Obsidian"
log_info "     - Close windows with Super+Q"
log_info "  3. Press Super to see dock and Activities"
log_info "  4. Run 'myubuntu doctor' to check system health"
log_info "  5. Run 'myubuntu keys' to see all keyboard shortcuts"
echo ""
log_info "Enjoy your customized Ubuntu desktop!"
echo ""
