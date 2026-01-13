# Gas Town Telegraph

**Automatically transmit all Gas Town rig changes to GitHub** - zero manual intervention required.

> *In Gas Town, the Telegraph automatically relays every change from the rigs to the remote depot. No operators needed—just pure steam-powered automation.*

## The Problem

Gas Town's refinery merges polecat work locally but doesn't push to origin. This breaks multi-clone workflows where you have:
- Gas Town rigs at `~/gt/`
- Dev servers or other clones elsewhere

When refinery merges, your other clones never see the changes.

## The Solution

**Gas Town Telegraph** runs as a background daemon that:
- ✅ Monitors **all** your rigs (auto-discovers)
- ✅ Automatically pushes when refinery merges
- ✅ Works for existing + future rigs (zero config)
- ✅ Survives Gas Town updates (separate installation)
- ✅ Starts on login (launchd integration)

## Features

- **Universal**: Works for all rigs without configuration
- **Automatic**: No manual commands ever needed
- **Durable**: Lives outside gt installation, survives updates
- **Self-Starting**: Runs on macOS login via launchd
- **Self-Healing**: Auto-restarts if it crashes
- **Zero-Config**: Auto-discovers new rigs
- **🚀 Menu Bar Monitor**: Visual status indicator (optional)

## Requirements

- macOS (uses launchd)
- Gas Town installed at `~/gt/` (or custom location)
- Git remotes configured for your rigs

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/gastown-telegraph.git
cd gastown-telegraph
./install.sh
```

The installer will:
1. Detect your Gas Town installation
2. Install binaries to `~/.gt-auto-sync/`
3. Create symlinks in `~/gt/bin/`
4. Set up launchd for auto-start

## Usage

### Start the daemon

```bash
gt-sync-control start
```

That's it! The daemon is now running and will:
- Check every 30 seconds for unpushed commits
- Automatically push to origin/main
- Continue running forever (even after reboot)

### Monitor activity

```bash
# Check status
gt-sync-control status

# Live tail log
gt-sync-control log

# View recent activity
tail ~/gt/logs/auto-sync.log
```

### Stop/restart

```bash
gt-sync-control stop
gt-sync-control restart
```

## How It Works

```
Every 30 seconds:
1. Scans ~/gt/* for all rigs
2. For each rig with a git remote:
   - Checks if main/master is ahead of origin
   - If yes: git push origin main
   - Logs result
3. Repeat forever
```

## Configuration (Optional)

Edit environment variables in the plist:

```bash
nano ~/Library/LaunchAgents/com.gastown.autosync.plist
```

Available settings:
- `GT_TOWN`: Town root (default: `$HOME/gt`)
- `GT_SYNC_INTERVAL`: Check interval in seconds (default: `30`)
- `GT_SYNC_LOG`: Log file location (default: `$HOME/gt/logs/auto-sync.log`)

After editing:
```bash
gt-sync-control restart
```

## Menu Bar Monitor (Optional)

Get visual status updates right in your macOS menu bar!

**Icon States:**
- 🚀 **Green**: All systems operational
- 🚀 **Orange**: Failures detected in past 24 hours
- 🚀 **Grey**: 3+ recent sync failures (critical)
- 🚀❌ **Red**: Daemon not running

**Quick Install:**
```bash
brew install swiftbar
cp menubar/gt-sync.30s.sh ~/Library/Application\ Support/SwiftBar/
open -a SwiftBar
```

Click the icon for:
- Live statistics
- Recent sync activity
- Daemon controls (start/stop/restart)
- Quick access to logs

See [menubar/MENUBAR.md](menubar/MENUBAR.md) for full documentation.

## Monitoring & Debugging

### Check daemon status
```bash
gt-sync-control status
```

### View recent activity
```bash
tail -20 ~/gt/logs/auto-sync.log
```

### Check for errors
```bash
cat ~/gt/logs/auto-sync-error.log
```

### Check which rigs have unpushed commits
```bash
for rig in ~/gt/*/mayor/rig; do
  [ -d "$rig/.git" ] && cd "$rig" && \
  ahead=$(git rev-list --count origin/main..main 2>/dev/null || echo "0") && \
  [ "$ahead" != "0" ] && \
  echo "$(basename $(dirname $(dirname $rig))): $ahead commits unpushed"
done
```

## Troubleshooting

### Daemon won't start
```bash
# Check permissions
chmod +x ~/.gt-auto-sync/bin/gt-auto-sync

# Check launchd
launchctl list | grep gastown
```

### Pushes failing
Common issues:
- Git credentials expired (run `git push` in any rig manually)
- Remote branch protected (disable branch protection)
- Network connectivity issues

### Rig not detected
```bash
# Verify rig structure
ls -la ~/gt/<rig>/mayor/rig/.git

# Check if rig has remote
cd ~/gt/<rig>/mayor/rig && git remote -v
```

## Uninstallation

```bash
cd gt-auto-sync
./uninstall.sh
```

## Integration with Dev Servers

For dev servers in other locations, add this to your `package.json`:

```json
{
  "scripts": {
    "dev:sync": ".git/hooks/pre-dev-sync && npm run dev"
  }
}
```

And create `.git/hooks/pre-dev-sync`:

```bash
#!/bin/bash
echo "🔄 Syncing with Gas Town..."
git fetch origin main
git pull --ff-only origin main
```

Then always start dev with:
```bash
npm run dev:sync
```

## Contributing

Contributions welcome! Please open an issue or PR.

## License

MIT License - see LICENSE file

## Credits

Built for the [Gas Town](https://github.com/steveyegge/gastown) multi-agent workspace manager.
