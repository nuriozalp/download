#!/bin/sh

 rsync -a dass-websocket/target/dass-websocket-1.0.0-SNAPSHOT.jar /opt/dass-build/ &

 rsync -a dass-web/target/dass-web-1.0.0-SNAPSHOT.jar /opt/dass-build/ &

 rsync -a dass-reporting/target/dass-reporting-1.0.0-SNAPSHOT.jar /opt/dass-build/ &