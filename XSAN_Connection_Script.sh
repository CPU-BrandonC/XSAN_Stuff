#!/bin/zsh

xsan_volume="XSAN_Volume" # XSAN volume name

echo "------------------------------------"
echo "Starting XSAN connection utility"
echo "------------------------------------"

# Check if XSAN disk is already connected
echo "INFO: Checking if $xsan_volume is already mounted..."
if mount | grep -q "/Volumes/$xsan_volume"
then
    echo "ERROR: $xsan_volume already mounted!"
else
    echo "INFO: $xsan_volume not mounted."
fi


# Check if XSAN Profile is installed
## Notify if false

# Check if connected to the correct network + XSAN is reachable
## Notify if either are false
network_interface_name=$(route -n get $xsan_volume | grep "interface" | awk -F ':\ ' '{print $2}')
network_interface_speed=$(networksetup -getmedia $network_interface_name | grep "Active" | awk -F ': ' '{print $2}')

# Check if XSAN service is started

# Attempt to connect QSAN
## Restart XSAN service if unsuccessful

# Reattempt connection after restarting XSAN

# Notify User