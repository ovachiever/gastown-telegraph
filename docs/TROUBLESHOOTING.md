# Troubleshooting Guide

## Daemon Won't Start

### Check if already running
```bash
launchctl list | grep gastown
ps aux | grep gt-auto-sync
```

### Check permissions
```bash
chmod +x ~/.gt-auto-sync/bin/gt-auto-sync
chmod +x ~/.gt-auto-sync/bin/gt-sync-control
```

### Check launchd plist
```bash
ls -la ~/Library/LaunchAgents/com.gastown.autosync.plist
cat ~/Library/LaunchAgents/com.gastown.autosync.plist
```

### Check error log
```bash
cat ~/gt/logs/auto-sync-error.log
```

### Force reload
```bash
launchctl unload ~/Library/LaunchAgents/com.gastown.autosync.plist
launchctl load ~/Library/LaunchAgents/com.gastown.autosync.plist
```

## Pushes Failing

### Check git credentials
```bash
# Try manual push
cd ~/gt/SOME_RIG/mayor/rig
git push origin main

# If fails with auth error:
# Update credentials (GitHub token, SSH key, etc.)
```

### Check remote configuration
```bash
cd ~/gt/SOME_RIG/mayor/rig
git remote -v
git remote get-url origin
```

### Check branch protection
GitHub branch protection may prevent pushes. Disable or add exception for service accounts.

### Check network connectivity
```bash
ping github.com
```

## Rig Not Being Detected

### Verify rig structure
```bash
# Daemon looks for: ~/gt/*/mayor/rig/.git
ls -la ~/gt/YOUR_RIG/mayor/rig/.git
```

### Check if it's a git repo
```bash
cd ~/gt/YOUR_RIG/mayor/rig
git status
```

### Check if remote exists
```bash
cd ~/gt/YOUR_RIG/mayor/rig
git remote -v
# Should show origin with GitHub URL
```

### Check branch name
```bash
cd ~/gt/YOUR_RIG/mayor/rig
git branch --show-current
# Must be 'main' or 'master'
```

## Daemon Stops Running

### Check if it crashed
```bash
cat ~/gt/logs/auto-sync-error.log
```

### Check launchd status
```bash
launchctl list | grep gastown
```

### Manually restart
```bash
gt-sync-control restart
```

### Check system logs
```bash
log show --predicate 'process == "gt-auto-sync"' --last 1h
```

## Logs Not Updating

### Check log file exists
```bash
ls -la ~/gt/logs/auto-sync.log
```

### Check daemon is running
```bash
gt-sync-control status
```

### Check write permissions
```bash
ls -ld ~/gt/logs/
# Should be writable by your user
```

## Commits Not Being Pushed

### Verify commits exist
```bash
cd ~/gt/YOUR_RIG/mayor/rig
git log --oneline origin/main..main
# Should show unpushed commits
```

### Check daemon detected them
```bash
tail ~/gt/logs/auto-sync.log
# Should show attempt to push within 30s
```

### Manual test
```bash
cd ~/gt/YOUR_RIG/mayor/rig
git push origin main
# See actual error message
```

## Dev Server Not Seeing Changes

### Check if push succeeded
```bash
cd ~/gt/YOUR_RIG/mayor/rig
git log origin/main -1
# Should show latest commit
```

### Check dev server clone
```bash
cd ~/your-dev-server-location
git fetch origin main
git log origin/main -1
# Should match above
```

### Pull in dev server
```bash
cd ~/your-dev-server-location
git pull origin main
```

## Performance Issues

### Reduce scan frequency
```bash
# Edit plist
nano ~/Library/LaunchAgents/com.gastown.autosync.plist

# Increase interval from 30 to 60 (or higher)
<string>60</string>

# Restart
gt-sync-control restart
```

### Check system resources
```bash
top | grep gt-auto-sync
```

## Getting Help

### Collect diagnostic info
```bash
# System info
uname -a

# Daemon status
gt-sync-control status

# Recent logs
tail -50 ~/gt/logs/auto-sync.log

# Error logs
cat ~/gt/logs/auto-sync-error.log

# Launchd status
launchctl list | grep gastown

# Rig structure
ls -la ~/gt/*/mayor/rig/.git | head -20
```

### Open an issue
Include the diagnostic info above at:
https://github.com/YOUR_USERNAME/gt-auto-sync/issues
