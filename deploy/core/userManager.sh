function  createUser(){

  local name=$1
  local password=$2

  id -u $name  &&  return $?

  groupadd ${name}group  || return $?
  useradd -g ${name}group  -m ${name} || return $?

}

function changeUserPasswordExp(){
  local user=$2
  local passwd=$3

  cat << EOF >> $1
set force_conservative 1
set timeout 30
send -- "passwd ${user} \r "
expect  {
   "assword:*?" {
    send -- "${passwd}\r"
  }
  timeout {
    exit 2
  }
}

expect  {
   "Retype" {
    send -- "${passwd}\r"
  }
  -re "${prompt}" {
   send -- "\r"
  }
  timeout {
    exit 2
  }
}

expect  {
   "all authentication tokens updated successfully" {
    exit 0
  }
  timeout {
    exit 2
  }
}

EOF
}