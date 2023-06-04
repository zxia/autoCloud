# 数智云平台-PaaS安装（基于数智中台-云图套件）

## 通用配置参数
   - NAMEPSACE
   - COMPONENT
   - HELM_NAME
```bash

HOSTS=${HOSTS:=${SSH_HOST}}
```

## 用户管理

- 生成部署文件并上传到git中

````bash
EXECUTED_PERMISSION="suroot"
setConfig gitops
setConfig harbor
executeExpect Bash "operateGitExp:paas ${GITOPS_URI}"
genGitHelmService2 paas 
executeExpect Bash "operateGitPushExp:paas ${GITOPS_URI} ’create helm deployment‘ "

````

## 部署组件

````bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "createDomain:${NAMESPACE} ${HARBOR_USER} ${HARBOR_PASSWORD} ${HARBOR_URI}"
setConfig argocd
setConfig harbor
executeExpect Bash loginArgocdExp
deployArgoCDApp paas ${COMPONENT} ${NAMESPACE} ${GITOPS_URI} ${HELM_NAME}
sleep 1
executeExpect SSH "applyRegcredSa:${NAMESPACE}"
executeExpect SSH "resetPods:${NAMESPACE}"
executeExpect SSH  "waitFunctionReady:300 'healthCheckPods ${NAMESPACE}' "
unsetConfig harbor
````

##安装后清理

````bash
unsetConfig argocd
unsetConfig  ${COMPONENT}
unsetConfig harbor
unsetConfig gitops

````

#### @由数智云图-自动化云平台构建工具支持