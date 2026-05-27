# Ubuntu Snap Purge & Block Script

A minimalist Bash script to completely remove Canonical's `snapd` package manager ecosystem from Ubuntu Server/Desktop, clean up residual files, and apply a permanent APT pin block to prevent it from ever sneaking back during standard system upgrades. 

Perfect for preparing clean, lightweight headless Docker hosts.

## 🚀 Features
* **Automated Dependency Removal:** Uninstalls core system snaps and user application snaps in reverse order to bypass file locks.
* **Aggressive Cleanup:** Wipes residual files from `/var/snap`, `/var/lib/snapd`, systemd mounts, and home directories.
* **Permanent Block:** Generates an APT preference rule (`/etc/apt/preferences.d/nosnap.pref`) pinning `snapd` to a negative priority.

## 📦 Quick Execution (One-Liner)

You can execute the script directly from this repository without cloning it manually:

```bash
curl -sSL [https://raw.githubusercontent.com/livemike78/ubuntu-purge-snap/main/purge-snap.sh](https://raw.githubusercontent.com/livemike78/ubuntu-purge-snap/main/purge-snap.sh) | sudo bash
