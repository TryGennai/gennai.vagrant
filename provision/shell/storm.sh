#!/bin/sh

echo "in storm."

STORM_VERSION=0.9.2
STORM_TAR_FILE=apache-storm-${STORM_VERSION}-incubating.tar.gz
STORM_INSTALL_DIR=/opt
STORM_USER=vagrant
STORM_GROUP=vagrant
STORM_SERVICE=off

export JAVA_HOME=/usr/java/default
export PATH=${JAVA_HOME}/bin:${PATH}

# mode check.
. /vagrant/provision/shell/common.sh
getConfig common
getConfig storm

STORM_MODE=`getMode`
case ${STORM_MODE} in
	"distributed")
		;;
	*)
		install=false
		service=off
esac

# source config and override settings.
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

# install check.
if [ -d ${STORM_INSTALL_DIR}/apache-storm-${STORM_VERSION}-incubating ] ; then
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

cd /tmp
echo " - download. : ${STORM_TAR_FILE}"
curl -L -O https://archive.apache.org/dist/incubator/storm/apache-storm-${STORM_VERSION}-incubating/${STORM_TAR_FILE} >/dev/null 2>&1

echo " - instal. : ${STORM_INSTALL_DIR}"
tar zxf ${STORM_TAR_FILE} -C ${STORM_INSTALL_DIR}
ln -s ${STORM_INSTALL_DIR}/apache-storm-${STORM_VERSION}-incubating ${STORM_INSTALL_DIR}/storm

echo " - setting."
cp /vagrant/files/storm.yaml ${STORM_INSTALL_DIR}/storm/conf/
mkdir -p /data/storm
mkdir -p /opt/storm/logs

echo " - chown."
chown -R ${STORM_USER}:${STORM_GROUP} ${STORM_INSTALL_DIR}/apache-storm-${STORM_VERSION}-incubating
chown -R ${STORM_USER}:${STORM_GROUP} /data/storm
chown -R ${STORM_USER}:${STORM_GROUP} /opt/storm/logs

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

sed \
	-e "s/__STORM_INSTALL_DIR__/${S_STORM_INSTALL_DIR}/g" \
	-e "s/__STORM_USER__/${STORM_USER}/g" \
	/vagrant/files/storm-logviewer.initd > /etc/rc.d/init.d/storm-logviewer
chmod +x /etc/rc.d/init.d/storm-logviewer

chkconfig --add storm-nimbus
chkconfig --add storm-supervisor
chkconfig --add storm-ui
chkconfig --add storm-logviewer

if [ "${STORM_SERVICE}" = "on" ] ; then
	chkconfig storm-nimbus on
	service storm-nimbus start
	chkconfig storm-supervisor on
	service storm-supervisor start
else
	chkconfig storm-nimbus off
	chkconfig storm-supervisor off
fi

chkconfig storm-ui off
chkconfig storm-logviewer off

# cleaning
rm -rf /tmp/${STORM_TAR_FILE}

exit 0
# EOF
