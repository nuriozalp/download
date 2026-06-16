#!/bin/bash

# Create a udev rule to give the 'meta' user full permissions on /dev/tty*
echo 'KERNEL=="tty[0-9]*", MODE="0666", OWNER="meta"' | sudo tee /etc/udev/rules.d/99-meta-tty.rules

# Reload udev rules and trigger them
sudo udevadm control --reload-rules
sudo udevadm trigger

# Confirm the changes
echo "Permissions for /dev/tty* have been granted to the 'meta' user."
