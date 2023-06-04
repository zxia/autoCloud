function addHelmRepo(){
    cat /home/opuser/helm/data/repoList.ini | awk '{ print "helm repo add "  $1 " " $2}' > /tmp/repoList.sh
    source /tmp/repoList.sh
    helm repo update
    rm -rf /tmp/repoList.sh
}

function getHelmPackage(){
   local packages=($(cat /home/opuser/helm/data/helmPackage.ini | awk ' { print $1 } ' | xargs ))
   local packageDir=/tmp/helm
   [ -d  ${packageDir} ] && rm -rf  ${packageDir}
   export https_proxy=http://192.168.0.34:3128
   export http_proxy=http://192.168.0.34:3128
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
   local packageDir=/tmp/helm
   [ -d  ${packageDir} ] && rm -rf  ${packageDir}
   https_proxy=http://192.168.0.34:3128
   http_proxy=http://192.168.0.34:3128
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