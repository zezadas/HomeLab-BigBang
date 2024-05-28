#!/bin/bash
set -ex
source ./env
#bootstrap source
docker build bootstrap/ -t bootstrap --build-arg AUTHORIZED_KEY="${AUTHORIZED_KEY}" --build-arg HASHED_PASSWORD="${HASHED_PASSWORD}"
docker run -v ./data:/data bootstrap
#build and run pxe
docker-compose build builder
docker-compose build localbuild
docker-compose up localbuild
docker-compose build netbootxyz-webapp
docker-compose up -d netbootxyz-webapp
#build and run dhcpd
docker-compose build dhcpd
docker-compose up -d dhcpd

#set interface ip for dhcpd server
ip addr add 172.20.11.1/24 dev ${PXE_NETIF} || true

#internet forwarding to pxe clients
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.forwarding=1

#remove any existent roule
iptables -t nat -D POSTROUTING -o ${INT_NETIF} -j MASQUERADE
iptables -D FORWARD -j ACCEPT
iptables -D FORWARD -i eth1 -o ${INT_NETIF} -j ACCEPT

#add roules to share internet 
iptables -t nat -A POSTROUTING -o ${INT_NETIF} -j MASQUERADE
iptables -A FORWARD -j ACCEPT
iptables -A FORWARD -i eth1 -o ${INT_NETIF} -j ACCEPT


