
function buildImage(){
   local privateRegistry=${1}/library
   local securityName=$2
   local securityWord=$3
   local type=$4
   local tag=$5
   local lowType=$(echo $type |tr A-Z a-z)
   cd /home/opuser/docker/${lowType}/

   docker login ${1} -u ${securityName} -p ${securityWord} || return $?

   local image=${privateRegistry}/${lowType}:${tag}
   docker build -t  ${image} . || return $?
   docker push ${image} || return $?
}

function genDockerFile(){
  local type=$1
  local lowType=$(echo $type |tr A-Z a-z)
  eval gen${lowType^}DockerFile
}

function prepareDockerfile(){
  local type=$1
  local lowType=$(echo $type |tr A-Z a-z)
  eval prepare${lowType^}Dockerfile
}
