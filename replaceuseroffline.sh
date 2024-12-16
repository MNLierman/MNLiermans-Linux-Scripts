#!/bin/bash

# Replace Username Offline
# Created by Mike Lierman (@MNLierman) and @InviseLabs.
# License: OK to modify & share, please consider contributing improvements, commercial use of @MNLierman's scripts by written agreement only.

# This script replaces all instances of $OLD_USERNAME with $NEW_USERNAME
# within the system user configuration files located at your specified dir.
# It logs the process and the number of replacements made. It also optionally
# makes a backup of each file before modification, based on the CP_BACKUP flag.
#
# Variables:
# - OLD_USERNAME: Username to replace.
# - NEW_USERNAME: New username to replace with.
# - CONFIG_DIR: Directory containing config files.
# - HOMEDIR: Location of the home dir which contains the user folder to rename.
# - RENAME_HOMEDIR: Whether to rename the user's home directory (true/false).
# - LOGFILE: Log file location (default: replaceuser.log in current dir).
# - LOGGING_ENABLED: (true/false).
# - CP_BACKUP: Make a backup of each file before modification (true/false).
# - FILES: Files to search through and modify. (Files *will* be modified, be sure this is what you intend!)

# Variables
OLD_USERNAME="OldNameSarah" # <- Change
NEW_USERNAME="NewNameAva"   # <- Change
CONFIG_DIR="/mnt/sda1/etc"  # <- Change
HOMEDIR="/mnt/sda1/home"    # <- Change
RENAME_HOMEDIR=true
LOGFILE="replaceuser.log"
LOGGING_ENABLED=true
CP_BACKUP=true

# Files to process
FILES=("group" "group-" "shadow" "shadow-" "passwd" "passwd-" "gshadow" "gshadow-")

# Logging function
log_message() {
    if $LOGGING_ENABLED; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    fi
}

# Start logging
log_message ""
log_message "Script started. Replacing '$OLD_USERNAME' with '$NEW_USERNAME' at '$CONFIG_DIR'."
log_message "Files to process: '${FILES[*]}'."
log_message ""

 if $RENAME_HOMEDIR; then
    old_home="${HOMEDIR}/${OLD_USERNAME}"
    new_home="${HOMEDIR}/${NEW_USERNAME}"
    log_message "Renaming home directory from $old_home to $new_home."
    mv "$old_home" "$new_home"
else
    log_message "Renaming home directory is disabled."
fi

# Process each file
for file in "${FILES[@]}"; do
    full_path="$CONFIG_DIR/$file"
    backup_path="$CONFIG_DIR/${file}.bak"
    
    if [[ -f $full_path ]]; then
        log_message "Processing $full_path"

        # Create a backup if CP_BACKUP is true
        if $CP_BACKUP; then
            sudo cp $full_path $backup_path
            log_message "Backup created at $backup_path"
        fi

        # Count instances of OLD_USERNAME
        count=$(sudo grep -o "$OLD_USERNAME" $full_path | wc -l)

        if [[ $count -gt 0 ]]; then
            # Replace OLD_USERNAME with NEW_USERNAME
            sudo sed -i -e "s/$OLD_USERNAME/$NEW_USERNAME/g" $full_path
            log_message "Replaced $count instances in $full_path"
        else
            log_message "No instances found in $full_path"
        fi
    else
        log_message "File not found: $full_path"
    fi
done

# End logging
log_message "Finished processing all files."

