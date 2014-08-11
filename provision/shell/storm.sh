#!/bin/sh

echo "in storm."

STORM_VERSION=0.9.0.1
STORM_TAR_FILE=storm-${STORM_VERSION}.tar.gz
STORM_INSTALL_DIR=/opt
STORM_USER=vagrant
STORM_GROUP=vagrant
STORM_SERVICE=off

# mode check.
. /vagrant/provision/shell/common.sh
STORM_MODE=`getMode`
if [ "${STORM_MODE}" = "local" ] ; then
	install=false
	service=off
fi

# source config and override settings.
if [ -f "/vagrant/files/config.ini" ] ; then
	eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
		-e 's/;.*$//' \
		-e 's/[[:space:]]*$//' \
		-e 's/^[[:space:]]*//' \
		-e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
		< /vagrant/files/config.ini \
		| sed -n -e "/^\[storm\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`

	if [ ! -z "${install}" -a "${install}" = "false" ] ; then
		echo " - not install."
		exit 0
	fi

	if [ ! -z "${dir}" ] ; then
		STORM_INSTALL_DIR=${dir}
	fi

	if [ ! -z "${version}" ] ; then
		STORM_VERSION=${version}
	fi

	if [ ! -z "${user}" ] ; then
		STORM_USER=${user}
	fi

	if [ ! -z "${group}" ] ; then
		STORM_GROUP=${group}
	fi

	if [ ! -z "${service}" -a "${service}" = "on" ] ; then
		STORM_SERVICE=${service}
	fi
fi

# install check.
if [ -d ${STORM_INSTALL_DIR}/storm-${STORM_VERSION} ] ; then
	echo " - already."
	exit 0
fi

# user/group check
RESULT=`grep ${STORM_GROUP} /etc/group >/dev/null 2>&1`
if [ $? -ne 0 ] ; then
	groupadd ${STORM_GROUP}
fi
RESULT=`id ${STORM_USER} >/dev/null 2>&1`
if [ $? -ne 0 ] ; then
	useradd -g ${STORM_GROUP} -s /sbin/nologin -M ${STORM_USER}
fi

### main

echo " - packages install."
yum install -y gcc gcc-c++ git autoconf libtool libuuid-devel >/dev/null 2>&1

# zeromq
echo " - zeromq."
if [ ! -d /usr/local/src/zeromq-2.1.7 ] ; then
	cd /tmp
	curl -L -O https://s3-ap-northeast-1.amazonaws.com/gennai/binary/zeromq-2.1.7.tar.gz >/dev/null 2>&1
	tar zxf zeromq-2.1.7.tar.gz -C /usr/local/src
	cd /usr/local/src/zeromq-2.1.7
	./autogen.sh >/dev/null 2>&1
	./configure >/dev/null 2>&1
	make >/dev/null 2>&1
	make install >/dev/null 2>&1
else
	echo " -- already."
fi

# jzmq
echo " - jzmq."
if [ ! -d /usr/local/src/jzmq ] ; then
	cd /tmp
	curl -L -O https://s3-ap-northeast-1.amazonaws.com/gennai/binary/jzmq2.tar.gz >/dev/null 2>&1
	tar zxf jzmq2.tar.gz -C /usr/local/src
	cd /usr/local/src/jzmq
	./autogen.sh >/dev/null 2>&1
	./configure >/dev/null 2>&1
	make >/dev/null 2>&1
	make install >/dev/null 2>&1
else
	echo " -- already."
fi

cd /tmp
echo " - download. : ${STORM_TAR_FILE}"
curl -L -O https://s3-ap-northeast-1.amazonaws.com/gennai/binary/${STORM_TAR_FILE} >/dev/null 2>&1

echo " - instal. : ${STORM_INSTALL_DIR}"
tar zxf ${STORM_TAR_FILE} -C ${STORM_INSTALL_DIR}
ln -s ${STORM_INSTALL_DIR}/storm-${STORM_VERSION} ${STORM_INSTALL_DIR}/storm

echo " - setting."
cp /vagrant/files/storm.yaml ${STORM_INSTALL_DIR}/storm/conf/
mkdir -p /var/log/storm
mkdir -p /var/run/storm

echo " - chown."
chown -R ${STORM_USER}:${STORM_GROUP} ${STORM_INSTALL_DIR}/storm-${STORM_VERSION}
chown -R ${STORM_USER}:${STORM_GROUP} /var/log/storm
chown -R ${STORM_USER}:${STORM_GROUP} /var/run/storm

echo " - service. : ${STORM_SERVICE}"
S_STORM_INSTALL_DIR=`echo ${STORM_INSTALL_DIR} | sed -e "s/\//\\\\\\\\\//g"`

sed \
	-e "s/__STORM_INSTALL_DIR__/${S_STORM_INSTALL_DIR}/g" \
	-e "s/__STORM_USER__/${STORM_USER}/g" \
	/vagrant/files/storm-nimbus.initd > /etc/rc.d/init.d/storm-nimbus
chmod +x /etc/rc.d/init.d/storm-nimbus

sed \
	-e "s/__STORM_INSTALL_DIR__/${S_STORM_INSTALL_DIR}/g" \
	-e "s/__STORM_USER__/${STORM_USER}/g" \
	/vagrant/files/storm-supervisor.initd > /etc/rc.d/init.d/storm-supervisor
chmod +x /etc/rc.d/init.d/storm-supervisor

sed \
	-e "s/__STORM_INSTALL_DIR__/${S_STORM_INSTALL_DIR}/g" \
	-e "s/__STORM_USER__/${STORM_USER}/g" \
	/vagrant/files/storm-ui.initd > /etc/rc.d/init.d/storm-ui
chmod +x /etc/rc.d/init.d/storm-ui

chkconfig --add storm-nimbus
chkconfig --add storm-supervisor
chkconfig --add storm-ui

if [ "${STORM_SERVICE}" = "on" ] ; then
	chkconfig storm-nimbus on
	service storm-nimbus start
	chkconfig storm-supervisor on
	service storm-supervisor start
else
	chkconfig storm-nimbus off
	chkconfig storm-supervisor off
fi

# cleaning
rm -rf /tmp/zeromq-2.1.7.tar.gz
rm -rf /tmp/jzmq2.tar.gz
rm -rf /tmp/${STORM_TAR_FILE}

exit 0
# EOF
