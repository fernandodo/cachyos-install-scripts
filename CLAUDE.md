# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CachyOS (Arch-based Linux) fresh installation automation scripts. Four independent scripts that can be run in sequence or standalone:
1. **check-network.sh** - Network diagnostics and mirror optimization
2. **cleanup.sh** - Package removal (rust, go, nodejs, Code-OSS, vanilla kernel, tmux)
3. **install.sh** - Development environment installation (main script)
4. **create-shortcuts.sh** - Chrome app mode shortcuts for ChatGPT/Claude

## Key Directories

- `apps/` - .desktop files for AI assistant shortcuts (chatgpt.desktop, claude.desktop)
- `settings/` - Post-installation configuration documentation (login wallpaper, fcitx5 wayland fix, power management, dropbox, SSH setup)

## Running the Scripts

**Recommended sequence:** `./check-network.sh` → `./cleanup.sh` → `./install.sh` → `./create-shortcuts.sh`

**Important:** Never run as root - scripts prompt for sudo when needed.

All scripts use common patterns:
- Idempotent (safe to run multiple times)
- `set -e` (exit on first error)
- Consistent logging functions (`log_info`, `log_warn`, `log_error`)
- Root check prevents accidental execution as root

## Script Architecture

### install.sh - Main Installation Script

**Critical Architecture Pattern:** Two-phase AUR installation to handle yay dependency

**Phase 1 - Official repos only:**
```
update_system() → install_dev_tools() → install_languages() →
install_ides() → install_chinese_fonts() → install_browsers() →
install_power_management() → install_aur_helper()
```

**Phase 2 - Retry AUR packages after yay is available:**
```
install_vscode_retry() → install_cursor_retry() →
install_obsidian_retry() → install_chrome_retry() →
install_dropbox() → install_aur_power_tools() → install_chinese_input()
```

**Why this pattern:** AUR packages (VSCode, Cursor, Chrome, Obsidian, Dropbox, WeChat, Spotify) require yay, but yay must be built from AUR first. Initial install functions check `command -v yay` and skip if unavailable, then retry functions install after `install_aur_helper()` completes.

**Key Installation Functions:**

- `install_power_management()` (install.sh:256-289) - Automatically detects and removes `power-profiles-daemon` (conflicts with TLP), enables TLP and thermald services, masks systemd-rfkill to prevent conflicts
- `install_chinese_input()` (install.sh:165-218) - Detects session type via `$XDG_SESSION_TYPE`:
  - **X11**: Adds environment variables to `/etc/environment`, creates autostart file
  - **Wayland (KDE Plasma)**: Uses native input protocol, no env vars needed, relies on KWin to launch fcitx5
- `install_aur_helper()` (install.sh:292-305) - Clones yay from AUR to `/tmp`, builds with `makepkg -si`
- All `*_retry()` functions (install.sh:323-411) - Check if command exists, skip if already installed, install via yay if available

### check-network.sh

Three-stage verification process:
1. `check_network()` (check-network.sh:34-74) - Tests connectivity (ping 8.8.8.8), DNS resolution (ping cachyos.org), CachyOS CDN (curl cdn77.cachyos.org)
2. `rank_mirrors()` (check-network.sh:77-137) - Uses `cachyos-rate-mirrors` to benchmark and rank mirrors, backs up mirrorlist to timestamped file before changes, refreshes package databases with `pacman -Syy`
3. `show_summary()` - Displays results

**Error recovery:** If mirror ranking fails, automatically restores most recent backup mirrorlist.

### cleanup.sh

Interactive removal script with two-stage confirmation:
1. `cleanup_unwanted_packages()` (cleanup.sh:34-114) - Scans for unwanted packages using `pacman -Qi`, adds to array if found, prompts for user confirmation
2. Attempts graceful removal with `pacman -Rns` (removes dependencies), falls back to force removal with `pacman -Rdd` if dependencies block

**Packages removed:** rust, go, npm, yarn, code (Code-OSS), tmux, vanilla linux kernel

**Special logic:** Only removes vanilla `linux` kernel if CachyOS kernel (`linux-cachyos`) is present (cleanup.sh:81-85).

### create-shortcuts.sh

Four-stage installation process:
1. `check_chrome()` (create-shortcuts.sh:34-41) - Verifies Chrome is installed, exits if not found
2. `download_icons()` (create-shortcuts.sh:44-73) - Downloads ChatGPT and Claude icons to `~/.local/share/icons/`, skips if already exist
3. `install_shortcuts()` (create-shortcuts.sh:76-103) - Copies .desktop files from `apps/` to `~/.local/share/applications/`
4. `update_desktop_database()` (create-shortcuts.sh:106-119) - Updates desktop database and icon cache for immediate availability

**Chrome app mode:** Shortcuts use `--app=URL --disable-extensions` flags to create standalone app windows without browser UI or extensions.

## Modifying Scripts

### Adding/removing packages in install.sh

**For official repo packages:** Edit the relevant function (e.g., `install_dev_tools()`) and modify the `pacman -S` command.

**For AUR packages:**
1. Add to existing function with `command -v yay` check (like install.sh:106-115 for VSCode)
2. Create corresponding `install_*_retry()` function (like install.sh:336-346 for VSCode)
3. Call retry function in `main()` after `install_aur_helper()` (like install.sh:465-471)

### Adding packages to cleanup.sh

Add to `cleanup_unwanted_packages()` following this pattern:
```bash
if pacman -Qi package-name &> /dev/null; then
    log_info "Found: package-name (reason)"
    unwanted_packages+=("package-name")
fi
```

### Adding shortcuts in create-shortcuts.sh

1. Create .desktop file in `apps/` directory with Chrome app mode command
2. Add icon download logic to `download_icons()` function
3. Add shortcut copy logic to `install_shortcuts()` function

## Power Management Configuration

**Default:** TLP (enabled and started by install.sh)
**Alternative:** auto-cpufreq (installed but not enabled)

**Conflict handling:** install.sh auto-removes `power-profiles-daemon` if detected at install.sh:260-265 (conflicts with TLP)

**Switch to auto-cpufreq:**
```bash
sudo systemctl disable tlp && sudo systemctl enable auto-cpufreq
```

**Rationale for TLP:** 20-35% battery improvement vs 10-15% with power-profiles-daemon, per-device power management (USB, PCIe, disk, Wi-Fi), automatic AC/battery mode switching.

**Note on thermald:** Thermald is enabled but inactive on AMD CPUs (Intel-only tool). This is expected behavior.

**Details:** See settings/power-management.md for comprehensive guide including battery thresholds, CPU governors, troubleshooting.

## Chinese Input Method (fcitx5)

**Session-aware configuration** - install.sh detects `$XDG_SESSION_TYPE` at install.sh:177:

**X11 session:**
- Adds environment variables to `/etc/environment` (GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS, SDL_IM_MODULE, GLFW_IM_MODULE)
- Creates `~/.config/autostart/org.fcitx.Fcitx5.desktop`
- fcitx5 autostarts on login

**Wayland session (KDE Plasma):**
- No environment variables added (uses native Wayland input protocol)
- No autostart file created
- KWin launches fcitx5 via Virtual Keyboard setting
- **Configuration required:** System Settings → Input Devices → Virtual Keyboard → Select "Fcitx 5"

**Post-installation (both):**
1. Log out and log back in (required for environment changes)
2. Run `fcitx5-configtool` to add Pinyin input method
3. Toggle input with Ctrl+Space

**Wayland troubleshooting:** If you see GTK_IM_MODULE warnings, remove `~/.config/autostart/org.fcitx.Fcitx5.desktop` (updated install.sh prevents this). See `settings/README.md` (line 52-78) for detailed fix.

## Package Manager Context

- **pacman** - Official CachyOS/Arch package manager
- **AUR** - Arch User Repository (requires helper like yay to install)
- **yay** - AUR helper installed by install.sh (built from source in `/tmp`)
- `--needed` flag skips already-installed packages (enables idempotency)
- `--noconfirm` flag auto-confirms installations

## Dropbox + KDE Plasma 6 Configuration

**Critical timing issue:** Dropbox requires libappindicator to display tray icon, but if Dropbox starts too quickly (before libappindicator is ready), the icon won't load.

**Solution:** Add startup delay to systemd service:

```bash
systemctl --user edit dropbox
```

Add between the comment markers:
```ini
[Service]
ExecStart=
ExecStart=/bin/bash -c "sleep 10 && /usr/bin/dropbox"
```

This ensures libappindicator is fully loaded before Dropbox starts. See settings/README.md (lines 556-579) for complete instructions.

## Installed Applications Summary

**Development Tools:** base-devel, git, git-lfs, github-cli, vim, neovim, curl, wget, openssh, rsync, htop, btop, tmux, tree, fzf, ripgrep, fd, bat, exa, mesa-demos

**Languages & Compilers:** python, python-pip, python-virtualenv, gcc, clang, cmake, ninja, make, gdb, valgrind, pkg-config, jre-lts (Oracle Java 21 LTS, AUR)

**GUI Libraries:** gtkmm-4.0, gtkmm-4.0-docs, gtk4, libappindicator

**IDEs & Editors:** visual-studio-code-bin (AUR), cursor-bin (AUR), obsidian (AUR), okular, markdownpart, freeplane

**Browsers:** firefox, google-chrome (AUR)

**Chinese Support:** noto-fonts-cjk, wqy-zenhei, wqy-microhei, adobe-source-han-sans-cn-fonts, adobe-source-han-serif-cn-fonts, fcitx5, fcitx5-gtk, fcitx5-qt, fcitx5-configtool, fcitx5-chinese-addons

**Power Management:** tlp, tlp-rdw, powertop, thermald, cpupower, acpi, acpi_call, auto-cpufreq (AUR)

**Cloud & Communication:** dropbox (AUR), wechat-universal-bwrap (AUR), spotify (AUR)

## Post-Installation Actions

1. **Log out and log back in** - Required for fcitx5 to work
2. **Configure fcitx5** - Run `fcitx5-configtool` and add Pinyin
3. **Configure git** - `git config --global user.name/user.email`
4. **Verify power management** - `sudo tlp-stat`
5. **Reboot** - Recommended for power management to fully activate
6. **Setup Dropbox** - Run `dropbox` to link account (see settings/README.md lines 512-567)
7. **Create AI shortcuts** - Run `./create-shortcuts.sh` after Chrome is installed
