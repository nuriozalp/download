#!/bin/bash

LATEST_TAG=$(curl -s https://api.github.com/repos/nuriozalp/download/releases/latest | grep -oP '"tag_name": "\K[^"]+')

setGoogleDNS() {
  echo "Testing DNS resolution..."
  if ping -c 1 github.com &> /dev/null; then
    echo "DNS is already working. Skipping DNS setup."
    return
  fi

  echo "DNS resolution failed. Checking existing DNS configuration..."

  # /etc/resolv.conf dosyasından mevcut nameserver'ları oku
  if grep -q "^nameserver" /etc/resolv.conf; then
    echo "Existing DNS configuration found:"
    grep "^nameserver" /etc/resolv.conf
    echo "Will not override existing DNS servers."
    return
  fi

  echo "No existing DNS servers found. Applying Google DNS (8.8.8.8, 8.8.4.4)..."

  if [ -L /etc/resolv.conf ]; then
    # systemd-resolved kullanılıyor
    IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    if [ -n "$IFACE" ]; then
      echo "Setting DNS for interface: $IFACE"
      sudo resolvectl dns "$IFACE" 8.8.8.8 8.8.4.4
      sudo resolvectl domain "$IFACE" '~.'
    else
      echo "Could not determine network interface. DNS not set."
    fi
  else
    # Klasik yöntem
    echo "Overriding /etc/resolv.conf with Google DNS"
    sudo bash -c 'cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF'
  fi
}


# Ensure dos2unix is installed
ensureDos2Unix() {
  if ! command -v dos2unix &> /dev/null; then
    echo "dos2unix not found. Trying to install..."
    sudo apt-get update || echo "Failed to update package lists, continuing..."
    sudo apt-get install -y dos2unix || echo "Failed to install dos2unix, continuing without it..."
  else
    echo "dos2unix is already installed."
  fi
}

cleanTempFiles(){
  echo "Cleaning temporary files..."
  rm -f meta.jar.temp meta.sh.temp udev.sh.temp rfid.sh.temp barcode.sh.temp grant_meta_tty_permissions.sh.temp logback.xml.temp meta.conf.temp
  echo "Temporary files cleaned."
}

downloadMeta(){
 echo "Download jar started";

 # Clean temporary files
 cleanTempFiles
 
 # Download files and exit on any error
 sudo wget -O meta.sh.temp https://github.com/nuriozalp/download/raw/master/test/meta.sh || { echo "meta.sh could not be downloaded."; cleanTempFiles; return 1; }
 sudo wget -O udev.sh.temp https://github.com/nuriozalp/download/raw/master/test/udev.sh || { echo "udev.sh could not be downloaded."; cleanTempFiles; return 1; }
 sudo wget -O rfid.sh.temp https://github.com/nuriozalp/download/raw/master/test/rfid.sh || { echo "rfid.sh could not be downloaded."; cleanTempFiles; return 1; }
 sudo wget -O barcode.sh.temp https://github.com/nuriozalp/download/raw/master/test/barcode.sh || { echo "barcode.sh could not be downloaded."; cleanTempFiles; return 1; }
 sudo wget -O grant_meta_tty_permissions.sh.temp https://github.com/nuriozalp/download/raw/master/test/grant_meta_tty_permissions.sh || { echo "grant_meta_tty_permissions.sh could not be downloaded."; cleanTempFiles; return 1; }
 sudo wget -O logback.xml.temp https://github.com/nuriozalp/download/raw/master/test/logback.xml || { echo "logback.xml could not be downloaded."; cleanTempFiles; return 1; }
  sudo wget -O meta.conf.temp https://github.com/nuriozalp/download/raw/master/test/meta.conf || { echo "meta.conf could not be downloaded."; cleanTempFiles; return 1; }
 #sudo wget -O meta.jar.temp https://github.com/nuriozalp/download/raw/master/test/meta.jar || { echo "meta.jar could not be downloaded."; cleanTempFiles; return 1; }
 sudo wget -O meta.jar.temp https://github.com/nuriozalp/download/releases/download/$LATEST_TAG/meta.jar || { echo "meta.jar could not be downloaded."; cleanTempFiles; return 1; }

 return 0
}

renameIfMissing(){
  local temp_file="$1"
  local target_file="$2"

  if [ -f "$target_file" ]; then
    # If the target file exists, replace it with the temp file
    echo "Target file exists: $target_file. Replacing with $temp_file."
    sudo mv -f "$temp_file" "$target_file"
  else
    # If the target file does not exist, rename the temp file
    echo "Target file not found. Renaming $temp_file to $target_file."
    sudo mv "$temp_file" "$target_file"
  fi
}

applyDos2Unix(){
  echo "Converting files to Unix format..."
  sudo dos2unix /opt/meta/meta.sh
  sudo dos2unix /opt/meta/udev.sh
  sudo dos2unix /opt/meta/rfid.sh
  sudo dos2unix /opt/meta/grant_meta_tty_permissions.sh
  echo "Conversion completed."
}

executeScripts(){
  # Run scripts
  echo "Running udev.sh..."
  sudo /opt/meta/udev.sh

  echo "Running rfid.sh..."
  sudo /opt/meta/rfid.sh

  echo "Running grant_meta_tty_permissions.sh..."
  sudo /opt/meta/grant_meta_tty_permissions.sh
}

authorizeAndRestart(){
 # Check and move target files
 renameIfMissing "meta.jar.temp" "/opt/meta/meta.jar"
 renameIfMissing "meta.sh.temp" "/opt/meta/meta.sh"
 renameIfMissing "meta.conf.temp" "/opt/meta/meta.conf"
 renameIfMissing "logback.xml.temp" "/opt/meta/conf/logback.xml"
 renameIfMissing "udev.sh.temp" "/opt/meta/udev.sh"
 renameIfMissing "rfid.sh.temp" "/opt/meta/rfid.sh"
 renameIfMissing "grant_meta_tty_permissions.sh.temp" "/opt/meta/grant_meta_tty_permissions.sh"

 # Convert to Unix format
 applyDos2Unix

 # Set permissions and ownership
 sudo chmod 777 /opt/meta/meta.jar
 sudo chmod 777 /opt/meta/meta.sh /opt/meta/udev.sh /opt/meta/rfid.sh /opt/meta/grant_meta_tty_permissions.sh
 sudo chown -R "meta" /opt/meta/*

 # Execute downloaded scripts
 executeScripts

 # Restart the service
 supervisorctl restart meta
}

# USB autosuspend settings
sudo echo -1 >/sys/module/usbcore/parameters/autosuspend
sudo modprobe usbcore autosuspend=-1

# User and device permissions
sudo adduser meta dialout
sudo chmod 777 /dev/tty*
sudo chown -R "meta" /dev/tty*

# Ensure dos2unix is installed
ensureDos2Unix
setGoogleDNS
# Download files and check
if downloadMeta; then
 echo "Download successful"
 authorizeAndRestart
else
 echo "Download failed. Existing files were not affected."
fi