#!/bin/sh


# This is a simple script that can be thrown into user startups, and when run, it checks if the local device
# you specify has the correct MAC address, if not it takes down the device, sets the MAC, and brings it back up.

DEV=eth0
MAC=YOUR_ADDRESS

sudo ifconfig $DEV down
sudo ifconfig $DEV hw ether $MAC
sudo ifconfig $DEV up

