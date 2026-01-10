#!/bin/bash

# myubuntu - Main Installer
# Lightweight Ubuntu desktop bootstrap script
# https://github.com/reisset/myubuntu

set -e

VERSION="0.2.0"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_FILE="$HOME/.myubuntu-manifest.txt"

source "$REPO_DIR/scripts/helpers.sh"

# Parse arguments
INSTALL_ALL=true
SKIP_COMPONENTS=()
ONLY_COMPONENTS=()
DRY_RUN=false
NO_CONFIRM=false

for arg in "$@"; do
    case $arg in
        --all)
            INSTALL_ALL=true
            shift
            ;;
        --skip=*)
            IFS=',' read -ra SKIP_COMPONENTS <<< "${arg#*=}"
            INSTALL_ALL=false
            shift
            ;;
        --only=*)
            IFS=',' read -ra ONLY_COMPONENTS <<< "${arg#*=}"
            INSTALL_ALL=false
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
        -h|--help)
            echo "myubuntu v$VERSION - Ubuntu Desktop Bootstrap"
            echo ""
            echo "Usage: ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --all           Install all components (default)"
            echo "  --only=X,Y      Install only specified components"
            echo "  --skip=X,Y      Install all except specified components"
            echo "  --dry-run       Show what would be installed without making changes"
            echo "  --no-confirm    Skip confirmation prompts"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Components:"
            echo "  shortcuts   - Keyboard shortcuts and keybindings"
            echo "  extensions  - GNOME extensions (User Themes, Blur, AppIndicator)"
            echo "  ulauncher   - Ulauncher application launcher"
            echo "  theming     - Tokyo Night theme, dark mode, icons, wallpaper"
            echo "  qol         - Quality of life tweaks (dock, Nautilus, etc.)"
            echo ""
            echo "Examples:"
            echo "  ./install.sh                    # Install everything"
            echo "  ./install.sh --only=shortcuts   # Only install shortcuts"
            echo "  ./install.sh --skip=ulauncher   # Install all except Ulauncher"
            echo "  ./install.sh --dry-run          # Preview what would be installed"
            exit 0
            ;;
        *)
            log_error "Unknown option: $arg"
            echo "Run './install.sh --help' for usage"
            exit 1
            ;;
    esac
done

# Show banner
echo "============================================="
echo "   myubuntu v$VERSION"
echo "   Ubuntu Desktop Bootstrap"
echo "============================================="
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

# Determine which components to install
COMPONENTS=(shortcuts extensions ulauncher theming qol)

if [ ${#ONLY_COMPONENTS[@]} -gt 0 ]; then
    COMPONENTS=("${ONLY_COMPONENTS[@]}")
elif [ ${#SKIP_COMPONENTS[@]} -gt 0 ]; then
    for skip in "${SKIP_COMPONENTS[@]}"; do
        COMPONENTS=("${COMPONENTS[@]/$skip}")
    done
fi

# Show installation plan
echo ""
log_info "Installation plan:"
for component in "${COMPONENTS[@]}"; do
    if [ -n "$component" ]; then
        echo "  ✓ $component"
    fi
done
echo ""

if $DRY_RUN; then
    log_info "Dry run complete. No changes made."
    exit 0
fi

# Confirm installation
if [ "$NO_CONFIRM" = false ]; then
    if ! confirm "Proceed with installation?"; then
        log_info "Installation cancelled"
        exit 0
    fi
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
echo "============================================="
echo ""
log_info "Installation complete!"
echo ""
log_info "Summary:"
log_info "  ✓ Installed ${#COMPONENTS[@]} component(s)"
log_info "  ✓ Backups saved to ~/.myubuntu-backup"
log_info "  ✓ Manifest saved to $MANIFEST_FILE"
echo ""
log_info "Next steps:"
log_info "  1. Log out and log back in for all changes to take effect"
log_info "  2. Test Super+Space to open Ulauncher"
log_info "  3. Press Super to see dock and Activities"
echo ""
log_info "Enjoy your customized Ubuntu desktop!"
echo ""
echo "============================================="
