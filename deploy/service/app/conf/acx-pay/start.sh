#!/bin/bash

APP_NAME="acx-pay"
WORK_DIR="/opt/acx/${APP_NAME}"
JAVA_HOME="/opt/java/openjdk"
JAVA_OPTS=" -Xms256M -Xmx1g -XX:MaxDirectMemorySize=512M -server  -XX:+HeapDumpOnOutOfMemoryError -Xlog:gc*=debug:file=${WORK_DIR}/logs/gc.log:time:filecount=50:filesize=10m "
cd ${WORK_DIR}/bin;
$JAVA_HOME/bin/java -jar  ${JAVA_OPTS}  -Dspring.config.location=${WORK_DIR}/conf/bootstrap.yaml   ${WORK_DIR}/bin/${APP_NAME}.jar
