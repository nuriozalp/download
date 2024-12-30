#!/bin/bash

authorizeAndRestart(){
 sudo chmod 777 /opt/meta/meta.jar;
 sudo chown -R "meta" /opt/meta/*;
 supervisorctl restart meta;
}

sudo echo -1 >/sys/module/usbcore/parameters/autosuspend;
sudo modprobe usbcore autosuspend=-1;
sudo adduser meta dialout;
sudo chmod 777 /dev/tty*;
sudo chown -R "meta" /dev/tty*;


