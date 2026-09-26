# AirMesh

AirMesh is a lightweight Linux utility for clipboard synchronization and peer-to-peer file transfers over a local Wi-Fi network.

## Features

- **Java 11** using AWT, Swing, and Sockets
- UDP device discovery on **port 8888**
- TCP clipboard/file transfer on **port 8889**
- Clipboard synchronization with anti-echo protection
- Incoming files saved to `~/Downloads`
- GNOME tray/AppIndicator support
- Systemd user-service integration
- Works on X11 and Wayland
- No cloud service required

## Architecture

- `Main.java` — Application entry point and `--minimized` argument.
- `DiscoveryService.java` — UDP discovery using port `8888`.
- `NetworkServer` / `NetworkClient` — TCP communication using port `8889`.
- `ClipboardService.java` — System clipboard monitoring and synchronization.
- `wifi-sync-app.service` — Systemd background service.

## Requirements

- Linux
- Java 11+
- Apache Maven
- Systemd
- UFW (optional)

## Installation

```bash
chmod +x install.sh
./install.sh
```

The installer creates:

```text
JAR:       ~/.local/share/wifi-sync-app/
Launcher:  ~/.local/bin/wifi-sync-app
Service:   ~/.config/systemd/user/wifi-sync-app.service
```

## Systemd Service

AirMesh runs as a **user-level systemd service**.

### Reload Service Configuration

Run this after modifying the service file:

```bash
systemctl --user daemon-reload
```

### Enable and Start AirMesh

Enable the service to start automatically when you log in and start it immediately:

```bash
systemctl --user enable --now wifi-sync-app.service
```

### Check Service Status

```bash
systemctl --user status wifi-sync-app.service
```

### Start Service

```bash
systemctl --user start wifi-sync-app.service
```

### Stop Service

```bash
systemctl --user stop wifi-sync-app.service
```

### Restart Service

```bash
systemctl --user restart wifi-sync-app.service
```

### Enable Automatic Startup

```bash
systemctl --user enable wifi-sync-app.service
```

### Disable Automatic Startup

```bash
systemctl --user disable wifi-sync-app.service
```

### Check Whether Service Is Enabled

```bash
systemctl --user is-enabled wifi-sync-app.service
```

### Check Whether Service Is Running

```bash
systemctl --user is-active wifi-sync-app.service
```

## Logs

### View Last 100 Logs

```bash
journalctl --user -u wifi-sync-app.service -n 100
```

### View Logs Without Pager

```bash
journalctl --user -u wifi-sync-app.service -n 100 --no-pager
```

### View Live Logs

```bash
journalctl --user -u wifi-sync-app.service -f
```

### View All Service Logs

```bash
journalctl --user -u wifi-sync-app.service
```

## Service File

Show the installed systemd service:

```bash
systemctl --user cat wifi-sync-app.service
```

Check the actual service file:

```bash
cat ~/.config/systemd/user/wifi-sync-app.service
```

Verify the service configuration:

```bash
systemd-analyze --user verify ~/.config/systemd/user/wifi-sync-app.service
```

After changing the service file:

```bash
systemctl --user daemon-reload
systemctl --user restart wifi-sync-app.service
```

## Firewall Setup (UFW)

AirMesh requires:

| Port | Protocol | Purpose |
|------|----------|---------|
| `8888` | UDP | Device discovery |
| `8889` | TCP | Clipboard and file transfer |

Allow UDP discovery:

```bash
sudo ufw allow 8888/udp
```

Allow TCP transfers:

```bash
sudo ufw allow 8889/tcp
```

Reload UFW:

```bash
sudo ufw reload
```

Check firewall status:

```bash
sudo ufw status
```

## Verify Listening Ports

Check UDP discovery:

```bash
sudo ss -lunp | grep 8888
```

Check TCP transfer:

```bash
sudo ss -ltnp | grep 8889
```

Expected UDP output:

```text
UNCONN 0 0 0.0.0.0:8888 0.0.0.0:*
```

Expected TCP output:

```text
LISTEN 0 50 0.0.0.0:8889 0.0.0.0:*
```

## GNOME Tray Fix

If the AirMesh tray icon does not appear on GNOME:

### Enable AppIndicator Support

```bash
gnome-extensions enable ubuntu-appindicators@ubuntu.com 2>/dev/null || \
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com 2>/dev/null
```

### Import GUI Environment Variables

```bash
systemctl --user import-environment \
DISPLAY \
WAYLAND_DISPLAY \
XAUTHORITY \
DBUS_SESSION_BUS_ADDRESS \
XDG_RUNTIME_DIR
```

### Restart AirMesh

```bash
systemctl --user restart wifi-sync-app.service
```

## Manual Execution

Run AirMesh manually:

```bash
wifi-sync-app
```

Start minimized:

```bash
wifi-sync-app --minimized
```

Or run the launcher directly:

```bash
~/.local/bin/wifi-sync-app --minimized
```

## Troubleshooting

### Check Whether the Service Exists

```bash
systemctl --user list-unit-files | grep wifi-sync-app
```

### Check Service Status

```bash
systemctl --user status wifi-sync-app.service
```

### Check Recent Errors

```bash
journalctl --user -u wifi-sync-app.service -n 100 --no-pager
```

### Check Running Java Process

```bash
pgrep -a java
```

Or specifically:

```bash
pgrep -af wifi-sync-app
```

### Check AirMesh Files

```bash
ls -l ~/.local/share/wifi-sync-app/
```

```bash
ls -l ~/.local/bin/wifi-sync-app
```

```bash
ls -l ~/.config/systemd/user/wifi-sync-app.service
```

## Complete Service Restart

If AirMesh is not responding, run:

```bash
systemctl --user daemon-reload
systemctl --user restart wifi-sync-app.service
systemctl --user status wifi-sync-app.service
```

Then check logs:

```bash
journalctl --user -u wifi-sync-app.service -n 100 --no-pager
```

## Network Troubleshooting

Check the local IP address:

```bash
hostname -I
```

Or:

```bash
ip addr
```

Check UDP discovery:

```bash
sudo ss -lunp | grep 8888
```

Check TCP transfer:

```bash
sudo ss -ltnp | grep 8889
```

From another device on the same network, test TCP port `8889`:

```bash
nc -vz <AIR-MESH-IP> 8889
```

Example:

```bash
nc -vz 192.168.1.20 8889
```

Both devices must:

- Be connected to the same Wi-Fi/LAN.
- Have AirMesh running.
- Allow UDP `8888`.
- Allow TCP `8889`.
- Not use Wi-Fi client isolation.
- Not have a VPN blocking local traffic.

## Quick Start

For a fresh installation:

```bash
chmod +x install.sh
./install.sh
```

Enable and start the service:

```bash
systemctl --user daemon-reload
systemctl --user enable --now wifi-sync-app.service
```

Check status:

```bash
systemctl --user status wifi-sync-app.service
```

Check logs:

```bash
journalctl --user -u wifi-sync-app.service -f
```

Configure firewall:

```bash
sudo ufw allow 8888/udp
sudo ufw allow 8889/tcp
sudo ufw reload
```

Check ports:

```bash
sudo ss -lunp | grep 8888
sudo ss -ltnp | grep 8889
```

## Uninstallation

Stop and disable the service:

```bash
systemctl --user disable --now wifi-sync-app.service
```

Remove application files:

```bash
rm -rf ~/.local/share/wifi-sync-app
```

Remove launcher:

```bash
rm -f ~/.local/bin/wifi-sync-app
```

Remove systemd service:

```bash
rm -f ~/.config/systemd/user/wifi-sync-app.service
```

Reload systemd:

```bash
systemctl --user daemon-reload
```

Remove firewall rules:

```bash
sudo ufw delete allow 8888/udp
sudo ufw delete allow 8889/tcp
```

## Network Architecture

```text
                    Local Wi-Fi / LAN
                           |
             +-------------+-------------+
             |                           |
             v                           v
       +-----------+               +-----------+
       |  Device A |               |  Device B |
       |  AirMesh  |               |  AirMesh  |
       +-----------+               +-----------+
             |                           |
             |<---- UDP 8888 ---------->|
             |     Discovery            |
             |                           |
             |<---- TCP 8889 ---------->|
             | Clipboard / Files        |
             |                           |
             +---------------------------+
```

### UDP Port 8888

Used for:

- Device discovery
- UDP broadcast
- Discovery requests
- Discovery responses

### TCP Port 8889

Used for:

- Clipboard synchronization
- File transfers
- Incoming connections
- Peer-to-peer communication

## Security

AirMesh is designed for trusted local networks.

- Do not expose port `8889` to the public internet.
- Do not forward ports `8888` or `8889` on your router.
- Avoid using AirMesh on untrusted public Wi-Fi.
- Incoming file transfers should require user confirmation.
- Use firewall rules to limit access where appropriate.

## License

Add your project license here.

## Author

**AirMesh**

A lightweight Linux utility for local-network clipboard synchronization and peer-to-peer file transfers.
