#!/bin/sh

echo "in kafka."

SCALA_VERSION=2.8.0
KAFKA_VERSION=0.8.0
KAFKA_INSTALL_DIR=/opt
KAFKA_USER=vagrant
KAFKA_GROUP=vagrant
KAFKA_SERVICE=off

# source config and override settings.
if [ -f "/vagrant/files/config.ini" ] ; then
	eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
		-e 's/;.*$//' \
		-e 's/[[:space:]]*$//' \
		-e 's/^[[:space:]]*//' \
		-e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
		< /vagrant/files/config.ini \
		| sed -n -e "/^\[kafka\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`

	if [ ! -z "${install}" -a "${install}" = false ] ; then
		echo " - not install."
		exit 0
	fi

	if [ ! -z "${dir}" ] ;  then
		KAFKA_INSTALL_DIR=${dir}
	fi

	if [ ! -z "${version}" ] ; then
		KAFKA_VERSION=${version}
	fi

	if [ ! -z "${scala}" ] ; then
		SCALA_VERSION=${scala}
	fi

	if [ ! -z "${user}" ] ; then
		KAFKA_USER=${user}
	fi

	if [ ! -z ${group} ] ; then
		KAFKA_GROUP=${group}
	fi

	if [ ! -z "${service}" -a "${service}" = "on" ] ; then
		KAFKA_SERVICE=on
	fi
fi

KAFKA_TAR_FILE=kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tar.gz

# install check
if [ -d "${KAFKA_INSTALL_DIR}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}" ] ; then
	echo " - already."
	exit 0
fi

# user/group check
RESULT=`grep ${KAFKA_GROUP} /etc/group >/dev/null 2>&1`
if [ $? -ne 0 ] ; then
	groupadd ${KAFKA_GROUP}
fi
RESULT=`id ${KAFKA_USER} >/dev/null 2>&1`
if [ $? -ne 0 ] ; then
	useradd -g ${KAFKA_USER} -s /sbin/nologin -M ${KAFKA_USER}
fi


### main

cd /tmp
echo " - download. : ${KAFKA_TAR_FILE}"
curl -L -O https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_TAR_FILE} >/dev/null 2>&1

echo " - install. : ${KAFKA_INSTALL_DIR}"
tar zxf ${KAFKA_TAR_FILE} -C ${KAFKA_INSTALL_DIR}
ln -s ${KAFKA_INSTALL_DIR}/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_INSTALL_DIR}/kafka

echo " - setting."
cp /vagrant/files/kafka.server.properties ${KAFKA_INSTALL_DIR}/kafka/config/server.properties
S_KAFKA_INSTALL_DIR=`echo ${KAFKA_INSTALL_DIR} | sed -e "s/\//\\\\\\\\\//g"`
sed \
	-e "s/__KAFKA_INSTALL_DIR__/${S_KAFKA_INSTALL_DIR}/g" \
	/vagrant/files/kafkaServer > ${KAFKA_INSTALL_DIR}/kafka/bin/kafkaServer
chmod +x ${KAFKA_INSTALL_DIR}/kafka/bin/kafkaServer

mkdir -p /data/kafka
mkdir -p /var/log/kafka

# OUTPUT=/home/${KAFKA_USER}/.bashrc
# echo "" >> ${OUTPUT}
# echo "export KAFKA_HOME=${KAFKA_INSTALL_DIR}/kafka" >> ${OUTPUT}
# echo "export PATH=\${KAFKA_HOME}/bin:\${PATH}" >> ${OUTPUT}

echo " - chown."
chown -R ${KAFKA_USER}:${KAFKA_GROUP} ${KAFKA_INSTALL_DIR}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
chown -R ${KAFKA_USER}:${KAFKA_GROUP} /data/kafka
chown -R ${KAFKA_USER}:${KAFKA_GROUP} /var/log/kafka

echo " - service. : ${KAFKA_SERVICE}"
sed \
	-e "s/__KAFKA_INSTALL_DIR__/${S_KAFKA_INSTALL_DIR}/g" \
	-e "s/__KAFKA_USER__/${KAFKA_USER}/g" \
	/vagrant/files/kafka.initd > /etc/init.d/kafka
chmod +x /etc/init.d/kafka
chkconfig --add kafka
if [ "${KAFKA_SERVICE}" = "on" ] ; then
	chkconfig kafka on
	service kafka start
else
	chkconfig kafka off
fi

# cleaning
rm -rf /tmp/${KAFKA_TAR_FILE}

exit 0
# EOF
