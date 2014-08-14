#!/bin/sh

echo "in mongod."

MONGO_SERVICE=off

# mode check.
. /vagrant/provision/shell/common.sh
getConfig mongodb

MODE=`getMode`
case ${MODE} in
	"minimum")
		install=false
		service=off
		;;
	*)
		;;
esac

# source config and override settings.
if [ ! -z "${install}" -a "${install}" = "false" ] ; then
	echo " - not install."
	exit 0
fi

if [ ! -z "${service}" -a "${service}" = "on" ] ; then
	MONGO_SERVICE=${service}
fi

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
if [ "${MONGO_SERVICE}" = "on" ] ; then
	chkconfig mongod on
	service mongod start
else
	chkconfig mongod off
fi
