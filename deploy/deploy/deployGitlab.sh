function prepareGitlab(){
  local gitPort=$1
  local gitwebPort=$2
  local gitsshPort=$3
  local hostname=$4
  local user=$5
  local password=$6
  local path=$7
  
  docker login ${hostname} -u ${user} -p ${password} || return $?
  docker pull ${hostname}/${path}/gitlab/gitlab-ce:latest || return $?
  [ -d /usr/local/gitlab/config ] || mkdir -p /usr/local/gitlab/config
  [ -d /usr/local/gitlab/log ] || mkdir -p /usr/local/gitlab/log
  [ -d /usr/local/gitlab/data ] || mkdir -p /usr/local/gitlab/data
  docker run -d  -p ${gitPort}:443 -p ${gitwebPort}:80 -p ${gitsshPort}:22 --name gitlab-dev \
  --restart always --privileged=true \
  -v /usr/local/gitlab/config:/etc/gitlab \
  -v /usr/local/gitlab/log:/var/log/gitlab \
  -v /usr/local/gitlab/data:/var/opt/gitlab  ${hostname}/${path}/gitlab/gitlab-ce
}

function genGitlabValue(){
  [ -d ${workDir}/output/gitlab ] || mkdir ${workDir}/output/gitlab

  rsync ${workDir}/template/deploy/gitlab.rb.tpl  ${workDir}/output/gitlab/gitlab.rb || return $?
  replaceVariabls gitlabBase ${workDir}/output/gitlab/gitlab.rb || return $?
}


function configGitlab(){
  rsync  /home/opuser/gitlab/gitlab.rb   /usr/local/gitlab/config/gitlab.rb || return $?
}


function deployGitlab(){
  docker restart gitlab-dev || return $?
}
