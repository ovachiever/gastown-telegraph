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

# Base64 encoded telegraph icons (18x18 PNG)
ICON_GREEN="iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAABvElEQVR4nFVUwXaEQAgL6P9/a2/tRdKXhHHb2eeqwwBJAOvr+4eogq7iA60CQe1Bl00g80b/GuCgulHM2bvPeRJTl4/6ciDGqBuI0d3Oa9JGl5P05Iz/OtZ9JWqAGnqHTijUBokqoVLwMY67WJs3CHLf9+WjZyqw7VmiE/pZ/T6tQwIN6AQV2+hg0JgViVYO58l+5yE8DV9H2eJkBAiejbAoF+0JruvWv+yvgFySfxxqA4lKarApJjb539FOJQ0FC7qBJbOWEx2aQrtJpkVZuIjbt03+lp7ArCD9X0a1z64H5dKnPW5l3Tb6BNsyH+m1eJQ+UiiBY6SyNzkhIOcWbAWJkcr4KFE0cTBT0p6wHmEVqPN6qblGIfmisUb9QRMka6vH7ZFKqyGPYSYVUcfaK+Xl1kC7apNokNZVxx/yt+bFQ3m1o/cpOTV3YwpxISSDu7kaLT+xEYtu3J51Dd8VbYzsuuyYyo35tAZaNsMZ63eIat/SK3KrPyYju11lKqUivI25Y+HPwDvrboF8E9Q3eJL5ak89Hmmk5xXaM+TwJuwkT1J6+jOtGZi0iVVKA2/7K4io/Jv1/dC5OAR+AQEFJyKaSyycAAAAAElFTkSuQmCC"
ICON_YELLOW="iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAABqklEQVR4nFVU0W7EMAizWf//X/c2TWqYbEN7u9OuaUJssGH8/v1pHAAkgIY+rSUBNsCjBXB4gyigG02vcHeDOkSjdECBsKGvPl9NlMD1KjQ/AiJUfQVRu2LhEv2Q7k3gnIcJpVCh5nyxqcxC4f1Liy/vEN3Lliy3RPTsCWBInagCiuABLtWqJLuP0zWrNYF1YKciZ8wCjiHDIFnuwWunmNSVRRgj5haLuRgVle2YMgSO10Uh5ghIXkSfE217bgxqsxJfQFXlmJBGA9IHNVr3U0ujT4Th6Kc9rVeCcSkVCLdYuB/yKaHKKQcgGvGjTJE7DTauWB8rVhdrpRgL+7JaS4fq6d+4JyCHxoCxeprO9vPtFG5JT/9/EBDXDgZH6DAq7RkVpH/+O6j2kHvPZhqSR8FzMKW94teUZHjQuqhvkryz7gHKCdVUEVFbVW5KzJhs48j2NJDHdBt/htZ/YRwZRvn+KGgHUs8d1se0jKSDNKg+eRTcQXjGJC7GSb27Gd4+CsP2xTsccSMVDa1uqd51bxLW22UQw8+0e3inFMOLKy7q/44yD39MWnP+AMP6AzsU1I+2AAAAAElFTkSuQmCC"
ICON_ORANGE="iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAABvElEQVR4nE2UQXYkMQhDhbvuf9jZZVEw70u4k04ncdkghFC5/v38zJRUM9JIqrPrUX+kw6FGVcWWPz2jU+X/dcpph9OEApJVazSHtRY8IPyyC6gWzGkAbZHkuKRDA0ZyhalZ7xoORAZ8pHf0pI0SP3yXj8qZMuhbYQ2z9va227cVWmObjd7gy5VA/v7pMEer1cwfOUoPUI5uWokIdFDIdyGSEVCzz1AAgQTHj1uw4KtPg/I7KdGLxZdOS03rQzYTgwX5hdgwobfQJBcAA3fYHfiZWKkcy+oYwCxr9ITBjng1sOQGk1M8uSs4sGQfBrKWKGtE4HXSbAXoMj1Zwki1Q/laZaewqU/3G9e6rRwG8pui6/i12BrTorhwCn5K84EqOVvSKCijmM4y2COrZ0DoJlJNmEcNG91TYjoRV67oIABgvWy+TNfdJ56+VlydbkVeYLdir38bvi0JWQDBkHEqdAPWS8UcX6jJL7BhNsyaSnqZ3D4/8XCp31S5ghsNEHKxCAi47q73nbuDOXjCVlpB7nv3nRyt+UqxHX3/9N5BPH/mWM+H/r19JXBivIToqUB5rq4U4Dqx93D2tEX5DxkVIRWi0uzSAAAAAElFTkSuQmCC"
ICON_RED="iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAABtklEQVR4nF1UQXLEMAiTiP//1h7bQ6EjAc5sk+yOY2MJhBx+/XzXA0JPVYEgCgCK+oMfltc1AwSSCVaCeDxWzHk69gZq3IADGrNegeIvwESkJh6AhShCr8cbWVpHDpgAevdeBbJQRe1FabHTa0ISRyU4c4GonGoEE0xpoReR3eUEKEGaWZhnmcVmRDHs3M2mi3bJDJTKEodQBc7CYTRNIm9JTqxlwyrXm9hZLYu5my7KwknYBZjtoX3sUgSw76Jzhg1GhH/Hc0Nj9FvXqpmoCR4N3BiF5XSU6e5JUt1ODVCKSzhdcLbtC+9UpCXVXeXxcfDKqsBHYi5WGcxtN+EkPOZd/RghHykDopSvGVqH7R53DNpnV20DJyr6LNiQH9c6PGeFCivoBLzHpb3XV1qNaCOKXYthWQUU8AmEgdUyZ7udejN1O0POnm6I1cc1d4POFUDXo5j89JGd3pCabGfrGKgUp23DjPwBZFo/Car2VCXUjopndOyenwZ/0VtHsSiL+Xxo7DZ3pzr3+cTMEYpQKbfZbZA1RBlc/GPY91vgg7xFywnnv5Nb4O7MOGccvwl2Ka9Rw7r9AdTHD1bsSvKKAAAAAElFTkSuQmCC"

# Check if daemon is running
if ! pgrep -f "gt-auto-sync" > /dev/null 2>&1; then
  echo "| templateImage=$ICON_RED"
  echo "---"
  echo "❌ Daemon NOT Running | color=red"
  echo "Start Daemon | shell='$CONTROL_SCRIPT' param1=start terminal=false refresh=true"
  echo "---"
  echo "View Logs | shell=open param1=-a param2=Console param3='$LOG_FILE' terminal=false"
  exit 0
fi

# Parse log file for recent activity
if [ ! -f "$LOG_FILE" ]; then
  echo "| templateImage=$ICON_YELLOW"
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
ICON="$ICON_GREEN"
COLOR="green"
STATUS="All systems operational"

if [ "$TOTAL_RECENT_ATTEMPTS" -gt 0 ] && [ "$RECENT_FAILURES" -ge 3 ]; then
  # Red: 3+ of last 10 syncs failed (critical)
  ICON="$ICON_RED"
  COLOR="red"
  STATUS="Multiple recent failures"
elif [ "$FAILURES_24H" -gt 0 ]; then
  # Orange: Some failures in 24h
  ICON="$ICON_ORANGE"
  COLOR="orange"
  STATUS="Failures in last 24 hours"
fi

# Menu bar display
echo "| templateImage=$ICON"
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
