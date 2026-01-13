#!/bin/bash
# Gas Town Auto-Sync Installer
# https://github.com/YOUR_USERNAME/gt-auto-sync

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Gas Town Auto-Sync Installer"
echo ""

# Detect GT_TOWN location
if [ -z "$GT_TOWN" ]; then
  if [ -d "$HOME/gt" ]; then
    GT_TOWN="$HOME/gt"
  else
    echo -e "${YELLOW}GT_TOWN not found at $HOME/gt${NC}"
    read -p "Enter your Gas Town directory path: " GT_TOWN
    GT_TOWN="${GT_TOWN/#\~/$HOME}"  # Expand ~
  fi
fi

if [ ! -d "$GT_TOWN" ]; then
  echo -e "${RED}Error: Directory not found: $GT_TOWN${NC}"
  exit 1
fi

echo "✓ Found Gas Town at: $GT_TOWN"

# Determine install location
INSTALL_DIR="${INSTALL_DIR:-$HOME/.gt-auto-sync}"

# Create directories
echo ""
echo "Creating directories..."
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$GT_TOWN/bin"
mkdir -p "$GT_TOWN/logs"
mkdir -p "$HOME/Library/LaunchAgents"

# Copy binaries
echo "Installing binaries..."
cp bin/gt-auto-sync "$INSTALL_DIR/bin/"
cp bin/gt-sync-control "$INSTALL_DIR/bin/"
chmod +x "$INSTALL_DIR/bin/"*

# Create symlinks
echo "Creating symlinks..."
ln -sf "$INSTALL_DIR/bin/gt-sync-control" "$GT_TOWN/bin/gt-sync-control"

# Create plist
echo "Installing launchd plist..."
sed -e "s|__INSTALL_DIR__|$INSTALL_DIR|g" \
    -e "s|__GT_TOWN__|$GT_TOWN|g" \
    templates/com.gastown.autosync.plist.template \
    > "$HOME/Library/LaunchAgents/com.gastown.autosync.plist"

# Add to PATH if not already there
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
  if ! grep -q "gt/bin" "$SHELL_RC"; then
    echo "" >> "$SHELL_RC"
    echo "# Gas Town binaries" >> "$SHELL_RC"
    echo "export PATH=\"\$PATH:$GT_TOWN/bin\"" >> "$SHELL_RC"
    echo -e "${YELLOW}Added $GT_TOWN/bin to PATH in $SHELL_RC${NC}"
    echo -e "${YELLOW}Run: source $SHELL_RC${NC}"
  fi
fi

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Start the daemon:"
echo "  $GT_TOWN/bin/gt-sync-control start"
echo ""
echo "Or reload your shell and run:"
echo "  gt-sync-control start"
echo ""
echo "Monitor activity:"
echo "  gt-sync-control log"
