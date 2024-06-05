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
    exit 1
fi

# Check if XSAN Profile is installed
if sudo profiles -P | grep -q "com.apple.xsan.6"
then
    echo "INFO: QSAN profile installed"
else 
    echo "ERROR: QSAN profile not installed!"
    exit 1
fi

# Check if connected to the correct network + XSAN is reachable
if ping -c 1 $xsan_volume
then
    echo "INFO: $xsan_volume is reachable."
    # Checks which interface is used to connect to QSAN
    network_interface_name=$(route -n get $xsan_volume | grep "interface" | awk -F ':\ ' '{print $2}')
    echo "INFO: Network interface is $network_interface_name."
else
    echo "ERROR. Unable to ping QSAN"
    exit 1
fi

# Checks interface speed
network_interface_speed=$(networksetup -getmedia $network_interface_name | grep "Active" | awk -F ': ' '{print $2}')
if [[ if $network_interface_speed = "" ]]





# Check if XSAN service is started

# Attempt to connect QSAN
## Restart XSAN service if unsuccessful

# Reattempt connection after restarting XSAN

# Notify User