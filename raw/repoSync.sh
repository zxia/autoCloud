

function repoSyncs (){
   local fileName=$1
   local cnt=$2
   local token=$3
   local lab=$4
   applications=$(cat ${fileName} | grep -v '+' | grep -v "id" | awk -F'\|' '{ print $2}' | xargs)

   for app in ${applications}
   do
     [ ${cnt} -le 0 ] && return 0
     repoSync ${app} ${token} ${lab}
     [ $? -eq 0 ] || return 1
     sed -i "s/${app}/\+${app}/g" ${fileName}
     (( cnt-- ))

   done

}

function repoSync(){
  local appName=$1
  local token=$2
  local lab=$3
  curl --location --request GET "${lab}/acx/appcenter/internal/app/app-prepare?appVersion=${appName}" \
       --header "X-Access-Token: ${token}"

}

while getopts "f:c:t:l:" opt; do
  case ${opt} in
  f)
    fileName=${OPTARG}
    ;;
  c)
    #the config file for special Lab
     cnt=${OPTARG}
    ;;
  t)
    #the confige file for special Lab
     token=${OPTARG}
    ;;
  l)
    lab=${OPTARG}
    ;;
  h)
    exit 1
    ;;
  \? | *)
    echo "Wrong options! ${opt}"
    usage
    exit 1
    ;;
  esac
done

repoSyncs ${fileName} ${cnt} ${token} ${lab}