#!/bin/sh

set -eux

# Spotlight: keep mds off trees of generated files (git worktrees, node_modules), which
# made mds/mds_stores the top CPU consumers. This is the list behind System Settings >
# Spotlight > Search Privacy. There is no supported CLI for it, so edit the plist mds reads
# and restart mds. Needs sudo, and Full Disk Access for the terminal running this.
PLIST=/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist
BUDDY=/usr/libexec/PlistBuddy

if ! sudo test -r "$PLIST"; then
  echo "spotlight.sh: cannot read $PLIST; grant this terminal Full Disk Access" >&2
  exit 1
fi

sudo "$BUDDY" -c "Print :Exclusions" "$PLIST" >/dev/null 2>&1 \
  || sudo "$BUDDY" -c "Add :Exclusions array" "$PLIST"

for dir in "$HOME/dev" "$HOME/worktrees"; do
  # Exact line match: a substring match would treat an excluded subdirectory as the parent.
  if ! sudo "$BUDDY" -c "Print :Exclusions" "$PLIST" | sed 's/^ *//' | grep -qxF "$dir"; then
    sudo "$BUDDY" -c "Add :Exclusions: string '$dir'" "$PLIST"
  fi
done

# launchd respawns mds, which then rereads the plist.
sudo killall mds || true
