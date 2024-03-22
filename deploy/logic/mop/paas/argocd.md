# 数智云平台-部署argo workflow

## 通用配置参数

```bash
setConfig k8s
SERVICE=argocd
NAMESPACE=argocd
SSH_HOST=${controlPlaneEndpointIP}
HOSTS=${HOSTS:=${SSH_HOST}}
```

## 利用通用部署模板进行部署

[通用部署模板](deployYamlService.md)

## update argocd NodePort and change the password

```bash
EXECUTED_PERMISSION="suroot"
setConfig argocd
sleep 30
executeExpect SSH "setArgocdNodePort"
updateArgoConfig
ARGOCD_PASSWORD=${init_ARGOCD_PASSWORD}
executeExpect Bash loginArgocdExp
setConfig argocd
executeExpect Bash updateArgoPasswordExp
```

##释放变量

```bash
unsetConfig k8s
unsetConfig argocd
```

#### @由数智云图-自动化云平台构建工具支持