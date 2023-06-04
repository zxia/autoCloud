# 数智云平台-主机安装分册（基于数智中台-云图套件）

## 升级内核

- 创建管理用户

````
EXECUTED_PERMISSION="suroot"
executeExpect SSH "installKernal"
executeExpect SSH "shutdown -r +1"
sleep 120 
````

#### @由数智云图-自动化云平台构建工具支持