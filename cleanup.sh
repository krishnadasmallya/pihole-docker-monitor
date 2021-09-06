#!/bin/bash
set -e -x

sudo docker-compose -f /tmp/work/pihole_monitor/docker-compose.yml down -v

sudo rm -rf /opt/pihole_monitor/*

sudo rm -rf /tmp/work/pihole_monitor