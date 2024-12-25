#!/bin/bash

# Backup the existing sources.list
echo "Backing up the current sources.list to /etc/apt/sources.list.bak"
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Update sources.list with the correct components
echo "Updating /etc/apt/sources.list with the new repository structure..."
bash -c 'cat > /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
EOF'

# Update the package list
echo "Updating package list..."
apt update

# Upgrade available packages
echo "Upgrading packages..."
apt upgrade -y

# Notify the user
echo "Done! Your system has been updated with the new repository structure and packages have been upgraded."
