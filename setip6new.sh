#!/bin/bash

# This script sets IPv6 addresses and routes on specified network interfaces.
# Using vars defined below, you can specify to deprecate all current addresses, and optionally define additional ones.
# It logs the process and ensures that specified addresses are added and old ones are removed.

# Variables:
# - ADDRESSES: Space-separated list of IPv6 addresses to be added.
# - GATEWAY: Default gateway for the default route.
# - SPECIFIC_ROUTES: Space-separated list of specific routes to be added.
# - INTERFACES: Space-separated list of network interfaces to configure.
# - DEPRECATED_ADDRESSES: Space-separated list of IPv6 addresses to be deprecated (optional).
# - LOGFILE: Location of the log file (default: /var/log/setip6.log).
# - LOGGING_ENABLED: Flag to enable or disable logging (true/false).
# - RUN_DEPRECATE: Whether to deprecate current and optionally defined addresses (true/false).
# - RUN_DELETE: Whether to delete all addresses on each device (true/false).
#      (This *will* delete all addresses, ensure this is what you intend!)
# - RUN_CONFIGURE_ROUTES: Whether to add configured routes (true/false).

# Variables
ADDRESSES="SPACE SEPARATED LIST OF ADDRS"  # <- Change
GATEWAY="YOUR_GATEWAY"                     # <- Change
SPECIFIC_ROUTES=""                         # <- Change
INTERFACES="end0"                          # <- Change
DEPRECATED_ADDRESSES="" # Optional additional addresses to deprecate
LOGFILE="/var/log/setip6.log"
LOGGING_ENABLED=true
RUN_DEPRECATE=true
RUN_DELETE=true
RUN_CONFIGURE_ROUTES=true

# Logging function
log_message() {
    if $LOGGING_ENABLED; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    fi
}

# Start logging
log_message "Script started. Configuring IPv6 settings."

# Collect current addresses for deprecation
CURRENT_ADDRESSES=""
for iface in $INTERFACES; do
    CURRENT_ADDRESSES=$(ip -6 addr show dev $iface | grep 'scope global' | awk '{print $2}')
    log_message "Current addresses on $iface: $CURRENT_ADDRESSES"
done

# Check if any of the IPv6 addresses are already added
for addr in $ADDRESSES; do
    if ip -6 addr show | grep -q "${addr%%/*}"; then
        log_message "$addr appears to have already been added, exiting."
        exit 0
    fi
done

# Remove IPv6 addresses from specified interfaces if configured to do so
if $RUN_DELETE; then
    for iface in $INTERFACES; do
        ip_count=0
        for addr in $(ip -6 addr show dev $iface | grep 'scope global' | awk '{print $2}'); do
            ip -6 addr del $addr dev $iface
            ip_count=$((ip_count + 1))
        done
        log_message "Removed $ip_count addresses from $iface."
    done
fi

# Add static IPv6 addresses
log_message "Adding static IPv6 addresses."
for iface in $INTERFACES; do
    for addr in $ADDRESSES; do
        ip -6 addr add $addr dev $iface
        log_message "Added $addr to $iface."
    done
done



# Deprecate specific IPv6 addresses if configured to do so
if $RUN_DEPRECATE; then
    log_message "Deprecating specific IPv6 addresses."
    for iface in $INTERFACES; do
        for addr in $CURRENT_ADDRESSES $DEPRECATED_ADDRESSES; do
            ip -6 addr change $addr dev $iface preferred_lft 0
            log_message "Deprecated $addr on $iface."
        done
    done
fi

# Configure routes if configured to do so
if $RUN_CONFIGURE_ROUTES; then
    log_message "Configuring routes."
    for iface in $INTERFACES; do
        # Add default route
        ip -6 route del default
        ip -6 route add default via $GATEWAY dev $iface
        log_message "Default route set via $GATEWAY on $iface."
        
        # Add specific routes
        for route in $SPECIFIC_ROUTES; do
            ip -6 route add $route dev $iface
            log_message "Route added for $route on $iface."
        done
    done
fi

# Verify if any of the IPv6 addresses were added
for addr in $ADDRESSES; do
    if ip -6 addr show | grep -q "${addr%%/*}"; then
        log_message "$addr appears to have been added successfully."
   else
        log_message "Failed to add $addr."
    fi
done

log_message "Script finished executing."

