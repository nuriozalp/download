#!/bin/bash
supervisorctl stop meta ;
sudo echo -1 >/sys/module/usbcore/parameters/autosuspend;
sudo modprobe usbcore autosuspend=-1;
sudo adduser meta dialout;
sudo chmod 777 /dev/tty*;
sudo chown -R "meta" /dev/tty*;
sudo rm -rf /opt/meta/meta.jar ;
sudo wget https://github.com/nuriozalp/download/raw/master/new_io_protocol/meta.jar;
sudo chmod 777 /opt/meta/meta.jar ;
sudo chown -R "meta" /opt/meta/* ;
supervisorctl start meta ;
