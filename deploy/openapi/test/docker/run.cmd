   docker run -it -p 8000:8000 --name openapi   -v /opt/deployment/autoCloud/deploymd/:/deploy gmct.storage.com/library/openapi:v1.0.0.0112  bash
  docker run --detach   --publish 8000:8000    --name openapi --env work_dir="/deploy/"  --restart always    --volume /largeDisk/openapi/lab:/deploy/lab   --volume /largeDisk/openapi/output:/deploy/output gmct.storage.com/library/openapi:v4.0.0.01025 bash /deploy/openapi/start.sh