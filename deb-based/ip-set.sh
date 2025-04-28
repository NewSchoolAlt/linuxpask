#!/usr/bin/env bash

set -e

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
  read -p "Interface name (e.g., eth0): " IFACE
  while [[ -z "$IFACE" ]]; do
    read -p "Interface cannot be empty. Enter interface: " IFACE
  done

  PS3="Select mode: "
  options=(dhcp static)
  select MODE in "\${options[@]}"; do
    [[ -n "$MODE" ]] && break
    echo "Invalid choice."
  done

  if [[ "$MODE" == "static" ]]; then
    read -p "Static IP address: " IP
    read -p "Netmask: " NETMASK
    read -p "Gateway: " GATEWAY
    read -p "DNS servers (space-separated): " DNS
  fi
}

# --- Parse args ---
if [[ " $* " == *" -h "* || " $* " == *" --help "* ]]; then
  print_usage
fi

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

# If no mandatory args provided, go interactive
if [[ -z "$IFACE" || -z "$MODE" ]]; then
  interactive_prompt
fi

# --- Checks ---
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if [[ "$MODE" == "static" ]]; then
  for var in IP NETMASK GATEWAY DNS; do
    if [[ -z "${!var}" ]]; then
      echo "Static mode requires $var to be set." >&2
      exit 1
    fi
  done
fi

# --- Backup ---
cp "$INTERFACES_FILE" "$BACKUP_FILE"
echo "Backup saved: $BACKUP_FILE"

# --- Generate new config ---
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

# --- Restart networking ---
systemctl restart networking

echo "Interface $IFACE is now set to $MODE mode."
