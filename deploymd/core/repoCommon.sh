function genGeneralRepo(){
  [ -d ${workDir}/output/deploy/ ] || mkdir -p ${workDir}/output/deploy
  rsync ${workDir}/template/deploy/CentOS7-ctyun.repo.tpl  ${workDir}/output/deploy/CentOS7-ctyun.repo
  rsync ${workDir}/template/deploy/docker-ce.repo.tpl ${workDir}/output/deploy/docker-ce.repo
}

