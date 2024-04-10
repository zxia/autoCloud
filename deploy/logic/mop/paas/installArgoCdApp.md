# 数智云平台-安装argoCD 的应用


## 用户管理

- 生成部署文件并上传到git中

```bash
EXECUTED_PERMISSION="suroot"
setConfig gitops
setConfig ${COMPONENT}
setConfig harbor
```

## 部署组件

```bash
setConfig argocd
executeExpect Bash loginArgocdExp
deployArgoCDApp paas ${COMPONENT} ${NAMESPACE} ${GITOPS_URI}
executeExpect SSH "applyRegcredSa:${NAMESPACE}"
executeExpect SSH  "waitFunctionReady:1200 'healthCheckPods ${NAMESPACE}' "
```


#### @由数智云图-自动化云平台构建工具支持