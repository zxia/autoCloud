# 数智云平台-（基于数智中台-云图套件）

## 安装配置

- 配置安装repository

```bash
setConfig harbor
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "addEtcHost:${HARBOR_NAME} ${HARBOR_IP}"
executeExpect SSH  "loadcrt:${HARBOR_NAME} ${HARBOR_IP}"
unsetConfig harbor
```

#### @由数智云图-自动化云平台构建工具支持