#!/bin/bash

# Service Cleanup Script
# Created by Mike Lierman (@MNLierman) and @InviseLabs.
# License: OK to modify & share, please consider contributing improvements, commercial use of @MNLierman's scripts by written agreement only.
#
# This script will cleanup / delete the specified services, optional logging
# is available. Arguments can be passed or you can define the variables below.
#
# Variables:
# - SERVICES: Space-separated list of service names to clean up, you can leave blank and pass args instead.
# - SKIP_CONFIRM: Whether to confirmation and proceed with cleanup (true/false).
# - LOGGING_ENABLED: Whether to enable or disable logging (true/false).
# - LOGFILE: Location of the log file (default: service_cleanup.log in current dir).

# Initialize variables
SERVICES="svcname1 svcname2"  # <- Change
SKIP_CONFIRM=false
LOGGING_ENABLED=true
LOGFILE="/var/log/service_cleanup.log"

print_help() {
    echo "Usage: $0 -s [servicenames] [-y]"
    echo "-s [servicenames] : Specify the service names to clean up, separated by spaces"
    echo "-y                : Skip confirmation and proceed with cleanup"
    echo "--help, -help, -h, -? : Display this help message"
}

while getopts ":s:yh?" opt; do
    case ${opt} in
        s ) SERVICES=$OPTARG ;;
        y ) SKIP_CONFIRM=true ;;
        h | \? ) print_help; exit 0 ;;
    esac
done

[[ -z "$SERVICES" ]] && { echo "Service names are required."; print_help; exit 1; }

# Logging function
log_message() {
    if $LOGGING_ENABLED; then
        echo "$1" | tee -a "$LOGFILE"
    else
        echo "$1"
    fi
}

# Function to find service files
find_files() {
    FILES=$(find /etc/systemd/system /usr/lib/systemd/system /lib/systemd/system /etc/init.d /var/lib/systemd/deb-systemd-helper-enabled /run/systemd/generator.late -type f -name "*${SERVICE}*")
    echo "$FILES"
}

# Function to clean up the service
cleanup_service() {
    local SERVICE=$1

    # Stop and disable the service
    systemctl stop "$SERVICE" && systemctl disable "$SERVICE"
    log_message "Stopped and disabled service: $SERVICE"

    # Remove the files
    for FILE in $FILES; do
        rm -rf "$FILE" && log_message "Removed: $FILE"
    done

    # Reload the systemd daemon
    systemctl daemon-reload
    log_message "Reloaded systemd daemon"

    # Check if service still exists
    if systemctl status "$SERVICE" > /dev/null 2>&1; then
        log_message "Service $SERVICE still exists."
        systemctl cat "$SERVICE"
    else 
        log_message "Cleanup successful. Service $SERVICE is removed."
    fi
}

# Script starts here:
log_message ""
log_message "Service Cleanup Script started, date and time is $(date '+%Y-%m-%d %H:%M:%S')."
log_message ""

# Iterate over each service and perform the steps
for SERVICE in $SERVICES; do
    # Find files related to the service
    FILES=$(find_files)
    
    if [[ -z "$FILES" ]]; then
        log_message "No files found for service $SERVICE."
        continue
    fi

    log_message "Found files for service $SERVICE: $FILES"

    # Only proceed if skip confirmation or user confirms
    if $SKIP_CONFIRM; then
        cleanup_service "$SERVICE"
    else
        read -p "Proceed with cleaning up the service $SERVICE? (y/n): " confirm
        if [[ "$confirm" == "y" ]]; then
            cleanup_service "$SERVICE"
        else
            log_message "Cleanup aborted for $SERVICE."
        fi
    fi
done

