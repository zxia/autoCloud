# 数智云平台-Paas Helm Package 创建分册（基于数智中台-云图套件）

## 用户管理

- 创建管理用户

```bash
EXECUTED_PERMISSION="root"
executeExpect SSH "createUser:${SSH_USER}"
executeExpect SSH "changeUserPasswordExp:${SSH_USER} ${SSH_USER_PASSWORD}"
```

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
executeExpect SSH "setupRepos:${PROXY_HOST}  ${PROXY_PORT}"
executeExpect SSH "saveRpms:${PROXY_HOST}  ${PROXY_PORT}"
executeExpect Bash "rsyncDownFoldExp:/allinone/repo/${OS} /tmp/baseRpm"
executeExpect Bash "rsyncDownFoldExp:/allinone/repo/${OS} /var/cache/yum"
```
