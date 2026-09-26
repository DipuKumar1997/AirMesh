#!/bin/bash
set -e

APP_NAME="wifi-sync-app"
INSTALL_DIR="$HOME/.local/share/$APP_NAME"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
AUTOSTART_DIR="$HOME/.config/autostart"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

echo "==== Building $APP_NAME with Maven ===="
mvn clean package

echo "==== Creating Installation Directories ===="
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$AUTOSTART_DIR"
mkdir -p "$SYSTEMD_USER_DIR"

JAR_PATH=$(find target -name "*.jar" ! -name "original-*.jar" | head -n 1)

if [ -z "$JAR_PATH" ]; then
    echo "Error: Built JAR file not found in target/ directory."
    exit 1
fi

echo "==== Copying JAR to $INSTALL_DIR ===="
cp "$JAR_PATH" "$INSTALL_DIR/wifi-sync-app.jar"

echo "==== Creating Launcher Script in $BIN_DIR ===="
cat << 'LAUNCHER' > "$BIN_DIR/wifi-sync-app"
#!/bin/bash
JAVA_EXEC=$(which java || echo "/usr/bin/java")

# Ensure GUI display export fallbacks for systemd environments
export DISPLAY=${DISPLAY:-:0}
export XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}

exec "$JAVA_EXEC" -jar "$HOME/.local/share/wifi-sync-app/wifi-sync-app.jar" "$@"
LAUNCHER
chmod +x "$BIN_DIR/wifi-sync-app"

echo "==== Registering Desktop & Autostart Launchers ===="
cat << DESKTOP > "$DESKTOP_DIR/wifi-sync-app.desktop"
[Desktop Entry]
Type=Application
Name=Wi-Fi Sync Application
Comment=Sync Clipboard and Files across Wi-Fi Network
Exec=$BIN_DIR/wifi-sync-app
Icon=network-wireless
Terminal=false
Categories=Utility;Network;
StartupNotify=false
DESKTOP

chmod +x "$DESKTOP_DIR/wifi-sync-app.desktop"

# Desktop Autostart backup for GNOME session log-in
cat << DESKTOP_AUTO > "$AUTOSTART_DIR/wifi-sync-app.desktop"
[Desktop Entry]
Type=Application
Name=Wi-Fi Sync Application
Exec=$BIN_DIR/wifi-sync-app --minimized
Icon=network-wireless
Terminal=false
X-GNOME-Autostart-enabled=true
DESKTOP_AUTO

echo "==== Registering Systemd User Service ===="
cp wifi-sync-app.service "$SYSTEMD_USER_DIR/wifi-sync-app.service"

# Import active GUI variables into systemd user environment
systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS XDG_RUNTIME_DIR || true

systemctl --user daemon-reload
systemctl --user enable wifi-sync-app.service
systemctl --user restart wifi-sync-app.service

echo "========================================================="
echo " Installation Complete!"
echo " Service Status: Active and running on system startup."
echo "========================================================="