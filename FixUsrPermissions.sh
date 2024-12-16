#!/bin/bash

# Fix /Usr Permissions
# Created by Mike Lierman (@MNLierman) and @InviseLabs.
# License: OK to modify & share, please consider contributing improvements, commercial use of @MNLierman's scripts by written agreement only.
#
# This script fixes permissions in the /usr dir when it's been screwed up or damaged,
# which should get the system back to functional status. Other changes may be necessary.

# Function to fix permissions
fix_permissions() {
    local dir=$1
    echo "Fixing permissions in $dir..."
    find "$dir" -type d -exec chmod 755 {} \; -print
    find "$dir" -type f -executable -exec chmod 755 {} \; -print
    find "$dir" -type f ! -executable -exec chmod 644 {} \; -print
}

# Fix permissions for /usr/bin
fix_permissions /usr/bin

# Fix permissions for /usr/sbin
fix_permissions /usr/sbin

# Fix permissions for /usr/lib
fix_permissions /usr/lib

# Fix permissions for /usr/share
fix_permissions /usr/share

# Fix permissions for /usr/include
fix_permissions /usr/include

# Fix permissions for /usr/local
fix_permissions /usr/local

# Fix permissions for critical binaries
echo "Fixing permissions for critical binaries..."
chmod 4755 /bin/ping6
chmod 4755 /bin/su
chmod 4755 /bin/mount
chmod 4755 /bin/ping
chmod 4755 /bin/umount

# Set permissions for sudo and su
chmod 0440 /usr/bin/sudo
chmod 0440 /usr/bin/su

# Set SUID bit for other critical binaries
chmod u+s /usr/bin/sudo
chmod u+s /usr/bin/passwd
chmod u+s /usr/bin/chsh
chmod u+s /usr/bin/chfn
chmod u+s /usr/bin/su
chmod u+s /usr/bin/gpasswd
chmod u+s /usr/bin/newgrp
chmod u+s /usr/bin/pkexec

# Fix permissions for shells
echo "Fixing permissions for shells..."
chmod 755 /bin/bash
chown root:root /bin/bash
chmod 755 /bin/sh
chown root:root /bin/sh
chmod 755 /bin/dash
chown root:root /bin/dash
chmod 755 /bin/zsh
chown root:root /bin/zsh
chmod 755 /bin/ksh
chown root:root /bin/ksh

# Fix permissions for polkit
echo "Fixing permissions for polkit..."
find /usr/share/polkit-1 -type d -exec chmod 755 {} \; -print
find /usr/share/polkit-1 -type f -exec chmod 644 {} \; -print

echo "Permissions fixed."

