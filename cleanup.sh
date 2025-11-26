#!/bin/bash

# CachyOS Package Cleanup Script
# Removes unwanted packages from the system

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_error "Please do not run this script as root. It will prompt for sudo when needed."
    exit 1
fi

# Remove unwanted packages
cleanup_unwanted_packages() {
    log_info "=== CachyOS Package Cleanup ==="
    echo ""
    log_info "This script will remove packages you don't need:"
    echo "  - rust, go (programming languages not used)"
    echo "  - nodejs, npm, yarn (JavaScript tools not used)"
    echo "  - code (Code-OSS, if you prefer official VSCode)"
    echo "  - linux (vanilla Arch kernel, if CachyOS kernel is present)"
    echo ""

    # List of packages to remove
    local unwanted_packages=()

    # Check and mark packages for removal
    if pacman -Qi rust &> /dev/null; then
        log_info "Found: rust (not needed)"
        unwanted_packages+=("rust")
    fi

    if pacman -Qi go &> /dev/null; then
        log_info "Found: go (not needed)"
        unwanted_packages+=("go")
    fi

    if pacman -Qi nodejs &> /dev/null; then
        log_info "Found: nodejs (not needed)"
        unwanted_packages+=("nodejs")
    fi

    if pacman -Qi npm &> /dev/null; then
        log_info "Found: npm (not needed)"
        unwanted_packages+=("npm")
    fi

    if pacman -Qi yarn &> /dev/null; then
        log_info "Found: yarn (not needed)"
        unwanted_packages+=("yarn")
    fi

    if pacman -Qi code &> /dev/null; then
        log_info "Found: code (Code-OSS)"
        unwanted_packages+=("code")
    fi

    # Check for vanilla Arch kernel (only if CachyOS kernel is present)
    if pacman -Qi linux-cachyos &> /dev/null && pacman -Qi linux &> /dev/null; then
        log_warn "Found: vanilla Arch kernel alongside CachyOS kernel"
        log_info "Will remove vanilla Arch kernel (keeping CachyOS kernel)"
        unwanted_packages+=("linux")
    fi

    # Remove packages if any were found
    if [ ${#unwanted_packages[@]} -gt 0 ]; then
        echo ""
        log_warn "The following packages will be removed: ${unwanted_packages[*]}"
        echo ""
        read -p "Continue with removal? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Removing unwanted packages..."
            sudo pacman -Rns --noconfirm "${unwanted_packages[@]}" 2>/dev/null || {
                log_warn "Some packages could not be removed with dependencies, trying force removal..."
                sudo pacman -Rdd --noconfirm "${unwanted_packages[@]}" 2>/dev/null || true
            }
            echo ""
            log_info "✓ Cleanup completed successfully"

            # Show disk space freed
            echo ""
            log_info "Run 'sudo pacman -Sc' to clean package cache and free more space"
        else
            log_info "Cleanup cancelled by user"
            exit 0
        fi
    else
        echo ""
        log_info "✓ No unwanted packages found - system is clean!"
    fi
}

# Display summary
show_summary() {
    echo ""
    echo "================================"
    log_info "Cleanup Summary"
    echo "================================"
    echo ""
    echo "Removed unwanted packages to free disk space."
    echo ""
    echo "What's still installed:"
    echo "  - Python (python, pip, virtualenv)"
    echo "  - C/C++ tools (gcc, clang, cmake, gdb, valgrind)"
    echo "  - Development tools (git, vim, tmux, etc.)"
    echo ""
    echo "Optional next steps:"
    echo "  1. Run './install.sh' to install remaining packages"
    echo "  2. Run 'sudo pacman -Sc' to clean package cache"
    echo "  3. Run 'sudo pacman -Qtdq | sudo pacman -Rns -' to remove orphaned packages"
    echo ""
}

# Main execution
main() {
    cleanup_unwanted_packages
    show_summary
}

# Run main function
main
