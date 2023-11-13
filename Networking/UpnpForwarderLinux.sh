#!/bin/bash

# Check if upnpc is installed
if ! command -v upnpc >/dev/null 2>&1; then
  echo "upnpc is not installed. Please install it before running this script."
  exit 1
fi

# Function to add a port forwarding rule
add_port_forwarding() {
  read -p "Enter the IP address to forward: " ip_address
  read -p "Enter the internal port: " internal_port
  read -p "Enter the external port: " external_port
  read -p "Enter the protocol (TCP/UDP): " protocol

  upnpc -a "$ip_address" "$internal_port" "$external_port" "$protocol"
  echo "Port forwarding rule added: $ip_address:$internal_port->$external_port ($protocol)"
}

# Function to remove a port forwarding rule
remove_port_forwarding() {
  read -p "Enter the external port to remove: " external_port
  read -p "Enter the protocol (TCP/UDP): " protocol

  upnpc -d "$external_port" "$protocol"
  echo "Port forwarding rule removed: $external_port ($protocol)"
}

# Function to set up the cron job
setup_cron_job() {
  cron_command="upnpc -r"

  # Add the cron job
  (crontab -l 2>/dev/null; echo "0 * * * * $cron_command") | crontab -
  echo "Cron job set up to renew port forwarding rules every hour."
}

# Main menu loop
while true; do
  clear
  echo "1. Add port forwarding"
  echo "2. Remove port forwarding"
  echo "3. Set up cron job to renew port forwarding rules"
  echo "4. Exit"
  read -p "Enter your choice: " choice

  case $choice in
    1) add_port_forwarding ;;
    2) remove_port_forwarding ;;
    3) setup_cron_job ;;
    4) exit ;;
    *) echo "Invalid choice. Please try again." ;;
  esac
done