# 数智云平台-通过Helm部署微服务

## 接口定义

- ### 参数
    - SERVICE_NAME
    - DOMAIN_NAME
    - LABEL
    - CONFIG_LIST
    - SERVICE_PATH

## 安装CNI

- ### 上传helm包，生成和配置定制化数据

````bash
setConfig k8s 

EXECUTED_PERMISSION="opuser"
executeExpect SSH createFold:/home/opuser/${SERVICE_NAME} 
genK8sYaml ${SERVICE_NAME} ${CONFIG_LIST} ${workDir}/${TEMPLATE_PATH}
executeExpect Bash "rsyncFoldExp:${workDir}/output/${SERVICE_NAME}  /home/opuser/${SERVICE_NAME}"

EXECUTED_PERMISSION="suroot"
setConfig harbor
executeExpect SSH "createDomain:${DOMAIN_NAME} ${HARBOR_USER} ${HARBOR_PASSWORD} ${HARBOR_URI}"
executeExpect SSH "deployK8sService ${SERVICE_NAME}  ${SERVICE_PATH} ${DOMAIN_NAME} "
executeExpect SSH  "waitFunctionReady:300 'healthCheckPods kube-system' "
unsetConfig harbor
````

#### @由数智云图-自动化云平台构建工具支持
