#! /bin/sh

# Enables rsyslog and displays it's status. Disabling rsyslog when
# not needed for troubleshooting greatly increases performance.

sudo systemctl enable rsyslog
sudo systemctl enable syslog.socket
sudo systemctl start rsyslog
sudo systemctl status rsyslog
