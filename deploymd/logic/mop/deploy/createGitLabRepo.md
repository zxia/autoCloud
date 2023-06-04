****# 数智云平台-主机安装分册（基于数智中台-云图套件）

## Gitlab用户管理

### input param

    GITLAB_SERVICENAME

- 创建用户

```bash
setConfig gitlab

executeExpect SSH "createGitlabRepo:${GITLAB_TOKEN} ${GITLAB_URL} ${GITLAB_GROUPID} ${GITLAB_SERVICENAME}"

unsetConfig  gitlab
```

#### @由数智云图-自动化云平台构建工具支持[