#!/bin/sh

echo "in gungnir."

GUNGNIR_SERVER_FILE=gungnir-server-0.0.1-20150612.tar.gz
GUNGNIR_CLIENT_FILE=gungnir-client-0.0.1-20150612.tar.gz
GUNGNIR_VERSION=0.0.1
GUNGNIR_INSTALL_DIR=/opt
GUNGNIR_USER=vagrant
GUNGNIR_GROUP=vagrant
GUNGNIR_SERVICE=off

. /vagrant/provision/shell/common.sh
getConfig common
getConfig gungnir

# source config and override settings.
if [ ! -z "${install}" -a "${install}" = false ] ; then
	echo " - not install."
	exit 0
fi

if [ ! -z "${dir}" ] ; then
	GUNGNIR_INSTALL_DIR=${dir}
fi

if [ ! -z "${user}" ] ; then
	GUNGNIR_USER=${user}
fi

if [ ! -z "${group}" ] ; then
	GUNGNIR_GROUP=${group}
fi

if [ ! -z "${service}" -a "${service}" = "on" ] ; then
	GUNGNIR_SERVICE=${service}
fi

# install check
if [ -d "${GUNGNIR_INSTALL_DIR}/gungnir-server" ] ; then
	echo " - already."
	exit
fi

# user/group check
RESULT=`grep ${GUNGNIR_GROUP} /etc/group >/dev/null 2>&1`
if [ $? -ne 0 ] ; then
	groupadd ${GUNGNIR_GROUP}
fi
RESULT=`id ${GUNGNIR_GROUP} >/dev/null 2>&1`
if [ $? -ne 0 ] ; then
	useradd -g ${GUNGNIR_GROUP} -s /sbin/nologin -M ${GUNGNIR_USER}
fi

### main

cd /tmp

echo " - download. : ${GUNGNIR_SERVER_FILE} / ${GUNGNIR_CLIENT_FILE}"
curl -L -O https://s3-ap-northeast-1.amazonaws.com/gennai/${GUNGNIR_SERVER_FILE} >/dev/null 2>&1
curl -L -O https://s3-ap-northeast-1.amazonaws.com/gennai/${GUNGNIR_CLIENT_FILE} >/dev/null 2>&1

echo " - install. : ${GUNGNIR_INSTALL_DIR}"

tar zxf ${GUNGNIR_SERVER_FILE} -C ${GUNGNIR_INSTALL_DIR}
tar zxf ${GUNGNIR_CLIENT_FILE} -C ${GUNGNIR_INSTALL_DIR}

ln -s ${GUNGNIR_INSTALL_DIR}/gungnir-server-${GUNGNIR_VERSION} ${GUNGNIR_INSTALL_DIR}/gungnir-server
ln -s ${GUNGNIR_INSTALL_DIR}/gungnir-client-${GUNGNIR_VERSION} ${GUNGNIR_INSTALL_DIR}/gungnir-client

echo " - setting."

# mode check.
MODE=`getMode`
cp /vagrant/files/gungnir.yaml.${MODE} ${GUNGNIR_INSTALL_DIR}/gungnir-server/conf/gungnir.yaml

OUTPUT=/home/${GUNGNIR_USER}/.bashrc
echo "" >> ${OUTPUT}
echo "export GUNGNIR_SERVER_HOME=${GUNGNIR_INSTALL_DIR}/gungnir-server" >> ${OUTPUT}
echo "export GUNGNIR_CLIENT_HOME=${GUNGNIR_INSTALL_DIR}/gungnir-client" >> ${OUTPUT}
echo "export PATH=\${GUNGNIR_CLIENT_HOME}/bin:\${PATH}" >> ${OUTPUT}

echo " - chown."
chown -R ${GUNGNIR_USER}:${GUNGNIR_GROUP} ${GUNGNIR_INSTALL_DIR}/gungnir-server-${GUNGNIR_VERSION}
chown -R ${GUNGNIR_USER}:${GUNGNIR_GROUP} ${GUNGNIR_INSTALL_DIR}/gungnir-client-${GUNGNIR_VERSION}

echo " - service. : ${GUNGNIR_SERVICE}"
S_GUNGNIR_INSTALL_DIR=`echo ${GUNGNIR_INSTALL_DIR} | sed -e "s/\//\\\\\\\\\//g"`
sed \
	-e "s/__GUNGNIR_INSTALL_DIR__/${S_GUNGNIR_INSTALL_DIR}/g" \
	-e "s/__GUNGNIR_USER__/${GUNGNIR_USER}/g" \
	/vagrant/files/gungnir-server.initd > /etc/rc.d/init.d/gungnir-server
sed \
	-e "s/__GUNGNIR_INSTALL_DIR__/${S_GUNGNIR_INSTALL_DIR}/g" \
	-e "s/__GUNGNIR_USER__/${GUNGNIR_USER}/g" \
	/vagrant/files/tuple-store-server.initd > /etc/rc.d/init.d/tuple-store-server
chmod +x /etc/rc.d/init.d/gungnir-server /etc/rc.d/init.d/tuple-store-server
chkconfig --add gungnir-server
chkconfig --add tuple-store-server
if [ "${GUNGNIR_SERVICE}" = "on" ] ; then
	chkconfig gungnir-server on
	service gungnir-server start
	if [ "${MODE}" = "distributed" ] ; then
		chkconfig tuple-store-server on
		service tuple-store-server start
	else
		chkconfig tuple-store-server off
	fi
else
	chkconfig gungnir-server off
fi

# cleanup
rm -rf /tmp/gungnir*

exit 0
# EOF
