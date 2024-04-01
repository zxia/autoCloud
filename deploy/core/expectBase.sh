###################golabel variable################
expectTimeout=60
debug=true
SSHPrompt='(%|#|\\$|\])(\\s{0,3})'
###################################################
#######################Base Expect ################
###################################################
function commonExpectHeader() {
  local file=$1
  prompt=${SSHPrompt}
  cat <<EOF1 >${file}
#!/usr/bin/expect -f
  log_file ${file}.log
EOF1

  cat <<'EOF' >>${file}
  set timeout -1
  set force_conservative 0  ;# set to 1 to force conservative mode even if
                            ;# script wasn't run conservatively originally
  if {$force_conservative} {
          set send_slow {1 .1}
          proc send {ignore arg} {
                  sleep .1
                  exp_send -s -- $arg
          }
  }
EOF

}

function commonExpectTailer() {
  local file=$1
  cat <<'EOF' >>${file}
expect eof
catch wait result
exit [lindex $result 3]
EOF
}

logbuf=""
function executeExpect() {

  local type=$1
  local command=$2
  local output=${workDir}/output/expect
  [ -d ${output} ] || mkdir -p ${output}
  set +x
  local randNum=$(($RANDOM % 49999))

  expFile=${output}/${type}-$$-${randNum}.exp
  commonExpectHeader ${expFile}
  execute${type^}Expect ${expFile} ${command}
  commonExpectTailer ${expFile}
  chmod 0755 ${expFile}
  logbuf=${expFile}.log
  log "${command} log is located at ${loguf}"
  set -x
  if [ "${debug}" = "true" ]; then
    expect  ${expFile}
  else
    expect ${expFile}
  fi

}

function executeCommand() {
  local expectFile=$1
  local command=$2
  local functionName=${command%%:*}
  local args=${command#*:}

  loadFunctionResult ${expectFile}  "${command}"
  if [[ ${functionName} =~ .*Exp ]]; then
    ${functionName} ${expectFile} ${args}
  elif [ "$(type -t ${functionName})" = "function" ]; then
    exectueFunction  ${expectFile}  "${command}"
  else
    local expectFile=$1
    cat <<EOF >>${expectFile}
send -- "${command}\r"
expect -re "${prompt}"
EOF
  fi
  checkFunctionResult ${expectFile}  "${command}"
}

function insertSideCar() {
  local function=$1
  local funcstr=$(type -a ${function})
  funcstr=${funcstr%\}*}
  funcstr=${funcstr#*\{}
  local cmd=$(trs "$funcstr")
  echo $cmd
}

function genFunctionDeclaration() {
  set +x
  local command=$1
  local functionName=${command%%:*}
  local funcstr=$(type -a ${functionName})
  funcstr=${funcstr#*function}
  funcstr=${funcstr%\}*}
  echo $(trs "$funcstr") ' ; \}'
}

function loadFunctionResult() {
  local expectFile=$1
  local command=$2
  local functionName=${command%%:*}
  functionName=${functionName%%' '*}
  local cmd2=$(genFunctionDeclaration logResult)
  cat <<EOF >>${expectFile}
send -- "function ${cmd2}\r"
expect -re "${prompt}"
EOF
}

function checkFunctionResult(){
  local expectFile=$1
  local command=$2
  local functionName=${command%%:*}
  functionName=${functionName%%' '*}
  cat <<'EOFA' >>${expectFile}
  set original_timeout $timeout
EOFA

  cat <<EOF >>${expectFile}
  set timeout 90
  send -- "logResult ${functionName} \$? \r"
  expect  {
   "${functionName} success" {
      send -- "\r"
    }
    "${functionName} failed" {
         exit 2
    }
    timeout {
     exit 3
     }
}

EOF
  cat <<'EOFB' >>${expectFile}
  set timeout \${original_timeout}
EOFB
}
function declareFunction(){
  local expectFile=$1
  local functionName=$2
  local cmd=$(genFunctionDeclaration ${functionName})
    cat <<EOF >>${expectFile}
send -- "function ${cmd}\r"
expect -re "${prompt}"
EOF
}

function analyzeAndDeclareDependency(){
  set +x
  local expectFile=$1
  local functionName=$2

  eval $(type -a ${functionName} | grep dependency )
  for function in ${dependency}
  do
      type -a ${function} | continue
      declareFunction ${expectFile}  ${function}
  done
  set -x
}

function exectueFunction() {
  local expectFile=$1
  local command=$2
  local functionName=${command%%:*}
  local functionArg=''
  if [[ ${command} =~ .*:.* ]] ;then
    functionArg=${command#*:}
  fi
  command="${functionName}  ${functionArg}"
  declareFunction ${expectFile} ${functionName}
  analyzeAndDeclareDependency ${expectFile} ${functionName}
   #local appendix=$(insertSideCar logResult)
  cat <<EOF >>${expectFile}
send -- "${command}\r "
expect -re "${prompt}"
EOF
}

function changeUser(){
  local mode=$1
  case ${mode} in
  root)
    USER=root
    USER_PASSWORD=${SSH_ROOT_PASSWORD}
    ;;
  suroot|opuser)
    USER=${SSH_USER}
    USER_PASSWORD=${SSH_USER_PASSWORD}
    ;;
  esac
}

function rsyncFileExp(){
  local localFile=$2
  local remotePath=$3

  cat << EOF >> $1
set timeout 1200
send --  "rsync -aqz -e \'ssh  ${SSH_OPTIONS}   \' ${localFile}  ${USER}@${SSH_HOST}:${remotePath}/\r"
expect  {
  "assword: " {
        send -- "${USER_PASSWORD}\r"
      }
   timeout {
      exit  3
   }
}
expect -re "${prompt}"
EOF

}

function scpUpFilesExp() {
  local localFile=$2
  local remotePath=$3


  cat <<EOF >>$1
send -- "scp -r ${localFile} ${USER}@${SSH_HOST}:${remotePath} \r"
expect {
  *sername* {
    send -- "${USER_PASSWORD}\r"
    exp_continue
  }
  *continue* {
    send -- "yes\r"
    exp_continue
  }

  *assword* {
    send -- "${USER_PASSWORD}\r"
  }
  "*Proceed insecurely*" {
    send -- "y\r"
    exp_continue
  }
}
expect -re "${prompt}"

EOF
}

function scpDownFilesExp() {
  local localFile=$2
  local remotePath=$3

  [ -d ${localFile} ] || mkdir -p ${localFile}


  cat <<EOF >>$1
send -- "scp -r {USER}@${SSH_HOST}:${remotePath} ${localFile}  \r"
expect {
  *sername* {
    send -- "${USER_PASSWORD}\r"
    exp_continue
  }
  *continue* {
    send -- "yes\r"
    exp_continue
  }

  *assword* {
    send -- "${USER_PASSWORD}\r"
  }
  "*Proceed insecurely*" {
    send -- "y\r"
    exp_continue
  }
}
expect -re "${prompt}"

EOF
}

function rsyncDownFileExp(){
  local localPath=$2
  local remoteFile=$3
  [ -d ${localFile} ] || mkdir -p ${localFile}
  cat << EOF >> $1
set timeout 1200
send --  "rsync -az -e \'ssh  ${SSH_OPTIONS}   \'  ${USER}@${SSH_HOST}:${remoteFile}/  ${localPath}\r"
expect  {
  "assword: " {
        send -- "${USER_PASSWORD}\r"
      }
   timeout {
      exit  3
   }
}
expect -re "${prompt}"
EOF

}

function rsyncFoldExp(){
  local localFile=$2
  local remotePath=$3

  cat << EOF >> $1
set timeout 1200
send --  "rsync -aqz -e \'ssh  ${SSH_OPTIONS}   \' ${localFile}/  ${USER}@${SSH_HOST}:${remotePath}\r"
expect  {
  "assword: " {
        send -- "${USER_PASSWORD}\r"
      }
   timeout {
      exit  3
   }
}
expect -re "${prompt}"
EOF

}

function rsyncDownFoldExp(){
  local localFile=$2
  local remotePath=$3
  [ -d ${localFile} ] || mkdir -p ${localFile}
  cat << EOF >> $1
send --  "rsync -az -e \'ssh  ${SSH_OPTIONS}   \'  ${USER}@${SSH_HOST}:${remotePath}/  ${localFile}\r"
expect  {
  "assword: " {
        send -- "${USER_PASSWORD}\r"
      }
   timeout {
      exit  3
   }
}
expect -re "${prompt}"
EOF

}