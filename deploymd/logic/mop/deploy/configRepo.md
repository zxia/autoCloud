# 数智云平台-（基于数智中台-云图套件）

## 安装配置

- 配置安装repository

```bash
setConfig repo
EXECUTED_PERMISSION="opuser"
genMiddlePlatformRepo
executeExpect SSH "createFold:/home/opuser/deploy/${REPO_VERSION}"
executeExpect Bash "rsyncFoldExp:/${workDir}/output/deploy/${REPO_VERSION} /home/opuser/deploy/${REPO_VERSION}"
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "prepareCtyunOS:${REPO_VERSION}"
unsetConfig repo
```

#### @由数智云图-自动化云平台构建工具支持
