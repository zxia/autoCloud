# 数智云平台-rpm repo 安装分册（基于数智中台-云图套件）

##

- 准备安装RPM Repo

````bash
setConfig repo
EXECUTED_PERMISSION="opuser"
genMiddlePlatformRepo
genMiddlePlatformLocalRepo
executeExpect SSH "createFold:/home/opuser/deploy/${REPO_VERSION}"
executeExpect Bash "rsyncFoldExp:/${workDir}/output/deploy/${REPO_VERSION} /home/opuser/deploy/${REPO_VERSION}"
executeExpect SSH "createFold: /home/opuser/installpackage"
executeExpect Bash "rsyncFoldExp:/allinone/installpackage /home/opuser/installpackage"
executeExpect SSH "createFold:/home/opuser/repo/${REPO_VERSION}"
executeExpect Bash "rsyncFoldExp:/allinone/repo/${REPO_VERSION} /home/opuser/repo/${REPO_VERSION}"
````

- 配置本地repository

````bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "installCreaterrepoRpm"
executeExpect SSH  "buildCentosRepo ${REPO_PATH}  ${REPO_VERSION}"
````

- 配置Repo Server

````bash
executeExpect SSH  "setupHttpd"
executeExpect SSH  "setupHttpRepo ${REPO_PATH}  ${REPO_VERSION}"
unsetConfig repo
````

#### @由数智云图-自动化云平台构建工具支持
