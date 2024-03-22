#upload deploy scripts
```bash
setConfig elasticsearch
EXECUTED_PERMISSION="suroot"
executeExpect SSH "addKibanaUser:elk-system ${ELASTICSEARCH_ELASTICSEARCH_KIBANA_USER} ${ELASTICSEARCH_KIBANA_PASSWORD}"
unsetConfig elasticsearch
```
#end
