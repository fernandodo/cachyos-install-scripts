# Dropbox Usage & KDE Tray Fix

Dropbox is installed by `install.sh`. In KDE Plasma 6 (especially on Wayland), the system tray icon often fails to appear because the systemd service lacks access to the graphical environment variables.

## Symptoms
- Dropbox is running (`systemctl --user status dropbox`) but no icon appears in the system tray.
- Manual starts work, but autostart at boot fails to show the icon.

## Solution: Systemd Service Override

To fix the tray icon, you must provide a delay and explicitly define the environment variables in a systemd override.

1.  **Create/Edit the override file:**
    ```bash
    systemctl --user edit dropbox
    ```

2.  **Paste the following configuration:**
    ```ini
    [Service]
    Type=simple
    # Clear the original ExecStart
    ExecStart=
    # 20s delay ensures KDE plasma is ready; 'exec' ensures correct process management
    ExecStart=/bin/bash -c "sleep 20 && exec /usr/bin/dropbox"
    
    # Critical environment variables for KDE 6 / Wayland compatibility
    Environment=DISPLAY=:0
    Environment=GDK_BACKEND=x11
    Environment=XDG_CURRENT_DESKTOP=Unity
    Environment=QT_QPA_PLATFORM=xcb
    
    Restart=always
    RestartSec=10
    ```

3.  **Apply the changes:**
    ```bash
    systemctl --user daemon-reload
    systemctl --user restart dropbox.service
    ```

## Important: Prevent Autostart Conflict
Dropbox often tries to create its own autostart file which lacks these fixes. To prevent it from overriding your systemd setup:

1.  **Disable internal autostart:**
    ```bash
    dropbox autostart n
    ```
2.  **Lock the autostart file (Optional but recommended):**
    ```bash
    rm -f ~/.config/autostart/dropbox.desktop
    mkdir -p ~/.config/autostart/dropbox.desktop
    ```

## Common Commands
- `dropbox status`: Check sync progress.
- `dropbox stop/start`: Manage the daemon manually.
- `dropbox help`: See all CLI options.
