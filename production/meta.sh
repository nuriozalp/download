#!/bin/bash

downloadMeta(){
 echo "Download jar started";
rm -rf /opt/meta/meta.jar.temp
rm -rf /opt/meta/meta.sh.temp
sudo wget -O meta.jar.temp  https://github.com/nuriozalp/download/raw/master/test/meta.jar;
sudo wget -O meta.sh.temp  https://github.com/nuriozalp/download/raw/master/test/meta.sh;
sudo wget -O udev.sh  https://github.com/nuriozalp/download/raw/master/test/udev.sh;
sudo wget -O rfid.sh  https://github.com/nuriozalp/download/raw/master/test/rfid.sh;
sudo wget -O barcode.sh  https://github.com/nuriozalp/download/raw/master/test/barcode.sh;
sudo apt-get install dos2unix;
sudo dos2unix ./udev.sh;
sudo dos2unix ./rfid.sh;
sudo dos2unix ./meta.sh;
sudo dos2unix ./barcode.sh;
chown -R "meta" udev.sh;
chown -R "meta" rfid.sh;
chown -R "meta" barcode.sh;
sudo chmod 777 udev.sh rfid.sh barcode.sh
sudo ./udev.sh;
sudo ./rfid.sh;
}

authorizeAndRestart(){
 mv /opt/meta/meta.jar.temp /opt/meta/meta.jar
 mv /opt/meta/meta.sh.temp /opt/meta/meta.sh
 sudo chmod 777 /opt/meta/meta.jar;
 sudo chmod 777 meta.sh
 sudo chown -R "meta" /opt/meta/*;
 sudo chown -R "meta" meta.sh;
 supervisorctl restart meta;
}

sudo echo -1 >/sys/module/usbcore/parameters/autosuspend;
sudo modprobe usbcore autosuspend=-1;
sudo adduser meta dialout;
sudo chmod 777 /dev/tty*;
sudo chown -R "meta" /dev/tty*;
downloadMeta;

if [ -f "/opt/meta/meta.jar.temp" ] ; then
 echo "Download succes"
 authorizeAndRestart
else
 echo "Download failed"
fi

