# 数智云平台-Chrony安装分册（基于数智中台-云图套件）

### 准备工作

````bash
setConfig chrony
````

### 安装 Chrony

- 生成 Harbor 安装文件并上传到安装主机

````bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH "createFold: /home/opuser/installpackage"
executeExpect Bash "rsyncFoldExp:/allinone/installpackage /home/opuser/installpackage"
genChronyValue
executeExpect SSH "createFold: /home/opuser/chrony"
executeExpect Bash "rsyncFoldExp:${workDir}/output/chrony /home/opuser/chrony"
````

- 安装 Chrony

````bash
EXECUTED_PERMISSION="suroot"       
executeExpect SSH "deployChrony:${CHRONY_VERSION}"
unsetConfig chrony
````