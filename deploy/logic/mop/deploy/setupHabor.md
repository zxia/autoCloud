# 数智云平台-Harbor安装分册（基于数智中台-云图套件）

### 准备工作

````bash
setConfig harborbase
````

### 安装 Harbor

- 生成 Harbor 安装文件并上传到安装主机

```bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH "createFold: /home/opuser/installpackage"
executeExpect Bash "rsyncFoldExp:/allinone/base /home/opuser/installpackage"
genHarborValue
executeExpect SSH "createFold: /home/opuser/harbor"
executeExpect Bash "rsyncFoldExp:${workDir}/output/harbor /home/opuser/harbor"
```

- 安装 Harbor

```bash
EXECUTED_PERMISSION="suroot"
   
executeExpect SSH "prepareHarbor:${HARBORBASE_VERSION}"
executeExpect SSH  "genHarborConfig:${HARBORBASE_VERSION}"
executeExpect SSH "configHarbor"
executeExpect SSH "deployCrt:${HARBORBASE_HOST_NAME}"
executeExpect SSH "deployHarbor"
executeExpect SSH "uploadcrt"
unsetConfig harborbase
```
