# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CachyOS (Arch-based Linux) fresh installation automation scripts. Four independent scripts that can be run in sequence or standalone:
1. **check-network.sh** - Network diagnostics and mirror optimization
2. **cleanup.sh** - Package removal (rust, go, nodejs, Code-OSS, vanilla kernel)
3. **install.sh** - Development environment installation (main script)
4. **create-shortcuts.sh** - Chrome app mode shortcuts for ChatGPT/Claude

## Key Directories

- `apps/` - .desktop files for AI assistant shortcuts
- `settings/` - Post-installation configuration documentation (login wallpaper, fcitx5 wayland fix)

## Running the Scripts

**Recommended sequence:** `./check-network.sh` → `./cleanup.sh` → `./install.sh`

**Important:** Never run as root - scripts prompt for sudo when needed.

Each script is idempotent (safe to run multiple times) and uses `set -e` (exits on first error).

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
install_aur_power_tools() → install_chinese_input()
```

**Why this pattern:** AUR packages (VSCode, Cursor, Chrome, Obsidian) require yay, but yay must be built from AUR first. Initial install functions check `command -v yay` and skip if unavailable, then retry functions install after `install_aur_helper()` completes.

**Key Installation Functions:**

- `install_power_management()` - Automatically detects and removes `power-profiles-daemon` (conflicts with TLP), enables TLP and thermald services, masks systemd-rfkill
- `install_chinese_input()` - Detects session type via `$XDG_SESSION_TYPE`:
  - **X11**: Adds environment variables to `/etc/environment`, creates autostart file
  - **Wayland (KDE Plasma)**: Uses native input protocol, no env vars needed, relies on KWin to launch fcitx5
- `install_aur_helper()` - Clones yay from AUR to `/tmp`, builds with `makepkg -si`

### check-network.sh

Tests connectivity (ping 8.8.8.8, DNS, CachyOS CDN), then uses `cachyos-rate-mirrors` to benchmark and rank mirrors. Backs up mirrorlist before changes, refreshes package databases after ranking.

### cleanup.sh

Interactive removal script. Scans for unwanted packages using `pacman -Qi`, prompts for confirmation, removes with `pacman -Rns` (tries force removal with `-Rdd` if dependencies block).

## Modifying Scripts

### Adding/removing packages in install.sh

Edit the relevant function (e.g., `install_dev_tools()`) and modify the `pacman -S` or `yay -S` command. For AUR packages, ensure they're in a function called after `install_aur_helper()`.

### Adding packages to cleanup.sh

Add to `cleanup_unwanted_packages()` following this pattern:
```bash
if pacman -Qi package-name &> /dev/null; then
    log_info "Found: package-name (reason)"
    unwanted_packages+=("package-name")
fi
```

## Power Management Configuration

**Default:** TLP (enabled and started by install.sh)
**Alternative:** auto-cpufreq (installed but not enabled)

**Conflict handling:** install.sh auto-removes `power-profiles-daemon` if detected (conflicts with TLP)

**Switch to auto-cpufreq:**
```bash
sudo systemctl disable tlp && sudo systemctl enable auto-cpufreq
```

**Rationale for TLP:** 20-35% battery improvement vs 10-15% with power-profiles-daemon, per-device power management (USB, PCIe, disk, Wi-Fi), automatic AC/battery mode switching.

## Chinese Input Method (fcitx5)

**Session-aware configuration** - install.sh detects `$XDG_SESSION_TYPE`:

**X11 session:**
- Adds environment variables to `/etc/environment` (GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS, SDL_IM_MODULE)
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

**Wayland troubleshooting:** If you see GTK_IM_MODULE warnings, remove `~/.config/autostart/org.fcitx.Fcitx5.desktop` (updated install.sh prevents this). See `settings/README.md` for details.

## Package Manager Context

- **pacman** - Official CachyOS/Arch package manager
- **AUR** - Arch User Repository (requires helper like yay to install)
- **yay** - AUR helper installed by install.sh (built from source in `/tmp`)
- `--needed` flag skips already-installed packages (enables idempotency)
- `--noconfirm` flag auto-confirms installations

## Post-Installation Actions

1. **Log out and log back in** - Required for fcitx5 to work
2. **Configure fcitx5** - Run `fcitx5-configtool` and add Pinyin
3. **Configure git** - `git config --global user.name/user.email`
4. **Verify power management** - `sudo tlp-stat`
5. **Reboot** - Recommended for power management to fully activate