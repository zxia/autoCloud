# 数智云平台-主机安装分册（基于数智中台-云图套件）

## 更新 Rpms

````bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH "createFold:/home/opuser/grafana/dashboard"
executeExpect Bash "rsyncFoldExp:/${workDir}/data/deploy/grafana_dashboard /home/opuser/grafana/dashboard"
EXECUTED_PERMISSION="suroot"
setConfig gitops
setConfig harbor
executeExpect SSH "createDomain:${NAMESPACE} ${HARBOR_USER} ${HARBOR_PASSWORD} ${HARBOR_URI}"
unsetConfig gitops
unsetConfig harbor
executeExpect SSH "loadDashboard"
````

#### @由数智云图-自动化云平台构建工具支持