#!/usr/bin/env bash

set -euo pipefail

# --- Constants ---
INTERFACES_FILE="/etc/network/interfaces"
BACKUP_DIR="/etc/network"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/interfaces.bak.$TIMESTAMP"

print_usage() {
  cat << EOF
Usage: $0 [--ifname IFACE] [--mode dhcp|static] [--ip IP --netmask NM --gateway GW --dns "DNS1 DNS2"]
If run without arguments, the script will prompt interactively.
Options:
  --ifname    Network interface name (e.g., eth0)
  --mode      dhcp | static
  --ip        Static IP address          (required for static)
  --netmask   Network mask               (required for static)
  --gateway   Default gateway            (required for static)
  --dns       Space-separated DNS servers (required for static)
  -h, --help  Show this help message
EOF
  exit 1
}

interactive_prompt() {
  echo "No arguments provided. Entering interactive mode..."
  # Prompt for interface
  while true; do
    read -rp "Interface name (e.g., eth0): " IFACE
    [[ -n "$IFACE" ]] && break
    echo "Interface cannot be empty."
  done

  # Prompt for mode using a validated select
  PS3="Select mode (1 for dhcp, 2 for static): "
  options=("dhcp" "static")
  select choice in "${options[@]}"; do
    if [[ -n "$choice" ]]; then
      MODE=$choice
      break
    else
      echo "Invalid choice. Please enter 1 or 2."
    fi
  done

  # If static, prompt for details
  if [[ "$MODE" == "static" ]]; then
    read -rp "Static IP address: " IP
    read -rp "Netmask: " NETMASK
    read -rp "Gateway: " GATEWAY
    read -rp "DNS servers (space-separated): " DNS
  fi
}

# --- Parse args ---
if [[ " ${*:-} " =~ " -h " || " ${*:-} " =~ " --help " ]]; then
  print_usage
fi

# Process flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --ifname)   IFACE="$2"; shift 2;;
    --mode)     MODE="$2"; shift 2;;
    --ip)       IP="$2"; shift 2;;
    --netmask)  NETMASK="$2"; shift 2;;
    --gateway)  GATEWAY="$2"; shift 2;;
    --dns)      DNS="$2"; shift 2;;
    *)          echo "Unknown option: $1"; print_usage;;
  esac
done

# Enter interactive if missing required
if [[ -z "${IFACE:-}" || -z "${MODE:-}" ]]; then
  interactive_prompt
fi

# Validate root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Validate static params
if [[ "$MODE" == "static" ]]; then
  for var in IP NETMASK GATEWAY DNS; do
    if [[ -z "${!var:-}" ]]; then
      echo "Static mode requires $var to be set." >&2
      exit 1
    fi
  done
fi

# Backup original
cp "$INTERFACES_FILE" "$BACKUP_FILE"
echo "Backup saved: $BACKUP_FILE"

# Write new config
{
  echo "source /etc/network/interfaces.d/*"
  echo
  echo "auto $IFACE"
  if [[ "$MODE" == "dhcp" ]]; then
    echo "iface $IFACE inet dhcp"
  else
    echo "iface $IFACE inet static"
    echo "    address $IP"
    echo "    netmask $NETMASK"
    echo "    gateway $GATEWAY"
    for dns in $DNS; do
      echo "    dns-nameservers $dns"
    done
  fi
} > "$INTERFACES_FILE"

# Apply changes
if systemctl restart networking; then
  echo "Interface $IFACE is now set to $MODE mode."
else
  echo "Failed to restart networking. Restoring backup..." >&2
  mv "$BACKUP_FILE" "$INTERFACES_FILE"
  systemctl restart networking
  echo "Restored previous configuration."
  exit 1
fi
