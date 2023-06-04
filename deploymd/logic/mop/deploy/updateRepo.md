# 数智云平台-主机安装分册（基于数智中台-云图套件）

## 更新 Rpms

````
setConfig repo
EXECUTED_PERMISSION="opuser"
executeExpect Bash "rsyncFoldExp:/allinone/repo /home/opuser/repo"
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "updateCentosRepo ${REPO_PATH}"
unsetConfig repo
````

#### @由数智云图-自动化云平台构建工具支持