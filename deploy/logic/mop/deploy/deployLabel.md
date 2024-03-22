### input Param

#### NODES

#### KEY

#### VALUE

```bash
EXECUTED_PERMISSION="suroot"
setConfig harbor
executeExpect SSH  "kubectl label nodes ${NODES} ${KEY}=${VALUE} --overwrite=true" 
```