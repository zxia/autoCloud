# 数智云平台-主机安装分册（基于数智中台-云图套件）

## 加入结点

````bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH changeHostNameExp
setConfig k8s
setConfig harbor
genJoinK8sCommand
executeExpect SSH 'systemctl restart containerd'

````

##安装后清理

````bash
unsetConfig k8s
unsetConfig harbor
````

#### @由数智云图-自动化云平台构建工具支持