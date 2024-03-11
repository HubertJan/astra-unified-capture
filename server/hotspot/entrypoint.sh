#!/bin/sh

ifconfig wlan0 192.168.2.1 netmask 255.255.255.0
dhcpd wlan0 >/dev/null 2>&1 &
hostapd /etc/hostapd/hostapd.conf
