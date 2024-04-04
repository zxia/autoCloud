
function createUser(){

  local name=$1
  local password=$2

  # Check if user already exists
  id -u $name &> /dev/null
  if [ $? -eq 0 ]; then
    echo "User $name already exists."
    return 0
  fi

  # Check if user group already exists
  getent group ${name}group &> /dev/null
  if [ $? -ne 0 ]; then
    # If user group doesn't exist, create it
    groupadd ${name}group || return $?
  fi

  # Create user and add to user group
  useradd -g ${name}group -m $name || return $?


  echo "User $name created successfully."
  return 0
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
  -re ${prompt} {
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