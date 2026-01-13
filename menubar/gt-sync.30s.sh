#!/bin/bash
#
# <xbar.title>Gas Town Auto-Sync Monitor</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Gas Town</xbar.author>
# <xbar.author.github>ovachiever</xbar.author.github>
# <xbar.desc>Monitors Gas Town auto-sync daemon status</xbar.desc>
# <xbar.dependencies>bash</xbar.dependencies>
#
# SwiftBar/xbar plugin for Gas Town auto-sync daemon
# Refresh interval: 30 seconds (from filename)

# Don't use pipefail - grep with no matches is expected behavior
set -e

TOWN_ROOT="${GT_TOWN:-$HOME/gt}"
LOG_FILE="${GT_SYNC_LOG:-$HOME/gt/logs/auto-sync.log}"
CONTROL_SCRIPT="$HOME/gt/bin/gt-sync-control"

# Check if daemon is running
if ! pgrep -f "gt-auto-sync" > /dev/null 2>&1; then
  echo "🚀❌ | color=red"
  echo "---"
  echo "❌ Daemon NOT Running | color=red"
  echo "Start Daemon | shell='$CONTROL_SCRIPT' param1=start terminal=false refresh=true"
  echo "---"
  echo "View Logs | shell=open param1=-a param2=Console param3='$LOG_FILE' terminal=false"
  exit 0
fi

# Parse log file for recent activity
if [ ! -f "$LOG_FILE" ]; then
  echo "🚀⚠️ | color=orange"
  echo "---"
  echo "⚠️ No log file found | color=orange"
  exit 0
fi

# Get timestamp 24 hours ago
if date -v-24H > /dev/null 2>&1; then
  # macOS date
  CUTOFF_24H=$(date -v-24H '+%Y-%m-%d %H:%M:%S')
else
  # GNU date
  CUTOFF_24H=$(date -d '24 hours ago' '+%Y-%m-%d %H:%M:%S')
fi

# Count recent sync events (last 10)
RECENT_SYNCS=$(grep -E "📤.*Pushing|✅.*Successfully pushed|❌.*failed" "$LOG_FILE" 2>/dev/null | tail -20 || echo "")
TOTAL_RECENT_ATTEMPTS=$(echo "$RECENT_SYNCS" | grep -o "📤" 2>/dev/null | wc -l | tr -d ' ')
RECENT_FAILURES=$(echo "$RECENT_SYNCS" | grep -o "❌" 2>/dev/null | wc -l | tr -d ' ')
# Default to 0 if empty
TOTAL_RECENT_ATTEMPTS=${TOTAL_RECENT_ATTEMPTS:-0}
RECENT_FAILURES=${RECENT_FAILURES:-0}

# Count failures in last 24 hours (simple approach - last 100 lines with failures)
FAILURES_24H=$(tail -100 "$LOG_FILE" 2>/dev/null | grep -o "❌" 2>/dev/null | wc -l | tr -d ' ')
FAILURES_24H=${FAILURES_24H:-0}

# Get last sync time
LAST_SYNC=$(grep "📤" "$LOG_FILE" | tail -1 | sed -E 's/^\[([^]]+)\].*/\1/' || echo "Never")

# Determine icon state
ICON="🚀"
COLOR="green"
STATUS="All systems operational"

if [ "$TOTAL_RECENT_ATTEMPTS" -gt 0 ] && [ "$RECENT_FAILURES" -ge 3 ]; then
  # Grey: 3+ of last 10 syncs failed
  ICON="🚀"
  COLOR="#888888"
  STATUS="Multiple recent failures"
elif [ "$FAILURES_24H" -gt 0 ]; then
  # Semi-transparent: Some failures in 24h
  ICON="🚀"
  COLOR="orange"
  STATUS="Failures in last 24 hours"
fi

# Menu bar display
echo "$ICON | color=$COLOR"
echo "---"
echo "Gas Town Auto-Sync"
echo "Status: $STATUS | color=$COLOR"
echo "---"
echo "📊 Statistics"
echo "Last Sync: $LAST_SYNC"
echo "Recent Attempts: $TOTAL_RECENT_ATTEMPTS"
echo "Recent Failures: $RECENT_FAILURES/10"
echo "Failures (24h): $FAILURES_24H"
echo "---"

# Show recent sync activity (last 5)
echo "📋 Recent Activity"
grep -E "📤.*Pushing|✅.*Successfully|❌.*failed" "$LOG_FILE" | tail -10 | while IFS= read -r line; do
  if [[ "$line" =~ ✅ ]]; then
    echo "$line | color=green font=Monaco size=11"
  elif [[ "$line" =~ ❌ ]]; then
    echo "$line | color=red font=Monaco size=11"
  else
    echo "$line | font=Monaco size=11"
  fi
done

echo "---"
echo "🔧 Controls"
echo "Restart Daemon | shell='$CONTROL_SCRIPT' param1=restart terminal=false refresh=true"
echo "Stop Daemon | shell='$CONTROL_SCRIPT' param1=stop terminal=false refresh=true"
echo "---"
echo "📄 Logs & Status"
echo "View Full Logs | shell=open param1=-a param2=Console param3='$LOG_FILE' terminal=false"
echo "Open Log File | shell=open param1=-e param2='$LOG_FILE' terminal=false"
echo "Detailed Status | shell='$CONTROL_SCRIPT' param1=status terminal=true"
echo "---"
echo "Refresh | refresh=true"
