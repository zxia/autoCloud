function genSSHkeyExp(){

  [ -d ${localFile} ] || mkdir -p ${localFile}
  cat << EOF >> $1
send --  "ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519\r"
expect -re ${prompt}
EOF
}

function copySSHKeyExp(){
  local hosts="$(echo $2 | tr -d \')"
  for host in ${hosts}
  do
  cat << EOF >> $1
send --  "ssh-copy-id ${host}\r"
expect "assword"
send -- "${SSH_ROOT_PASSWORD}\r"
expect -re ${prompt}
EOF
  done
}

