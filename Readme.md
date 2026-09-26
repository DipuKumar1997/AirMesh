# AirMesh

AirMesh is a lightweight, cross-device background utility for Linux designed to automatically synchronize system clipboards and enable peer-to-peer file transfers across a shared local Wi-Fi network.

---

## Basic Info

AirMesh runs silently in your Linux system tray or top-bar extension area. Once active, devices connected to the same local Wi-Fi network running AirMesh automatically discover one another and synchronize clipboard text and file selections without relying on cloud services or external servers.

### Core Features

* Automatic local device discovery using UDP broadcasting.
* Real-time bidirectional clipboard text and file synchronization.
* Direct TCP peer-to-peer file transfers with prompt confirmation dialogs.
* Systemd user service integration for automated background execution on boot/login.
* Top-bar system tray integration via GNOME AppIndicators or standard desktop trays.

---

## Architecture & Developer Guide

AirMesh is implemented in Java 11 using native AWT, Swing, and Socket networking to remain lightweight and dependency-free.

### Codebase Structure

1. **`Main.java` (Application Entry Point)**
   * Configures system Swing Look and Feel.
   * Parses command-line arguments such as `--minimized` passed by systemd or autostart shortcuts.

2. **`com.wifisync.network.DiscoveryService` (UDP Peer Discovery)**
   * Listens on UDP port `8888`.
   * Periodically sends broadcast packets (`WIFI_SYNC_DISCOVER_REQ`) across all active network interfaces.
   * Responds with local hostname information (`WIFI_SYNC_DISCOVER_RESP:<hostname>`) upon receiving discovery requests.

3. **`com.wifisync.network.NetworkServer` & `NetworkClient` (TCP Data Handler)**
   * Server listens on TCP port `8889` for inbound data payloads.
   * Handles multi-threaded transfers for `CLIPBOARD` text streams and `FILE` byte streams.
   * Prompts user approval via interactive Swing dialogs before writing incoming files to `~/Downloads`.

4. **`com.wifisync.service.ClipboardService` (Clipboard Listener)**
   * Registers a `java.awt.datatransfer.FlavorListener` to detect system copy events (`Ctrl+C`).
   * Differentiates between text payloads (`DataFlavor.stringFlavor`) and file lists (`DataFlavor.javaFileListFlavor`).
   * Uses an internal `isSelfUpdating` flag to prevent infinite clipboard echo loops during remote updates.

5. **`airmesh.service` (Systemd User Service)**
   * Installed at `~/.config/systemd/user/airmesh.service`.
   * Imports active GUI environment variables (`DISPLAY`, `WAYLAND_DISPLAY`, `XAUTHORITY`, `DBUS_SESSION_BUS_ADDRESS`, `XDG_RUNTIME_DIR`) into systemd scope to ensure AWT tray UI elements render correctly under X11/Wayland.

---

## Prerequisites

* Operating System: Linux (Ubuntu, Debian, Fedora, Arch Linux, etc.)
* Java Runtime Environment (JRE) / JDK 11 or higher
* Apache Maven
* Systemd
* UFW (optional, recommended if firewall protection is enabled)

---

# Installation & Setup

### 1. Make the Installation Script Executable

```bash
chmod +x install.sh
```

### 2. Run the Installer

```bash
./install.sh
```

The script compiles the application via Maven, copies binary files to `~/.local/share/airmesh/`, places a wrapper script in `~/.local/bin/airmesh`, registers the desktop shortcut, and enables the background systemd service.

---

# Comprehensive Service Management Commands

AirMesh runs as a user-level systemd service (`airmesh.service` or `wifi-sync-app.service`).

Use the following commands in your terminal to manage and verify the service status.

## 1. Check Service Status

To check if the service is currently running, active, or failing:

```bash
systemctl --user status airmesh.service
```

If your service is named `wifi-sync-app.service`, use:

```bash
systemctl --user status wifi-sync-app.service
```

---

## 2. View Live Application Logs

To stream live console logs, connection events, and runtime errors:

```bash
journalctl --user -u airmesh.service -f
```

To view the last 100 log lines:

```bash
journalctl --user -u airmesh.service -n 100
```

To view logs without following them:

```bash
journalctl --user -u airmesh.service
```

---

## 3. Start, Stop, and Restart Service

### Start Service

```bash
systemctl --user start airmesh.service
```

### Stop Service

```bash
systemctl --user stop airmesh.service
```

### Restart Service

```bash
systemctl --user restart airmesh.service
```

---

## 4. Enable or Disable Automatic Startup

### Enable on system login

```bash
systemctl --user enable airmesh.service
```

### Disable on system login

```bash
systemctl --user disable airmesh.service
```

### Enable and start immediately

```bash
systemctl --user enable --now airmesh.service
```

---

## 5. Verify Running Process

To verify that the Java application process is running:

```bash
pgrep -a java | grep airmesh
```

You can also search for all Java processes:

```bash
pgrep -a java
```

---

# Troubleshooting & Common Fixes

## Top-Bar Extension Icon Missing

If the top-bar icon does not appear, ensure GNOME AppIndicators support is enabled and display variables are imported into systemd.

### 1. Enable GNOME AppIndicators

```bash
gnome-extensions enable ubuntu-appindicators@ubuntu.com 2>/dev/null || \
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com 2>/dev/null
```

### 2. Re-import Graphical Display Session Variables

```bash
systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS XDG_RUNTIME_DIR
```

Then restart AirMesh:

```bash
systemctl --user restart airmesh.service
```

---

# Firewall Port Access

AirMesh requires the following network ports:

| Port | Protocol | Purpose |
|------|----------|---------|
| `8888` | UDP | Device discovery and broadcast |
| `8889` | TCP | Clipboard and file transfers |

If Ubuntu's UFW firewall is enabled, allow these ports.

## Allow UDP Discovery

```bash
sudo ufw allow 8888/udp
```

## Allow TCP File and Clipboard Transfers

```bash
sudo ufw allow 8889/tcp
```

## Check UFW Status

```bash
sudo ufw status
```

Expected output:

```text
Status: active

To                         Action      From
--                         ------      ----
8888/udp                   ALLOW       Anywhere
8889/tcp                   ALLOW       Anywhere
```

For IPv6-enabled UFW configurations, you may also see:

```text
8888/udp (v6)              ALLOW       Anywhere (v6)
8889/tcp (v6)              ALLOW       Anywhere (v6)
```

---

## Enable UFW

If UFW is installed but currently disabled:

```bash
sudo ufw enable
```

> **Warning:** Enabling UFW can block existing network connections depending on your current rules. If you are connected to a remote machine through SSH, allow SSH first.

```bash
sudo ufw allow ssh
```

Then:

```bash
sudo ufw enable
```

---

## Remove AirMesh Firewall Rules

If you want to remove the AirMesh firewall rules later:

```bash
sudo ufw delete allow 8888/udp
```

```bash
sudo ufw delete allow 8889/tcp
```

---

## Reset UFW Completely

If you need to reset UFW to its default configuration:

```bash
sudo ufw reset
```

> **Warning:** `ufw reset` removes existing UFW rules, including rules unrelated to AirMesh. Use this only if you intentionally want to reset the firewall.

---

# Verify AirMesh Network Ports

After starting AirMesh, verify that the application is listening on the expected ports.

## Check UDP Port 8888

```bash
sudo ss -lunp | grep 8888
```

Expected output should contain something similar to:

```text
UNCONN 0 0 0.0.0.0:8888 0.0.0.0:*
```

## Check TCP Port 8889

```bash
sudo ss -ltnp | grep 8889
```

Expected output should contain something similar to:

```text
LISTEN 0 50 0.0.0.0:8889 0.0.0.0:*
```

If both ports are listening and UFW allows them, AirMesh should be able to communicate with other devices on the same local network.

---

# Test Connectivity Between Devices

From another device on the same Wi-Fi network, test TCP connectivity to the AirMesh machine.

Replace `<AIR-MESH-IP>` with the local IP address of the AirMesh machine.

```bash
nc -vz <AIR-MESH-IP> 8889
```

Example:

```bash
nc -vz 192.168.1.20 8889
```

A successful connection should report something similar to:

```text
Connection to 192.168.1.20 8889 port [tcp/*] succeeded!
```

If `nc` is not installed:

### Ubuntu/Debian

```bash
sudo apt install netcat-openbsd
```

Then:

```bash
nc -vz <AIR-MESH-IP> 8889
```

---

# Testing UDP Discovery

AirMesh uses UDP broadcast on port `8888` for device discovery.

Verify that both devices:

1. Are connected to the same local Wi-Fi/LAN.
2. Have AirMesh running.
3. Have UDP port `8888` allowed.
4. Have TCP port `8889` allowed.
5. Are not connected through a guest Wi-Fi network with client isolation.
6. Are not being blocked by another firewall.
7. Are not using a VPN that interferes with local network traffic.

Check the local IP address:

```bash
ip addr
```

Or:

```bash
hostname -I
```

---

# Quick AirMesh Network Checklist

If devices cannot discover or communicate with each other, check the following:

```text
[ ] Both devices are connected to the same Wi-Fi/LAN
[ ] AirMesh is running on both devices
[ ] UDP port 8888 is allowed
[ ] TCP port 8889 is allowed
[ ] UFW is configured correctly
[ ] AirMesh is listening on port 8888
[ ] AirMesh is listening on port 8889
[ ] Wi-Fi AP/client isolation is disabled
[ ] No VPN is interfering with local network traffic
[ ] Systemd service is running correctly
```

Useful commands:

```bash
systemctl --user status airmesh.service
```

```bash
journalctl --user -u airmesh.service -n 100
```

```bash
sudo ufw status
```

```bash
sudo ss -lunp | grep 8888
```

```bash
sudo ss -ltnp | grep 8889
```

```bash
ip addr
```

---

# Manual Launch

If you want to test AirMesh without systemd, run it directly:

```bash
airmesh
```

To start it minimized:

```bash
airmesh --minimized
```

This is useful when debugging startup or systemd-related problems.

---

# Systemd Troubleshooting

If the service fails to start, first check:

```bash
systemctl --user status airmesh.service
```

Then inspect the logs:

```bash
journalctl --user -u airmesh.service -n 100 --no-pager
```

For live logs:

```bash
journalctl --user -u airmesh.service -f
```

Reload systemd configuration if the service file was modified:

```bash
systemctl --user daemon-reload
```

Then restart:

```bash
systemctl --user restart airmesh.service
```

Check whether the service is enabled:

```bash
systemctl --user is-enabled airmesh.service
```

Check whether the service is running:

```bash
systemctl --user is-active airmesh.service
```

---

# Checking the Service File

Display the installed service file:

```bash
systemctl --user cat airmesh.service
```

Check the service configuration without starting it:

```bash
systemd-analyze --user verify ~/.config/systemd/user/airmesh.service
```

---

# Stopping AirMesh Completely

To stop the systemd service:

```bash
systemctl --user stop airmesh.service
```

To prevent it from starting automatically:

```bash
systemctl --user disable airmesh.service
```

To terminate any remaining Java process associated with AirMesh:

```bash
pkill -f airmesh
```

---

# Uninstallation

If an uninstall script is provided:

```bash
chmod +x uninstall.sh
```

Then:

```bash
./uninstall.sh
```

Otherwise, remove the installed application and service manually.

### 1. Stop and Disable the Service

```bash
systemctl --user disable --now airmesh.service
```

### 2. Remove Application Files

```bash
rm -rf ~/.local/share/airmesh
```

### 3. Remove Wrapper Script

```bash
rm -f ~/.local/bin/airmesh
```

### 4. Remove Systemd Service

```bash
rm -f ~/.config/systemd/user/airmesh.service
```

### 5. Reload User Systemd Configuration

```bash
systemctl --user daemon-reload
```

### 6. Remove Firewall Rules

```bash
sudo ufw delete allow 8888/udp
sudo ufw delete allow 8889/tcp
```

---

# Network Architecture

AirMesh uses two network ports:

```text
                         Local Wi-Fi / LAN
                                |
              +-----------------+-----------------+
              |                                   |
              v                                   v
        +-----------+                       +-----------+
        |  Device A |                       |  Device B |
        |  AirMesh  |                       |  AirMesh  |
        +-----------+                       +-----------+
              |                                   |
              | UDP 8888                           |
              | <---- Device Discovery ----------> |
              |                                   |
              | TCP 8889                           |
              | <--- Clipboard / File Transfer --> |
              |                                   |
              +-----------------------------------+
```

### UDP `8888`

Used for:

* Device discovery
* UDP broadcast requests
* Discovery responses
* Finding AirMesh devices on the local network

### TCP `8889`

Used for:

* Clipboard synchronization
* File transfers
* Incoming connection handling
* Direct peer-to-peer communication

---

# Security Considerations

AirMesh is designed for trusted local networks.

Because AirMesh communicates directly between devices on the LAN:

* Do not expose TCP port `8889` directly to the public internet.
* Do not forward ports `8888` or `8889` from your router.
* Use AirMesh primarily on trusted home, college, office, or private networks.
* Incoming file transfers should require user confirmation.
* Avoid using AirMesh on untrusted public Wi-Fi networks.
* Firewall rules should restrict access to the local network where possible.

For a trusted local network, the basic UFW rules are:

```bash
sudo ufw allow 8888/udp
sudo ufw allow 8889/tcp
```

---

# Quick Start

For a fresh Ubuntu installation:

```bash
chmod +x install.sh
./install.sh
```

Allow the required firewall ports:

```bash
sudo ufw allow 8888/udp
sudo ufw allow 8889/tcp
```

Check the service:

```bash
systemctl --user status airmesh.service
```

Check the application logs:

```bash
journalctl --user -u airmesh.service -f
```

Check the network ports:

```bash
sudo ss -lunp | grep 8888
sudo ss -ltnp | grep 8889
```

Check the firewall:

```bash
sudo ufw status
```

---

**AirMesh**

A lightweight local-network clipboard synchronization and peer-to-peer file transfer utility for Linux.
