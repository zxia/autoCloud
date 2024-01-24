# 数智云平台-Paas Helm Package 创建分册（基于数智中台-云图套件）

## 通用配置参数

```

LOCAL_HOST_IP=$(getLocalHostIP)
setConfig ssh
```


## 下载rpms

````
EXECUTED_PERMISSION="suroot"
executeExpect Bash "rsyncDownFoldExp:/allinone/repo/  /tmp/baseRpm"
executeExpect Bash "rsyncDownFoldExp:/allinone/repo/  /var/cache/yum"
````
