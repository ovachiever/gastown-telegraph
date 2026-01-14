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
ICON_GREEN="iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAADjklEQVR4nD2Uy24cRRSGv6quvszdt4kdO+PYSuKQRCAwLJASQ2ABiaKIHRJihcQrsOFBYIPYIMRLgCASKDuCInIxthU7sePEY49vTM+lp+qg6nFoqdW3c059dfr/j/r8hy+XdJR9a1U2K06UKJSIgFJopUDA4RAEheLVoUT5KAITthIXfW0k6H3vinLedizK5CEYFeTJ3UEHK5bYRIQ6wokgzi8CiC8MQSzlNE2/M5n0Z3XXg2iFDwLSQUoxKnJhZIGiKfKi/SI/4yD2FUBUTuyje2lPUCrRKDXISXNQxcBZ6sVTXJu+xuvjb5CoEov1RS6NXqY/yAi0OQHyBX0NrfyDebVr/0FwaKVZml7CKmGltcrW0SY73SafXfqUVneP7XQ7J/P9CnSAlQG+s9qn5yxaY8VRi2v0pcdaa4Wp0iQ3L9ygMTLH+uEzqlGVq9NXuX3uE0phOW+B1n5TCu05/Y0n02icWDJn+fPlXwxcj42DpzQKUzQqM1weu0za69Dut7l5/gaVsIpzoEX7DmvfIMQ5AhWwm+5hbcb1s9f5ef03lveWOVOZphZV6Ls+SgdcmrhIJCG35m/lJE4cxsvDb26ARSQjDhPubN7hrfqbfDT3IaW4yqnqFI93HvLH1l0mS5NsH2/Rt31anT36tofRBi15GWEkGeVMeZZEJQwY8LD1mEo8yr3mPX569CPlqEqjdpaO7bBxtME/+ytsdbZxyv85hW+2KpsS12fe50rtCouTiygXMlue5ersuxRUSEGVefv0O9STccaSMTI34KC7Tz2p46z1KscYjBz1julkbSZrp/Oe3Dz3MfMj8/yy+ivvNT7ABDF3n/1OHIQsjF9EHIxEo8xVGzzYuU/qUrQTq7q2D9qQmJjXJhbYTw/YOHzGZvsph9khh/0Dnrd3KESVoU0UhGHEbqdFEia5E41ooR5P5B5abq5gdJDboJuljBUn2Dx+TqRDZqrTBErTSlu5uitRifu793nZbVIwBYwTpBJViEzE380HJFFMEGia/WYuVPzyniK3A4QmpJN1adBgujbDk6M1xIqYgMC8/LfpHukHul4eFYcor/Chj7xQvVS9QYeG9tdqVOEoO5D1/Q1llBEVoExkoie6rBZWj9aw2NzSeWru7v8NNCx4Mj6GdEp5zxVqRZW1bdsYwi9cz30TB8V5Zx0oN5wPw/wTDj8e8mE2fJc/IB580GOvqCtf/Qd5trSGi351TQAAAABJRU5ErkJggg=="
ICON_YELLOW="iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAADMklEQVR4nD2UzYscVRTFf/fVq6ru6eqYnkwykGTMuHD8IFERE0QISFARRBeKC1HB7Nz6N/hXKGJ0I+hC3Eo2ioIoMhAXMSLOaBBRJtPdmZ6Pru5698p73Z1HUVS9evfUvefcc6V/45nLnez3DzUc3d8EESdgJoLFS4hLRDEDiXdDZvtmRYE11vt5WG+8LaPN5V+rau/hoz0jgswjwZr5C0R0w4MpCYKIKqiatXteRsPVa55Qr433MDOHGpJOhimar0DrEZAcOdpEpkNwBYhFpLTS06Ga2GTDiUnjXCwl/Ru0QdsX0OV3CUtXMGsReu+g7cfSN8wlBDFDNAXFQprZ7jxVLGCugx5/Awsj2P8ODn7A736M3fcSOI9YjUiTMjNxszjA42aJpA0NWH4GbIhMbkLnAtZ9Au1/jk3/RYsHobqUALLdTyMHYJE7Jw51UQZQSWCCIqFPNryOhH1k/DdaXcGkQqvL6PgvtHiUpvcWptlCHHMWZTaHxIzcEtRbYDn0XibbuYYe3YJyA9rnscl/UJzF3CmsdRHtvQJag8twSadU5wT0ABGH63+GSklz4nWk9xquWIW7X5MNvkKaQVKR5h8Y/wHiQRUf+TGU4NeQ7Bgy/ROau9jhJrpylezOBxgFcvxVKE4iuour+5g/g0xuQ+kw08hRA1kPPXGVpnqBUD0L0oWli2Td5zAVzK9h3efBH8Pyc1DvQKghXwWdxA6IqhXCdBeb3EbKc1hYpll9D8lPozufIKffT12u/S+w9lO48iGwDCnX0WIdRr+Bc/jY7qoN4lcEfxZreTj8BWwfm24jk1PJa9l0G+s8iYY9pFjGdIDpGHMebTQyNUGKlcS+HHyDuBZkkbqAletQ38Ikh9YDOFNUB6lFohgy+BJpRU8GvFhjkvUQX5kbfS+4fKbEdGtmUJu7KokScJIhkdfqxTlHA5yIeaPMwnjbkOuoP5n8ZLHU6PaFBZJ9ImLMSIEOMvo28aqtXINZ4TUrt7vV5PzB8MfZGInn742Te5MkmX6xFv4O5OI6mTDIbsqdG5eeXpKtj7Sp15uQOjzGzMZJqmdRm80SW8AbVhbKVFs/1eHxN/8HyEeOHiYsh44AAAAASUVORK5CYII="
ICON_ORANGE="iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAADaElEQVR4nEWUSW8cRRTHf6+qF8/YHo8dx45N4gBJjC1jQxDLyRLLCQkJIYGAA+ICEgdOfAC+BifgwolTJA5cEIeITaAgNiUkJGAC8XiJJzb2xDPTXe+h6jGipZaq1F3v1X97cvOjZ5ebxcb7rt9Z6AeHYCIixMfEQ1xaQCwuDav+ADMxL4bPhrZ23fQ7sv3ewsXJWn/1oAPexUOGOIdZgLJX7fE5JBloGdtUb1XWoJ557vSSO4nHzvUOVZVEUBPEQb+HZaPoifOQj0L7Gm7vTywdHhSOhSzeWdg/LCz1btyZSelEXLx2hCFlHx2ZpVh8mf6ppynICadWCSdXcWUPJwkS7KiQ4p2ImjOHq+BXjeJHcynl2ecJLofWd7jtyyQ/fIjNPIY174VuGyMgEsD5o0Mh4ohLweKdtEBrTdR73PbPuMYctvIqNv0g1r5CmY1RnHmO8uE30KFxpOhgVMTiVCtQA5UiyaHAaZ9k7XNct43sXCc0H0DHzqDTj6BFH/qHhJU30foUYmVFibPI3EBtcDly2EY6O4TFF3HXLkDrW7Qxi9amwGdEa9jMo6jLCcuvYxGeRalcJQOiJaJdJMmw6xcIc08Rll6BbJRkfIFy4xJy+WPk2Dy618LursPdW9DvItkYUTURU0I+QTmxRJmO4KzAb1xCG3O4W99gF9/FZSO4mYeQ7ha0vsS3b+B6exU/qiUuEhQV0sWXCDNPEE4/g5KizXn86SexfAxXn8BOPo7l4zB8D15S3EELy8ZBA+LTCM2bFAfwz9/46fPo7auUS6/hji8Tfv0EN/8CwdfQta8qCNK8D1MdEH3sLLb+NVIW0UWKWB9JRwi+gU2cw0IP27uK7PyC7P2OHNzEd9ahPknpPCEaOxtCO9uYr2GR7Mi45U001tz+cRDSskQKhbH70f0NYBPqx/Euxbq7iPYhyfF/fYHvbVGkDRJUjeEJXGMWufEp+BSJMTgYZMnMqo5xAsTUe58j5SE2uYKOn0XbV1BnliAu1YNNZe0zYWQKygIdOOLIW3G0RCyhypFG90auOi3k9k8Eyc1jkuCS34brTIet7yvZB/48mkdHlh8EOiZ6kNVBH8WSGvVGTXZ76XZSTsy/tbv/xweS+sVDi93/L/VfdGLKYx6linfMVpw4WELJfuk3e0Mn3v4Xl/yjQdas8AoAAAAASUVORK5CYII="
ICON_RED="iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAADcUlEQVR4nD2UyW9cRRDGf9X95s2Mx0vGjtexHAQCJUZccgm2MElYEsIJIkCJEAqIExL/Tf4GDkjmEEVCHDiAxAmxJASSeAmOiZfYOONlHHtmXr8u1D0OdXj91N1V/VXV95X8duXS2yONveu0m2MeUBBECKZxFcR70HhCOFNR8KgV0GJxZSspfilLF848Gjb5+L7zSLiggDHRWdstyHMkLUKaoiFgfKGz5ECPFdaxy0mBvNZwuXqRGEeMhWYTXyrD5EmkWkUX5pC1FaTSDf4oypHtO6/WUEsEzS0kaMBtkIND8udfIDt3Ad9qYRbmkVffwDy4R/Gv22ixhPocjbCEBMSqOCNeJe6pIt7hy2WymfP4VhOWFpH5+yQ3voIzU7jqMfxBA+9zJNZMYum8qpgItAMGzdvo8cEOsju3MWPj6LVPyUdHcQtzuL4B3FuXyK9eIy+XoXWIN8FfMSEj/b8bCT5zmKf72Ds/Y1oH+Fu/k028hE6cgKnXyHZ3cM6Rf/AxLtbMg7EERKIefK5QSDGbq/EFzr2Dmf0aefg3MvkyWh3E17cxpQq8eIqsUkHfv4KYDj1MJy9FXBtpHWDTFHNzFs2V/PJH2JnzlEZrmKU5+O5Gp3sP5rHb2+jKMtpuo6ok4RMQ+OFhtNyNPF4naezgF++RvXsZ++03ZHkGr1/E1mrg27EBLpRiawNCOtZgQl6+0oO7+B7t09Po9FlcsYgfGac0NYN09YDpwk6fheFRtLcfPTyA3ToyOBIJixgSCgWV3R3MkyeYkTH80z381c8xx4do3Zyl8OEnkXjupx9gZALT20u+u42US9jac/hbv0C7jZE8SCFDqv1odw9+rAZLS5j1NezGGn5jDalvYufvh0oGiWEGhyJF3NIiJIGSQqIBWv8AWWMXqW9hjAEj0DzED9fw/zwkKMyeOklqC+SbjyMJqQ5g//yV5LABpR4SXOapDljT1w8/fo+pVCCx+Cf/YtRjQ+Bg66sxoCmk6H4DX+nF106ggf2qKstvnvZJ25FPviLS2wfOoaETYYR0mBEGSdwL+gr/Ym1suczdpXCwr01j88Sn6eqxtDDeuPtH1Fp0DhIJblE/z+ZQh6fPpkicOOUyfaVUNjCPkkZ16LNSo37ddZVrWQwgnbHWEXcE1uHaUUwJN0xAqIl66jZZ20uLX/wHfderi3Swv4AAAAAASUVORK5CYII="

# Check if daemon is running
if ! pgrep -f "gt-auto-sync" > /dev/null 2>&1; then
  echo "| image=$ICON_RED"
  echo "---"
  echo "❌ Daemon NOT Running | color=red"
  echo "Start Daemon | shell='$CONTROL_SCRIPT' param1=start terminal=false refresh=true"
  echo "---"
  echo "View Logs | shell=open param1=-a param2=Console param3='$LOG_FILE' terminal=false"
  exit 0
fi

# Parse log file for recent activity
if [ ! -f "$LOG_FILE" ]; then
  echo "| image=$ICON_YELLOW"
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
echo "| image=$ICON"
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
