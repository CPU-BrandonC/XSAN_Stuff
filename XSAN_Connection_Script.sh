#!/bin/zsh

# Set the notification level. Must have SwiftDialog installed.
notifications="debug"
# debug = all messages
# error = errors only
# error_success = errors and success
# success = success only

xsan_volume="XSAN_Volume" # XSAN volume name

# Don't change anything below this line
notify_failed="false"

notify_user() {
if [ -f "/usr/local/bin/dialog" ]
then
    echo "$1"
    /usr/local/bin/dialog --notification --title "$xsan_volume" --message "$1"
else
    if [[ "$notify_failed" = "false" ]]
    then
        echo "WARNING: Swift Dialog not installed. Proceeding..."
        notify_failed="true"
        echo "$1"
    else
        echo "$1"
    fi
fi
}

connect_qsan() { 
    echo "INFO: Connecting to $xsan_volume..."
    xsanctl mount $xsan_volume
    if [ $? = 0 ]
    then
        echo "SUCCESS: Successfully mounted $xsan_volume."
        exit 0
    else
        echo "ERROR: Failed to mount $xsan_volume."
        exit 1
    fi
}

restart_xsan_service() {
    if launchctl list | grep -q "xsan" # check if XSAN is already running
    then
        echo "INFO: XSAN service is running. Restarting service."
        echo "INFO: Unloading..."
        launchctl unload /System/Library/LaunchDaemons/com.apple.xsan.plist | true # this sometimes fails so return true even if it fails
        echo "INFO: Loading..."
        launchctl load -w /System/Library/LaunchDaemons/com.apple.xsan.plist
        if [ $? = 0 ]
        then
            echo "INFO: Successfully restarted XSAN service."
            sleep 8 # XSAN will automatically attempt to mount volumes after starting. This delay prevents the script from also attempting to mount it at the same time 
        else
            echo "ERROR: Failed to restart XSAN service"
            exit 1
        fi
    else
        echo "INFO: Loading XSAN service"
        launchctl load -w /System/Library/LaunchDaemons/com.apple.xsan.plist
        if [ $? = 0 ]
        then
            echo "INFO: Successfully restarted XSAN service."
            sleep 8 # XSAN will automatically attempt to mount volumes after starting. This delay prevents the script from also attempting to mount it at the same time
        else
            echo "ERROR: Failed to restart XSAN service"
            exit 1
        fi
    fi
}

echo "------------------------------------"
echo "Starting XSAN connection utility"
echo "------------------------------------"

# Check if XSAN disk is already connected
echo "INFO: Checking if $xsan_volume is already mounted..."
if mount | grep -q "/Volumes/$xsan_volume"
then
    echo "ERROR: $xsan_volume already mounted!"
    exit 1
else
    echo "INFO: $xsan_volume not mounted."
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
