#!/bin/bash

APP_NAME="acx-appcenter"
WORK_DIR="/opt/acx/${APP_NAME}"
JAVA_OPTS=" -Xms1g -Xmx2g -XX:MaxDirectMemorySize=512M -server  -XX:+HeapDumpOnOutOfMemoryError -Xlog:gc*=debug:file=${WORK_DIR}/logs/gc.log:time:filecount=50:filesize=10m "

mkdir -p ${WORK_DIR}/logs;
cd ${WORK_DIR}/bin;
exec java -jar ${JAVA_OPTS} -Dspring.config.location=${WORK_DIR}/conf/bootstrap.yaml ${WORK_DIR}/bin/${APP_NAME}.jar
