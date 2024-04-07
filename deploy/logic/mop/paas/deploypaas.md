# 数智云平台-PaaS安装（基于数智中台-云图套件）

## 通用配置参数

```bash
HOSTS=${HOSTS:=${SSH_HOST}}
```

## 用户管理

- 生成部署文件并上传到git中

```bash
EXECUTED_PERMISSION="suroot"
setConfig gitops
setConfig ${COMPONENT}
setConfig harbor
executeExpect Bash "operateGitExp:paas ${GITOPS_URI}"
genGitHelmService paas ${COMPONENT} ${helmPackage}
executeExpect Bash "operateGitPushExp:paas ${GITOPS_URI} ’create helm deployment‘ "
```

## 部署组件

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "createDomain:${NAMESPACE} ${HARBOR_USER} ${HARBOR_PASSWORD} ${HARBOR_URI}"
setConfig argocd
executeExpect Bash loginArgocdExp
deployArgoCDApp paas ${COMPONENT} ${NAMESPACE} ${GITOPS_URI}
sleep 1
executeExpect SSH "applyRegcredSa:${NAMESPACE}"
executeExpect SSH "resetPods:${NAMESPACE}"
executeExpect SSH  "waitFunctionReady:600 'healthCheckPods ${NAMESPACE}' "
```

##安装后清理

```bash
unsetConfig argocd
unsetConfig  ${COMPONENT}
unsetConfig harbor
unsetConfig gitops
```

#### @由数智云图-自动化云平台构建工具支持