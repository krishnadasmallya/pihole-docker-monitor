#!/bin/bash
set -e -x

sudo docker-compose down -v

sudo rm -rf /opt/pihole_monitor/*

sudo rm -f /tmp/work/pihole_monitor/*