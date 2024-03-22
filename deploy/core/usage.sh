
function usage() {
  cat <<EOF
 cloud shell system
EOF
}

function commandLine() {
  functions=$(grep "function " ${rootDir}/setupK8s.sh | grep -v "#" | awk '{ split($2,a,"(",seps); print "     "a[1]}' | sort)
  cat <<EOF
Welcome to the 5GMC HOST Controller Command Line GUI
the supported commmand are :
${functions}

####################################################
EOF
}
