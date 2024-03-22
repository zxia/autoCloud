# 通过Helm部署微服务

## 接口定义

- ### 参数
    - HELM_PACKAGE
    - SERVICE_NAME
    - DOMAIN_NAME
    - LABEL
  

- ### 上传helm包，生成和配置定制化数据

```bash
setConfig k8s 

EXECUTED_PERMISSION="opuser"
executeExpect Bash "genAcxConfigValue ${HELM_PACKAGE} ${LAB_NAME} ${SERVICE_NAME} "
executeExpect SSH createFold:/home/opuser/service 
executeExpect Bash "rsyncFoldExp:${workDir}/service/output  /home/opuser/service"
```
- ### 部署Helm包
```bash
EXECUTED_PERMISSION="suroot"
setConfig harbor
executeExpect SSH "createDomain:${DOMAIN_NAME} ${HARBOR_USER} ${HARBOR_PASSWORD} ${HARBOR_URI}"
executeExpect SSH "deployHelmPackage ${SERVICE_NAME} ${HELM_PACKAGE}  ${DOMAIN_NAME} ${LAB_NAME}" 
executeExpect SSH  "waitFunctionReady:300 'healthCheckPods ${DOMAIN_NAME}' "
unsetConfig harbor
```

#### @自动化构建工具支持
