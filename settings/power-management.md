# Power Management Guide

Complete guide to power management tools installed on your CachyOS system.

## System Information

- **CPU:** AMD Ryzen 5 PRO 5650U with Radeon Graphics
- **Kernel:** 6.17.9-2-cachyos (CachyOS optimized kernel)
- **Battery Threshold Support:** Yes (95% start, 100% stop)

---

## Installed Power Management Tools

### Active Tools

| Tool | Version | Status | Purpose |
|------|---------|--------|---------|
| **TLP** | 1.8.0-1 | ✓ Enabled & Active | Main power management daemon |
| **tlp-rdw** | 1.8.0-1 | Bundled with TLP | Radio Device Wizard for Wi-Fi/Bluetooth power management |

### Installed but Not Active

| Tool | Version | Status | Purpose |
|------|---------|--------|---------|
| **thermald** | 2.5.10-1.1 | Enabled but Inactive | Intel thermal management (not supported on AMD CPUs) |
| **auto-cpufreq** | 2.6.0-2 | Installed, Not Enabled | Alternative automatic CPU frequency optimizer |

### Diagnostic & Monitoring Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **powertop** | 2.15-2.1 | Power consumption analysis and optimization suggestions |
| **cpupower** | 6.17-3 | CPU frequency scaling and power state management |
| **acpi** | 1.8-2 | Battery, power, and thermal readings |
| **acpi_call** | 1.2.2-320 | Kernel module for ACPI method calls (battery thresholds) |

---

## Current Configuration

### TLP (Active Power Manager)

TLP is currently managing your system's power consumption.

**Service Status:**
```bash
$ systemctl status tlp
● tlp.service - TLP system startup/shutdown
   Loaded: loaded (/usr/lib/systemd/system/tlp.service; enabled)
   Active: active (exited)
```

**What TLP manages:**
- CPU frequency scaling and performance/power modes
- Hard drive power management (AHCI, SATA)
- PCI Express ASPM (Active State Power Management)
- USB device autosuspend
- Wi-Fi and Bluetooth power saving
- Display backlight brightness
- Battery charge thresholds (95-100% on your ThinkPad)

**Configuration Files:**
- Main config: `/etc/tlp.conf` (19KB, default settings)
- Drop-in configs: `/etc/tlp.d/` (for custom overrides)

**Battery Charge Thresholds:**
```
Start charging at: 95%
Stop charging at:  100%
```

This prevents constant trickle charging when plugged in near 100%, extending battery lifespan.

### Systemd-rfkill (Masked)

systemd-rfkill services are **masked** to prevent conflicts with TLP's radio device management:

```bash
● systemd-rfkill.service - masked
● systemd-rfkill.socket - masked
```

**Why masked:** TLP's Radio Device Wizard (tlp-rdw) handles Wi-Fi/Bluetooth power states. Running both would cause conflicts.

### Thermald (Not Running on AMD)

thermald is enabled but **not running** because it only supports Intel CPUs:

```bash
○ thermald.service - inactive (dead)
  Reason: "Unsupported cpu model or platform"
```

**Note:** This is expected behavior on AMD systems. AMD CPUs have their own thermal management built into the processor firmware.

---

## Common Commands

### TLP Commands

```bash
# View full TLP status and configuration
sudo tlp-stat

# View battery-specific information
sudo tlp-stat -b

# View disk information
sudo tlp-stat -d

# View PCI device information
sudo tlp-stat -e

# View processor information
sudo tlp-stat -p

# Start TLP (apply power saving settings)
sudo tlp start

# Check TLP version
tlp-stat -V
```

### Powertop Commands

```bash
# Launch interactive power consumption monitor
sudo powertop

# Generate HTML report
sudo powertop --html=powertop-report.html

# Auto-tune all power settings (temporary until reboot)
sudo powertop --auto-tune
```

**Note:** Don't use `powertop --auto-tune` permanently as it may conflict with TLP settings.

### CPU Power Management

```bash
# View current CPU frequency and governor
cpupower frequency-info

# Set CPU governor (requires TLP to be stopped)
sudo cpupower frequency-set -g powersave

# View available CPU governors
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
```

**Note:** TLP manages CPU governors automatically, so manual changes may be overridden.

### Battery Information

```bash
# View battery status (simple)
acpi

# View detailed battery info
acpi -V

# View battery charge thresholds
cat /sys/class/power_supply/BAT0/charge_control_start_threshold
cat /sys/class/power_supply/BAT0/charge_control_end_threshold

# Check battery capacity (current vs design)
cat /sys/class/power_supply/BAT0/energy_now
cat /sys/class/power_supply/BAT0/energy_full
cat /sys/class/power_supply/BAT0/energy_full_design
```

---

## Customizing TLP Settings

### Method 1: Edit Main Config (Not Recommended)

```bash
sudo vim /etc/tlp.conf
```

**Downside:** Updates to TLP package may overwrite `/etc/tlp.conf`.

### Method 2: Drop-in Config (Recommended)

Create a custom config file in `/etc/tlp.d/`:

```bash
sudo vim /etc/tlp.d/01-custom.conf
```

**Example custom settings:**

```bash
# Battery charge thresholds (already working via ACPI)
START_CHARGE_THRESH_BAT0=75
STOP_CHARGE_THRESH_BAT0=90

# CPU scaling governor (AC vs Battery)
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# CPU energy/performance policy
CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_BAT=power

# USB autosuspend (disable for specific devices)
USB_AUTOSUSPEND=1
USB_EXCLUDE_BTUSB=1
USB_EXCLUDE_PHONE=1

# Aggressive Wi-Fi power saving on battery
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on
```

**Apply changes:**
```bash
sudo tlp start
```

### Common Customizations

**Extend battery life (more aggressive):**
```bash
# In /etc/tlp.d/01-battery-life.conf
START_CHARGE_THRESH_BAT0=60
STOP_CHARGE_THRESH_BAT0=80
CPU_BOOST_ON_BAT=0
SOUND_POWER_SAVE_ON_BAT=10
```

**Maximize performance on AC:**
```bash
# In /etc/tlp.d/02-performance.conf
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_BOOST_ON_AC=1
SATA_LINKPWR_ON_AC=max_performance
```

---

## Switching to auto-cpufreq

If you prefer auto-cpufreq over TLP:

### Why Choose auto-cpufreq?

- Simpler configuration (automatic optimization)
- Active monitoring and dynamic adjustment
- Better for users who want "set and forget" power management

### Why Stick with TLP?

- More granular control over individual components
- Better battery life (20-35% improvement vs 10-15% with auto-cpufreq)
- Proven track record on ThinkPads
- Manages more devices (USB, PCIe, SATA, Wi-Fi, Bluetooth)

### How to Switch

**1. Disable TLP:**
```bash
sudo systemctl stop tlp
sudo systemctl disable tlp
```

**2. Enable auto-cpufreq:**
```bash
sudo systemctl enable auto-cpufreq
sudo systemctl start auto-cpufreq
```

**3. Verify:**
```bash
sudo auto-cpufreq --stats
```

**4. Monitor (live updates):**
```bash
sudo auto-cpufreq --monitor
```

### Switch Back to TLP

```bash
sudo systemctl stop auto-cpufreq
sudo systemctl disable auto-cpufreq
sudo systemctl enable tlp
sudo systemctl start tlp
```

---

## Troubleshooting

### TLP Not Working

**Check service status:**
```bash
systemctl status tlp
```

**Check for conflicts:**
```bash
systemctl status power-profiles-daemon
```

If power-profiles-daemon is running, it conflicts with TLP:
```bash
sudo systemctl stop power-profiles-daemon
sudo systemctl disable power-profiles-daemon
sudo pacman -Rdd power-profiles-daemon
sudo systemctl start tlp
```

### Battery Thresholds Not Working

**Check if your laptop supports it:**
```bash
ls /sys/class/power_supply/BAT0/charge_control_*
```

If the files don't exist, your laptop doesn't support charge thresholds.

**Manually set thresholds (temporary until reboot):**
```bash
echo 75 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold
echo 90 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
```

**Make permanent with TLP:**
```bash
# Add to /etc/tlp.d/01-battery.conf
START_CHARGE_THRESH_BAT0=75
STOP_CHARGE_THRESH_BAT0=90
```

Then restart TLP:
```bash
sudo tlp start
```

### High CPU Temperature

**Check thermal status:**
```bash
sensors
```

If `sensors` command not found:
```bash
sudo pacman -S lm_sensors
sudo sensors-detect  # Answer YES to all
sensors
```

**Check CPU frequency:**
```bash
watch -n 1 'grep MHz /proc/cpuinfo'
```

**Force power saving mode:**
```bash
sudo cpupower frequency-set -g powersave
```

### Poor Battery Life

**1. Check what's using power:**
```bash
sudo powertop
```

Press `Tab` to navigate to "Tunables" and see what can be optimized.

**2. Check for power-hungry processes:**
```bash
btop  # or htop
```

**3. Verify TLP is active:**
```bash
sudo tlp-stat -s
```

Look for:
```
+++ System Info
System         = CachyOS
TLP version    = 1.8.0
```

**4. Check if running on battery or AC:**
```bash
tlp-stat -s | grep "Power source"
```

**5. Review USB devices (some may prevent sleep):**
```bash
tlp-stat -u
```

---

## Power Consumption Benchmarks

### Expected Battery Life (AMD Ryzen 5 PRO 5650U)

| Workload | TLP Enabled | TLP Disabled | Improvement |
|----------|-------------|--------------|-------------|
| Idle (screen on) | 6-8W | 9-12W | ~33% |
| Web browsing | 8-12W | 12-16W | ~25% |
| Video playback | 10-14W | 14-18W | ~22% |
| Code compilation | 25-35W | 30-40W | ~14% |

**Battery capacity estimation:**
```bash
# Check battery capacity
cat /sys/class/power_supply/BAT0/energy_full_design  # Original capacity (Wh)
cat /sys/class/power_supply/BAT0/energy_full         # Current full capacity (Wh)
```

**Example calculation:**
- Battery capacity: 50Wh (typical for ThinkPad)
- Average power draw: 10W (light work)
- Estimated runtime: 50Wh ÷ 10W = **5 hours**

---

## Recommended Settings for ThinkPad

Your current setup is already optimized, but here are recommended tweaks:

**Create `/etc/tlp.d/01-thinkpad.conf`:**
```bash
# Battery charge thresholds (extend battery lifespan)
START_CHARGE_THRESH_BAT0=75
STOP_CHARGE_THRESH_BAT0=85

# CPU boost (disable on battery for longer runtime)
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0

# CPU scaling governor
CPU_SCALING_GOVERNOR_ON_AC=schedutil
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# AMD P-State driver (better than acpi-cpufreq)
CPU_DRIVER_OPMODE_ON_AC=active
CPU_DRIVER_OPMODE_ON_BAT=guided

# Platform profile (AMD laptops)
PLATFORM_PROFILE_ON_AC=balanced
PLATFORM_PROFILE_ON_BAT=low-power

# Disk power management
DISK_IDLE_SECS_ON_AC=0
DISK_IDLE_SECS_ON_BAT=2

# Wi-Fi power saving
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# Sound power saving
SOUND_POWER_SAVE_ON_AC=0
SOUND_POWER_SAVE_ON_BAT=1

# USB autosuspend
USB_AUTOSUSPEND=1

# Runtime PM for PCI devices
RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=auto
```

**Apply settings:**
```bash
sudo tlp start
sudo tlp-stat -s
```

---

## Additional Resources

**Official Documentation:**
- TLP Documentation: https://linrunner.de/tlp/
- TLP Settings Reference: https://linrunner.de/tlp/settings/
- Arch Wiki - TLP: https://wiki.archlinux.org/title/TLP
- Arch Wiki - Power Management: https://wiki.archlinux.org/title/Power_management

**Check Your Settings:**
```bash
# View all active TLP settings
sudo tlp-stat -c

# View battery info
sudo tlp-stat -b

# View temperatures
sudo tlp-stat -t
```

**Verify Power Savings:**
```bash
# Before changing settings
sudo powertop --html=before.html

# After changing settings (reboot first)
sudo powertop --html=after.html

# Compare the reports in a web browser
firefox before.html after.html
```
