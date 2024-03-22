# 数智云平台-Paas 容器镜像 创建分册（基于数智中台-云图套件）

## 通用配置参数

````bash

setConfig ssh
````

## 用户管理

- 创建管理用户

````bash
EXECUTED_PERMISSION="root"
executeExpect SSH "createUser:${SSH_USER}"
executeExpect SSH "changeUserPasswordExp:${SSH_USER} ${SSH_USER_PASSWORD}"
````

## 准备工作

````bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH "createFold:/home/opuser/image/data"
executeExpect Bash "rsyncFoldExp:/${workDir}/data/build/images /home/opuser/image/data"
````

## 根据镜像列表，拉取镜像并保存在私有镜像仓库中

````bash
EXECUTED_PERMISSION="suroot"
setConfig harbor
executeExpect SSH "saveImages:${HARBOR_URI} ${HARBOR_USER} ${HARBOR_PASSWORD}"
unsetConfig harbor
````
