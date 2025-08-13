#!/bin/bash
# installer_items/postinstall
# Custom post-install script for cpinfo with startup configuration

set -e

echo "Configuring cpinfo for startup..."

# Make sure the binary is executable
chmod +x /usr/local/bin/cpinfo

# Add /usr/local/bin to PATH if not already there
if ! echo "$PATH" | grep -q "/usr/local/bin"; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> /etc/paths.d/cpinfo
fi

# Choose one of the following approaches:

# OPTION 1: Launch Daemon (System-wide, runs as root, starts before user login)
DAEMON_PLIST="/Library/LaunchDaemons/com.yourcompany.cpinfo.plist"
cat > "$DAEMON_PLIST" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.yourcompany.cpinfo</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/cpinfo</string>
        <!-- Add any command line arguments here -->
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/var/log/cpinfo.error.log</string>
    <key>StandardOutPath</key>
    <string>/var/log/cpinfo.out.log</string>
    <key>UserName</key>
    <string>root</string>
    <!-- Optional: Limit resource usage -->
    <key>SoftResourceLimits</key>
    <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
    </dict>
    <!-- Optional: Set working directory -->
    <key>WorkingDirectory</key>
    <string>/usr/local/bin</string>
</dict>
</plist>
EOF

# Set proper permissions
chown root:wheel "$DAEMON_PLIST"
chmod 644 "$DAEMON_PLIST"

# Load the launch daemon
launchctl load "$DAEMON_PLIST"

echo "✅ cpinfo installed successfully!"
echo "🚀 Service configured to start automatically on system boot"
echo ""
echo "Service Management Commands:"
echo "  Check status: sudo launchctl list | grep cpinfo"
echo "  Start:        sudo launchctl load $DAEMON_PLIST"
echo "  Stop:         sudo launchctl unload $DAEMON_PLIST"
echo "  Restart:      sudo launchctl unload $DAEMON_PLIST && sudo launchctl load $DAEMON_PLIST"
echo ""
echo "Logs:"
echo "  Output: /var/log/cpinfo.out.log"
echo "  Errors: /var/log/cpinfo.error.log"

exit 0