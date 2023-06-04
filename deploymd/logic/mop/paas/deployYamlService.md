# 数智云平台-kubernetes 描述文件通用部署

## 生成并上传配置文件

```bash
EXECUTED_PERMISSION="opuser"
setConfig harbor
genYamlServiceFile ${SERVICE}
executeExpect SSH "createFold:/home/opuser/${SERVICE}"
executeExpect Bash "rsyncFoldExp:/${workDir}/output/${SERVICE} /home/opuser/${SERVICE}"
executeExpect Bash 'rsyncFoldExp:/allinone/installpackage /home/opuser/installpackage'
```

## 部署argo cd

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "createDomain:${NAMESPACE} ${HARBOR_USER} ${HARBOR_PASSWORD} ${HARBOR_URI}"
executeExpect SSH "deployYamlService:${SERVICE} ${NAMESPACE}"
sleep 0.5
executeExpect SSH "applyRegcredSa:${NAMESPACE}"
executeExpect SSH "resetPods:${NAMESPACE}"
executeExpect SSH  "waitFunctionReady:300  'healthCheckPods ${NAMESPACE}' "
unsetConfig harbor
```

#### @由数智云图-自动化云平台构建工具支持