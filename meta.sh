#!/bin/bash

downloadMeta(){
 echo "Download jar started";
rm -rf /opt/meta/meta.jar.temp
 sudo wget -O meta.jar.temp  https://github.com/nuriozalp/download/raw/master/test/meta.jar;
}

authorizeAndRestart(){
 mv /opt/meta/meta.jar.temp /opt/meta/meta.jar
 sudo chmod 777 /opt/meta/meta.jar;
 sudo chown -R "meta" /opt/meta/*;
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
 echo "Second Time attempt to download"
 downloadMeta
    if [ -f "/opt/meta/meta.jar.temp" ] ; then
     echo "Download succes"
     authorizeAndRestart
    else
     echo "Second time Download failed"
    fi
fi

