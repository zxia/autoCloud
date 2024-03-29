# 数智云平台-Paas Helm Package 创建分册（基于数智中台-云图套件）


## 准备工作

```bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH "createFold:/home/opuser/helm/data"
executeExpect Bash "rsyncFoldExp:/${workDir}/data/build/helm /home/opuser/helm/data"
````

## 下载最新helm package

```bash
setConfig buildDocker
EXECUTED_PERMISSION="suroot"
executeExpect SSH "addHelmRepo:\"${BUILDDOCKER_RPOXY}\"" 
executeExpect SSH "getHelmPackage:\"${BUILDDOCKER_RPOXY}\""
executeExpect Bash 'rsyncDownFoldExp:/allinone/helm /tmp/helm '

```
