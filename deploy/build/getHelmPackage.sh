function addHelmRepo(){
    local proxy=$1
    export https_proxy=http://${proxy}
    export http_proxy=http://${proxy}
    cat /home/opuser/helm/data/repoList.ini | awk '{ print "helm repo add "  $1 " " $2}' > /tmp/repoList.sh
    source /tmp/repoList.sh
    helm repo update
    rm -rf /tmp/repoList.sh
}

function getHelmPackage(){
   local proxy=$1
   local packages=($(cat /home/opuser/helm/data/helmPackage.ini | awk ' { print $1 } ' | xargs ))
   local packageDir=/tmp/helm
   [ -d  ${packageDir} ] && rm -rf  ${packageDir}
   export https_proxy=http://${proxy}
   export http_proxy=http://${proxy}
   mkdir -p ${packageDir}
   for package in ${packages[@]}
   do
      helm pull ${package} -d ${packageDir}
      if [ $? -eq 0  ] ; then
           echo "pull ${package}  success"
      else
           echo  "pull ${package} failed "
      fi
   done
}

function getHelmPackageOne(){
   local packages=$1
   local proxy=$2
   local packageDir=/tmp/helm
   [ -d  ${packageDir} ] && rm -rf  ${packageDir}
   export https_proxy=http://${proxy}
   export http_proxy=http://${proxy}
   mkdir -p ${packageDir}
   for package in ${packages[@]}
   do
      helm pull ${package} -d ${packageDir}
      if [ $? -eq 0  ] ; then
           echo "pull ${package}  success"
      else
           echo  "pull ${package} failed "
      fi
   done
}