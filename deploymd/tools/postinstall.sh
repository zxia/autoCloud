function installShc() {
  cp -r /allinone/installpackage/shc-4.0.3.tar.gz  /tmp
  tar xvzf /tmp/shc-4.0.3.tar.gz -C /tmp
  cd /tmp/shc-4.0.3
  ./configure
  make
  make install
}
installShc
apt -y install dos2unix
alias cli="bash /deploy/dp.sh"


