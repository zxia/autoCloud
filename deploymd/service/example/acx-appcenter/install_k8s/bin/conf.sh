###for jenkins build, copy conf template and modify for k8s
#!/bin/bash

workdir="$(cd $(dirname $0); pwd)/../acx-appcenter-chart/conf"
mkdir -p $workdir
cd $workdir
cp ../../../install/conf/templates/* ./

### modify for k8s
sed -i 's#${NACOS_SERVER}:${NACOS_PORT}#nacos-service.nacos:30001#' acx-appcenter.yaml
sed -i 's#value="acx-appcenter"#value="${hostName}"#' log4j2-spring.xml 
