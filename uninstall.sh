#!/bin/bash
# Gas Town Auto-Sync Uninstaller

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🗑️  Gas Town Auto-Sync Uninstaller"
echo ""

GT_TOWN="${GT_TOWN:-$HOME/gt}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.gt-auto-sync}"
PLIST="$HOME/Library/LaunchAgents/com.gastown.autosync.plist"

# Stop daemon
if launchctl list | grep -q com.gastown.autosync; then
  echo "Stopping daemon..."
  launchctl unload "$PLIST" 2>/dev/null || true
fi

# Remove files
echo "Removing files..."
rm -f "$PLIST"
rm -f "$GT_TOWN/bin/gt-sync-control"
rm -rf "$INSTALL_DIR"

# Ask about logs
echo ""
read -p "Remove logs from $GT_TOWN/logs/auto-sync*.log? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -f "$GT_TOWN/logs/auto-sync"*.log
  echo "Logs removed"
fi

echo ""
echo -e "${GREEN}✅ Uninstallation complete${NC}"
echo ""
echo "To reinstall, run: ./install.sh"
