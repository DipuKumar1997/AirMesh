# AirMesh

AirMesh is a lightweight, cross-device background utility designed to automatically synchronize system clipboards and enable peer-to-peer file transfers across a shared local Wi-Fi network.

---

## Basic Overview

RelayNet operates silently in the system tray / top-bar extension area. Once installed, devices on the same local network running RelayNet will automatically discover each other and broadcast clipboard copies (text and files) without relying on external cloud servers.

### Core Features
* Automatic local network device discovery via UDP broadcasting.
* Real-time system clipboard synchronization (text and copied files).
* Peer-to-peer TCP file transfer with prompt approval dialogs.
* Systemd user service integration for automated system startup.
* System tray integration with minimize-to-tray capabilities.

---

## Architecture & Developer Guide

RelayNet is written in Java 11 using standard Java AWT, Swing, and Socket APIs to minimize external dependencies.

### Module Breakdown

1. **`Main.java` (Application Entry Point)**
   * Initializes look-and-feel settings.
   * Checks startup flags (e.g., `--minimized`) passed by systemd or desktop entry shortcuts.

2. **`com.wifisync.network.DiscoveryService` (UDP Discovery)**
   * Listens on UDP port `8888`.
   * Sends broadcast packets (`WIFI_SYNC_DISCOVER_REQ`) across active network interfaces.
   * Responds with host details (`WIFI_SYNC_DISCOVER_RESP:<hostname>`) when requested by peers.

3. **`com.wifisync.network.NetworkServer` & `NetworkClient` (TCP Data Stream)**
   * Listens on TCP port `8889` for inbound requests.
   * Handles multi-threaded socket streams for `CLIPBOARD` text payloads and `FILE` byte streams.
   * Evaluates user confirmation via Swing dialogs before writing file transfers to target disk locations.

4. **`com.wifisync.service.ClipboardService` (System Monitor)**
   * Registers a `java.awt.datatransfer.FlavorListener` to detect local `Ctrl+C` clipboard changes.
   * Differentiates between text content (`DataFlavor.stringFlavor`) and file selections (`DataFlavor.javaFileListFlavor`).
   * Suppresses recursive echo loops during automated remote updates.

5. **`wifi-sync-app.service` (Systemd Integration)**
   * Registered as a user-level background service (`~/.config/systemd/user/`).
   * Explicitly imports desktop session environment variables (`DISPLAY`, `WAYLAND_DISPLAY`, `DBUS_SESSION_BUS_ADDRESS`, `XAUTHORITY`) to allow headless systemd processes to render AWT system tray icons under GNOME / Wayland / X11 desktop managers.

---

## Prerequisites

* Operating System: Linux (Ubuntu, Debian, Fedora, Arch, etc.)
* Java Runtime Environment (JRE) / JDK 11 or higher
* Apache Maven
* Systemd (for background service automation)

---

## Installation & Setup

1. **Clone or Extract the Project**
   Navigate to the project root directory in your terminal:
   ```bash
   cd wifi-sync-app
