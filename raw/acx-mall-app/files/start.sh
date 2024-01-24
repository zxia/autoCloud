#!/bin/bash

APP_NAME="acx-mall"
WORK_DIR="/opt/acx/${APP_NAME}"
JAVA_HOME="/opt/java/openjdk"
JAVA_OPTS=" -Xms1g -Xmx2g -XX:MaxDirectMemorySize=512M -server  -XX:+HeapDumpOnOutOfMemoryError -Xlog:gc*=debug:file=${WORK_DIR}/logs/gc.log:time:filecount=50:filesize=10m "

cd ${WORK_DIR}/bin;
$JAVA_HOME/bin/java -jar  ${JAVA_OPTS}   -Dhttps.proxyHost="10.0.35.251" -Dhttps.proxyPort="3128" -Dspring.config.location=${WORK_DIR}/conf/bootstrap.yaml   ${WORK_DIR}/bin/${APP_NAME}.jar
