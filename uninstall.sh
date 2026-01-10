#!/bin/bash

# myubuntu - Uninstaller
# Reverts myubuntu changes and restores backups
# https://github.com/reisset/myubuntu

set -e

VERSION="0.3.1"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.myubuntu-backup"
MANIFEST_FILE="$HOME/.myubuntu-manifest.txt"

source "$REPO_DIR/scripts/helpers.sh"

# Parse arguments
UNINSTALL_ALL=true
SKIP_COMPONENTS=()
ONLY_COMPONENTS=()
DRY_RUN=false
NO_CONFIRM=false
REMOVE_PACKAGES=false

for arg in "$@"; do
    case $arg in
        --all)
            UNINSTALL_ALL=true
            shift
            ;;
        --skip=*)
            IFS=',' read -ra SKIP_COMPONENTS <<< "${arg#*=}"
            UNINSTALL_ALL=false
            shift
            ;;
        --only=*)
            IFS=',' read -ra ONLY_COMPONENTS <<< "${arg#*=}"
            UNINSTALL_ALL=false
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-confirm)
            NO_CONFIRM=true
            shift
            ;;
        --remove-packages)
            REMOVE_PACKAGES=true
            shift
            ;;
        -h|--help)
            echo "myubuntu v$VERSION - Uninstaller"
            echo ""
            echo "Usage: ./uninstall.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --all              Uninstall all components (default)"
            echo "  --only=X,Y         Uninstall only specified components"
            echo "  --skip=X,Y         Uninstall all except specified components"
            echo "  --dry-run          Show what would be uninstalled without making changes"
            echo "  --no-confirm       Skip confirmation prompts"
            echo "  --remove-packages  Also remove installed packages (Ulauncher, Papirus, etc.)"
            echo "  -h, --help         Show this help message"
            echo ""
            echo "Components:"
            echo "  shortcuts   - Keyboard shortcuts and keybindings"
            echo "  extensions  - GNOME extensions (disables, doesn't remove)"
            echo "  ulauncher   - Ulauncher application launcher"
            echo "  theming     - Orchis shell theme, dark mode, icons, wallpaper"
            echo "  qol         - Quality of life tweaks (dock, Nautilus, etc.)"
            echo ""
            echo "Examples:"
            echo "  ./uninstall.sh                       # Uninstall everything (keep packages)"
            echo "  ./uninstall.sh --only=shortcuts      # Only remove shortcuts"
            echo "  ./uninstall.sh --remove-packages     # Uninstall and remove packages"
            echo "  ./uninstall.sh --dry-run             # Preview what would be removed"
            exit 0
            ;;
        *)
            log_error "Unknown option: $arg"
            echo "Run './uninstall.sh --help' for usage"
            exit 1
            ;;
    esac
done

# Show banner
echo "============================================="
echo "   myubuntu v$VERSION - Uninstaller"
echo "   Reverting Ubuntu Desktop Customizations"
echo "============================================="
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

# Determine which components to uninstall
COMPONENTS=(shortcuts extensions ulauncher theming qol)

if [ ${#ONLY_COMPONENTS[@]} -gt 0 ]; then
    COMPONENTS=("${ONLY_COMPONENTS[@]}")
elif [ ${#SKIP_COMPONENTS[@]} -gt 0 ]; then
    for skip in "${SKIP_COMPONENTS[@]}"; do
        COMPONENTS=("${COMPONENTS[@]/$skip}")
    done
fi

# Show uninstall plan
echo ""
log_info "Uninstall plan:"
for component in "${COMPONENTS[@]}"; do
    if [ -n "$component" ]; then
        echo "  ✓ $component"
    fi
done
echo ""

if $REMOVE_PACKAGES; then
    log_warn "Will also attempt to remove packages (Ulauncher, Papirus, etc.)"
    echo ""
fi

if $DRY_RUN; then
    log_info "Dry run complete. No changes made."
    exit 0
fi

# Confirm uninstall
if [ "$NO_CONFIRM" = false ]; then
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

    # Optionally remove package
    if $REMOVE_PACKAGES; then
        if command -v ulauncher &> /dev/null; then
            log_info "Removing Ulauncher package..."
            sudo apt remove -y ulauncher
            sudo apt autoremove -y
        fi
    else
        log_info "Ulauncher package kept (use --remove-packages to uninstall)"
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

    # Optionally remove packages and theme files
    if $REMOVE_PACKAGES; then
        if dpkg -l | grep -q papirus-icon-theme; then
            log_info "Removing Papirus icon theme..."
            sudo apt remove -y papirus-icon-theme
        fi

        local theme_dir="$HOME/.local/share/themes/Orchis-Purple-Dark"
        if [ -d "$theme_dir" ]; then
            log_info "Removing Orchis theme..."
            rm -rf "$theme_dir"
        fi
    else
        log_info "Theme packages kept (use --remove-packages to uninstall)"
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

# Done!
echo ""
echo "============================================="
echo ""
log_info "Uninstall complete!"
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
echo "============================================="
