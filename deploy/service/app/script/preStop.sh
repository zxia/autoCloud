#!/bin/bash

# NACOS参数, 通过环境变量替换
#NACOS_SERVER="NACOS_SERVER_ADDRESS"
#NACOS_PORT="NACOS_PORT_NUMBER"
#NACOS_USERNAME="nacos"
#NACOS_PASSWD="nacos"
#NACOS_NAMESPACE="k8sA"
#NACOS_CLUSTER="k8sA"
#NACOS_GROUP="DEFAULT_GROUP"



# 获取 Token 函数
function getToken() {
    local tokenResponse
    tokenResponse=$(curl -s --location --request POST "http://${NACOS_SERVER}:${NACOS_PORT}/nacos/v1/auth/users/login" \
                    --form "username=${NACOS_USERNAME}" \
                    --form "password=${NACOS_PASSWD}")

    accessToken=$(echo "$tokenResponse" | grep -o '"accessToken":"[^"]*"' | awk -F ':"' '{print $2}' | tr -d '"')
    echo "${accessToken}"
}

# 更新实例信息函数
function updateInstance() {
    local accessToken="$1"
    local myPodIP=$2
    local myPodPort=$3
    local enabled=$4
    local instanceUrl="http://${NACOS_SERVER}:${NACOS_PORT}/nacos/v1/ns/instance"
    local ephemeral="true"
    local weight="1"
    local instanceResponse

    instanceResponse=$(curl -s -X PUT "${instanceUrl}?accessToken=${accessToken}&serviceName=${serviceName}&groupName=${NACOS_GROUP}&namespaceId=${NACOS_NAMESPACE}&ip=${myPodIP}&clusterName=${NACOS_CLUSTER}&port=${myPodPort}&ephemeral=${ephemeral}&weight=${weight}&enabled=${enabled}")

    # 检查实例信息是否成功注册
    if [[ ! $instanceResponse =~ "\"code\":[[:space:]]*200" ]]; then
        echo "Error: Failed to register instance with Nacos."
        return 1
    fi

    echo "Instance registered successfully with Nacos."
}

function updateServiceInstance(){

    local serviceName=$1
    local port=$2
    local enabled=$3  # true or false

    # get IP
    local myPodIP=$(cat /etc/hosts | grep ${serviceName} | awk '{print $1}')

      # 获取 Token
    token=$(getToken)

    # 检查 Token 是否为空
    if [ -z "$token" ]; then
        echo "Error: Access token is empty."
        return 1
    fi

    # 更新实例信息
    updateInstance "$token" "${myPodIP}" "${port}" "${enabled}"
}

#force service instance offline
updateServiceInstance $1 $2 false

#wait for a while
sleep 60
