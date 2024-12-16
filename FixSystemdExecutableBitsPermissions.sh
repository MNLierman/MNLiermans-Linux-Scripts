#!/bin/bash

# Fix Systemd Permissions
# Created by Mike Lierman (@MNLierman) and @InviseLabs.
# License: OK to modify & share, please consider contributing improvements, commercial use of @MNLierman's scripts by written agreement only.
#
# This script strips the executable bits from all files in /etc/systemd. I've seen other scripts
# out there that set all files to 644 and I found this concerning and possibly damaging.

SYSTEMD_DIR="/etc/systemd" # Dir containing the files to strip -x from.
LOGFILE="/var/log/fix_systemd_files.log" # Log file location.
LOGGING_ENABLED=true # Enable logging (true/false).

# Logging function
log() {
    if [ "$LOGGING_ENABLED" = true ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
    fi
}

# Find files with executable bits
find "$SYSTEMD_DIR" -type f -perm /111 -print0 | while read -d $'\0' file; do
    echo "Removing executable bits from: $file"
    chmod -x "$file"
    log "Removed executable bits from: $file"
done

log "Script completed. All unnecessary executable bits have been removed."

echo "Done. All unnecessary executable bits have been removed."
