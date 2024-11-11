#!/bin/bash

# Share Eth1 (iPhone USB Hotspot) with Eth0 device (Unifi WAN2)
#
#
# This script is created to work with Raspbian Stretch
# but it can be used with most of the distributions
# by making few changes.
#
# Make sure you have already installed `dnsmasq`
# Please modify the variables according to your need
# Don't forget to change the name of network interface
# Check them with `ifconfig`

ip_address_and_network_mask_in_CDIR_notation="172.16.2.1/24"
dhcp_range_start="172.16.2.10"
dhcp_range_end="172.16.2.100"
dhcp_time="12h"
dns_server="9.9.9.9"

sudo systemctl start network-online.target &> /dev/null

sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
sudo iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

sudo ip link set eth0 down
sudo ip link set eth0 up
sudo ip addr add  $ip_address_and_network_mask_in_CDIR_notation dev eth0 

# Remove default route created by dhcpcd
sudo ip route del 0/0 dev eth0 &> /dev/null

sudo systemctl stop dnsmasq

sudo rm -rf /etc/dnsmasq.d/* &> /dev/null

echo -e "interface=eth0
bind-interfaces
server=$dns_server
domain-needed
bogus-priv
dhcp-range=$dhcp_range_start,$dhcp_range_end,$dhcp_time" > /tmp/custom-dnsmasq.conf

sudo cp /tmp/custom-dnsmasq.conf /etc/dnsmasq.d/custom-dnsmasq.conf
sudo systemctl start dnsmasq
