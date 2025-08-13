#!/bin/bash

# Detect current user's home directory reliably
USER_HOME=$(eval echo "~$USER")

# Define paths
PLIST_SRC="$PWD/installer_items/com.test.cpinfo.plist"
PLIST_DEST="$USER_HOME/Library/LaunchAgents/com.test.cpinfo.plist"
EXEC_PATH="/usr/local/bin/cpinfo-mac-arm64"

# Copy executable to /usr/local/bin
echo "Copying executable to /usr/local/bin"
sudo cp "$PWD/cpinfo-mac-arm64" "$EXEC_PATH"
sudo chmod +x "$EXEC_PATH"

# Create LaunchAgents folder if missing
mkdir -p "$USER_HOME/Library/LaunchAgents"

# Copy plist to user's LaunchAgents folder
echo "Copying plist to $PLIST_DEST"
cp "$PLIST_SRC" "$PLIST_DEST"
chmod 644 "$PLIST_DEST"

# Load the Launch Agent for the current user
echo "Loading launch agent"
launchctl bootstrap gui/$(id -u) "$PLIST_DEST"
launchctl enable gui/$(id -u)/com.test.cpinfo

echo "Installation complete."

exit 0
