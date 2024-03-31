function saveImages(){
  local dependency="genAliyunImage  genAliyunDocker getInternetImage"
   local privateRegistry=${1}/library
   local securityName=$2
   local securityWord=$3
   local dataDir=/home/opuser/image/data/
   docker login ${1} -u ${securityName} -p ${securityWord} || return $?
   components=$(cat ${dataDir}/image.list  |  grep -v '#' | awk '{print $1"."$2}' | xargs)

   for component in ${components}; do
      local images=$(cat ${dataDir}/${component} | grep -v ''# | awk ' {print $1":"$2}' | xargs )
      for image in ${images}; do
      #  if [[ ${image} =~ .*\.k8s\.io.*  || ${image} =~ gcr\.io.* ]]; then
      #      getInternetImage ${image} ${privateRegistry} || return $?
      #  else
          local privateImage=${privateRegistry}/${image#*/}
          docker pull ${image}  || return $?
          docker tag ${image} ${privateImage}  || return $?
          docker push ${privateImage} || return $?
       # fi
      done
  done
}

function saveOneImage(){
   local dependency="genAliyunImage  genAliyunDocker getInternetImage"
   local privateRegistry=${1}/library
   local securityName=$2
   local securityWord=$3
   local image=$4
   docker login ${1} -u ${securityName} -p ${securityWord} || return $?

   if [[ ${image} =~ .*\.k8s\.io.*  || ${image} =~ gcr\.io.* ]]; then
          getInternetImage ${image} ${privateRegistry} || return $?
        else
          local privateImage=${privateRegistry}/${image#*/}
          docker pull ${image}  || return $?
          docker tag ${image} ${privateImage}  || return $?
          docker push ${privateImage} || return $?
  fi

}

function submitImages() {
   local images=($(getCurrentImagesList))
   local repo=artifact.srdcloud.cn/middleplatform-snapshot-docker-local
   docker login  -uxiazw1  artifact.srdcloud.cn
   for image in ${images[@]}
   do
       local repoImage=${repo}/${image#*/}
       docker pull ${image}  || return $?
       docker tag ${image}  ${repoImage} || return $?
       docker push ${repoImage} || return $?
       docker image rm ${image} ${repoImage}
   done

}
#when get the image with digit, then tag should be set
#else tag should be null
function genAliyunImage(){

  local cnfRoot=/tmp/cnfRoot/
  [ -d ${cnfRoot} ] || mkdir -p ${cnfRoot}
  local genImageFunction=$1
  local internetImage=$2
  local tag=$4
  local dockerRegistry=$3
  local privateImage=${dockerRegistry}/${internetImage#*/}
  [ -n "${tag}" ] && privateImage=${privateImage[@]%@*}:${tag}

  if [[ ${internetImage} == *\@* ]]; then
    internetImage=${internetImage%:*}
    privateImage=${privateImage%@*}:${privateImage##*:}
  fi
  local workDir=${cnfRoot}/run/buildDocker
  [ -d ${workDir} ] && mv ${workDir}  ${workDir}.$(date +"%Y-%m-%d-%T" | tr -d ':')
  mkdir -p ${workDir}
  cd ${workDir}
  git clone https://deepblue2022:8acc0487cd397aaa21d022ae9a6a1b6e@code.aliyun.com/deepblue2022/buildDocker.git  || return $?
  cd buildDocker
  git config user.name "deepblue2022"  || return $?
  git config user.email "15803109@qq.com"  || return $?
  eval "${genImageFunction} ${internetImage}"   || return $?
  git commit -am "${genImageFunction} ${internetImage}"
  git push   || return $?
  sleep 120
  docker login -u deepblue2022 -p wps200000 registry.cn-beijing.aliyuncs.com  || return $?
  docker pull registry.cn-beijing.aliyuncs.com/zxia_docker/docker:111   || return $?
  docker tag registry.cn-beijing.aliyuncs.com/zxia_docker/docker:111 ${privateImage}  || return $?
  docker push ${privateImage}
}

function genAliyunDocker(){
  local image=$1

echo "FROM ${image}" > ${cnfRoot}/run/buildDocker/buildDocker/dockerfile
}

function getInternetImage(){
  local dockerRegistry=$2
  local image=$1
  local tag=$3
  genAliyunImage "genAliyunDocker" "${image}" ${dockerRegistry} ${tag} || return $?
}
#getKnativeImages knative-serving v1.2.0
#getKnativeImages knative-eventing v1.2.0
function getKnativeImages(){

   local tag=$2
   local namespace=$1
   local images=($(kubectl get pods -n ${namespace} |grep -v NAME | awk '{print $1}' | xargs -I {}  kubectl describe pods {} -n ${namespace} | grep Image: | uniq | grep gcr | awk '{ print $2}'| xargs))
   for image in ${images[@]}
   do
       genAliyunImage "genAliyunDocker" "${image}" ${tag}
   done
}

function getKnativeImages(){

   local tag=$2
   local namespace=$1
   kubectl get pods -n ${namespace} |grep -v NAME | awk '{print $1}' | xargs -I {}  kubectl describe pods {} -n ${namespace} | grep Image: | uniq | grep gcr | awk '{ print $2 " v1.8.2"}'

}

#formatKnativeImages serving v1.2.0
function formatKnativeImages(){
  local tag=v1.2.0
  local project=$1
  local images=$(docker images | grep knative | grep dev | awk ' {print $1}' | xargs)

  for image in ${images}
  do
     img=${image##*/}
     docker tag ${image}:${tag} ${dockerRegistry}/knative-releases/${project}/${img}:${tag}
     docker push ${dockerRegistry}/knative-releases/${project}/${img}:${tag}
  done
}

function saveImagesListFromHarbor(){
  local harborUrl=$1
  local harborName="admin"
  local harborPassWord="Ctsi5G@2021"
  local imagefile=harbor-images-`date '+%Y-%m-%d'`.txt
  [ -f ${imagefile} ] && rm -rf ${imagefile}

  local repolist=$(curl -u ${harborName}:${harborPassWord}  -H "Content-Type: application/json" \
     -X GET  https://${harborUrl}/api/v2.0/search?q=library  -k  \
       | jq '.repository[].repository_name' | xargs)

  for image in ${repolist};do
        # 循环获取镜像的版本（tag)
        imageTags=$(curl -u ${harborName}:${harborPassWord} -H "Content-Type: application/json"   \
        -X GET  https://${harborUrl}/v2/${image}/tags/list  -k |  awk -F '"'  '{print $8,$10,$12}')
        for tag in $imageTags;do
            # 格式化输出镜像信息
            echo "${harborUrl}/$image:$tag"   >> ${imagefile}
        done
    done

  echo "save files on " ${imagefile}
}

#
# helm ls | grep -v NAME | awk '{ print $1}' | xargs -I{} helm get manifest {} | grep image: | awk  '{ print $2 }'
# get imageList
function saveImagesToFile(){
   local privateRegistry=${1}/library
   local securityName=$2
   local securityWord=$3
   local dataDir=/largeDisk/images
   local imageListFile=$4
   [ -d  ${dataDir} ] || mkdir -p ${dataDir}

   docker login ${1} -u ${securityName} -p ${securityWord} || return $?

  local images=$(cat ${imageListFile} | xargs )
  for image in ${images}; do
      docker pull ${image}  || return $?
      local savefile=$(echo ${image} | tr  '/' '~' | tr ':' '@')
      docker save ${image} > ${dataDir}/${savefile}.tar
      docker rmi ${image}
  done
}

function uploadImages(){
   local privateRegistry=${1}/library
   local securityName=$2
   local securityWord=$3
   local dataDir=$4

   docker login ${1} -u ${securityName} -p ${securityWord} || return $?

  local images=$(ls ${dataDir} | xargs )
  for image in ${images}; do
      docker load < ${image}  || return $?
      local savefile=$(echo ${image%.*} | tr  '~' '/' | tr '@' ':')
      docker push ${savefile} || return $?
      docker rmi ${savefile}
  done
}

function uploadImages(){
  local dataDir=$1

  local images=$(ls ${dataDir} | xargs )
  for image in ${images}; do
      ctr -n k8s.io image import ${imag}
  done
}