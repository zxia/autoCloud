#!/bin/bash

APP_NAME="acx-mall"
WORK_DIR="/opt/acx/${APP_NAME}"
JAVA_HOME="/opt/java/openjdk"
JAVA_OPTS=" -Xms128M -Xmx256M -XX:MaxDirectMemorySize=128M -server  -XX:+HeapDumpOnOutOfMemoryError -Xlog:gc*=debug:file=${WORK_DIR}/logs/gc.log:time:filecount=50:filesize=10m "
# 设置HTTP代理配置为Java系统属性
export HTTPS_PROXY_HOST=""
export HTTPS_PROXY_PORT=""

cd ${WORK_DIR}/bin;
$JAVA_HOME/bin/java -jar  ${JAVA_OPTS}   -Dhttps.proxyHost="${HTTPS_PROXY_HOST}" -Dhttps.proxyPort="${HTTPS_PROXY_PORT}" -Dspring.config.location=${WORK_DIR}/conf/bootstrap.yaml   ${WORK_DIR}/bin/${APP_NAME}.jar
