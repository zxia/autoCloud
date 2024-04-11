
###################################################
##################Base Docker Expect ################
###################################################

SSH_OPTIONS="-o StrictHostKeyChecking=no -o ConnectTimeout=30 "
#permission [root, opuser,suroot]
EXECUTED_PERMISSION="root"

function executeDockerExpect(){
 local expectFile=$1
 changeUser ${EXECUTED_PERMISSION}
 cat << EOF >>  ${expectFile}
spawn  ssh  ${SSH_OPTIONS}  ${USER}@${SSH_HOST}
expect  {
  "assword: " {
        send -- "${USER_PASSWORD}\r"
        exp_continue
      }
  "continue connecting (yes/no)" {
       send -- "yes\r"
       exp_continue
  }
  "Permission denied"  {
      exit 10
  }
   -re ${prompt} {
     send -- "\r"
   }
   timeout {
      exit  3
   }
}
EOF
  if [  ${EXECUTED_PERMISSION} = 'suroot' ]; then

    cat << EOF >>  ${expectFile}
send -- "su -\r"
expect "assword"
send -- "${SSH_ROOT_PASSWORD}\r"
expect -re ${prompt}
EOF
  fi

     cat << EOF >>  ${expectFile}
send -- "docker exec -it ${DOCKER_NAME} bash  -\r"
expect -re ${prompt}
EOF

  executeCommand ${expectFile} "${command}"

cat << EOF >> ${expectFile}

expect  {
    -re  ${prompt} {
     send -- "exit\r"
	   expect "*"
     send -- "exit\r"
   }
   timeout {
     send -- "exit\r"
         expect "*"
     send -- "exit\r"
   }
   eof {
     exit 0
   }
}

exit 0
EOF
}

