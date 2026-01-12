#!/bin/bash

# myubuntu - Helper Functions
# Shared functions for logging, confirmations, and utilities

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Confirmation prompts
confirm() {
    echo -ne "${YELLOW}[?] $1 (Y/n) ${NC}"
    read -r response
    [[ "$response" =~ ^[Nn]$ ]] && return 1
    return 0
}

confirm_no() {
    echo -ne "${YELLOW}[?] $1 (y/N) ${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Check if running on Ubuntu
check_ubuntu() {
    if ! command -v lsb_release &> /dev/null; then
        log_error "lsb_release not found. Are you running Ubuntu?"
        return 1
    fi

    local distro=$(lsb_release -is)
    if [ "$distro" != "Ubuntu" ]; then
        log_error "This script is designed for Ubuntu. Detected: $distro"
        return 1
    fi

    return 0
}

# Check Ubuntu version
check_ubuntu_version() {
    local version=$(lsb_release -rs)
    local major=$(echo "$version" | cut -d. -f1)

    log_info "Detected Ubuntu $version"

    if [ "$major" -lt 24 ]; then
        log_warn "This script is tested on Ubuntu 24.04+. Your version: $version"
        if ! confirm "Continue anyway?"; then
            return 1
        fi
    fi

    return 0
}

# Check if GNOME is running
check_gnome() {
    if [ "$XDG_CURRENT_DESKTOP" != "ubuntu:GNOME" ] && [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
        log_warn "Not running GNOME desktop. Detected: ${XDG_CURRENT_DESKTOP:-unknown}"
        if ! confirm "Continue anyway? (Settings may not apply correctly)"; then
            return 1
        fi
    fi
    return 0
}

# Check if a dependency/command is available
check_dependency() {
    local cmd=$1
    local package=${2:-$cmd}  # Use command name as package name if not provided

    if ! command -v "$cmd" &> /dev/null; then
        log_error "$cmd is not installed"
        log_info "Install it with: sudo apt install $package"
        return 1
    fi
    return 0
}

# Backup dconf settings
backup_dconf() {
    local path=$1
    local backup_file=$2

    if command -v dconf &> /dev/null; then
        mkdir -p "$(dirname "$backup_file")"
        dconf dump "$path" > "$backup_file" 2>/dev/null
        if [ -s "$backup_file" ]; then
            log_info "Backed up $path to $backup_file"
        else
            rm -f "$backup_file"
        fi
    fi
}

# Apply gsettings safely with existence check
safe_gsettings() {
    local schema=$1
    local key=$2
    local value=$3

    # Check if schema exists
    if ! gsettings list-schemas | grep -q "^${schema}$"; then
        log_warn "Schema $schema not found, skipping: $key"
        return 1
    fi

    # Check if key exists in schema
    if ! gsettings list-keys "$schema" 2>/dev/null | grep -q "^${key}$"; then
        log_warn "Key $key not found in $schema, skipping"
        return 1
    fi

    gsettings set "$schema" "$key" "$value"
    return 0
}

# Enable a GNOME extension by directly modifying gsettings array
# This is more reliable than gnome-extensions enable which can fail silently
enable_extension() {
    local ext_uuid=$1
    local current=$(gsettings get org.gnome.shell enabled-extensions)

    # Check if already enabled
    if [[ "$current" == *"'$ext_uuid'"* ]]; then
        return 0
    fi

    # Add to enabled-extensions array
    if [[ "$current" == "@as []" ]]; then
        # Empty array
        gsettings set org.gnome.shell enabled-extensions "['$ext_uuid']"
    else
        # Append to existing array
        local new_array="${current%]}, '$ext_uuid']"
        gsettings set org.gnome.shell enabled-extensions "$new_array"
    fi
}

# Disable a GNOME extension by directly modifying gsettings array
disable_extension() {
    local ext_uuid=$1
    local current=$(gsettings get org.gnome.shell disabled-extensions)

    # Check if already disabled
    if [[ "$current" == *"'$ext_uuid'"* ]]; then
        return 0
    fi

    # Add to disabled-extensions array
    if [[ "$current" == "@as []" ]]; then
        gsettings set org.gnome.shell disabled-extensions "['$ext_uuid']"
    else
        local new_array="${current%]}, '$ext_uuid']"
        gsettings set org.gnome.shell disabled-extensions "$new_array"
    fi
}
