#!/bin/bash
set -e

# Variables
APP_NAME="cpinfo-mac-arm64"
PKG_ID="com.test.cpinfo"
PKG_VERSION="1.0.0"
PKG_NAME="cpinfo-mac-installer.pkg"

ROOT_DIR=$(pwd)
PKG_ROOT="$ROOT_DIR/package-root"
SCRIPTS_DIR="$ROOT_DIR/installer_items"

echo "Cleaning previous package root..."
rm -rf "$PKG_ROOT"

echo "Creating package root structure..."
mkdir -p "$PKG_ROOT/usr/local/bin"
mkdir -p "$PKG_ROOT/Library/LaunchAgents"

echo "Copying executable..."
cp "$ROOT_DIR/$APP_NAME" "$PKG_ROOT/usr/local/bin/"
chmod +x "$PKG_ROOT/usr/local/bin/$APP_NAME"

echo "Copying plist..."
cp "$SCRIPTS_DIR/com.test.cpinfo.plist" "$PKG_ROOT/Library/LaunchAgents/"

echo "Copying postinstall script and making executable..."
chmod +x "$SCRIPTS_DIR/postinstall.sh"

echo "Building the package..."
pkgbuild --root "$PKG_ROOT" \
         --install-location / \
         --scripts "$SCRIPTS_DIR" \
         --identifier "$PKG_ID" \
         --version "$PKG_VERSION" \
         "$PKG_NAME"

echo "Package built: $PKG_NAME"
