#!/bin/bash

# Install AI Assistant Shortcuts
# Downloads icons and installs ChatGPT and Claude shortcuts in Chrome app mode

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
    log_error "Please do not run this script as root."
    exit 1
fi

# Check if Chrome is installed
check_chrome() {
    if ! command -v google-chrome-stable &> /dev/null; then
        log_error "Google Chrome is not installed!"
        log_error "Install it first with: ./install.sh"
        exit 1
    fi
    log_info "✓ Google Chrome found"
}

# Download icons
download_icons() {
    local icons_dir="$HOME/.local/share/icons"
    mkdir -p "$icons_dir"

    log_info "Downloading icons..."

    # ChatGPT icon
    if ! [ -f "$icons_dir/chatgpt.png" ]; then
        log_info "Downloading ChatGPT icon..."
        curl -sL "https://cdn.oaistatic.com/_next/static/media/apple-touch-icon.82af6fe1.png" \
            -o "$icons_dir/chatgpt.png" || {
            log_warn "Failed to download ChatGPT icon, using Chrome icon"
        }
    else
        log_info "ChatGPT icon already exists"
    fi

    # Claude icon
    if ! [ -f "$icons_dir/claude.png" ]; then
        log_info "Downloading Claude icon..."
        curl -sL "https://claude.ai/images/claude_app_icon.png" \
            -o "$icons_dir/claude.png" || {
            log_warn "Failed to download Claude icon, using Chrome icon"
        }
    else
        log_info "Claude icon already exists"
    fi

    # Gemini icon
    if ! [ -f "$icons_dir/gemini.png" ]; then
        log_info "Downloading Gemini icon..."
        curl -sL "https://www.google.com/s2/favicons?domain=gemini.google.com&sz=128" \
            -o "$icons_dir/gemini.png" || {
            log_warn "Failed to download Gemini icon, using Chrome icon"
        }
    else
        log_info "Gemini icon already exists"
    fi

    # NotebookLM icon
    if ! [ -f "$icons_dir/notebooklm.png" ]; then
        log_info "Downloading NotebookLM icon..."
        curl -sL "https://www.google.com/s2/favicons?domain=notebooklm.google.com&sz=128" \
            -o "$icons_dir/notebooklm.png" || {
            log_warn "Failed to download NotebookLM icon, using Chrome icon"
        }
    else
        log_info "NotebookLM icon already exists"
    fi

    # Microsoft 365 Copilot icon
    if ! [ -f "$icons_dir/microsoft-365-copilot.png" ]; then
        log_info "Downloading Microsoft 365 Copilot icon..."
        curl -sL "https://www.google.com/s2/favicons?domain=m365.cloud.microsoft&sz=128" \
            -o "$icons_dir/microsoft-365-copilot.png" || {
            log_warn "Failed to download Microsoft 365 Copilot icon, using Chrome icon"
        }
    else
        log_info "Microsoft 365 Copilot icon already exists"
    fi

    log_info "✓ Icons ready"
}

# Install desktop shortcuts
install_shortcuts() {
    local apps_dir="$HOME/.local/share/applications"
    local script_dir="$(cd "$(dirname "$0")" && pwd)"

    mkdir -p "$apps_dir"

    log_info "Installing shortcuts..."

    # Copy ChatGPT shortcut
    if [ -f "$script_dir/apps/chatgpt.desktop" ]; then
        cp "$script_dir/apps/chatgpt.desktop" "$apps_dir/"
        chmod +x "$apps_dir/chatgpt.desktop"
        log_info "✓ ChatGPT shortcut installed"
    else
        log_error "chatgpt.desktop not found in apps/ folder"
        exit 1
    fi

    # Copy Claude shortcut
    if [ -f "$script_dir/apps/claude.desktop" ]; then
        cp "$script_dir/apps/claude.desktop" "$apps_dir/"
        chmod +x "$apps_dir/claude.desktop"
        log_info "✓ Claude shortcut installed"
    else
        log_error "claude.desktop not found in apps/ folder"
        exit 1
    fi

    # Copy Gemini shortcut
    if [ -f "$script_dir/apps/gemini.desktop" ]; then
        cp "$script_dir/apps/gemini.desktop" "$apps_dir/"
        chmod +x "$apps_dir/gemini.desktop"
        log_info "✓ Gemini shortcut installed"
    else
        log_error "gemini.desktop not found in apps/ folder"
        exit 1
    fi

    # Copy NotebookLM shortcut
    if [ -f "$script_dir/apps/notebooklm.desktop" ]; then
        cp "$script_dir/apps/notebooklm.desktop" "$apps_dir/"
        chmod +x "$apps_dir/notebooklm.desktop"
        log_info "✓ NotebookLM shortcut installed"
    else
        log_error "notebooklm.desktop not found in apps/ folder"
        exit 1
    fi

    # Copy Microsoft 365 Copilot shortcut
    if [ -f "$script_dir/apps/microsoft-365-copilot.desktop" ]; then
        cp "$script_dir/apps/microsoft-365-copilot.desktop" "$apps_dir/"
        chmod +x "$apps_dir/microsoft-365-copilot.desktop"
        log_info "✓ Microsoft 365 Copilot shortcut installed"
    else
        log_error "microsoft-365-copilot.desktop not found in apps/ folder"
        exit 1
    fi
}

# Update desktop database
update_desktop_database() {
    log_info "Updating desktop database..."

    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$HOME/.local/share/applications" &> /dev/null || true
    fi

    # Refresh icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons" &> /dev/null || true
    fi

    log_info "✓ Desktop database updated"
}

# Display summary
show_summary() {
    echo ""
    echo "================================"
    log_info "Shortcuts Installed"
    echo "================================"
    echo ""
    echo "Installed shortcuts:"
    echo "  ✓ ChatGPT - https://chatgpt.com"
    echo "  ✓ Claude  - https://claude.ai"
    echo "  ✓ Gemini  - https://gemini.google.com"
    echo "  ✓ NotebookLM - https://notebooklm.google.com"
    echo "  ✓ Microsoft 365 Copilot - https://m365.cloud.microsoft"
    echo ""
    echo "Features:"
    echo "  - Runs in Chrome app mode (no browser UI)"
    echo "  - NO extensions loaded (--disable-extensions)"
    echo "  - Separate window from regular browser"
    echo "  - Shows as standalone app in launcher"
    echo ""
    echo "How to use:"
    echo "  - Open your application menu"
    echo "  - Search for 'ChatGPT', 'Claude', 'Gemini', 'NotebookLM', or 'Microsoft 365 Copilot'"
    echo "  - Click to launch"
    echo ""
    echo "To remove:"
    echo "  rm ~/.local/share/applications/{chatgpt,claude,gemini,notebooklm,microsoft-365-copilot}.desktop"
    echo "  rm ~/.local/share/icons/{chatgpt,claude,gemini,notebooklm,microsoft-365-copilot}.png"
    echo ""
}

# Main execution
main() {
    log_info "=== AI Assistant Shortcuts Installer ==="
    echo ""

    check_chrome
    download_icons
    install_shortcuts
    update_desktop_database

    show_summary
}

# Run main function
main
