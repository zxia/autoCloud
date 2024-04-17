
function interactMode(){
  [ "${engineMode}" = "interact" ] || return 0

   read -p "continue[c],pause[p],stop[s]" -t 120 flag
   [ ${flag} = 's' ] && exit 0
   [ ${flag} = 'p' ] && sleep 180
   [ ${flag} = 'c' ] && return 0
}

function runEngine(){
 local runFile=$1
 local tmpDir=${workDir}/tmp
 [ -d ${tmpDir} ] || mkdir -p ${tmpDir}

 local retryFile=${runFile}_$$.retry.md
 [ -f ${retryFile} ] && rm -rf ${retryFile}

 [ -f ${runFile} ] || return $?
 # load steps
 local -A steps
 local cnt=0
 set +x
  while read line; do
    case $line in
    '^$' | $'\r' )
    ;;

    *)
        steps[${cnt}]="${line}"
        ((  cnt ++ ))
     ;;

    *)
     ;;
    esac
  done <${runFile}


 # execute steps
 local result=0
 local arrayLen=${#steps[@]}
 local codeBlockBegin=false
 local featureMark=false
 local lang="bash"
 local featureRe='\]\(.*md\)'
 local step
 local i=0
 local oneTimeError=0
 local overrideResult=0

 for (( i=0; i<${arrayLen}; i++    ))
 do
    #reset the runFile in case modified by the sub function
    [ "${featureMark}"  = true ] && featureMark=false
    step=${steps[$i]}

    if [[ "${step}"  =~ .*成功.* ]]; then
      echo "${step}" >>  ${retryFile}
      continue
    fi

    if [[ "${step}"  =~ .*disable.* ]]; then
      echo "${step}" >>  ${retryFile}
      continue
    fi

    if [[ "${step}"  =~ \`{3,4} ]]; then
      if [ "${codeBlockBegin}" = "false" ]; then
        codeBlockBegin=true
      else
        codeBlockBegin=false
      fi

      if [ ${codeBlockBegin} = "true" ];then
        lang=${step##*\`}
        lang=${lang:='bash'}
      else
        lang=""
      fi

      echo "${step}" >>  ${retryFile}
      continue

    elif [[ "${step}"  =~ ${featureRe} ]]; then
      lang='dp'
      featureMark=true
    fi

    if [ "${codeBlockBegin}" = "false" -a "${featureMark}" = "false" ]; then
      echo "${step}" >>  ${retryFile}
      continue
    fi

    if [[ "${step}" =~ ^\s*#  ]] ; then
      if [ "${featureMark}" = "false" ]; then
        echo "${step}" >>  ${retryFile}
        continue
      fi
    fi

    interactMode || return $?

    if [ ${result} -eq 0   ] ; then
        set -x
        execFunc "${lang}" "${step}" "${runFile%/*}"
        result=$?
        set +x
        # if the step is failed and the step is not override, then the whole run is failed
        if [ ${result} -ne 0 -a ${overrideResult} -eq 1 ] ;then
          result=0
          overrideResult=0
        fi

        log "${lang} ${step} ${runFile%/*}" $result
        echo "${lang} ${step} ${runFile%/*}" $result
        sleep 0.1
    fi

    if [ ${result} -eq 0  ]; then
       case "${step}" in
       *=*)
        ;;
       *setConfig*)
        ;;
       *unsetConfig*)
        ;;
        ^$ | \r)
        ;;
       ^?{0,3}# )
         ;;
       *)
         step='#### [成功] '${step}
      ;;

       esac
    else
       if [ ${oneTimeError} = 0 ];  then
            echo "NOTICE: FAILED at ${step}, PLEASE CHECK ERROR AT HERE "
            oneTimeError=1
       fi
    fi
        echo "${step}" >>  ${retryFile}
 done
 if [ ${result} -ne 0 ] ; then
    echo "check the failed reson and try to rerun with  ${retryFile} as input !!!"
 fi
    echo "check the execute result from ${retryFile}"
 return ${result}
}


function execFunc(){
  set +x
  local lang=$1
  local function=$2
  local parentPath=$3
  if [ "${lang}" = "bash" -o "${lang}" = "dp" ] ; then
     exec${lang^}Func "${function}" "${parentPath}"
  fi

 }

function execDpFunc(){
  local rawLine=$1
  local runFile=${rawLine##*\(}
  local runFile=${runFile%\)*}
  local parentPath=$2
  local sshHostBack=${SSH_HOST}
  local result=0
  for host in ${HOSTS}
  do
     eval SSH_HOST=${host}
     runEngine "${parentPath}/${runFile}" || return $?
  done

  SSH_HOST=${sshHostBack}
  return ${result}
}
function execBashFunc(){
  local function=$1
  eval "${function}"
}