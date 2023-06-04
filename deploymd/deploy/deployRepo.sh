#buildCentosRepo /usr/local/middlePlatform.repo

function setupHttpd(){
  #install apache web server
  #Step 1: Update Software Versions List
  yum update -y
  #Step 2: Install Apache
  yum install httpd -y
  systemctl start httpd
  systemctl status httpd  || return $?
}

function setupHttpRepo(){
   local repoDir=$1
   local rpmDir=$2
   ln -s ${repoDir}  /var/www/html/middlePlatform${rpmDir}
   rsync /home/opuser/deploy/${rpmDir}/middlePlatform.repo  /etc/yum.repos.d/middlePlatform${rpmDir}.repo
}

function installCreaterrepoRpm(){
  local rpmPackage=/home/opuser/installpackage/createrepo.tar.gz
  tar Czxvf /tmp  ${rpmPackage}  || return $?
  cd /tmp/createrepo
  rpm -ivh '*.rpm' --force --nodeps  || return $?

  which createrepo || return $?

}

function buildCentosRepo()
{
  local repoDir=$1
  local rpmDir=$2
  [ -d ${repoDir} ] || mkdir -p ${repoDir}

  rsync -ar /home/opuser/repo/${rpmDir} ${repoDir}/
  cd ${repoDir}/
  find . -name "*.rpm" | xargs -I {} cp {} .
  #创建仓库
  createrepo -p ${repoDir}
  rsync /home/opuser/deploy/${rpmDir}/local.repo  /etc/yum.repos.d/local${rpmDir}.repo
}

function genMiddlePlatformLocalRepo(){
    local repoIP=${REPO_PATH}
    local rpmDir=${REPO_VERSION}
    cat << EOF >  ${workDir}/output/deploy/${rpmDir}/local.repo
[local-yum]
name=local-yum
baseurl=file://${REPO_PATH}
enabled=1
gpgcheck=0
EOF
}


function genMiddlePlatformRepo(){
  local repoIP=${REPO_HOST}
  local rpmDir=${REPO_VERSION}
  [ -d ${workDir}/output/deploy/${rpmDir} ] || mkdir -p ${workDir}/output/deploy/${rpmDir}
  cat << EOF >  ${workDir}/output/deploy/${rpmDir}/middlePlatform.repo
[middlePlatform]
name=middlePlatform
baseurl=http://${repoIP}/middlePlatform${rpmDir}
enabled=1
gpgcheck=0
EOF
}

function updateCentosRepo()
{
  local repoDir=$1
  local rpmDir=$2
  [ -d ${repoDir} ] || mkdir -p ${repoDir}

  rsync -ar /home/opuser/repo/${rpmDir} ${repoDir}/  || return $?
  cd ${repoDir}/
  find . -name "*.rpm" | xargs -I {} cp {} .
  #创建仓库
  createrepo  --update  ${repoDir}    || return $? 
}

