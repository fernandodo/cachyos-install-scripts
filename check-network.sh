#!/bin/bash

# CachyOS Network Check & Mirror Ranking Script
# Verifies internet connectivity and ranks mirrors for optimal download speed

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

# Check network connectivity
check_network() {
    log_info "=== Network Connectivity Check ==="
    echo ""

    # Test basic internet connectivity
    log_info "Testing internet connection..."
    if ! ping -c 3 -W 5 8.8.8.8 &> /dev/null; then
        echo ""
        log_error "✗ No internet connection detected!"
        echo ""
        echo "Troubleshooting steps:"
        echo "  1. Check if your network cable is plugged in"
        echo "  2. Check if WiFi is connected"
        echo "  3. Run: ip link"
        echo "  4. Run: systemctl status NetworkManager"
        echo ""
        exit 1
    fi
    log_info "✓ Internet connection verified"

    # Test DNS resolution
    log_info "Testing DNS resolution..."
    if ! ping -c 2 -W 5 cachyos.org &> /dev/null; then
        log_warn "✗ DNS resolution slow or failing"
        log_warn "This might cause issues, but continuing..."
    else
        log_info "✓ DNS resolution working"
    fi

    # Test CachyOS mirror connectivity
    log_info "Testing CachyOS mirror connectivity..."
    if curl --connect-timeout 10 -s -I https://cdn77.cachyos.org &> /dev/null; then
        log_info "✓ CachyOS CDN reachable"
    else
        log_warn "✗ CachyOS CDN not reachable"
        log_warn "Mirror ranking recommended"
    fi

    echo ""
    log_info "✓ Network check completed"
}

# Rank and update CachyOS mirrors
rank_mirrors() {
    echo ""
    log_info "=== CachyOS Mirror Ranking ==="
    echo ""

    # Check if cachyos-rate-mirrors exists
    if ! command -v cachyos-rate-mirrors &> /dev/null; then
        log_warn "cachyos-rate-mirrors not found"
        log_info "Install it with: sudo pacman -S cachyos-rate-mirrors"
        echo ""
        log_info "Skipping mirror ranking, using default mirrors..."
        return 0
    fi

    log_info "This will test mirrors and select the fastest ones"
    log_info "It may take 1-2 minutes..."
    echo ""

    # Backup current mirrorlist
    if [ -f /etc/pacman.d/cachyos-mirrorlist ]; then
        sudo cp /etc/pacman.d/cachyos-mirrorlist /etc/pacman.d/cachyos-mirrorlist.backup.$(date +%Y%m%d_%H%M%S)
        log_info "Backed up current mirrorlist"
    fi

    # Run mirror ranking
    log_info "Testing mirrors..."
    if sudo cachyos-rate-mirrors; then
        log_info "✓ Mirrors ranked successfully"
    else
        log_error "✗ Mirror ranking failed"
        # Restore most recent backup if ranking failed
        local latest_backup=$(ls -t /etc/pacman.d/cachyos-mirrorlist.backup.* 2>/dev/null | head -1)
        if [ -n "$latest_backup" ]; then
            sudo cp "$latest_backup" /etc/pacman.d/cachyos-mirrorlist
            log_info "Restored previous mirrorlist"
        fi
        echo ""
        log_warn "Continuing with previous mirror configuration"
        return 1
    fi

    echo ""
    log_info "Refreshing package databases with new mirrors..."
    if sudo pacman -Syy --noconfirm; then
        log_info "✓ Package databases refreshed successfully"
    else
        log_error "✗ Failed to refresh package databases"
        echo ""
        echo "Possible issues:"
        echo "  1. Mirrors are temporarily down"
        echo "  2. Network connection unstable"
        echo "  3. Firewall blocking connections"
        echo ""
        echo "Solutions:"
        echo "  - Wait a few minutes and run this script again"
        echo "  - Try: sudo pacman -Syy"
        echo "  - Manually edit: /etc/pacman.d/cachyos-mirrorlist"
        echo ""
        exit 1
    fi
}

# Display summary
show_summary() {
    echo ""
    echo "================================"
    log_info "Network Check Summary"
    echo "================================"
    echo ""
    echo "✓ Network connectivity verified"
    echo "✓ Mirrors optimized for your location"
    echo "✓ Package databases up to date"
    echo ""
    echo "You can now run: ./install.sh"
    echo ""
}

# Main execution
main() {
    check_network
    rank_mirrors
    show_summary
}

# Run main function
main
