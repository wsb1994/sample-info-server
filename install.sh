#!/bin/bash

# macOS Installer Creation Script for cpinfo-mac-arm64
# This script creates a proper .pkg installer for your binary

set -e

# Configuration variables
APP_NAME="cpinfo"
BINARY_NAME="cpinfo-mac-arm64"
VERSION="1.0.0"
IDENTIFIER="com.yourcompany.cpinfo"
INSTALL_LOCATION="/usr/local/bin"

# Directory structure
WORK_DIR="installer_build"
PAYLOAD_DIR="$WORK_DIR/payload"
SCRIPTS_DIR="$WORK_DIR/scripts"
RESOURCES_DIR="$WORK_DIR/resources"

echo "Creating macOS installer for $BINARY_NAME..."

# Clean and create working directories
rm -rf "$WORK_DIR"
mkdir -p "$PAYLOAD_DIR$INSTALL_LOCATION"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy the binary to payload directory
if [ ! -f "$BINARY_NAME" ]; then
    echo "Error: Binary $BINARY_NAME not found in current directory"
    exit 1
fi

cp "$BINARY_NAME" "$PAYLOAD_DIR$INSTALL_LOCATION/cpinfo"
chmod +x "$PAYLOAD_DIR$INSTALL_LOCATION/cpinfo"

# Copy post-install script from installer_items directory
if [ -f "installer_items/postinstall" ]; then
    cp "installer_items/postinstall" "$SCRIPTS_DIR/"
    chmod +x "$SCRIPTS_DIR/postinstall"
    echo "Post-install script copied from installer_items/"
else
    echo "Warning: No postinstall script found in installer_items/ directory"
    echo "Creating a basic post-install script..."
    
    # Create a basic post-install script with startup configuration
    cat > "$SCRIPTS_DIR/postinstall" << 'EOF'
#!/bin/bash
# Post-install script for cpinfo with startup configuration

# Make sure the binary is executable
chmod +x /usr/local/bin/cpinfo

# Add /usr/local/bin to PATH if not already there
if ! echo "$PATH" | grep -q "/usr/local/bin"; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> /etc/paths.d/cpinfo
fi

# Create Launch Daemon for system-wide startup (runs as root)
DAEMON_PLIST="/Library/LaunchDaemons/com.yourcompany.cpinfo.plist"
cat > "$DAEMON_PLIST" << 'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.yourcompany.cpinfo</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/cpinfo</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/var/log/cpinfo.error.log</string>
    <key>StandardOutPath</key>
    <string>/var/log/cpinfo.out.log</string>
</dict>
</plist>
PLIST_EOF

# Set proper permissions for the plist
chown root:wheel "$DAEMON_PLIST"
chmod 644 "$DAEMON_PLIST"

# Load the launch daemon
launchctl load "$DAEMON_PLIST"

echo "cpinfo installed successfully and configured to start on boot!"
echo "You can now run: cpinfo"
echo "Service will start automatically on system boot"
echo ""
echo "To manually control the service:"
echo "  Start:   sudo launchctl load $DAEMON_PLIST"
echo "  Stop:    sudo launchctl unload $DAEMON_PLIST"
echo "  Status:  sudo launchctl list | grep cpinfo"

exit 0
EOF
    chmod +x "$SCRIPTS_DIR/postinstall"
fi

# Copy any pre-install script if it exists
if [ -f "installer_items/preinstall" ]; then
    cp "installer_items/preinstall" "$SCRIPTS_DIR/"
    chmod +x "$SCRIPTS_DIR/preinstall"
    echo "Pre-install script copied from installer_items/"
fi

# Create distribution.xml file for productbuild
cat > "$WORK_DIR/distribution.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
    <title>$APP_NAME Installer</title>
    <organization>$IDENTIFIER</organization>
    <domains enable_localSystem="true"/>
    <options customize="never" require-scripts="true" rootVolumeOnly="true" />
    <choices-outline>
        <line choice="default">
            <line choice="$IDENTIFIER"/>
        </line>
    </choices-outline>
    <choice id="default"/>
    <choice id="$IDENTIFIER" visible="false">
        <pkg-ref id="$IDENTIFIER"/>
    </choice>
    <pkg-ref id="$IDENTIFIER" version="$VERSION" onConclusion="none">$APP_NAME.pkg</pkg-ref>
</installer-gui-script>
EOF

# Build the component package
echo "Building component package..."
pkgbuild --root "$PAYLOAD_DIR" \
         --identifier "$IDENTIFIER" \
         --version "$VERSION" \
         --scripts "$SCRIPTS_DIR" \
         --install-location / \
         "$WORK_DIR/$APP_NAME.pkg"

# Build the final installer
echo "Building final installer..."
productbuild --distribution "$WORK_DIR/distribution.xml" \
             --package-path "$WORK_DIR" \
             --resources "$RESOURCES_DIR" \
             "${APP_NAME}-${VERSION}-installer.pkg"

echo ""
echo "✅ Installer created successfully!"
echo "📦 Output: ${APP_NAME}-${VERSION}-installer.pkg"
echo ""
echo "To test the installer:"
echo "  sudo installer -pkg ${APP_NAME}-${VERSION}-installer.pkg -target /"
echo ""
echo "To uninstall (if needed):"
echo "  sudo rm /usr/local/bin/cpinfo"
echo "  sudo rm -f /etc/paths.d/cpinfo"
echo "  sudo launchctl unload /Library/LaunchDaemons/com.yourcompany.cpinfo.plist"
echo "  sudo rm /Library/LaunchDaemons/com.yourcompany.cpinfo.plist"