# 数智云平台-主机安装分册（基于数智中台-云图套件）

## 磁盘操作

```bash
EXECUTED_PERMISSION="suroot"
setNodeConfig disk   
setNodeConfig docker 
executeExpect SSH  "yum install -y lvm2"
executeExpect SSH "formatFsDisk:${DISK_ERASED} ${DOCKER_PATH} ${DISK_DISK} ${DOCKER_VOLUME} ${DOCKER_LV} ${DISK_VG}"

unsetNodeConfig disk  
unsetNodeConfig docker 
```

#### @由数智云图-自动化云平台构建工具支持