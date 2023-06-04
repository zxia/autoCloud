# 数智云平台-Paas Helm Package 创建分册（基于数智中台-云图套件）

## 用户管理

- 创建管理用户

````
EXECUTED_PERMISSION="root"
executeExpect SSH "createUser:${SSH_USER}"
executeExpect SSH "changeUserPasswordExp:${SSH_USER} ${SSH_USER_PASSWORD}"
````

## 准备工作

````
EXECUTED_PERMISSION="opuser"
executeExpect SSH "createFold:/home/opuser/helm/data"
executeExpect Bash "rsyncFoldExp:/${workDir}/data/build/helm /home/opuser/helm/data"
````

## 下载最新helm package

````
EXECUTED_PERMISSION="suroot"
executeExpect SSH addHelmRepo
executeExpect SSH getHelmPackage
executeExpect Bash 'rsyncDownFoldExp:/allinone/helm /tmp/helm '

````
