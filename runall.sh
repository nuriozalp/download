#!/bin/bash

nohup java -jar -Xmx256m -Dspring.config.location=file:/opt/pusnik/application_web_pusnik.properties dass-web-1.0.0-SNAPSHOT.jar   > web.out &

nohup java -jar -Xmx256m -Dspring.config.location=file:/opt/pusnik/application_reporting_pusnik.properties dass-reporting-1.0.0-SNAPSHOT.jar   > reporting.out &

nohup java -jar -Xmx256m -Dspring.config.location=file:/opt/pusnik/application_websocket_pusnik.properties dass-websocket-1.0.0-SNAPSHOT.jar   > websocket.out &

 
