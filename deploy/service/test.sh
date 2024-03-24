service=$1
subName=$2
bash -x serviceGenerator.sh  -f defination/${service}.ini
bash -x genValues.sh ${service}-${subName} k8s02
bash -x deployService.sh   ${service} ${subName} k8s02 default