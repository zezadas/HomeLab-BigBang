#!/bin/bash
set -ex
PXE_NETIF=eth1
INT_NETIF=eth0

docker build bootstrap/ -t bootstrap
docker run -v ./data:/data bootstrap
docker-compose build builder
docker-compose build localbuild
docker-compose up localbuild
docker-compose build netbootxyz-webapp
docker-compose up -d netbootxyz-webapp
docker-compose build dhcpd
docker-compose up -d dhcpd

#set interface ip for dhcpd server
ip addr add 172.20.11.1/24 dev ${PXE_NETIF}

#internet forwarding to pxe clients
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.forwarding=1

iptables -t nat -A POSTROUTING -o ${INT_NETIF} -j MASQUERADE
iptables -A FORWARD -j ACCEPT
iptables -A FORWARD -i eth1 -o ${INT_NETIF} -j ACCEPT


