# 数智云平台-（基于数智中台-云图套件）

## 安装配置

- 配置安装repository

```bash
EXECUTED_PERMISSION="suroot"
setConfig gitops
setConfig argocd
executeExpect Bash loginArgocdExp
addArgoCDAppGit ${GITOPS_URI} ${GITOPS_USER} ${GITOPS_PASSWORD}
unsetConfig gitops
unsetConfig argocd
```

#### @由数智云图-自动化云平台构建工具支持