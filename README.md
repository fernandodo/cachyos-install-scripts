# CachyOS Installation & Cleanup Scripts

Automated scripts for setting up a complete development environment and managing your CachyOS system.

## Scripts Overview

This repository contains four scripts:

1. **`check-network.sh`** - Tests internet connectivity and ranks mirrors for optimal speed
2. **`cleanup.sh`** - Removes unwanted packages (rust, go, nodejs, Code-OSS, vanilla kernel)
3. **`install.sh`** - Installs development tools, browsers, Chinese support, and power management
4. **`create-shortcuts.sh`** - Creates Chrome app mode shortcuts for ChatGPT and Claude (no extensions)

## Quick Start

### Full Setup (Recommended)

```bash
# 1. Check network and optimize mirrors
./check-network.sh

# 2. Remove unwanted packages (optional)
./cleanup.sh

# 3. Install development environment
./install.sh
```

### Install Only

```bash
# Skip network check and cleanup, just install
./install.sh
```

**Note:** Do not run scripts as root. They will prompt for sudo when needed.

---

## check-network.sh - Network Check & Mirror Ranking

Tests your internet connection and ranks CachyOS mirrors for optimal download speed.

### What It Does

1. **Tests internet connectivity** - Verifies you can reach the internet
2. **Tests DNS resolution** - Checks domain name lookups work
3. **Tests CachyOS mirrors** - Checks if mirrors are reachable
4. **Ranks mirrors** - Tests all mirrors and selects fastest ones
5. **Updates package databases** - Refreshes with new mirrors

### Usage

```bash
# Make executable
chmod +x check-network.sh

# Run network check and mirror ranking
./check-network.sh
```

### When to Use

Run this script if you encounter:
- `Connection timed out` errors with pacman
- Slow package downloads
- Mirror connection failures
- After moving to a new location/country

**Time:** Takes 1-2 minutes to test all mirrors.

---

## cleanup.sh - Remove Unwanted Packages

Removes packages you don't need from your system.

### What Gets Removed

| Package | Reason for Removal |
|---------|-------------------|
| **rust** | Not needed for your workflow |
| **go** | Not needed for your workflow |
| **nodejs, npm, yarn** | Not needed for your workflow |
| **code** (Code-OSS) | Replaced with official Microsoft VSCode |
| **linux** (vanilla Arch kernel) | Only if CachyOS kernel exists; frees ~150MB |

### Usage

```bash
# Make executable
chmod +x cleanup.sh

# Run cleanup
./cleanup.sh
```

The script will:
1. Show what packages it found
2. Ask for confirmation before removing
3. Remove packages safely
4. Show cleanup summary

**Safe:** Only removes explicitly checked packages, won't break your system.

---

## create-shortcuts.sh - AI Assistant Shortcuts

Creates Chrome app mode shortcuts for ChatGPT and Claude AI assistants.

### What It Does

1. **Downloads icons** - Fetches official ChatGPT and Claude icons
2. **Creates desktop shortcuts** - Generates .desktop files for application launcher
3. **Installs to system** - Copies files to `~/.local/share/applications/`
4. **Updates desktop database** - Makes shortcuts appear in app menu

### Features

- **Chrome app mode** - Runs as standalone app without browser UI
- **No extensions** - Uses `--disable-extensions` flag for clean environment
- **Separate windows** - ChatGPT and Claude appear as independent apps
- **Application launcher integration** - Shows up in your system's app menu

### Usage

```bash
# Run after installing Chrome
./create-shortcuts.sh
```

**Requirements:** Google Chrome must be installed (from `install.sh`)

### What Gets Created

**Desktop shortcuts:**
- `~/.local/share/applications/chatgpt.desktop`
- `~/.local/share/applications/claude.desktop`

**Icons:**
- `~/.local/share/icons/chatgpt.png`
- `~/.local/share/icons/claude.png`

### How to Use

After installation:
1. Open your application launcher/menu
2. Search for "ChatGPT" or "Claude"
3. Click to launch in app mode
4. Pin to taskbar/dock if desired

### To Remove

```bash
rm ~/.local/share/applications/{chatgpt,claude}.desktop
rm ~/.local/share/icons/{chatgpt,claude}.png
```

---

## install.sh - Install Development Environment

## What Gets Installed

## Development Tools

### Core Development Utilities

| Package | Description |
|---------|-------------|
| **base-devel** | Meta-package containing essential build tools (gcc, make, etc.) |
| **git** | Distributed version control system |
| **git-lfs** | Git Large File Storage extension |
| **github-cli** | GitHub's official CLI tool for repository management, PRs, issues |
| **vim** | Classic modal text editor |
| **neovim** | Modern Vim fork with better defaults and extensibility |
| **curl** | Command-line tool for transferring data with URLs |
| **wget** | Network downloader supporting HTTP, HTTPS, FTP |
| **openssh** | SSH client and server for secure remote access |
| **rsync** | Fast incremental file transfer tool |
| **unzip** | Extract compressed .zip archives |
| **zip** | Create compressed .zip archives |

### System Monitoring & Productivity

| Package | Description |
|---------|-------------|
| **htop** | Interactive process viewer (better than `top`) |
| **btop** | Modern resource monitor with beautiful interface |
| **tmux** | Terminal multiplexer for managing multiple sessions |
| **tree** | Display directory structure in tree format |

### Modern CLI Tools (Rust-based replacements)

| Package | Description | Replaces |
|---------|-------------|----------|
| **fzf** | Fuzzy file finder for command line | `find` + manual selection |
| **ripgrep** | Ultra-fast text search tool | `grep` |
| **fd** | Simple, fast, user-friendly alternative to find | `find` |
| **bat** | Cat clone with syntax highlighting | `cat` |
| **exa** | Modern replacement for ls with colors and icons | `ls` |

---

## Programming Languages & Compilers

### Python

| Package | Description |
|---------|-------------|
| **python** | Python 3 interpreter |
| **python-pip** | Python package installer |
| **python-virtualenv** | Virtual environment creator for Python |

### C/C++ Development

| Package | Description |
|---------|-------------|
| **gcc** | GNU C/C++ compiler |
| **clang** | LLVM-based C/C++ compiler |
| **cmake** | Cross-platform build system generator |
| **make** | Build automation tool |
| **gdb** | GNU debugger for C/C++ |
| **valgrind** | Memory debugging, profiling, and leak detection tool |

**When to use valgrind:**
- Detect memory leaks in C/C++ programs
- Find invalid memory access (buffer overflows, use-after-free)
- Debug segmentation faults
- Profile CPU performance with callgrind

---

## IDEs & Editors

| Package | Description | Source |
|---------|-------------|--------|
| **visual-studio-code-bin** | Visual Studio Code - Official Microsoft build with full extension marketplace | AUR |
| **cursor-bin** | Cursor AI - AI-powered code editor based on VSCode with built-in AI pair programming | AUR |
| **obsidian** | Obsidian - Powerful knowledge base and note-taking app using Markdown | AUR |

**Editor Details:**

**Visual Studio Code:**
- Full Microsoft extension marketplace (all extensions work)
- Better compatibility with Microsoft extensions (C#, Remote-SSH, etc.)
- Official Microsoft branding and updates

**Cursor AI:**
- AI-first code editor with GPT-4 integration
- Built on VSCode, compatible with VSCode extensions
- Features: AI autocomplete, chat with your code, AI-powered refactoring

**Obsidian:**
- Local-first knowledge management system
- Markdown-based notes with bidirectional linking
- Perfect for documentation, personal wiki, and Zettelkasten method

---

## Web Browsers

| Package | Description | Source |
|---------|-------------|--------|
| **firefox** | Mozilla Firefox web browser | Official repos |
| **google-chrome** | Google Chrome web browser | AUR |

---

## Chinese Language Support

### Chinese Fonts

| Package | Description |
|---------|-------------|
| **noto-fonts-cjk** | Google Noto fonts for CJK (Chinese, Japanese, Korean) languages |
| **wqy-zenhei** | WenQuanYi Zen Hei - Popular Chinese sans-serif font |
| **wqy-microhei** | WenQuanYi Micro Hei - Chinese font optimized for screen display |
| **adobe-source-han-sans-cn-fonts** | Adobe Source Han Sans for Simplified Chinese |
| **adobe-source-han-serif-cn-fonts** | Adobe Source Han Serif for Simplified Chinese |

### Chinese Input Method (fcitx5)

| Package | Description |
|---------|-------------|
| **fcitx5** | Next-generation input method framework |
| **fcitx5-gtk** | GTK integration for fcitx5 |
| **fcitx5-qt** | Qt integration for fcitx5 |
| **fcitx5-configtool** | Configuration tool for fcitx5 |
| **fcitx5-chinese-addons** | Chinese input methods (Pinyin, etc.) for fcitx5 |

#### fcitx5 Configuration

The script automatically:
- Configures environment variables in `/etc/environment`
- Enables fcitx5 autostart
- Sets up GTK/Qt integration

**After installation:**
1. Log out and log back in
2. Run `fcitx5-configtool`
3. Add "Pinyin" input method
4. Toggle input with `Ctrl+Space`

---

## Power Management Tools

### Official Packages

| Package | Description |
|---------|-------------|
| **tlp** | Advanced power management for Linux laptops |
| **tlp-rdw** | Radio Device Wizard for TLP (Wi-Fi/Bluetooth power management) |
| **powertop** | Power consumption analysis and optimization tool |
| **thermald** | Thermal daemon for temperature management |
| **cpupower** | CPU frequency scaling and power state management |
| **acpi** | ACPI information display tool |
| **acpi_call** | Kernel module for ACPI calls (battery thresholds on some laptops) |

### AUR Packages

| Package | Description |
|---------|-------------|
| **auto-cpufreq** | Automatic CPU speed & power optimizer (installed but not enabled) |

### Power Management Configuration

The script automatically:
- **Removes power-profiles-daemon** (conflicts with TLP)
- **Enables and starts TLP service**
- **Masks systemd-rfkill** to avoid conflicts with TLP
- **Enables and starts thermald service**

**Why TLP over power-profiles-daemon?**
- 20-35% battery life improvement vs 10-15% with power-profiles-daemon
- Manages individual hardware components (USB, PCIe, disk, Wi-Fi)
- Automatic switching between AC and battery power modes
- Better for laptops used unplugged frequently

---

## AUR Helper

| Package | Description |
|---------|-------------|
| **yay** | Yet Another Yogurt - AUR helper written in Go |

Yay enables easy installation of packages from the Arch User Repository (AUR).

---

## Post-Installation Steps

### 1. Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### 2. Configure Chinese Input Method

**IMPORTANT:** Log out and log back in first for fcitx5 to work.

After relogin:

```bash
# Open fcitx5 configuration tool
fcitx5-configtool
```

In the configuration:
1. Click "Input Method" tab
2. Click "+" to add input method
3. Uncheck "Only Show Current Language"
4. Search for "Pinyin"
5. Add "Pinyin" to your input methods
6. Click "Apply"

Toggle between English and Chinese: `Ctrl+Space`

### 3. Verify Power Management

```bash
# Check TLP status
sudo tlp-stat

# Analyze power consumption
sudo powertop
```

### 4. Reboot (Recommended)

```bash
sudo reboot
```

Reboot ensures all power management settings take effect.

---

## Power Management Commands

### TLP

```bash
# View TLP status and configuration
sudo tlp-stat

# View battery information
sudo tlp-stat -b

# Start TLP service
sudo systemctl start tlp

# Check TLP service status
sudo systemctl status tlp
```

### Alternative: Switch to auto-cpufreq

If you prefer auto-cpufreq over TLP:

```bash
# Disable TLP
sudo systemctl disable tlp
sudo systemctl stop tlp

# Enable auto-cpufreq
sudo systemctl enable auto-cpufreq
sudo systemctl start auto-cpufreq
```

**Note:** Only use one power management tool at a time.

---

## Chinese Input Method Commands

### fcitx5

```bash
# Open configuration tool
fcitx5-configtool

# Restart fcitx5
fcitx5 -r

# Check fcitx5 status
ps aux | grep fcitx5

# Kill fcitx5 (if needed)
killall fcitx5
```

### Troubleshooting Chinese Input

If fcitx5 doesn't work after installation:

1. **Verify environment variables:**
   ```bash
   cat /etc/environment | grep fcitx
   ```
   Should show:
   ```
   GTK_IM_MODULE=fcitx
   QT_IM_MODULE=fcitx
   XMODIFIERS=@im=fcitx
   SDL_IM_MODULE=fcitx
   ```

2. **Check if fcitx5 is running:**
   ```bash
   ps aux | grep fcitx5
   ```

3. **Restart fcitx5:**
   ```bash
   fcitx5 -r
   ```

4. **Test in terminal:**
   ```bash
   # Try typing with Ctrl+Space to toggle
   gedit  # or any text editor
   ```

5. **If still not working, log out and log back in**

---

## Customization

### Adding More Packages

Edit `install.sh` and add packages to the relevant function:

```bash
# Example: Add Firefox to install_dev_tools()
install_dev_tools() {
    sudo pacman -S --needed --noconfirm \
        # ... existing packages ...
        firefox  # Add this line
}
```

### Skipping Installation Steps

Comment out function calls in `main()`:

```bash
main() {
    update_system
    install_dev_tools
    # install_languages      # Skip language installation
    install_ides
    install_power_management
    # install_aur_helper     # Skip AUR helper
    install_aur_power_tools
}
```

---

## Script Features

- **Idempotent**: Safe to run multiple times (uses `--needed` flag)
- **Error handling**: Exits on first error (`set -e`)
- **Color-coded logging**: Info (green), warnings (yellow), errors (red)
- **Automatic conflict resolution**: Handles power-profiles-daemon conflict
- **Modular design**: Easy to customize individual components

---

## Troubleshooting

### Package Conflicts

If you encounter package conflicts:

```bash
# Remove conflicting package
sudo pacman -Rdd package-name

# Re-run the script
./install.sh
```

### AUR Installation Fails

If yay installation fails:

```bash
# Manually install yay
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### TLP Not Working

Check if power-profiles-daemon is running:

```bash
systemctl status power-profiles-daemon

# If active, disable it
sudo systemctl stop power-profiles-daemon
sudo systemctl disable power-profiles-daemon
sudo pacman -Rdd power-profiles-daemon
```

---

## System Requirements

- **OS**: CachyOS (Arch Linux based)
- **Network**: Active internet connection
- **Permissions**: Non-root user with sudo access
- **Disk Space**: ~5GB for all packages

---

## License

This script is provided as-is for personal use. Modify as needed for your setup.
