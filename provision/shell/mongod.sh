#!/bin/sh

echo "in mongod."

# install
if [ -f /etc/yum.repos.d/mongodb.repo ] ; then
	echo " - already."
	exit
fi

echo " - add repository."
cp /vagrant/files/mongodb.repo /etc/yum.repos.d/

echo " - install."
yum install -y mongodb-org > /dev/null 2>&1

echo " - service."
chkconfig mongod on
service mongod start

exit 0
# EOF
