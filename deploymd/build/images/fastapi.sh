function genFastapiDockerFile(){
  local type=fastapi
  local dockerPath=${workDir}/output/docker/${type}
  local proxy=${BUILD_DOCKER_PROXY}
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')

  cat << EOF > ${dockerPath}/dockerfile
FROM ${HARBOR_URI}/library/cloudfactory:v3.0.0.0926
ENV https_proxy=http://${proxy}
ENV http_proxy=http://${proxy}
WORKDIR /code
RUN  pip install --upgrade pip
COPY ./files/openapi/build/requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt
COPY ./files/openapi  /code/openapi
COPY ./files/service  /code/service
CMD ["python", "/code/openapi/main.py"]
EOF

}
function prepareFastapiDockerfile(){
  local type=fastapi
  local dockerPath=${workDir}/output/docker/${type}/files
  [ -d ${workDir}/output/docker/${type} ] && rm rf ${workDir}/output/docker/${type}
  [ -d ${dockerPath} ] || mkdir ${dockerPath}

  cp -r ${workDir}/openapi  ${dockerPath}/
  cp -r ${workDir}/service ${dockerPath}/
}

