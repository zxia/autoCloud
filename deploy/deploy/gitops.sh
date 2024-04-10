function deployArgocd(){
  local dependency="deployYamlService"
  deployYamlService argocd argocd || return $?
  rsync /home/opuser/installpackage/${service} /usr/bin/${service}
}

function deployYamlService(){
  local service=$1
  local namespace=$2
  local path=/home/opuser/${service}
  kubectl -n ${namespace} apply -f ${path}/${service}-install.yaml || return $?
  [ -f  /home/opuser/installpackage/${service} ] &&  rsync /home/opuser/installpackage/${service} /usr/bin/${service}
}

function genArgocdFile(){
 genYamlServiceFile argocd
}

function genYamlServiceFile(){

  local service=$1
  if [ $(type -t gen${service^}Values) = 'function' ]; then
    gen${service^}Values
    return $?
  fi


  local path=${workDir}/output/${service}
  [ -d ${path} ] || mkdir -p ${path}
  rsync ${workDir}/template/deploy/${service}-install.yaml.tpl ${path}/${service}-install.yaml

  local reg1=$(echo ${HARBOR_URI}/${HARBOR_LIBRARY} | sed 's/\./\\\./g' |sed 's/\//\\\//g' )
  sed -i "s/quay\.io/${reg1}/g" ${path}/${service}-install.yaml
  sed -i "s/ghcr\.io/${reg1}/g" ${path}/${service}-install.yaml
  sed -i "s/docker\.io/${reg1}/g" ${path}/${service}-install.yaml
  sed -i "s/image: redis/image: ${reg1}\/redis/g" ${path}/${service}-install.yaml
}
#
function gitCloneExp(){
  local git_path=$2
  local git_uri=$3

  [ -d ${git_path} ] && rm -rf ${git_path}
  mkdir -p ${git_path}

  cat << EOF >> $1
send -- "git clone ${git_uri} ${git_path}\r"
expect {
  *sername* {
    send -- "${GITOPS_USER}\r"
    exp_continue
  }
  *assword* {
    send -- "${GITOPS_PASSWORD}\r"
  }
  "is not an empty directory" {
    send -- "cd ${git_path} ; git fetch\r"
    exp_continue
  }
}
expect -re ${prompt}

EOF
}


#setConfig gitops
# operateGitExp:pass  ${GITOPS_URI}
function operateGitExp(){
  local git_base=${GITOPS_LOCAL:=/git}
  local git_path=${git_base}/$2
  local git_uri=$3
  [ -d ${git_base} ] && rm -rf ${git_base}
  [ -d ${git_path} ] || mkdir -p ${git_path}

  cat << EOF >> $1
send -- "git clone ${git_uri} ${git_path}\r"
expect {
  *sername* {
    send -- "${GITOPS_USER}\r"
    exp_continue
  }
  *assword* {
    send -- "${GITOPS_PASSWORD}\r"
  }
  "is not an empty directory" {
    send -- "cd ${git_path} ; git fetch\r"
    exp_continue
  }
}
expect -re ${prompt}

EOF
}

function operateGitPushExp(){
  local git_base=${GITOPS_LOCAL:=/git}
  local git_path=${git_base}/$2
  local git_uri=$3
  local git_message=$4
  git config  --global   user.name "admin"
  git config  --global   user.email "admin@chinatelcom.cn"

  [ -d ${git_path} ] || mkdir -p ${git_path}

  cat << EOF >> $1
send -- "cd ${git_path}; git add \.; git commit -m ${git_message}\r"
expect -re ${prompt}
send -- "git push \r"
expect {
  *sername* {
    send -- "${GITOPS_USER}\r"
    exp_continue
  }
  *assword* {
    send -- "${GITOPS_PASSWORD}\r"
  }
}
expect -re ${prompt}

EOF
}

function addArgoCDAppGit(){
   local gitUri=$1
   local userName=$2
   local password=$3

   argocd  repo add  \
    ${gitUri} \
    --username ${userName} \
    --password  ${password} \
    --insecure-skip-server-verification
}

function deployArgoCDApp(){
  local service=$2
  local type=$1
  local tmp_namespace=$3
  local namespace=${tmp_namespace:=default}
  local git_uri=$4
  local tmp_helm=$5
  local helm=${tmp_helm:=${service}}

  argocd app create ${service} \
   --repo ${git_uri}   \
   --path helm/${helm} \
   --dest-namespace ${namespace} \
   --dest-server https://kubernetes.default.svc \
   --values ../../data/${service}/userValues.yaml \
   --sync-policy auto \
   --sync-option CreateNamespace=true
}

function deleteArgoCDApp(){
  local service=$1
  argocd app delete ${service}
}

function loginArgocdExp(){
  cat << EOF >> $1
send -- "argocd login ${ARGOCD_URI}\r"
expect {
  *sername* {
    send -- "${ARGOCD_USER}\r"
    exp_continue
  }
  *assword* {
    send -- "${ARGOCD_PASSWORD}\r"
  }
  "*Proceed insecurely*" {
    send -- "y\r"
    exp_continue
  }
}
expect -re "${prompt}"

EOF
}

function setArgocdNodePort(){
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
  local port=$(kubectl get svc argocd-server -n argocd  -ojson | jq '.spec.ports|.[0].nodePort')
  echo "ARGOCD_PORT=${port}"
  local initPassword=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
  echo "ARGOCD_PASSWORD=${initPassword}"
}
function updateArgoConfig(){
  local buf=${logbuf}
  ARGOCD_URI=${controlPlaneEndpointIP}:$(cat ${buf} | grep ^ARGOCD_PORT= | awk -F\= '{print $2}')
  ARGOCD_URI=$(echo ${ARGOCD_URI} | tr -d '\r')
  local argoCnf=${workDir}/lab/${LAB_NAME}/argocd.ini
  sed -i "s/ARGOCD_URI=.*/ARGOCD_URI=${ARGOCD_URI}/g" ${argoCnf}
  init_ARGOCD_PASSWORD=$(cat ${buf} | grep ^ARGOCD_PASSWORD= | awk -F\= '{print $2}' | tr -d '\r')
}

function updateArgoPasswordExp(){
   cat << EOF >> $1
send -- " argocd account update-password\r"
expect {
  "password of currently logged" {
    send -- "${init_ARGOCD_PASSWORD}\r"
    exp_continue
  }
  "new password for" {
    send -- "${ARGOCD_PASSWORD}\r"
    exp_continue
  }
  "Confirm new password" {
    send -- "${ARGOCD_PASSWORD}\r"
  }
}
expect -re ${prompt}

EOF
}
# 检查gitlab service 与 argocd 关联
function checkArgoCDAppGit () {
   local gitUri=$1
   local userName=$2
   local password=$3
   #
   result=$(argocd get repo -o url | grep "${gitUri}")
   #argocd repo list -o url | grep "${gitUri}"
   echo "gitlabURI:${result}"
   return $result
}
# argoCD delete App
function deleteArgoCDApp () {
  local appName=$1
  #When you invoke argocd app delete with --cascade, the finalizer is added automatically. --cascade=false
  argocd app delete ${appName} 
}

###### gitlab openAPI ##########
#创建用户 access_token : 默认传 root用户的 personal acccess token; gitlab_url：gitlabIp:port
function createGitlabUser () {

  local access_token=$1
  local gitlab_url=$2
  local userName=$3
  local pwd=$4
  local email=$5

  local serviceGitlabHttp=$(curl -X POST -H "PRIVATE-TOKEN: ${access_token}" http://${gitlab_url}/api/v4/users -H 'cache-control: no-cache' -H 'content-type: application/json' -d '{ "email": "'${email}'",
  "username": "'${userName}'",
  "password": "'${pwd}'",
  "name": "'${userName}'",
  "skip_confirmation": "true"}' | jq .http_url_to_repo)
  return $serviceGitlabHttp
}

#### 创建 project
function createGitlabRepo () {
  local access_token=$1
  local gitlab_url=$2
  local groupId=$3
  local serviceName=$4

curl --request POST --header "PRIVATE-TOKEN: ${access_token}" \
     --header "Content-Type: application/json" --data '{ 
            "name": "'${serviceName}'", "description": "New '${serviceName}' Project", "path": "'${serviceName}'","group_id": "'${groupId}'", 
            "namespace_id": "1", "initialize_with_readme": "true"}' \
    "http://${gitlab_url}/api/v4/projects/" | jq .

}

###检查用户 access_token : 默认传 root用户的 personal acccess token; gitlab_url：gitlabIp:port
function checkUser () {

  local access_token=$1
  local gitlab_url=$2
  local userName=$3

  local result=$(curl -X GET -H "PRIVATE-TOKEN: ${access_token}" http://${gitlab_url}/api/v4/users?username=${userName} |jq .[0].id)
  echo "userId:${result}"
  return $result
}
#创建用户 access_token : 默认传 root用户的 personal acccess token; gitlab_url：gitlabIp:port
##检查 Project 是否创建 为空则未创建
function checkRepo () {

  local access_token=$1
  local gitlab_url=$2
  local projectName=$3

  result=$(curl --header "PRIVATE-TOKEN: ${access_token}" "http://${gitlab_url}/api/v4/projects" | jq . | grep '"name": "${projectName}"')
  echo "project name:${result}"
  return $result
}

###查询 groupId 创建project使用
function getGroupId () {
  local access_token=$1
  local gitlab_url=$2

  local groupId=$(curl --header "PRIVATE-TOKEN: ${access_token}" "http://${gitlab_url}/api/v4/groups" | jq .[0].id)

  return $groupId
}
## 修改密码
function changeUserPwd () {

  local access_token=$1
  local gitlab_url=$2
  local userid=$3
  local pwd=$4

  userId=$(curl -X PUT -H "PRIVATE-TOKEN: ${access_token}" http://${gitlab_url}/api/v4/users/${userid} \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{ "password": "${pwd}"}' | jq .[0].id)
  echo "userId:${userId}change pwd success."
  return $userId

}