source /opt/acx/service/cacheImage.sh

function convertVariablsAcx(){
  local infile=$1
  local file=$2
  [ -f ${file} ]  || return $?
  local vars=$(cat ${infile}| grep -v "#" | awk '{print $1}'| xargs)
  local value=''
  local key=''
  local escapeValue=''
  for var in ${vars}
  do
    eval $var
    key=${var%%=*}
    eval "value=\$$key"
    escapeValue=$(trs1 $value )
    #escapeValue=${value/\//\\/}
    sed -i "s/\${${key}}/${escapeValue}/g" ${file}
  done

}

function trs1(){
  local out=''
  input=$(echo -e $1 )
  for i in $(seq ${#input})
  do
  tmp=${input:$i-1:1}
    case ${tmp} in
    \/)
        tmp='\/'
    ;;
    esac
   out=${out}${tmp}
  done
  echo $out
}

function genAcxConfigValue(){
    local dependency="convertVariablsAcx trs1"
    local labName=$2
    local packageName=$1
    local appName=${packageName%-*}
    local labAppInfo=${workDir}/lab/${labName}/app.ini

    local configTemplateDir=${workDir}/service/app/conf/${appName}
    local outputConf=${workDir}/service/output/conf/${labName}/${packageName}

    [ -d ${outputConf} ] && rm -rf ${outputConf}
    mkdir -p ${outputConf}

    rsync -ar ${configTemplateDir}/  ${outputConf} || return $?
    rsync -ar ${workDir}/service/app/script/  ${outputConf}/script || return $?

    for file in $(find ${outputConf} -type f )
    do
        convertVariablsAcx ${labAppInfo} ${file}
    done
}

function genDeployValue(){
  local packageName=$1
  local labName=$2
  local appName=$(echo ${packageName}| sed 's/v[0-9]\{1,3\}//g')

  local srcValues=${workDir}/service/app/opValues/${appName}
  local desValues=${workDir}/service/output/data/${packageName}

  rsync -ar ${srcValues}/  ${desValues} || return $?

  sed -i "s/tag\:.*/tag\: $(getImageTag ${appName%-*})/g" ${desValues}/values.yaml

}


workDir=/opt/acx/
#--------------------------------------------------------
# Translate the template file into configuration files
# INPUT:
#   - serviceName
#   - labName
#
# OUTPUT:
#   output/config/{lab}/{serviceName} : the generated helm package
# --------------------------------------------------------
genAcxConfigValue $1 $2

#--------------------------------------------------------
# move the operation sevice values into helm package
# INPUT:
#   - serviceName
#   - labName
#
# --------------------------------------------------------
genDeployValue $1 $2
