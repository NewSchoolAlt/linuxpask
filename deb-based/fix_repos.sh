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

# Ask a yes/no question with default
# Usage: ask_yes_no "Prompt" [default]
# default: y (yes) or n (no)
ask_yes_no() {
    local prompt="$1"
    local default_answer="${2:-y}"
    local response
    local options
    case "${default_answer,,}" in
        y|yes) options="[Y/n]" ;;  # default Yes
        n|no)  options="[y/N]" ;;  # default No
        *)     options="[y/n]" ;;
    esac
    while true; do
        read -rp "$prompt $options: " response
        response="${response,,}"
        if [[ -z "$response" ]]; then
            response="$default_answer"
        fi
        case "$response" in
            y|yes) return 0 ;;  # yes
            n|no)  return 1 ;;  # no
            *)    echo "Please answer y or n." ;;
        esac
    done
}

# Check for root or sudo privileges
if [ "$EUID" -ne 0 ]; then
    if command_exists sudo; then
        log "Script not run as root; attempting sudo re-exec..."
        exec sudo bash "$0" "$@"
    else
        echo
        echo " message from buan: You need root privileges to run this script."
        if ask_yes_no "Do you want to enter the root password via su?" y; then
            log "Prompting for root password via su..."
            exec su -c "bash $0 ${*:-}" # allow empty args
        else
            echo "Aborting. Goodbye."
            exit 1
        fi
    fi
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
cp -f /etc/apt/sources.list /etc/apt/sources.list.bak

# Clear out the main sources.list to rely on .d files exclusively
log "Clearing /etc/apt/sources.list to rely on .d files exclusively"
: > /etc/apt/sources.list

# Determine .list filename and remove any old copy
LIST_FILE="/etc/apt/sources.list.d/${DISTRO,,}-${VERSION}.list"
if [ -f "$LIST_FILE" ]; then
    log "Removing existing file $LIST_FILE"
    rm -f "$LIST_FILE"
fi

# Create new repository file
log "Creating new repo list at $LIST_FILE for $DISTRO $VERSION"
case "$DISTRO" in
    Debian)
        case "$VERSION" in
            bullseye|bookworm)
                cat > "$LIST_FILE" << EOF
# Debian $VERSION - main, contrib, non-free, firmware
# Official mirrors
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
        cat > "$LIST_FILE" << EOF
# Ubuntu $VERSION - main, restricted, universe, multiverse
deb http://archive.ubuntu.com/ubuntu $VERSION main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $VERSION-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $VERSION-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu $VERSION-security main restricted universe multiverse
EOF
        ;;
    Kali)
        cat > "$LIST_FILE" << EOF
# Kali $VERSION
deb http://http.kali.org/kali $VERSION main non-free contrib
EOF
        ;;
    *)
        log "Unsupported distribution: $DISTRO"
        echo " message from buan: You're using a distro that's not supported by this script. You're on your own, buddy."
        exit 1
        ;;
 esac

# Ask whether to update & upgrade (default Yes)
if ask_yes_no "Do you want to update package lists and upgrade packages now?" y; then
    log "Updating package list..."
    apt-get update

    log "Upgrading packages..."
    apt-get upgrade -y
    log "Upgrade complete."
else
    log "Skipping update/upgrade as per user choice."
fi

log "Done! Your repo structure is set up for $DISTRO $VERSION."
