# System Settings & Tweaks

This directory contains documentation for customizing your CachyOS system after installation.

## Documentation Files

- **[power-management.md](power-management.md)** - Complete guide to power management tools (TLP, auto-cpufreq, powertop, battery thresholds, etc.)

---

## Change Login Screen Wallpaper

**GUI Method (Recommended):**

1. Open **System Settings**
2. Navigate to **Login Screen (SDDM)**
3. Change the **Background** image
4. Click **Apply**

**Available system wallpapers**: `/usr/share/wallpapers/*/contents/images/5120x2880.png`

---

## Change Lock Screen Wallpaper

The **lock screen** wallpaper is different from the **login screen** wallpaper.

**GUI Method (Recommended):**

1. Open **System Settings**
2. Navigate to **Screen Locking** (or search for "lock")
3. Click **Configure Appearance**
4. Select your desired wallpaper
5. Click **Apply**

**Alternative - Use Desktop Wallpaper:**

If you want the lock screen to match your desktop wallpaper:

1. Open **System Settings**
2. Navigate to **Screen Locking**
3. Click **Configure Appearance**
4. Choose the same wallpaper as your desktop

**Note:** KDE Plasma has three separate wallpaper settings:
- **Desktop wallpaper** (right-click desktop → Configure Desktop and Wallpaper)
- **Lock screen wallpaper** (System Settings → Screen Locking → Configure Appearance)
- **Login screen wallpaper** (System Settings → Login Screen SDDM)

---

## Fix fcitx5 Wayland Warning

If you see a warning about GTK_IM_MODULE/QT_IM_MODULE when using fcitx5 on KDE Plasma Wayland, this is the fix.

**The Issue:**
- fcitx5 was being launched TWICE: via autostart file AND by KWin
- On KDE Plasma Wayland, fcitx5 should ONLY be launched by KWin
- The autostart file created by the old install.sh causes conflicts

**The Fix:**

```bash
rm ~/.config/autostart/org.fcitx.Fcitx5.desktop
fcitx5 -r
```

**How it works:**
- KDE Plasma Wayland requires fcitx5 to be launched by KWin (via Virtual Keyboard setting)
- The autostart file conflicts with this and causes warning messages
- Removing it allows KWin to properly manage fcitx5

**Configuration:**
1. System Settings → Input Devices → Virtual Keyboard → Select "Fcitx 5"
2. Configure input methods: `fcitx5-configtool`

**Note**: The updated `install.sh` script now automatically detects Wayland and won't create the autostart file.

**Reference**: [Arch Wiki - Fcitx5 KDE Plasma](https://wiki.archlinux.org/title/Fcitx5#KDE_Plasma)

---

## Enable SSH Access from Other Computers

SSH server is installed by `install.sh`, but the firewall blocks incoming connections by default.

**Your laptop hostname:** `cachyos-thinkpad`
**mDNS name:** `cachyos-thinkpad.local` (Avahi is running)

### Step 1: Enable and Start SSH Server

```bash
sudo systemctl enable sshd
sudo systemctl start sshd
```

### Step 2: Allow SSH Through Firewall

**If using UFW:**

```bash
# Check firewall status
sudo ufw status

# Allow SSH port 22
sudo ufw allow ssh
# or
sudo ufw allow 22/tcp
```

**If using iptables/nftables:**

```bash
# Allow SSH through firewall
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Save rules (Arch/CachyOS)
sudo iptables-save > /etc/iptables/iptables.rules
sudo systemctl enable iptables
```

### Step 3: Connect from Other Computers

From another computer on the same network:

```bash
# Using mDNS hostname (recommended)
ssh username@cachyos-thinkpad.local

# Or using IP address
ssh username@192.168.1.19
```

**Note for other computers:**
- **Linux**: Install `avahi` or `nss-mdns` for `.local` hostname resolution
- **macOS**: Works by default (Bonjour)
- **Windows**: Install Bonjour or use IP address instead of `.local` hostname

### Troubleshooting

**Test if SSH port is reachable from other computer:**

```bash
# Test connectivity
nc -zv cachyos-thinkpad.local 22
# or
telnet cachyos-thinkpad.local 22
```

**Check SSH is listening on laptop:**

```bash
ss -tlnp | grep :22
```

**Check firewall rules on laptop:**

```bash
sudo ufw status
# or
sudo iptables -L -n | grep 22
```

### Disable SSH Access (Reverse Setup)

To disable SSH and re-enable firewall protection:

**Step 1: Block SSH in Firewall**

```bash
# If using UFW
sudo ufw delete allow ssh
# or
sudo ufw delete allow 22/tcp

# If using iptables
sudo iptables -D INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables-save > /etc/iptables/iptables.rules
```

**Step 2: Stop and Disable SSH Server**

```bash
# Stop SSH server
sudo systemctl stop sshd

# Disable SSH server from starting on boot
sudo systemctl disable sshd

# Verify it's stopped
sudo systemctl status sshd
```

This will prevent incoming SSH connections and stop the SSH service from running.

---

## Change Default Shell to Bash

If you have issues with fish shell in remote connections (SSH, VSCode Remote), change your default shell to bash.

```bash
# Change default shell to bash
chsh -s /bin/bash

# Verify the change
grep $USER /etc/passwd
```

**Log out and log back in** for the change to take effect.

**Result:** All SSH connections and VSCode Remote will use bash by default.

---

## Enable Mouse Control in Tmux

Enable mouse support in tmux for easier pane selection, resizing, and scrolling.

**Add to `~/.tmux.conf`:**

```bash
# Enable mouse support
set -g mouse on
```

**Apply the configuration:**

```bash
# If tmux is already running, reload config
tmux source-file ~/.tmux.conf
```

**What mouse control enables:**
- Click to select panes
- Drag pane borders to resize
- Scroll with mouse wheel to navigate history
- Click on window names in status bar to switch windows
- Select and copy text with mouse

**To apply:**

```bash
# Create or edit tmux config
vim ~/.tmux.conf
# or
nano ~/.tmux.conf

# Add the line: set -g mouse on

# Reload config (if tmux is running)
tmux source-file ~/.tmux.conf
```

New tmux sessions will automatically have mouse support enabled.

---

## Adjust Swap Size (zram)

Your system uses **zram** (compressed RAM as swap). Current size: **11.5GB** (equals RAM size).

**Current configuration:** `/usr/lib/systemd/zram-generator.conf`
- `zram-size = ram` (same as physical RAM)
- Compression: zstd
- Priority: 100

### Change zram Size

**Create custom configuration:**

```bash
sudo vim /etc/systemd/zram-generator.conf
```

**Add one of these configurations:**

```ini
[zram0]
# Option 1: Half of RAM (recommended for 8GB+ RAM)
zram-size = ram / 2

# Option 2: Same as RAM (current default)
zram-size = ram

# Option 3: Double RAM (for systems with low RAM)
zram-size = ram * 2

# Option 4: Fixed size (e.g., 8GB)
zram-size = 8192

# Keep these settings
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
```

**Apply changes:**

```bash
# Reboot to apply
sudo reboot
```

**Verify new size:**

```bash
# Check swap size
swapon --show

# Detailed info
zramctl
```

### Recommendations:

- **8GB+ RAM**: `ram / 2` (saves RAM for applications)
- **4-8GB RAM**: `ram` (balanced)
- **<4GB RAM**: `ram * 2` (maximize swap space)

**Note:** zram uses compression (zstd), so actual memory usage is much less than the swap size shown.

---

## Dropbox Usage

Dropbox is installed by `install.sh`. Here's how to set it up and use it.

### First Launch

```bash
# Start Dropbox for the first time
dropbox

# Or use systemd to auto-start on login
systemctl --user enable dropbox
systemctl --user start dropbox
```

On first launch, Dropbox will:
1. Download the Dropbox daemon (~100MB)
2. Open a browser window to link your account
3. Create `~/Dropbox` folder

### Commands

```bash
# Start Dropbox
dropbox start

# Stop Dropbox
dropbox stop

# Check status
dropbox status

# Command-line interface
dropbox help
```

### Auto-start on Login

**Option 1: Systemd (recommended)**
```bash
systemctl --user enable dropbox
systemctl --user start dropbox
```

**Option 2: KDE Autostart**
1. System Settings → Autostart
2. Add Program → `/usr/bin/dropbox start`

### Uninstall

```bash
# Remove Dropbox
yay -R dropbox

# Remove Dropbox folder (optional)
rm -rf ~/Dropbox
rm -rf ~/.dropbox ~/.dropbox-dist
```
