# 数智云平台-通过Helm部署微服务

## 接口定义

- ### 参数
    - HELM_PACKAGE
    - SERVICE_NAME
    - DOMAIN_NAME
    - LABEL

## 安装CNI

- ### 上传helm包，生成和配置定制化数据

````bash
setConfig k8s 

EXECUTED_PERMISSION="opuser"
executeExpect SSH createFold:/home/opuser/service 
executeExpect Bash "rsyncFoldExp:${workDir}/service/output  /home/opuser/service"

EXECUTED_PERMISSION="suroot"
setConfig harbor
executeExpect SSH "createDomain:${DOMAIN_NAME} ${HARBOR_USER} ${HARBOR_PASSWORD} ${HARBOR_URI}"
executeExpect SSH "deployHelmPackage ${SERVICE_NAME} ${HELM_PACKAGE}  ${DOMAIN_NAME}"
unsetConfig harbor
````

#### @由数智云图-自动化云平台构建工具支持
