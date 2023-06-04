
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base - ctyun.cn
baseurl=http://100.125.0.40/centos/$releasever/os/$basearch/
	http://mirror.centos.org/centos/$releasever/os/$basearch/
gpgcheck=1
failovermethod=priority
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
#released updates 
[updates]
name=CentOS-$releasever - Updates - ctyun.cn
baseurl=http://100.125.0.40/centos/$releasever/updates/$basearch/
	http://mirror.centos.org/centos/$releasever/updates/$basearch/
gpgcheck=1
failovermethod=priority
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras - ctyun.cn
baseurl=http://100.125.0.40/centos/$releasever/extras/$basearch/
	http://mirror.centos.org/centos/$releasever/extras/$basearch/
gpgcheck=1
failovermethod=priority
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus - ctyun.cn
baseurl=http://100.125.0.40/centos/$releasever/centosplus/$basearch/
	http://mirror.centos.org/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
failovermethod=priority
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
