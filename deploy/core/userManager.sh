
function createUser(){

  local name=$1
  local password=$2

  # 检查用户是否已存在
  id -u $name &> /dev/null
  if [ $? -eq 0 ]; then
    echo "用户 $name 已存在"
    return 1
  fi

  # 检查用户组是否已存在
  getent group ${name}group &> /dev/null
  if [ $? -ne 0 ]; then
    # 如果用户组不存在，则创建用户组
    groupadd ${name}group || { echo "无法创建用户组 ${name}group"; return 1; }
  fi

  # 创建用户并将其添加到用户组
  useradd -g ${name}group -m $name || { echo "无法创建用户 $name"; return 1; }

  # 设置用户密码
  echo "$name:$password" | chpasswd || { echo "无法设置用户 $name 的密码"; return 1; }

  echo "用户 $name 创建成功"
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