# 数智容器化-创建云图镜像

## 配置数据

### 本地准备镜像构建文件

````bash
setConfig harbor 
setConfig buildDocker
genDockerFile ${COMPONENT}
prepareDockerfile  ${COMPONENT}
````

### 在build server 上进行构建

#### [创建用户](../mop/deploy/createUser.md)

#### 上传原文件

````bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH createFold:/home/opuser/docker
executeExpect Bash "rsyncFoldExp:/${workDir}/output/docker /home/opuser/docker"
````

#### 执行构建

````bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "buildImage:${HARBOR_URI} ${HARBOR_USER} ${HARBOR_PASSWORD} ${COMPONENT} ${VERSION}"
````

#### @由数智云图-自动化云平台构建工具支持