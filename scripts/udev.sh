#!/bin/bash

 sudo chmod 777 /opt/meta/meta.jar;
 sudo chmod 777 /dev/tty*;
 sudo chown -R "meta" /opt/meta/*;
 sudo chown -R "meta" /dev/tty*;
 

# Determine which device is connected (ttyUSB0 or ttyUSB1)
if udevadm info -a -n /dev/ttyUSB0 | grep -q '{serial}'; then
    DEVICE="/dev/ttyUSB0"
elif udevadm info -a -n /dev/ttyUSB1 | grep -q '{serial}'; then
    DEVICE="/dev/ttyUSB1"
else
    echo "Neither /dev/ttyUSB0 nor /dev/ttyUSB1 has a serial. Exiting."
    exit 1
fi

# Extract the Serial Number:
echo "Fetching the serial number of the device connected to $DEVICE..."
SERIAL=$(udevadm info -a -n $DEVICE | grep '{serial}' | head -n1 | awk -F'==' '{print $2}' | tr -d '"')

# Check if serial was successfully extracted
if [ -z "$SERIAL" ]; then
    echo "Failed to extract the serial number from $DEVICE. Exiting."
    exit 1
fi

# Define the udev rule:
RULE="SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"0403\", ATTRS{idProduct}==\"6001\", ATTRS{serial}==\"$SERIAL\", TEST==\"power/control\", SYMLINK+=\"msfio\""

# Clear the file content and write the new rule
echo "$RULE" > /etc/udev/rules.d/msf_iiot_card_setting.rules

# Reload udev Rules:
echo "Reloading udev rules..."
udevadm control --reload-rules && udevadm trigger

echo "Done!"
