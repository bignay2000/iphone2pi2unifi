# https://pimylifeup.com/raspberry-pi-wifi-bridge/
apt update
apt upgrade
apt vim

nmcli c add con-name eth1bridge type ethernet ifname eth0 ipv4.method shared ipv6.method ignore
