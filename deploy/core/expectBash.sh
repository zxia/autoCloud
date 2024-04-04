
###################################################
##################Base MCAS Expect ################
###################################################
function executeBashExpect(){
 local expectFile=$1
 cat << EOF >>  ${expectFile}
spawn ${SHELL}
match_max 100000
set timeout ${expectTimeout}
EOF
changeUser ${EXECUTED_PERMISSION}
executeCommand ${expectFile} "${command}"

cat << EOF >> ${expectFile}

set timeout 1
expect  {
    -re ${prompt} {
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