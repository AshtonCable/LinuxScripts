#!/bin/bash

# Check if docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Please install it first."
    exit 1
fi

# Check if wireguard module is loaded
if ! lsmod | grep wireguard &> /dev/null
then
    echo "Wireguard module is not loaded. Please load it first."
    exit 1
fi

# Ask the user if they want to customize the variables
read -p "Do you want to customize the variables for the wireguard server? [y/N] " answer
case $answer in
    [yY]* )
        # Set some variables with user input
        read -p "Enter your server IP or Dynamic DNS hostname: " WG_HOST
        read -p "Enter a password for the web UI: " PASSWORD
        read -p "Enter the ethernet device the wireguard traffic should be forwarded through: " WG_DEVICE
        read -p "Enter the public UDP port of your VPN server: " WG_PORT
        read -p "Enter the MTU the clients will use: " WG_MTU
        read -p "Enter the value in seconds to keep the connection open: " WG_PERSISTENT_KEEPALIVE
        ;;
    * )
        # Set some variables with default values
        WG_HOST=YOUR_SERVER_IP # Replace this with your WAN IP or Dynamic DNS hostname
        PASSWORD=YOUR_ADMIN_PASSWORD # Replace this with a password for the web UI
        WG_DEVICE=eth0 # Replace this with the ethernet device the wireguard traffic should be forwarded through
        WG_PORT=51820 # Replace this with the public UDP port of your VPN server
        WG_MTU=1420 # Replace this with the MTU the clients will use
        WG_PERSISTENT_KEEPALIVE=25 # Replace this with the value in seconds to keep the connection open
        ;;
esac

# Pull the docker image for wireguard
docker pull weejewel/wg-easy

# Run the docker container for wireguard
docker run -d \
  --name=wg-easy \
  -e WG_HOST=$WG_HOST \
  -e PASSWORD=$PASSWORD \
  -e WG_DEVICE=$WG_DEVICE \
  -e WG_PORT=$WG_PORT \
  -e WG_MTU=$WG_MTU \
  -e WG_PERSISTENT_KEEPALIVE=$WG_PERSISTENT_KEEPALIVE \
  -v ~/.wg-easy:/etc/wireguard \
  -p $WG_PORT:$WG_PORT/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  weejewel/wg-easy

# Print the web UI URL
echo "The web UI is available at http://$WG_HOST:51821"