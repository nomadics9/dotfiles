#!/usr/bin/env bash

# Get the interface name (change this to your actual WireGuard interface name if needed)
interface="nmd"

handshake=$(ip a show "$interface" | grep 'link')

# Check if WireGuard is up
if [[ -n "$handshake" ]]; then
  # If it's up, bring it down
  pkexec wg-quick down "$interface"
  dunstify -a "WireGuard" "Disconnected from $interface"
else
  # Otherwise, bring it up
  pkexec wg-quick up "$interface"
  dunstify -a "WireGuard" "Connected to $interface"
fi
