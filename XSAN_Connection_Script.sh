#!/bin/zsh

xsan_volume="XSAN_Volume" # XSAN volume name

# Connect to QSAN
connect_qsan() { 
    echo "INFO: Connecting to QSAN"
    xsanctl mount $xsan_volume
}

restart_xsan_service() {
    if launchctl list | grep -q "xsan"
    then
        echo "INFO: XSAN service is running. Restarting service."
        echo "INFO: Unloading..."
        launchctl unload /System/Library/LaunchDaemons/com.apple.xsan.plist | true
        echo "INFO: Loading..."
        launchctl load -w /System/Library/LaunchDaemons/com.apple.xsan.plist
        if [ $? = 0 ]
        then
            echo "INFO: Successfully restarted XSAN service."
            sleep 8 # wait for xsan service to attept to connect to QSAN
            
    else

}

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
if sudo profiles -P | grep -q "com.apple.xsan."
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
    echo "ERROR. Unable to ping QSAN!"
    exit 1
fi

# Checks interface speed
network_interface_speed=$(networksetup -getmedia $network_interface_name | grep "Active" | awk -F ': ' '{print $2}')

if echo $network_interface_speed | grep -q "10G"
then
    echo "INFO: Network interface speed is $network_interface_speed."
else
    echo "WARNING: Network interface speed is $network_interface_speed. Connect to 10G network and confirm network service order. Continuing..."
fi

# Check if XSAN service is started
if launchctl list | grep -q "xsan"
then
    echo "INFO: XSAN service is currently running"
else
    echo "WARNING: XSAN service not running"
fi



# Reattempt connection after restarting XSAN

# Notify User