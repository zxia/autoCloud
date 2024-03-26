# 数智云平台-Paas Helm Package 创建分册（基于数智中台-云图套件）


## 配置repo并下载rpms

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "saveRpms"
executeExpect Bash "rsyncDownFoldExp:/allinone/repo/${OS} /tmp/baseRpm"
executeExpect Bash "rsyncDownFoldExp:/allinone/repo/${OS} /var/cache/yum"
```
