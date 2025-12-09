#!/bin/bash

# CachyOS Fresh Installation Script
# Automates installation of development tools and power management utilities

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

# System update and upgrade
update_system() {
    log_info "Updating system packages..."
    sudo pacman -Syu --noconfirm
}

# Install development tools
install_dev_tools() {
    log_info "Installing development tools..."

    # Base development packages
    sudo pacman -S --needed --noconfirm \
        base-devel \
        git \
        git-lfs \
        github-cli \
        vim \
        neovim \
        curl \
        wget \
        openssh \
        rsync \
        unzip \
        zip \
        htop \
        btop \
        tree \
        fzf \
        ripgrep \
        fd \
        bat \
        exa \
        mesa-demos

    log_info "Development base tools installed"
}

# Install programming languages and environments
install_languages() {
    log_info "Installing programming languages and tools..."

    sudo pacman -S --needed --noconfirm \
        python \
        python-pip \
        python-virtualenv \
        gcc \
        clang \
        cmake \
        make \
        gdb \
        valgrind \
        pkg-config

    log_info "Programming languages installed"
}

# Install GUI development libraries
install_gui_libs() {
    log_info "Installing GUI development libraries..."

    sudo pacman -S --needed --noconfirm \
        gtkmm-4.0 \
        gtkmm-4.0-docs \
        gtk4

    log_info "GUI development libraries installed"
}

# Install IDEs and editors
install_ides() {
    log_info "Installing IDEs and code editors..."

    # Visual Studio Code (official Microsoft build from AUR)
    if ! command -v code &> /dev/null; then
        if command -v yay &> /dev/null; then
            yay -S --needed --noconfirm visual-studio-code-bin
            log_info "Visual Studio Code installed"
        else
            log_warn "yay not available yet, will install VSCode after yay is ready"
        fi
    else
        log_info "Visual Studio Code already installed"
    fi

    # Cursor AI Editor (from AUR)
    if ! command -v cursor &> /dev/null; then
        if command -v yay &> /dev/null; then
            yay -S --needed --noconfirm cursor-bin
            log_info "Cursor AI Editor installed"
        else
            log_warn "yay not available yet, will install Cursor after yay is ready"
        fi
    else
        log_info "Cursor AI Editor already installed"
    fi

    # Obsidian (from AUR)
    if ! command -v obsidian &> /dev/null; then
        if command -v yay &> /dev/null; then
            yay -S --needed --noconfirm obsidian
            log_info "Obsidian installed"
        else
            log_warn "yay not available yet, will install Obsidian after yay is ready"
        fi
    else
        log_info "Obsidian already installed"
    fi

    # Okular (PDF viewer from official repos)
    sudo pacman -S --needed --noconfirm okular

    # MarkdownPart (KDE Markdown viewer component)
    sudo pacman -S --needed --noconfirm markdownpart

    log_info "IDEs and editors installed"
}

# Install Chinese fonts
install_chinese_fonts() {
    log_info "Installing Chinese fonts..."

    sudo pacman -S --needed --noconfirm \
        noto-fonts-cjk \
        wqy-zenhei \
        wqy-microhei \
        adobe-source-han-sans-cn-fonts \
        adobe-source-han-serif-cn-fonts

    log_info "Chinese fonts installed"
}

# Install Chinese input method (fcitx5)
install_chinese_input() {
    log_info "Installing Chinese input method (fcitx5)..."

    sudo pacman -S --needed --noconfirm \
        fcitx5 \
        fcitx5-gtk \
        fcitx5-qt \
        fcitx5-configtool \
        fcitx5-chinese-addons

    # Configure fcitx5 environment variables (only for X11)
    # On Wayland (especially KDE Plasma), native input method protocol is used
    SESSION_TYPE="${XDG_SESSION_TYPE:-x11}"

    if [ "$SESSION_TYPE" = "x11" ]; then
        log_info "Detected X11 session - configuring environment variables..."

        # Check if already configured
        if ! grep -q "GTK_IM_MODULE=fcitx" /etc/environment 2>/dev/null; then
            sudo tee -a /etc/environment > /dev/null <<EOF

# Fcitx5 Input Method (X11)
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF
            log_info "Environment variables configured for X11"
        else
            log_info "Environment variables already configured"
        fi
    else
        log_info "Detected Wayland session - using native input method protocol"
        log_info "No environment variables needed (KDE Plasma handles it automatically)"
    fi

    # On Wayland, fcitx5 should be launched by KWin, not autostart
    # On X11, enable autostart
    if [ "$SESSION_TYPE" = "x11" ]; then
        mkdir -p ~/.config/autostart
        cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/ 2>/dev/null || true
        log_info "Enabled fcitx5 autostart for X11"
    else
        log_info "On Wayland, configure fcitx5 via System Settings → Virtual Keyboard"
    fi

    log_info "Chinese input method installed (fcitx5)"
    log_warn "You need to log out and log back in for input method to work"
    if [ "$SESSION_TYPE" = "wayland" ]; then
        log_info "After relogin: System Settings → Input Devices → Virtual Keyboard → Select Fcitx 5"
    fi
    log_info "Then configure with 'fcitx5-configtool' and add Chinese input"
}

# Install browsers
install_browsers() {
    log_info "Installing web browsers..."

    # Firefox (official package)
    sudo pacman -S --needed --noconfirm firefox

    # Google Chrome (from AUR via yay)
    if command -v yay &> /dev/null; then
        log_info "Installing Google Chrome from AUR..."
        yay -S --needed --noconfirm google-chrome
        log_info "Google Chrome installed"
    else
        log_warn "yay not available, skipping Google Chrome (will install after yay)"
    fi

    # WeChat (from AUR via yay)
    if command -v yay &> /dev/null; then
        log_info "Installing WeChat from AUR..."
        yay -S --needed --noconfirm wechat-universal-bwrap
        log_info "WeChat installed"
    else
        log_warn "yay not available, skipping WeChat (will install after yay)"
    fi

    # Spotify (from AUR via yay)
    if command -v yay &> /dev/null; then
        log_info "Installing Spotify from AUR..."
        yay -S --needed --noconfirm spotify
        log_info "Spotify installed"
    else
        log_warn "yay not available, skipping Spotify (will install after yay)"
    fi
}

# Install power management tools
install_power_management() {
    log_info "Installing power management tools..."

    # Check for and remove power-profiles-daemon (conflicts with TLP)
    if pacman -Qi power-profiles-daemon &> /dev/null; then
        log_warn "Detected power-profiles-daemon (conflicts with TLP)"
        log_info "Removing power-profiles-daemon to install TLP..."
        sudo pacman -Rdd --noconfirm power-profiles-daemon
        log_info "power-profiles-daemon removed"
    fi

    sudo pacman -S --needed --noconfirm \
        tlp \
        tlp-rdw \
        powertop \
        thermald \
        cpupower \
        acpi \
        cachyos-extra-v3/acpi_call

    # Enable TLP service
    sudo systemctl enable tlp.service
    sudo systemctl start tlp.service

    # Mask systemd-rfkill services to avoid conflicts with TLP
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket

    # Enable thermald
    sudo systemctl enable thermald.service
    sudo systemctl start thermald.service

    log_info "Power management tools installed and configured"
}

# Install AUR helper (yay)
install_aur_helper() {
    if ! command -v yay &> /dev/null; then
        log_info "Installing yay AUR helper..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        log_info "yay installed"
    else
        log_info "yay already installed"
    fi
}

# Optional: Install additional power tools from AUR
install_aur_power_tools() {
    if command -v yay &> /dev/null; then
        log_info "Installing additional power management tools from AUR..."
        yay -S --needed --noconfirm \
            auto-cpufreq

        # Enable auto-cpufreq (alternative to TLP - choose one)
        # sudo systemctl enable auto-cpufreq
        log_info "AUR power tools installed (auto-cpufreq available but not enabled)"
    else
        log_warn "yay not available, skipping AUR power tools"
    fi
}

# Install Google Chrome if not already installed
install_chrome_retry() {
    if ! command -v google-chrome-stable &> /dev/null; then
        if command -v yay &> /dev/null; then
            log_info "Installing Google Chrome from AUR..."
            yay -S --needed --noconfirm google-chrome
            log_info "Google Chrome installed"
        fi
    else
        log_info "Google Chrome already installed"
    fi
}

# Install Visual Studio Code if not already installed
install_vscode_retry() {
    if ! command -v code &> /dev/null; then
        if command -v yay &> /dev/null; then
            log_info "Installing Visual Studio Code from AUR..."
            yay -S --needed --noconfirm visual-studio-code-bin
            log_info "Visual Studio Code installed"
        fi
    else
        log_info "Visual Studio Code already installed"
    fi
}

# Install Cursor AI Editor if not already installed
install_cursor_retry() {
    if ! command -v cursor &> /dev/null; then
        if command -v yay &> /dev/null; then
            log_info "Installing Cursor AI Editor from AUR..."
            yay -S --needed --noconfirm cursor-bin
            log_info "Cursor AI Editor installed"
        fi
    else
        log_info "Cursor AI Editor already installed"
    fi
}

# Install Obsidian if not already installed
install_obsidian_retry() {
    if ! command -v obsidian &> /dev/null; then
        if command -v yay &> /dev/null; then
            log_info "Installing Obsidian from AUR..."
            yay -S --needed --noconfirm obsidian
            log_info "Obsidian installed"
        fi
    else
        log_info "Obsidian already installed"
    fi
}

# Install Dropbox if not already installed
install_dropbox() {
    if ! command -v dropbox &> /dev/null; then
        if command -v yay &> /dev/null; then
            log_info "Installing Dropbox from AUR..."
            yay -S --needed --noconfirm dropbox
            log_info "Dropbox installed"
        fi
    else
        log_info "Dropbox already installed"
    fi
}

# Install WeChat if not already installed
install_wechat_retry() {
    if ! command -v wechat &> /dev/null; then
        if command -v yay &> /dev/null; then
            log_info "Installing WeChat from AUR..."
            yay -S --needed --noconfirm wechat-universal-bwrap
            log_info "WeChat installed"
        fi
    else
        log_info "WeChat already installed"
    fi
}

# Install Spotify if not already installed
install_spotify_retry() {
    if ! command -v spotify &> /dev/null; then
        if command -v yay &> /dev/null; then
            log_info "Installing Spotify from AUR..."
            yay -S --needed --noconfirm spotify
            log_info "Spotify installed"
        fi
    else
        log_info "Spotify already installed"
    fi
}

# Display post-installation information
post_install_info() {
    echo ""
    log_info "===== Installation Complete ====="
    echo ""
    echo "Installed components:"
    echo "  - Development tools (git, vim, tmux, ripgrep, fzf, etc.)"
    echo "  - Programming languages (Python, C/C++)"
    echo "  - IDEs (VSCode, Cursor AI, Obsidian)"
    echo "  - Browsers (Firefox, Google Chrome)"
    echo "  - Cloud storage (Dropbox)"
    echo "  - Chinese fonts (Noto CJK, WenQuanYi, Adobe Source Han)"
    echo "  - Chinese input method (fcitx5)"
    echo "  - Power management (TLP, powertop, thermald)"
    echo ""
    echo "Power Management Notes:"
    echo "  - TLP is enabled and running"
    echo "  - Use 'sudo tlp-stat' to check TLP status"
    echo "  - Use 'sudo powertop' for power consumption analysis"
    echo "  - auto-cpufreq is installed but not enabled (alternative to TLP)"
    echo "    To use auto-cpufreq instead: sudo systemctl disable tlp && sudo systemctl enable auto-cpufreq"
    echo ""
    echo "Chinese Input Method (fcitx5):"
    echo "  - fcitx5 is installed and configured for autostart"
    echo "  - IMPORTANT: Log out and log back in for input method to work"
    echo "  - After relogin, configure with: fcitx5-configtool"
    echo "  - Add 'Pinyin' input method in fcitx5 configuration"
    echo "  - Toggle input: Ctrl+Space (default)"
    echo ""
    echo "Next steps:"
    echo "  - Configure git: git config --global user.name 'Your Name'"
    echo "  - Configure git: git config --global user.email 'your@email.com'"
    echo "  - LOG OUT and LOG BACK IN to enable Chinese input method"
    echo "  - Run 'fcitx5-configtool' to configure Chinese input after relogin"
    echo "  - Reboot recommended for optimal power management"
    echo ""
}

# Main installation flow
main() {
    log_info "Starting CachyOS installation script..."
    echo ""

    update_system
    install_dev_tools
    install_languages
    install_gui_libs
    install_ides
    install_chinese_fonts
    install_browsers
    install_power_management
    install_aur_helper
    install_vscode_retry        # Retry VSCode after yay is installed
    install_cursor_retry        # Retry Cursor after yay is installed
    install_obsidian_retry      # Retry Obsidian after yay is installed
    install_chrome_retry        # Retry Chrome after yay is installed
    install_wechat_retry        # Retry WeChat after yay is installed
    install_spotify_retry       # Retry Spotify after yay is installed
    install_dropbox             # Install Dropbox
    install_aur_power_tools
    install_chinese_input       # Install after all other packages

    post_install_info
}

# Run main function
main
