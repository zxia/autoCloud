#!/bin/bash

APP_NAME="acx-fund"
WORK_DIR="/opt/acx/${APP_NAME}"
JAVA_HOME="/opt/java/openjdk"
JAVA_OPTS=" -Xms128M -Xmx256M -XX:MaxDirectMemorySize=512M -server  -XX:+HeapDumpOnOutOfMemoryError -Xlog:gc*=debug:file=${WORK_DIR}/logs/gc.log:time:filecount=50:filesize=10m "
cd ${WORK_DIR}/bin;
$JAVA_HOME/bin/java -jar  ${JAVA_OPTS}  -Dspring.config.location=${WORK_DIR}/conf/bootstrap.yaml   ${WORK_DIR}/bin/${APP_NAME}.jar
