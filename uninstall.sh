#!/bin/bash

# myubuntu - Uninstaller
# Reverts myubuntu changes and restores backups
# https://github.com/reisset/myubuntu

set -e

VERSION="0.4.0"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.myubuntu-backup"
MANIFEST_FILE="$HOME/.myubuntu-manifest.txt"

source "$REPO_DIR/scripts/helpers.sh"

# Show help if requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "myubuntu - Uninstaller"
    echo ""
    echo "Usage: ./uninstall.sh"
    echo ""
    echo "Reverts all myubuntu customizations and removes packages:"
    echo "  • shortcuts   - Keyboard shortcuts and keybindings"
    echo "  • extensions  - GNOME extensions (disables them)"
    echo "  • ulauncher   - Ulauncher application launcher (removes package)"
    echo "  • theming     - Orchis theme, dark mode, icons (removes packages)"
    echo "  • qol         - Quality of life tweaks"
    echo "  • fonts       - JetBrains Mono Nerd Font"
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
echo -e "${CYAN}║                    myubuntu - Uninstaller                      ║${NC}"
echo -e "${CYAN}║            Reverting Ubuntu Desktop Customizations            ║${NC}"
echo -e "${CYAN}║                                                               ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if myubuntu is installed
if [ ! -f "$MANIFEST_FILE" ]; then
    log_warn "No myubuntu installation found (missing manifest: $MANIFEST_FILE)"
    if ! confirm "Continue with uninstall anyway?"; then
        log_info "Uninstall cancelled"
        exit 0
    fi
fi

# Environment checks
log_info "Checking environment..."

if ! check_ubuntu; then
    exit 1
fi

if ! check_gnome; then
    exit 1
fi

# Components to uninstall
COMPONENTS=(shortcuts extensions ulauncher theming qol fonts)

# Show uninstall plan
echo ""
log_info "Uninstall plan:"
for component in "${COMPONENTS[@]}"; do
    echo "  ✓ $component"
done
echo ""
log_warn "Will also remove packages (Ulauncher, Orchis theme, fonts, etc.)"
echo ""

# Confirm uninstall
echo ""
log_warn "This will revert myubuntu customizations to Ubuntu defaults."
if [ -d "$BACKUP_DIR" ]; then
    log_info "Backups will be restored from: $BACKUP_DIR"
else
    log_warn "No backup directory found - will use Ubuntu defaults"
fi
echo ""
if ! confirm "Proceed with uninstall?"; then
    log_info "Uninstall cancelled"
    exit 0
fi

echo ""
log_info "Starting uninstall..."
echo ""

# Uninstall function: shortcuts
uninstall_shortcuts() {
    log_info "=== Uninstalling shortcuts ==="

    local backup="$BACKUP_DIR/media-keys.conf.backup"

    if [ -f "$backup" ]; then
        log_info "Restoring keyboard shortcuts from backup..."
        dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$backup"
        log_info "Keyboard shortcuts restored"
    else
        log_info "No backup found, clearing custom keybindings..."
        if gsettings list-schemas | grep -q "org.gnome.settings-daemon.plugins.media-keys"; then
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"
            log_info "Custom keybindings cleared"
        fi
    fi
}

# Uninstall function: extensions
uninstall_extensions() {
    log_info "=== Uninstalling extensions ==="
    log_warn "Desktop may briefly pause while reverting extension changes..."

    # Re-enable Ubuntu default extensions
    log_info "Re-enabling Ubuntu dock and default extensions..."
    gnome-extensions enable ubuntu-dock@ubuntu.com 2>/dev/null || true
    sleep 0.5
    gnome-extensions enable tiling-assistant@ubuntu.com 2>/dev/null || true
    sleep 0.5
    gnome-extensions enable ding@rastersoft.com 2>/dev/null || true
    sleep 0.5

    # Disable myubuntu extensions
    local extensions=(
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "blur-my-shell@aunetx"
        "appindicatorsupport@rgcjonas.gmail.com"
        "just-perfection-desktop@just-perfection"
        "tactile@lundal.io"
        "space-bar@luchrioh"
        "AlphabeticalAppGrid@stuarthayhurst"
    )

    for ext in "${extensions[@]}"; do
        if gnome-extensions list 2>/dev/null | grep -q "$ext"; then
            log_info "Disabling extension: $ext"
            gnome-extensions disable "$ext" 2>/dev/null || true
            sleep 0.3
        fi
    done

    log_info "Extensions disabled, Ubuntu dock restored"
    log_info "To remove extensions entirely, delete from ~/.local/share/gnome-shell/extensions/"
}

# Uninstall function: ulauncher
uninstall_ulauncher() {
    log_info "=== Uninstalling ulauncher ==="

    # Stop Ulauncher if running
    if pgrep -x ulauncher > /dev/null; then
        log_info "Stopping Ulauncher daemon..."
        pkill -x ulauncher || true
        sleep 1
    fi

    # Remove autostart
    if [ -f "$HOME/.config/autostart/ulauncher.desktop" ]; then
        log_info "Removing Ulauncher autostart..."
        rm -f "$HOME/.config/autostart/ulauncher.desktop"
    fi

    # Remove package
    if command -v ulauncher &> /dev/null; then
        log_info "Removing Ulauncher package..."
        sudo apt remove -y ulauncher
        sudo apt autoremove -y
    fi

    log_info "Ulauncher config preserved at ~/.config/ulauncher (delete manually if needed)"
}

# Uninstall function: theming
uninstall_theming() {
    log_info "=== Uninstalling theming ==="

    # Reset to Ubuntu defaults
    log_info "Resetting theme settings to Ubuntu defaults..."

    safe_gsettings org.gnome.desktop.interface color-scheme 'default'
    safe_gsettings org.gnome.desktop.interface gtk-theme 'Yaru'
    safe_gsettings org.gnome.desktop.interface icon-theme 'Yaru'
    safe_gsettings org.gnome.desktop.interface accent-color 'orange' || true

    # Set Ubuntu default wallpaper explicitly
    log_info "Resetting wallpaper to Ubuntu default..."
    UBUNTU_WALLPAPER="file:///usr/share/backgrounds/ubuntu-wallpaper-d.png"
    safe_gsettings org.gnome.desktop.background picture-uri "$UBUNTU_WALLPAPER"
    safe_gsettings org.gnome.desktop.background picture-uri-dark "$UBUNTU_WALLPAPER"
    safe_gsettings org.gnome.desktop.background picture-options 'zoom'

    # Reset shell theme if User Themes extension is installed
    if gsettings list-schemas | grep -q "org.gnome.shell.extensions.user-theme"; then
        safe_gsettings org.gnome.shell.extensions.user-theme name ''
    fi

    # Remove packages and theme files
    if dpkg -l | grep -q papirus-icon-theme; then
        log_info "Removing Papirus icon theme..."
        sudo apt remove -y papirus-icon-theme
    fi

    local theme_dir="$HOME/.local/share/themes/Orchis-Purple-Dark"
    if [ -d "$theme_dir" ]; then
        log_info "Removing Orchis theme..."
        rm -rf "$theme_dir"
    fi

    log_info "Theme reset to Ubuntu defaults"
}

# Uninstall function: qol
uninstall_qol() {
    log_info "=== Uninstalling qol tweaks ==="

    # Reset favorite apps to Ubuntu defaults
    log_info "Resetting pinned apps..."
    safe_gsettings org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'snap-store_ubuntu-software.desktop', 'firefox_firefox.desktop', 'org.gnome.Software.desktop', 'org.gnome.Settings.desktop']"

    # Reset Night Light
    log_info "Resetting Night Light..."
    safe_gsettings org.gnome.settings-daemon.plugins.color night-light-enabled 'false'

    # Reset Nautilus settings
    log_info "Resetting Nautilus settings..."
    if gsettings list-schemas | grep -q "org.gtk.Settings.FileChooser"; then
        safe_gsettings org.gtk.Settings.FileChooser sort-directories-first 'false'
    fi
    if gsettings list-schemas | grep -q "org.gtk.gtk4.Settings.FileChooser"; then
        safe_gsettings org.gtk.gtk4.Settings.FileChooser sort-directories-first 'false'
    fi

    log_info "Quality of life tweaks reverted"
}

# Uninstall function: fonts
uninstall_fonts() {
    log_info "=== Uninstalling fonts ==="

    local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    if [ -d "$font_dir" ]; then
        log_info "Removing JetBrains Mono Nerd Font..."
        rm -rf "$font_dir"
        fc-cache -fv > /dev/null 2>&1
        log_info "Font removed and cache refreshed"
    else
        log_info "Font directory not found, skipping"
    fi
}

# Run uninstall for each component
for component in "${COMPONENTS[@]}"; do
    if [ -n "$component" ]; then
        echo ""
        if type "uninstall_$component" &>/dev/null; then
            uninstall_$component
        else
            log_warn "No uninstall function for: $component"
        fi
    fi
done

# Remove CLI symlink
echo ""
log_info "Removing myubuntu CLI symlink..."
if [ -L "$HOME/.local/bin/myubuntu" ]; then
    rm -f "$HOME/.local/bin/myubuntu"
    log_info "CLI symlink removed"
else
    log_info "CLI symlink not found, skipping"
fi

# Done!
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}║                   Uninstall Complete! ✓                       ║${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
log_info "Summary:"
log_info "  ✓ Uninstalled ${#COMPONENTS[@]} component(s)"
log_info "  ✓ Settings reset to Ubuntu defaults"
if [ -d "$BACKUP_DIR" ]; then
    log_info "  ✓ Backups preserved at $BACKUP_DIR"
fi
echo ""
log_info "Next steps:"
log_info "  1. Log out and log back in for all changes to take effect"
if [ -d "$BACKUP_DIR" ]; then
    log_info "  2. Delete backups: rm -rf $BACKUP_DIR"
fi
if [ -f "$MANIFEST_FILE" ]; then
    log_info "  3. Delete manifest: rm -f $MANIFEST_FILE"
fi
if [ -d "$HOME/.config/ulauncher" ]; then
    log_info "  4. (Optional) Delete Ulauncher config: rm -rf ~/.config/ulauncher"
fi
echo ""
log_info "To reinstall, run: ./install.sh"
echo ""
