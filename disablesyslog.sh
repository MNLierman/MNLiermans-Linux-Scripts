#! /bin/sh

# Disables rsyslog and displays it's status. Disabling rsyslog when
# not needed for troubleshooting greatly increases performance.

sudo systemctl disable rsyslog
sudo systemctl disable syslog.socket
sudo systemctl stop rsyslog
sudo systemctl status rsyslog
