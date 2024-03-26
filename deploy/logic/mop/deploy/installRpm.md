# 数智云平台-（基于数智中台-云图套件）

## 安装配置

- 配置安装repository

```bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH "createFold:/home/opuser/deploy/rpms" 
executeExpect Bash "scpUpFilsExp:/allineone/installpackage/${RPM_PACKAGE_NAME} /home/opuser/deploy/rpms/"
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "rpm -ivh /home/opuser/deploy/rpms/${RPM_PACKAGE_NAME} --force --nodeps "

```

#### @由数智云图-自动化云平台构建工具支持
