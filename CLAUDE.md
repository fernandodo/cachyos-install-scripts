# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a CachyOS (Arch-based Linux) fresh installation automation project. It provides three scripts:
1. **check-network.sh** - Tests internet connectivity and ranks mirrors for optimal speed
2. **cleanup.sh** - Removes unwanted packages from the system
3. **install.sh** - Installs development tools, browsers, Chinese support, and power management

## Project Structure

- `check-network.sh` - Network check and mirror ranking script
- `cleanup.sh` - Cleanup script that removes unwanted packages (rust, go, nodejs, Code-OSS, vanilla kernel)
- `install.sh` - Main installation script that orchestrates all installation tasks
- `README.md` - Comprehensive documentation of all software and usage instructions
- `CLAUDE.md` - This file, guidance for Claude Code instances

## Running the Scripts

### Recommended Order

1. **check-network.sh** - Run first to optimize mirrors (recommended if encountering connection issues)
2. **cleanup.sh** - Run second to remove unwanted packages (optional)
3. **install.sh** - Run last to install development environment

### Network Check Script

Test connectivity and rank mirrors:

```bash
./check-network.sh
```

Run this if you encounter "Connection timed out" errors or slow downloads.

### Cleanup Script

Remove unwanted packages (optional):

```bash
./cleanup.sh
```

The cleanup script prompts for confirmation before removing packages.

### Installation Script

Install development environment and tools:

```bash
./install.sh
```

**Important:** Do not run scripts as root. They will prompt for sudo when needed.

## Script Architecture

### check-network.sh

Standalone script for testing network connectivity and optimizing mirror performance.

**Functions:**
- `check_network()` - Tests internet connectivity, DNS resolution, and mirror accessibility
- `rank_mirrors()` - Uses `cachyos-rate-mirrors` to test and rank all CachyOS mirrors by speed
- Backs up current mirrorlist before making changes
- Refreshes package databases after mirror optimization

**Usage:** Run this script first if experiencing slow downloads or connection timeouts. Takes 1-2 minutes to complete.

### cleanup.sh

Standalone script for removing unwanted packages. Uses interactive confirmation before removal.

**Removes:**
- rust, go (unused programming languages)
- nodejs, npm, yarn (unused JavaScript tools)
- code (Code-OSS, replaced by official VSCode)
- linux (vanilla Arch kernel, only if linux-cachyos exists)

### install.sh

The `install.sh` script is organized into modular functions:

**Core Functions:**

- `update_system()` - Updates all system packages via pacman
- `install_dev_tools()` - Installs base development tools (git, vim, tmux, ripgrep, etc.)
- `install_languages()` - Installs programming languages and compilers (Python, C/C++)
- `install_ides()` - Installs IDEs and code editors (VSCode, Cursor AI, Obsidian from AUR)
- `install_chinese_fonts()` - Installs Chinese fonts (Noto CJK, WenQuanYi, Adobe Source Han)
- `install_browsers()` - Installs web browsers (Firefox, Google Chrome)
- `install_power_management()` - Installs and configures power management tools (TLP, powertop, thermald)
- `install_aur_helper()` - Installs yay AUR helper
- `install_vscode_retry()` - Retries VSCode installation after yay is available
- `install_cursor_retry()` - Retries Cursor AI installation after yay is available
- `install_obsidian_retry()` - Retries Obsidian installation after yay is available
- `install_chrome_retry()` - Retries Google Chrome installation after yay is available
- `install_aur_power_tools()` - Installs additional power tools from AUR (auto-cpufreq)
- `install_chinese_input()` - Installs and configures fcitx5 Chinese input method

**Execution Flow:**

The `main()` function calls each installation function in sequence. The script uses `set -e` to exit on any error.

## Customizing Scripts

### Modifying cleanup.sh

To add or remove packages from cleanup:

1. Edit the `cleanup_unwanted_packages()` function in `cleanup.sh`
2. Add or remove package checks following this pattern:
   ```bash
   if pacman -Qi package-name &> /dev/null; then
       log_info "Found: package-name (reason)"
       unwanted_packages+=("package-name")
   fi
   ```

### Modifying install.sh

To add or remove packages from installation:

1. Edit the relevant function in `install.sh`
2. Modify the `sudo pacman -S` or `yay -S` command to include/exclude packages
3. For new categories, create a new function following the existing pattern

## Power Management Notes

- **TLP** is enabled by default for laptop power optimization
- The script automatically detects and removes **power-profiles-daemon** if present (conflicts with TLP)
- **auto-cpufreq** is installed but not enabled (alternative to TLP)
- Only one power management daemon should be active at a time
- To switch from TLP to auto-cpufreq:
  ```bash
  sudo systemctl disable tlp
  sudo systemctl enable auto-cpufreq
  ```

### TLP vs power-profiles-daemon
The script chooses TLP over power-profiles-daemon because:
- TLP provides 20-35% better battery life vs 10-15% with power-profiles-daemon
- TLP manages individual hardware components (USB, PCIe, disk, Wi-Fi, etc.)
- TLP automatically switches settings between AC and battery power
- TLP is better suited for laptops used unplugged frequently

## Chinese Language Support

The script installs comprehensive Chinese language support:

### Chinese Fonts
- Multiple font packages for optimal Chinese character display
- Includes Noto CJK, WenQuanYi, and Adobe Source Han fonts

### Chinese Input Method (fcitx5)
- Modern input method framework with Pinyin support
- Automatically configures environment variables in `/etc/environment`
- Sets up GTK and Qt integration
- Enables autostart for fcitx5

**Important:** User must log out and log back in after installation for fcitx5 to work. After relogin, configure with `fcitx5-configtool` and add Pinyin input method.

## Package Manager Context

- CachyOS uses **pacman** (Arch package manager)
- AUR packages require an AUR helper like **yay**
- The `--needed` flag skips already-installed packages
- The `--noconfirm` flag auto-confirms installations

## Post-Installation

After running the script:
1. **Log out and log back in** - Required for fcitx5 Chinese input to work
2. Configure fcitx5 - Run `fcitx5-configtool` and add Pinyin input method
3. Configure git credentials - Set user name and email
4. Verify TLP - Run `sudo tlp-stat` to check power management
5. **Reboot** - Recommended for optimal power management
