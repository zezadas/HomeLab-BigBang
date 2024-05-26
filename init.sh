#!/bin/bash
set -ex
docker build bootstrap/ -t bootstrap
docker run -v ./data:/data bootstrap
docker-compose build builder
docker-compose build localbuild
docker-compose up localbuild
docker-compose build netbootxyz-webapp
docker-compose up -d netbootxyz-webapp
docker-compose build dhcpd
docker-compose up -d dhcpd


