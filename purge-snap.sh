#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: Please run this script with sudo or as root."
    exit 1
fi

echo "🚀 Starting complete snapd removal and purge..."

# 1. Stop snapd services to prevent files being locked
echo "🛑 Stopping snapd services..."
systemctl stop snapd.service snapd.socket snapd.seeded.service || true
systemctl disable snapd.service snapd.socket snapd.seeded.service || true

# 2. Loop and purge all installed snaps individually
echo "📦 Removing all active snap packages..."
while true; do
    # Get the last snap listed (excluding the header) to avoid dependency conflicts
    SNAP_NAME=$(snap list 2>/dev/null | tail -n +2 | awk '{print $1}' | tail -n 1)
    
    # If no snaps are left, break the loop
    if [ -z "$SNAP_NAME" ]; then
        break
    fi
    
    echo "🗑️ Removing snap: $SNAP_NAME..."
    snap remove --purge "$SNAP_NAME"
done

# 3. Purge the main daemon and remove residual files
echo "🧹 Purging snapd package and configuration files..."
apt-get purge -y snapd

echo "📂 Cleaning up system directories..."
rm -rf /var/snap
rm -rf /var/lib/snapd
rm -rf /var/cache/snapd
rm -rf /usr/lib/snapd
rm -rf ~/snap

# Remove leftover snap mount units if they exist
echo "🔧 Cleaning up systemd artifacts..."
find /etc/systemd/system -name "*snap*" -delete
systemctl daemon-reload

# 4. Create the APT block rule to prevent accidental reinstallation
echo "🔒 Creating APT preference rule to permanently block snapd..."
cat << 'EOF' > /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# 5. Refresh package lists to apply the block
echo "🔄 Refreshing APT package cache..."
apt-get update

echo "✅ Success! snapd has been completely removed and blocked from this system."