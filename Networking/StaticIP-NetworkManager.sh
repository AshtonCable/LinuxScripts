#!/bin/bash

# Ask user for desired IPV4 address, subnet mask, gateway, primary DNS, and secondary DNS
read -p "Enter the desired IPV4 address: " ip_address
read -p "Enter the subnet mask: " subnet_mask
read -p "Enter the gateway: " gateway
read -p "Enter the primary DNS: " primary_dns
read -p "Enter the secondary DNS: " secondary_dns

# Generate a random IPV4 address if user's desired address is not available
function generate_random_ip {
    ip_address=$(shuf -i 2-254 -n 1).$(shuf -i 2-254 -n 1).$(shuf -i 2-254 -n 1).$(shuf -i 2-254 -n 1)
}

# Template for /etc/network/interfaces file
interfaces_template="
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
    address ${ip_address}
    netmask ${subnet_mask}
    gateway ${gateway}
    dns-nameservers ${primary_dns} ${secondary_dns}
"

# Write the configuration to /etc/network/interfaces
echo "${interfaces_template}" | sudo tee /etc/network/interfaces > /dev/null

# Restart network manager
sudo systemctl restart NetworkManager

# Display the updated network configuration
echo "Network configuration updated successfully:"
echo "IP Address: ${ip_address}"
echo "Subnet Mask: ${subnet_mask}"
echo "Gateway: ${gateway}"
echo "Primary DNS: ${primary_dns}"
echo "Secondary DNS: ${secondary_dns}"