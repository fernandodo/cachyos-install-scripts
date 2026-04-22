# Dropbox Usage & KDE Tray Fix

Dropbox is installed by `install.sh`. In KDE Plasma 6 (especially on Wayland), the system tray icon often fails to appear because the systemd service lacks access to graphical environment variables and conflicts with Dropbox's internal updater.

## Symptoms
- Dropbox is running but no icon appears in the tray.
- The icon appears briefly but disappears and restarts every 30-60 seconds.

## Final Solution: Systemd Service Override

The most stable way to run Dropbox on KDE 6 is to **bypass the wrapper script** and directly execute the latest core binary in your home directory.

1.  **Edit the override file:**
    ```bash
    systemctl --user edit dropbox
    ```

2.  **Use this exact configuration:**
    ```ini
    [Service]
    Type=simple
    # Ensure KDE plasma is ready
    ExecStartPre=/usr/bin/sleep 20
    # Clear original ExecStart
    ExecStart=
    # Directly execute the latest core binary in ~/.dropbox-dist (bypasses wrapper exit issues)
    ExecStart=/bin/bash -c "exec $(ls -d /home/felux/.dropbox-dist/dropbox-lnx.x86_64-*/dropbox | tail -n 1)"

    # Critical environment variables for Tray Icon compatibility
    Environment=DISPLAY=:0
    Environment=GDK_BACKEND=x11
    Environment=XDG_CURRENT_DESKTOP=Unity
    Environment=QT_QPA_PLATFORM=xcb

    Restart=always
    RestartSec=15
    ```

3.  **Apply and Restart:**
    ```bash
    systemctl --user daemon-reload
    # Clean up any old lingering processes first
    pkill -9 dropbox
    systemctl --user restart dropbox.service
    ```

## Prevent Autostart Conflict
Dropbox's internal "Start Dropbox on startup" setting will create a conflicting `~/.config/autostart/dropbox.desktop` file. You should block this:

1.  **Disable internal autostart:**
    ```bash
    dropbox autostart n
    ```
2.  **Lock the autostart path:**
    ```bash
    rm -f ~/.config/autostart/dropbox.desktop
    mkdir -p ~/.config/autostart/dropbox.desktop
    ```

## Common Commands
- `dropbox status`: Check sync progress.
- `dropbox stop/start`: Manage the daemon manually.
- `dropbox help`: See all CLI options.
