workDir=$(dirname ${PWD}/$(dirname $0))
exampleDir=${workDir}/example/
function genServicePackages() {
  local inputDir=$1
  files=$( ls ${inputDir}/*.ini)

  for file in $files
  do
     bash ${workDir}/serviceGenerator.sh  -f $file
  done

}

function testService(){
  local package=$1
  helm install --dry-run product-test --disable-openapi-validation \
   -f ${workDir}/output/data/${package}/userValues.yaml\
    ${workDir}/output/helm/${package}/
}

function deployService(){
  local package=$1
  local version=$2
  helm upgrade --install  ${package}${version}  \
   -f ${workDir}/output/data/${package}${version}/userValues.yaml  \
    ${workDir}/output/helm/${package}/
}
function oneInAll(){
  local nodes=$1
  bash testBook.sh -c
  rm -rf ./output
  bash testBook.sh -g 1
  bash testBook.sh -a v1
  bash testBook.sh -l "$nodes"
  bash testBook.sh -d "reviews-app v2"
  bash testBook.sh -d "reviews-app v3"

}

function testCase2(){
  local targetDir=${workDir}/output/data/reviews-network
  local fromDir=${workDir}/example/bookinfo/output/data/reviews-network

  rm -rf ${targetDir}/userValues.yaml
  cp -rf ${fromDir}/userValues.yaml.circuitBreak  ${targetDir}/userValues.yaml
  bash testBook.sh -d "reviews-network"
}

function testCase3(){
  local network=rating-network
  local targetDir=${workDir}/output/data/${network}
  local fromDir=${workDir}/example/bookinfo/output/data/${network}

  rm -rf ${targetDir}/userValues.yaml
  cp -rf ${fromDir}/userValues.yaml.abort  ${targetDir}/userValues.yaml
  bash testBook.sh -d "${network}"
}

function listCases(){
  cat <<EOF
case1:  verify the timeout
case2:  verify the circuit break
case3:   verify the fault injection
EOF
}
while getopts "a:bcd:o:r:l:gt:" opt; do
  case ${opt} in
  a)
    mode=all
    pkg="rating product-pager details reviews "
    version=${OPTARG}
    ;;
  c)
    mode=clear
    pkg="rating product-pager details reviews "
    ;;
  g)
    mode=gen
    pkg=${exampleDir}/bookinfo/input
    ;;
  t)
    mode=test
    pkg=${OPTARG}
    ;;
  d)
    mode=deployment
    pkg=${OPTARG}
    ;;
  l)
    mode=label
    pkg="rating product-pager details reviews "
    nodes="${OPTARG}"
    ;;
  b)
    mode=bash
    pkg=${OPTARG}
    ;;
  o)
    mode=oneinall
    pkg=${OPTARG}
    ;;
  r)
    mode=run
    pkg=${OPTARG}
    ;;
  \? | *)
    echo "Wrong options! ${opt}"
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

case ${mode} in
gen)
  genServicePackages ${pkg}
  cp -r ${workDir}/example/bookinfo/output .
  ;;
test)
  testService ${pkg}
  ;;
bash)
  eval "${pkg}"
  ;;
deployment)
  deployService ${pkg}
  ;;
all )
  for service in ${pkg}
  do
      deployService ${service}-app  ${version}
      deployService ${service}-network
  done
  ;;
run )
   eval test"${pkg^}"
  ;;
label)
  for service in ${pkg}
  do
      kubectl label nodes ${nodes} ${service}=${service} --overwrite
  done
  ;;
clear)
  helm ls | egrep 'detail|product|rating|review' | awk  '{ print $1 }' | xargs helm uninstall
  ;;
oneinall)
  oneInAll "${pkg}"
  ;;
*)
  echo " unsupported mode"
  ;;
esac