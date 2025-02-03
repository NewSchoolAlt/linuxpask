#!/bin/bash

# Enable strict error handling
set -euo pipefail

# Function to log messages with timestamps
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo " "
    echo " message from buan:"
    echo "This script must be run as root stoopid. re-run it using sudo or as the root user."
    echo " "
    exit 1
fi

# Check for lsb_release command
if ! command_exists lsb_release; then
    log "lsb_release command not found. Please install it or ensure the system provides distribution information."
    echo " message from buan: If this happens to you, your system is most likely kaput to the point it doesn't even know what it is itself. "
    exit 1
fi

# Get the distribution and version
DISTRO=$(lsb_release -is)
VERSION=$(lsb_release -cs)

# Backup the existing sources.list
log "Backing up the current sources.list to /etc/apt/sources.list.bak"
if ! cp /etc/apt/sources.list /etc/apt/sources.list.bak; then
    log "Failed to back up /etc/apt/sources.list. Aborting."
    exit 1
fi

# Update sources.list with the correct components based on the distribution and version
log "Updating /etc/apt/sources.list with the new repository structure for $DISTRO $VERSION..."
case "$DISTRO" in
    Debian)
        case "$VERSION" in
            bullseye|bookworm)
                cat > /etc/apt/sources.list.d/"$VERSION".list << EOF
deb http://deb.debian.org/debian $VERSION main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security $VERSION-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian $VERSION-updates main contrib non-free non-free-firmware
EOF
                ;;
            *)
                log "Unsupported Debian version: $VERSION"
                exit 1
                ;;
        esac
        ;;
    Ubuntu)
        cat > /etc/apt/sources.list.d/"$VERSION".list << EOF
deb http://archive.ubuntu.com/ubuntu $VERSION main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $VERSION-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $VERSION-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu $VERSION-security main restricted universe multiverse
EOF
        ;;
    Kali)
        cat > /etc/apt/sources.list.d/"$VERSION".list << EOF
deb http://http.kali.org/kali $VERSION main non-free contrib
EOF
        ;;
    *)
        log "Unsupported distribution: $DISTRO"
        echo " message from buan: You're using a distro that's not supported by this script. You're on your own, buddy."
        exit 1
        ;;
esac

# Update the package list
log "Updating package list..."
apt-get update

# Upgrade available packages
log "Upgrading packages..."
apt-get upgrade -y

# Notify the user
log "Done! Your system has been updated with the new repository structure and packages have been upgraded."
