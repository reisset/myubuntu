#!/bin/bash

# myubuntu - GNOME Extensions Installer
# Installs User Themes, Blur my Shell, and AppIndicator extensions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Installing GNOME extensions..."

# Check dependencies
if ! check_dependency curl; then
    exit 1
fi

if ! check_dependency python3; then
    exit 1
fi

# Extension details
EXTENSIONS=(
    # Existing
    "user-theme@gnome-shell-extensions.gcampax.github.com|User Themes|19"
    "blur-my-shell@aunetx|Blur my Shell|3193"
    "appindicatorsupport@rgcjonas.gmail.com|AppIndicator|615"
    # New (Omakub-inspired)
    "just-perfection-desktop@just-perfection|Just Perfection|3843"
    "tactile@lundal.io|Tactile|4548"
    "space-bar@luchrioh|Space Bar|5090"
    "AlphabeticalAppGrid@stuarthayhurst|Alphabetical App Grid|4238"
    "focus-changer@heartmire|Focus Changer|4627"
)

# Check if GNOME Shell is available
if ! command -v gnome-shell &> /dev/null; then
    log_error "gnome-shell not found. Are you running GNOME?"
    exit 1
fi

# Get GNOME Shell version
GNOME_VERSION=$(gnome-shell --version | grep -oP '\d+' | head -n 1)
log_info "Detected GNOME Shell version: $GNOME_VERSION"

# Disable Ubuntu default extensions (Omakub-style: dock only in overview)
log_info "Disabling Ubuntu default extensions..."
disable_extension "ubuntu-dock@ubuntu.com"
disable_extension "tiling-assistant@ubuntu.com"
disable_extension "ding@rastersoft.com"
log_info "Ubuntu dock disabled (dock will only appear in overview)"

# Extension Manager removed - using gnome-extensions CLI only
# Users can use gnome-extensions-app (built into Ubuntu) for GUI management

# Install gnome-shell-extension-prefs for CLI management
if ! dpkg -l | grep -q gnome-shell-extension-prefs; then
    log_info "Installing gnome-shell-extension-prefs..."
    sudo apt install -y gnome-shell-extension-prefs
else
    log_info "gnome-shell-extension-prefs already installed"
fi

# Function to install a single extension
install_extension() {
    local ext_uuid=$1
    local ext_name=$2
    local ext_id=$3
    local max_attempts=2
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if [ $max_attempts -eq 1 ]; then
            log_info "Installing $ext_name..."
        else
            log_info "Installing $ext_name (attempt $attempt/$max_attempts)..."
        fi

        # Check if already installed
        if gnome-extensions list 2>/dev/null | grep -q "^${ext_uuid}$"; then
            log_info "$ext_name is already installed"

            # Enable extension via gsettings (more reliable than gnome-extensions enable)
            log_info "Enabling $ext_name..."
            enable_extension "$ext_uuid"

            exit 0
        fi

        # Query API for download URL
        local info_url="https://extensions.gnome.org/extension-info/?uuid=${ext_uuid}&shell_version=${GNOME_VERSION}"
        local ext_info=$(curl -sf "$info_url")

        if [ -n "$ext_info" ]; then
            # Parse download_url using Python (guaranteed on Ubuntu)
            local download_url=$(echo "$ext_info" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('download_url',''))" 2>/dev/null)

            if [ -n "$download_url" ]; then
                download_url="https://extensions.gnome.org${download_url}"
                local temp_zip="/tmp/${ext_uuid}.zip"

                if curl -Lfs -o "$temp_zip" "$download_url"; then
                    if gnome-extensions install --force "$temp_zip" 2>/dev/null; then
                        log_info "$ext_name installed successfully"
                        rm -f "$temp_zip"

                        # Enable the extension via gsettings (more reliable)
                        enable_extension "$ext_uuid"

                        exit 0
                    fi
                    rm -f "$temp_zip"
                fi
            fi
        fi

        ((attempt++))
        [ $attempt -le $max_attempts ] && sleep 2
    done

    log_warn "Failed to install $ext_name after $max_attempts attempts"
    exit 1
}

# Track installation failures
FAILED_EXTENSIONS=()

# Install each extension
for ext_data in "${EXTENSIONS[@]}"; do
    IFS='|' read -r ext_uuid ext_name ext_id <<< "$ext_data"
    if ! install_extension "$ext_uuid" "$ext_name" "$ext_id"; then
        FAILED_EXTENSIONS+=("$ext_name|$ext_id")
    fi
done

echo ""

# Summary
if [ ${#FAILED_EXTENSIONS[@]} -eq 0 ]; then
    log_info "All extensions installed successfully!"
    log_info ""
    log_info "Installed extensions:"
    for ext_data in "${EXTENSIONS[@]}"; do
        IFS='|' read -r ext_uuid ext_name ext_id <<< "$ext_data"
        echo "  ✓ $ext_name"
    done
else
    log_warn "Some extensions could not be installed automatically."
    echo ""
    log_info "You can install them manually:"
    log_info "  1. Open GNOME Extensions app (gnome-extensions-app)"
    log_info "  2. Or visit the following URLs and install via browser:"
    for failed in "${FAILED_EXTENSIONS[@]}"; do
        IFS='|' read -r ext_name ext_id <<< "$failed"
        echo "     - $ext_name: https://extensions.gnome.org/extension/$ext_id/"
    done
fi

# Configure extensions
echo ""
if [ -f "$SCRIPT_DIR/configure.sh" ]; then
    bash "$SCRIPT_DIR/configure.sh"
fi

echo ""
log_info "Notes:"
log_info "  - Extensions may require logging out and back in to take effect"
log_info "  - You can manage extensions via: gnome-extensions-app"
log_info "  - Or via browser: https://extensions.gnome.org/local/"
