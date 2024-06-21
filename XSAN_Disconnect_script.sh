#!/bin/zsh

# Xsan Volume name
xsan_volume="XSAN_Volume"

notifications_enabled="true"

notify_failed=""

# Get logged in User
current_user=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

force_disconnect_xsan() {
    xsanctl unmount QSAN -f
    if [ $? = 0 ]
    then
        notify_user "SUCCESS: Disconnected from $xsan_volume"
        exit 0
    else
        notify_user "ERROR: Failed to disconnect $xsan_volume"
        exit 1
    fi
}

disconnect_xsan() {
    echo "INFO: Attempting to gracefully disconnect $xsan_volume..."
    xsanctl unmount QSAN
    if [ $? = 0 ]
    then
        notify_user "SUCCESS: Disconnected from $xsan_volume"
        exit 0
    else
        echo "WARNING: Failed to gracefully disconnect from $xsan_volume"
        return 1
    fi
}

get_open_files() {
    open_files="$(sudo -u $current_user lsof | grep $xsan_volume | sed '/\.Trashes/d')"
    echo "$open_files"
}

notify_user() {
    if [ -f "/usr/local/bin/dialog" ]
    then
        if [ "$notifications_enabled" = "true" ]
     then
            echo "$1"
            /usr/local/bin/dialog --notification --title "$xsan_volume" --message "$1"
        else
            echo "$1"
        fi
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

open_files_notify() {
    if [ -n "$(get_open_files)" ]
    then
        /usr/local/bin/dialog --title "Unable to disconnect $xsan_volume" \
            --message "The following file(s) are still open:\n$open_files\n..." \
            --button1text "Retry" \
            --button2text "Force Disconnect" \
            --moveable
        case $? in
            0)
                # Retry
                echo "INFO: User clicked $dialog_button1_text"
                open_files_notify && return
                ;;
            2)
                # Force Disconnect
                echo "WARNING: User clicked $dialog_button2_text."
                force_disconnect_xsan
                ;;
        esac
    else
        disconnect_xsan
        if [ $? != 0 ]
        then
            echo "INFO: Force disconnecting from $xsan_volume..."
            force_disconnect_xsan
        fi
    fi
}

# Check if XSAN Volume is currently mounted
echo "INFO: Checking if $xsan_volume is already mounted..."
if mount | grep -q "/Volumes/$xsan_volume"
then
    echo "INFO: $xsan_volume is mounted"
else
    notify_user "ERROR: $xsan_volume not mounted."
    exit 1
fi

open_files_notify