#!/bin/sh

echo "in mongod."

MONGO_SERVICE=off

# source config and override settings.
if [ -f "/vagrant/files/config.ini" ] ; then
	eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
		-e 's/;.*$//' \
		-e 's/[[:space:]]*$//' \
		-e 's/^[[:space:]]*//' \
		-e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
		< /vagrant/files/config.ini \
		| sed -n -e "/^\[mongodb\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`

	if [ ! -z "${install}" -a "${install}" = "false" ] ; then
		echo " - not install."
		exit 0
	fi
	if [ ! -z "${service}" -a "${service}" = "on" ] ; then
		MONGO_SERVICE=${service}
	fi
fi

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
