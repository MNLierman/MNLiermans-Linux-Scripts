#!/bin/bash

# SetMTU Script
# Created by Mike Lierman (@MNLierman) and @InviseLabs.
# License: OK to modify & share, please consider contributing improvements to GitHub, commercial use of @MNLierman's scripts by written agreement only.

# Description: Loops through each adapter and sets a slightly higher (2500) MTU for specific adapters.
# Technology has come a long way since the invention of the Internet and its dial-up origins.
# A higher MTU (packet size) significantly increases network throughput. Path discovery still remains on for system auto-adjust.

# Log file
LOGFILE="/var/log/mtu_change.log"

# MTU values
MTU_SPECIFIC=2500
MTU_OTHER=5000

# Initialize counter
count=0

# Function to log messages with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

# Log script start
log_message "Script started"

# Iterate through all network interfaces
for iface in $(ls /sys/class/net/); do
    # Get the current MTU of the interface
    current_mtu=$(ip link show $iface | grep -oP 'mtu \K[0-9]+')

    # Check if the current MTU is above 1501
    if [ "$current_mtu" -gt 1501 ]; then
        log_message "Skipping $iface with MTU $current_mtu"
        continue
    fi

    # Set MTU to 2500 for all physical interfaces
    if echo "$iface" | grep -q '^e[a-z][0-9]$'; then
        log_message "Changing MTU on $iface from $current_mtu to $MTU_SPECIFIC."
        sudo ip link set mtu $MTU_SPECIFIC $iface
    # Set MTU to 5000 for assumed virtual interfaces
    else
        log_message "Changing MTU on $iface from $current_mtu to $MTU_OTHER."
        sudo ip link set mtu $MTU_OTHER $iface
    fi

    # Increment counter
    count=$((count + 1))
done

# Log the total number of interfaces processed
log_message "Total interfaces processed: $count"
