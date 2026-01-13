# Gas Town Auto-Sync Menu Bar Monitor

Visual status indicator for the gt-auto-sync daemon that lives in your macOS menu bar.

## Features

- **🚀 Green Rocket**: All systems operational
- **🚀 Orange Rocket**: Failures detected in past 24 hours
- **🚀 Grey Rocket**: 3+ of last 10 sync attempts failed
- **🚀❌ Red X**: Daemon not running

Click the icon for:
- Detailed statistics
- Recent sync activity
- Daemon controls (start/stop/restart)
- Quick access to logs

## Installation Options

### Option 1: SwiftBar (Recommended - Easy)

**Pros:** Simple installation, automatic updates, easy to customize
**Cons:** Requires installing SwiftBar

1. **Install SwiftBar:**
   ```bash
   brew install swiftbar
   ```

2. **Copy plugin:**
   ```bash
   mkdir -p ~/Library/Application\ Support/SwiftBar
   cp menubar/gt-sync.30s.sh ~/Library/Application\ Support/SwiftBar/
   chmod +x ~/Library/Application\ Support/SwiftBar/gt-sync.30s.sh
   ```

3. **Launch SwiftBar:**
   - Open SwiftBar from Applications
   - Choose plugin folder: `~/Library/Application Support/SwiftBar`
   - Look for 🚀 in your menu bar

4. **Verify:**
   - Click the rocket icon
   - You should see "Gas Town Auto-Sync" with statistics

### Option 2: Native Swift App (No Dependencies)

**Pros:** No external dependencies, runs natively
**Cons:** More complex setup, requires compilation

1. **Compile the app:**
   ```bash
   cd menubar
   swiftc -o GTSyncMonitor GTSyncMonitor.swift
   cp GTSyncMonitor ~/gt/bin/
   ```

2. **Create launchd plist:**
   ```bash
   cat > ~/Library/LaunchAgents/com.gastown.syncmonitor.plist << 'EOF'
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.gastown.syncmonitor</string>
       <key>ProgramArguments</key>
       <array>
           <string>/Users/YOUR_USERNAME/gt/bin/GTSyncMonitor</string>
       </array>
       <key>RunAtLoad</key>
       <true/>
       <key>KeepAlive</key>
       <true/>
       <key>StandardOutPath</key>
       <string>/Users/YOUR_USERNAME/gt/logs/menubar.log</string>
       <key>StandardErrorPath</key>
       <string>/Users/YOUR_USERNAME/gt/logs/menubar-error.log</string>
   </dict>
   </plist>
   EOF
   ```

3. **Replace YOUR_USERNAME** with your actual username:
   ```bash
   sed -i '' "s/YOUR_USERNAME/$USER/g" ~/Library/LaunchAgents/com.gastown.syncmonitor.plist
   ```

4. **Load and start:**
   ```bash
   launchctl load ~/Library/LaunchAgents/com.gastown.syncmonitor.plist
   launchctl start com.gastown.syncmonitor
   ```

## Icon States Explained

### 🚀 Green (All Good)
- Daemon is running
- No failures in last 10 syncs
- No failures in last 24 hours

### 🚀 Orange (Warning)
- Daemon is running
- At least 1 failure detected in past 24 hours
- But less than 3 recent failures

### 🚀 Grey (Critical)
- Daemon is running
- 3 or more of the last 10 sync attempts failed
- Indicates persistent sync problems

### 🚀❌ Red (Not Running)
- Daemon is not running
- Click to start it

## Menu Features

When you click the icon, you'll see:

```
Gas Town Auto-Sync
Status: All systems operational
────────────────────────────
📊 Statistics
Last Sync: 2026-01-13 13:00:17
Recent Attempts: 5
Recent Failures: 0/10
Failures (24h): 0
────────────────────────────
📋 Recent Activity
[2026-01-13 13:00:16] 📤 gtdispat: Pushing 1 commit(s)...
[2026-01-13 13:00:17] ✅ gtdispat: Successfully pushed
────────────────────────────
🔧 Controls
Restart Daemon
Stop Daemon
────────────────────────────
📄 Logs & Status
View Full Logs
Open Log File
Detailed Status
────────────────────────────
Refresh
```

## Customization

### Change Refresh Interval (SwiftBar)

Rename the plugin file:
- `gt-sync.15s.sh` - Refresh every 15 seconds
- `gt-sync.30s.sh` - Refresh every 30 seconds (default)
- `gt-sync.1m.sh` - Refresh every 1 minute

### Adjust Thresholds

Edit the plugin script and modify these values:

```bash
# Grey state: 3+ of last 10 failed
if [ "$RECENT_FAILURES" -ge 3 ]; then

# Warning state: Any failures in 24h
elif [ "$FAILURES_24H" -gt 0 ]; then
```

## Troubleshooting

### Icon not appearing (SwiftBar)

1. Check SwiftBar is running:
   ```bash
   ps aux | grep SwiftBar
   ```

2. Verify plugin location:
   ```bash
   ls -la ~/Library/Application\ Support/SwiftBar/gt-sync.30s.sh
   ```

3. Check plugin is executable:
   ```bash
   chmod +x ~/Library/Application\ Support/SwiftBar/gt-sync.30s.sh
   ```

4. View SwiftBar logs:
   - Open SwiftBar preferences
   - Click "Open Plugin Folder"
   - Check for error files

### Icon not appearing (Native Swift)

1. Check if compiled app exists:
   ```bash
   ls -la ~/gt/bin/GTSyncMonitor
   ```

2. Check if launchd service is running:
   ```bash
   launchctl list | grep syncmonitor
   ```

3. View logs:
   ```bash
   tail -f ~/gt/logs/menubar.log
   tail -f ~/gt/logs/menubar-error.log
   ```

4. Restart the service:
   ```bash
   launchctl unload ~/Library/LaunchAgents/com.gastown.syncmonitor.plist
   launchctl load ~/Library/LaunchAgents/com.gastown.syncmonitor.plist
   ```

### Icon shows "Not Running" but daemon is running

The detection looks for process named `gt-auto-sync`. Verify:
```bash
ps aux | grep gt-auto-sync | grep -v grep
```

If the process is running but not detected, the script path might be different. Check:
```bash
which gt-auto-sync
```

## Uninstallation

### SwiftBar
```bash
rm ~/Library/Application\ Support/SwiftBar/gt-sync.30s.sh
# Optionally uninstall SwiftBar:
brew uninstall swiftbar
```

### Native Swift
```bash
launchctl unload ~/Library/LaunchAgents/com.gastown.syncmonitor.plist
rm ~/Library/LaunchAgents/com.gastown.syncmonitor.plist
rm ~/gt/bin/GTSyncMonitor
```

## Quick Reference

| Command | Description |
|---------|-------------|
| Click icon | View detailed status and controls |
| "Restart Daemon" | Restart the sync service |
| "Stop Daemon" | Stop the sync service |
| "View Full Logs" | Open logs in Console.app |
| "Detailed Status" | Run gt-sync-control status |

## Notes

- The menu bar monitor is independent of the daemon
- If you stop the monitor, the daemon continues running
- Updates refresh automatically every 30 seconds (SwiftBar default)
- The monitor reads from the same log file as gt-sync-control
- Green/orange/grey states help you catch issues at a glance
