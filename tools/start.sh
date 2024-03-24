### global variable user:port
declare -A port
port[xiazw]=8000
port[xingpf]=9000
port[fusl]=10000
port[luozg]=11000
port[zhangxy]=12000
####
user=$1
mode=$2
debug=$3
workdir=/largeDisk/${user}

[ -d ${workdir} ]  || mkdir -p ${workdir}

if [ "${mode}" = "build" ] ; then
   "echo "
elif [ "${mode}" = "deploy" ];then
  docker stop ${user}-openapi
  docker rm  ${user}-openapi
  docker run -it --publish ${port[$user]}:8000 \
    --name ${user}-openapi --restart always  \
    --volume ${workdir}/lab:/deploy/lab  \
    --volume ${workdir}/output:/deploy/output \
    gmct.storage.com/library/openapi:v4.0.0.1228
else
  docker stop ${user}-openapi
  docker rm  ${user}-openapi
  docker run -it --publish ${port[$user]}:8000 \
    --name ${user}-openapi --restart always  \
    --volume ${workdir}/deploymd:/deploy \
    --volume ${workdir}/lab:/deploy/lab  \
    --volume ${workdir}/output:/deploy/output \
    gmct.storage.com/library/openapi:v4.0.0.1228   bash


fi

