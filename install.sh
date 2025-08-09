#!/bin/bash
set -e

THEME_NAME="nibelung"
REPO_URL="https://github.com/veschin/nibelung-sddm-theme"
SDDM_THEMES_DIR="/usr/share/sddm/themes"
THEME_DIR="$SDDM_THEMES_DIR/$THEME_NAME"
TEMP_DIR=""

# Cleanup function
cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        echo "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Set trap for cleanup on exit/error
trap cleanup EXIT

echo "Nibelung SDDM Theme Installer"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (use sudo)" 
   exit 1
fi

# Check dependencies
if ! command -v sddm &> /dev/null; then
    echo "Error: SDDM not found. Please install SDDM first."
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Error: Git is required but not installed."
    exit 1
fi

echo "Downloading theme..."

# Create themes directory if it doesn't exist
mkdir -p "$SDDM_THEMES_DIR"

# Remove existing installation if present
if [ -d "$THEME_DIR" ]; then
    echo "Removing existing installation..."
    rm -rf "$THEME_DIR"
fi

# Clone the repository to temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Cloning repository..."
git clone --depth=1 --quiet "$REPO_URL" .

# Copy theme files (exclude .git and install.sh)
echo "Installing theme files..."
mkdir -p "$THEME_DIR"

# Copy all files except .git directory and install.sh
find . -mindepth 1 -maxdepth 1 ! -name '.git' ! -name 'install.sh' -exec cp -r {} "$THEME_DIR/" \;

# Set proper permissions
chmod -R 755 "$THEME_DIR"

echo "Theme installed successfully."

# Check current SDDM configuration
SDDM_CONF="/etc/sddm.conf"
echo "Checking SDDM configuration..."

configure_theme() {
    if [ -f "$SDDM_CONF" ]; then
        # Backup existing config
        cp "$SDDM_CONF" "$SDDM_CONF.backup"
        echo "Created backup: $SDDM_CONF.backup"
        
        # Make temporary copy for diff
        cp "$SDDM_CONF" "$SDDM_CONF.temp"
        
        # Check if [Theme] section exists
        if grep -q "^\[Theme\]" "$SDDM_CONF.temp"; then
            # Check if Current= line exists in Theme section
            if grep -A 20 "^\[Theme\]" "$SDDM_CONF.temp" | grep -q "^Current="; then
                # Update existing Current= line
                sed -i "/^\[Theme\]/,/^\[/ { /^Current=/ s/.*/Current=$THEME_NAME/; }" "$SDDM_CONF.temp"
            else
                # Add Current= line to existing Theme section
                sed -i "/^\[Theme\]/a Current=$THEME_NAME" "$SDDM_CONF.temp"
            fi
        else
            # Add Theme section with Current=
            echo "" >> "$SDDM_CONF.temp"
            echo "[Theme]" >> "$SDDM_CONF.temp"
            echo "Current=$THEME_NAME" >> "$SDDM_CONF.temp"
        fi
        
        # Show diff
        echo "Proposed changes to $SDDM_CONF:"
        echo "----------------------------------------"
        diff -u "$SDDM_CONF" "$SDDM_CONF.temp" || true
        echo "----------------------------------------"
        
        echo "Apply these changes? (y/n)"
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            mv "$SDDM_CONF.temp" "$SDDM_CONF"
            echo "Theme activated in $SDDM_CONF"
        else
            rm -f "$SDDM_CONF.temp"
            echo "Changes cancelled. Original config restored."
        fi
        
    else
        # Show what will be created
        echo "Will create $SDDM_CONF with:"
        echo "----------------------------------------"
        echo "[Theme]"
        echo "Current=$THEME_NAME"
        echo "----------------------------------------"
        
        echo "Create this config file? (y/n)"
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            cat > "$SDDM_CONF" << EOF
[Theme]
Current=$THEME_NAME
EOF
            echo "Theme activated in $SDDM_CONF"
        else
            echo "Config creation cancelled."
        fi
    fi
}

if [ -f "$SDDM_CONF" ]; then
    if grep -q "Current=$THEME_NAME" "$SDDM_CONF"; then
        echo "Theme is already active in $SDDM_CONF"
    else
        echo "Do you want to automatically activate the theme? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            configure_theme
        else
            echo "To activate manually, add this to $SDDM_CONF:"
            echo "[Theme]"
            echo "Current=$THEME_NAME"
        fi
    fi
else
    echo "SDDM config not found."
    echo "Do you want to create $SDDM_CONF and activate the theme? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        configure_theme
    else
        echo "To activate manually, create $SDDM_CONF with:"
        echo "[Theme]"
        echo "Current=$THEME_NAME"
    fi
fi

echo "Installation complete."
echo "Theme installed to: $THEME_DIR"
echo "Restart SDDM to apply: sudo systemctl restart sddm"