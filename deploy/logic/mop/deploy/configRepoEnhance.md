# 数智云平台-（基于数智中台-云图套件）

## 安装配置

- 配置安装repository

```bash
setConfig repo
EXECUTED_PERMISSION="suroot"
executeExpect SSH "rm -rf /etc/yum.repos.d/*.repo"
executeExpect SSH "curl -L http://${REPO_HOST}/middlePlatform.repo -o /etc/yum.repos.d/middlePlatform.repo"
executeExpect SSH  "yum install -y rsync"
unsetConfig repo
```

#### @由数智云图-自动化云平台构建工具支持
