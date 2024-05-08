#!/bin/sh

ifconfig wlan0 192.168.2.1 netmask 255.255.255.0
dnsmasq
hostapd /etc/hostapd/hostapd.conf
