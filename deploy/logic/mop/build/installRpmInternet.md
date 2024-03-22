# 数智云平台-Paas Helm Package 创建分册（基于数智中台-云图套件）


## 准备工作

```bash
genGeneralRepo
EXECUTED_PERMISSION="opuser"
genRepos
executeExpect SSH "createFold:/home/opuser/repo/data"
executeExpect Bash "rsyncFoldExp:/${workDir}/data/build/rpms /home/opuser/repo/data"
executeExpect SSH "createFold:/home/opuser/deploy/"
executeExpect Bash "rsyncFoldExp:/${workDir}/output/deploy /home/opuser/deploy"
```

## 配置repo并下载rpms

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "installRpmFromInternet:${PROXY_HOST}  ${PROXY_PORT} ${RPM_PACKAGE}"
```
