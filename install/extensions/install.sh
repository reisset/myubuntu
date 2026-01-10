#!/bin/bash

# myubuntu - GNOME Extensions Installer
# Installs User Themes, Blur my Shell, and AppIndicator extensions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/helpers.sh"

log_info "Installing GNOME extensions..."

# Extension details
EXTENSIONS=(
    "user-theme@gnome-shell-extensions.gcampax.github.com|User Themes|19"
    "blur-my-shell@aunetx|Blur my Shell|3193"
    "appindicatorsupport@rgcjonas.gmail.com|AppIndicator|615"
)

# Check if GNOME Shell is available
if ! command -v gnome-shell &> /dev/null; then
    log_error "gnome-shell not found. Are you running GNOME?"
    return 1
fi

# Get GNOME Shell version
GNOME_VERSION=$(gnome-shell --version | grep -oP '\d+' | head -n 1)
log_info "Detected GNOME Shell version: $GNOME_VERSION"

# Install Extension Manager (flatpak)
if ! flatpak list | grep -q "com.mattjakeman.ExtensionManager"; then
    log_info "Installing Extension Manager (flatpak)..."
    if flatpak install -y flathub com.mattjakeman.ExtensionManager 2>/dev/null; then
        log_info "Extension Manager installed"
    else
        log_warn "Could not install Extension Manager flatpak (non-fatal)"
    fi
else
    log_info "Extension Manager already installed"
fi

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

    log_info "Installing $ext_name ($ext_uuid)..."

    # Check if already installed
    if gnome-extensions list 2>/dev/null | grep -q "^${ext_uuid}$"; then
        log_info "$ext_name is already installed"

        # Enable if disabled
        if ! gnome-extensions info "$ext_uuid" 2>/dev/null | grep -q "State: ENABLED"; then
            log_info "Enabling $ext_name..."
            gnome-extensions enable "$ext_uuid" 2>/dev/null || log_warn "Could not enable $ext_name"
        fi

        return 0
    fi

    # Try to install via gnome-extensions (requires extension zip)
    log_info "Downloading $ext_name from extensions.gnome.org..."

    # Download extension zip
    local temp_zip="/tmp/${ext_uuid}.zip"
    local download_url="https://extensions.gnome.org/download-extension/${ext_uuid}.shell-extension.zip?version_tag=${GNOME_VERSION}"

    if curl -Lfs -o "$temp_zip" "$download_url"; then
        log_info "Installing $ext_name..."
        if gnome-extensions install --force "$temp_zip" 2>/dev/null; then
            log_info "$ext_name installed successfully"
            rm -f "$temp_zip"

            # Enable the extension
            log_info "Enabling $ext_name..."
            gnome-extensions enable "$ext_uuid" 2>/dev/null || log_warn "Could not enable $ext_name (may need logout)"

            return 0
        else
            log_warn "Failed to install $ext_name via CLI"
            rm -f "$temp_zip"
        fi
    else
        log_warn "Failed to download $ext_name"
    fi

    return 1
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
    log_info "You can install them manually via Extension Manager:"
    log_info "  1. Open Extension Manager: flatpak run com.mattjakeman.ExtensionManager"
    log_info "  2. Search for and install the following:"
    for failed in "${FAILED_EXTENSIONS[@]}"; do
        IFS='|' read -r ext_name ext_id <<< "$failed"
        echo "     - $ext_name (https://extensions.gnome.org/extension/$ext_id/)"
    done
fi

echo ""
log_info "Notes:"
log_info "  - Extensions may require logging out and back in to take effect"
log_info "  - You can manage extensions via: gnome-extensions-app"
log_info "  - Or use Extension Manager: flatpak run com.mattjakeman.ExtensionManager"
