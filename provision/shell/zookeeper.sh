#!/bin/sh

echo "in zookeeper."

ZK_VERSION=3.4.5
ZK_INSTALL_DIR=/opt
ZK_USER=vagrant
ZK_GROUP=vagrant
ZK_SERVICE=off

# source config and override settings.
if [ -f "/vagrant/files/config.ini" ] ; then
	eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
		-e 's/;.*$//' \
		-e 's/[[:space:]]*$//' \
		-e 's/^[[:space:]]*//' \
		-e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
		< /vagrant/files/config.ini \
		| sed -n -e "/^\[zookeeper\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`

	if [ ! -z "${install}" -a "${install}" = "false" ] ; then
		echo " - not install."
		exit 0
	fi

	if [ ! -z "${dir}" ] ; then
		ZK_INSTALL_DIR=${dir}
	fi

	if [ ! -z "${version}" ] ; then
		ZK_VERSION=${version}
	fi

	if [ ! -z "${user}" ] ; then
		ZK_USER=${user}
	fi

	if [ ! -z "${group}" ] ; then
		ZK_GROUP=${group}
	fi

	if [ ! -z "${service}" -a "${service}" = "on" ] ; then
		ZK_SERVICE=${service}
	fi
fi

# install check
if [ -d "${ZK_INSALL_DIR}/zookeeper-${ZK_VERSION}" ] ; then
	echo " - already."
	exit 0
fi

# user/group check
RESULT=`grep ${ZK_GROUP} /etc/group >/dev/null 2>&1`
if [ $? -ne 0 ] ; then
	groupadd ${ZK_GROUP}
fi
RESULT=`id ${ZK_USER} >/dev/null 2>&1`
if [ $? -ne 0 ] ; then
	useradd -g ${ZK_GROUP} -s /sbin/nologin -M ${ZK_USER}
fi

### main

cd /tmp
echo " - download. : zookeeper-${ZK_VERSION}.tar.gz"
curl -L -O http://archive.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz >/dev/null 2>&1

echo " - install. : ${ZK_INSTALL_DIR}"
tar zxf zookeeper-${ZK_VERSION}.tar.gz -C ${ZK_INSTALL_DIR}
ln -s ${ZK_INSTALL_DIR}/zookeeper-${ZK_VERSION} ${ZK_INSTALL_DIR}/zookeeper

echo " - setting."
cp /vagrant/files/zoo.cfg ${ZK_INSTALL_DIR}/zookeeper-${ZK_VERSION}/conf/
mkdir -p /data/zookeeper

OUTPUT=/home/${ZK_USER}/.bashrc
if [ -f ${OUTPUT} ] ; then
	echo "" >> ${OUTPUT}
	echo "export ZOOKEEPER_HOME=${ZK_INSTALL_DIR}/zookeeper" >> ${OUTPUT}
	echo "export PATH=\${ZOOKEEPER_HOME}/bin:\${PATH}" >> ${OUTPUT}
	echo "export ZOO_LOG_DIR=${ZK_INSTALL_DIR}/zookeeper" >> ${OUTPUT}
fi

echo " - chown."
chown -R ${ZK_USER}:${ZK_GROUP} ${ZK_INSTALL_DIR}/zookeeper-${ZK_VERSION}
chown -R ${ZK_USER}:${ZK_GROUP} /data/zookeeper

echo " - service. : ${ZK_SERVICE}"
S_ZK_INSTALL_DIR=`echo ${ZK_INSTALL_DIR} | sed -e "s/\//\\\\\\\\\//g"`
sed \
  -e "s/__ZK_INSTALL_DIR__/${S_ZK_INSTALL_DIR}/g" \
  -e "s/__ZK_USER__/${ZK_USER}/g" \
  /vagrant/files/zookeeper.initd > /etc/init.d/zookeeper
chmod +x /etc/init.d/zookeeper
chkconfig --add zookeeper
if [ "${ZK_SERVICE}" = "on" ] ; then
	chkconfig zookeeper on
	service zookeeper start
else
	chkconfig zookeeper off
fi

# cleaning
rm -rf /tmp/zookeeper-${ZK_VERSION}.tar.gz

exit 0
# EOF
