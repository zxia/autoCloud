# 数智云平台-Paas Helm Package 创建分册（基于数智中台-云图套件）


## 准备工作

```bash
setConfig buildDocker
genGeneralRepo
genRepos ${K8S_VERSION}
EXECUTED_PERMISSION="opuser"
executeExpect SSH "createFold:/home/opuser/repo/data"
executeExpect Bash "rsyncFoldExp:/${workDir}/data/build/rpms /home/opuser/repo/data"
executeExpect SSH "createFold:/home/opuser/deploy/"
executeExpect Bash "rsyncFoldExp:/${workDir}/output/deploy /home/opuser/deploy"
```

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "setupBuildHost:\"${BUILDDOCKER_PROXY}\"  \"${BUILDDOCKER_NAMESERVER}\""
```