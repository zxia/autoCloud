# 数智云平台-rpm repo 安装分册（基于数智中台-云图套件）

##

- 准备安装RPM Repo

````bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH "createFold: /home/opuser/installpackage"
executeExpect Bash "rsyncFoldExp:/allinone/installpackage /home/opuser/installpackage"
````

- 配置本地repository

````bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "rsync /home/opuser/installpackage/kn-linux-amd64 /usr/bin/kn"
executeExpect SSH  "chmod 0755 /usr/bin/kn"
````

#### @由数智云图-自动化云平台构建工具支持
