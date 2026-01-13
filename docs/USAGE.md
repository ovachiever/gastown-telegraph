# Usage Guide

## Quick Start

```bash
# Install
./install.sh

# Start daemon
gt-sync-control start

# Check status
gt-sync-control status

# Monitor activity
gt-sync-control log
```

## Complete Workflow

### 1. Installation
```bash
git clone https://github.com/YOUR_USERNAME/gt-auto-sync.git
cd gt-auto-sync
./install.sh
```

### 2. Start the Daemon
```bash
gt-sync-control start
```

The daemon now runs in the background and will:
- Start automatically on login
- Scan all rigs every 30 seconds
- Push unpushed commits to origin/main
- Log all activity

### 3. Verify It's Working

**Make a test commit:**
```bash
cd ~/gt/YOUR_RIG/mayor/rig
echo "test" > .test-file
git add .test-file
git commit -m "Test auto-sync"
```

**Check the log (wait 30 seconds):**
```bash
tail -f ~/gt/logs/auto-sync.log

# You should see:
# [timestamp] 📤 YOUR_RIG: Pushing 1 commit(s) to origin/main...
# [timestamp] ✅ YOUR_RIG: Successfully pushed
```

**Verify on GitHub:**
```bash
# Your test commit should now be on GitHub
git log origin/main -1
```

**Clean up:**
```bash
git rm .test-file
git commit -m "Remove test file"
# Auto-pushed in 30 seconds!
```

## Daily Usage

### You Don't Need to Do Anything!

The daemon runs automatically. Your workflow is unchanged:
1. Gas Town polecats work
2. Refinery merges locally
3. Daemon auto-pushes (30s later)
4. Changes visible on GitHub

### Checking Status (Optional)

```bash
# Is daemon running?
gt-sync-control status

# Recent activity?
tail ~/gt/logs/auto-sync.log

# Live monitoring?
gt-sync-control log
```

## Commands Reference

### gt-sync-control

```bash
gt-sync-control start    # Start daemon (auto-starts on login)
gt-sync-control stop     # Stop daemon
gt-sync-control restart  # Restart daemon
gt-sync-control status   # Check status + recent activity
gt-sync-control log      # Live tail of activity log
```

## Multi-Clone Workflow

If you have dev servers in other locations:

### Option 1: Manual Sync Before Dev

```bash
cd ~/your-dev-server-location
git pull origin main
npm run dev
```

### Option 2: Automatic Sync Before Dev

Add to `package.json`:
```json
{
  "scripts": {
    "dev:sync": ".git/hooks/pre-dev-sync && npm run dev"
  }
}
```

Create `.git/hooks/pre-dev-sync`:
```bash
#!/bin/bash
echo "🔄 Syncing with Gas Town..."
git fetch origin main
git pull --ff-only origin main
```

Then:
```bash
npm run dev:sync  # Auto-syncs before starting
```

## Advanced Usage

### Custom Check Interval

Default is 30 seconds. To change:

```bash
# Edit plist
nano ~/Library/LaunchAgents/com.gastown.autosync.plist

# Change this line:
<string>30</string>  <!-- to whatever you want -->

# Restart
gt-sync-control restart
```

### Custom GT_TOWN Location

```bash
# Edit plist
nano ~/Library/LaunchAgents/com.gastown.autosync.plist

# Change:
<key>GT_TOWN</key>
<string>/your/custom/path</string>

# Restart
gt-sync-control restart
```

### Multiple Town Installations

Currently only supports one GT_TOWN. For multiple:
1. Clone gt-auto-sync to different directory
2. Run `./install.sh` with different `INSTALL_DIR`
3. Manually edit plist to change `GT_TOWN` path

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
