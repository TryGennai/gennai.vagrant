#!/bin/sh

echo "in kafka."

SCALA_VERSION=2.10
KAFKA_VERSION=0.8.2.1
KAFKA_TAR_FILE=kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

# install check
if [ -d "/opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}" ] ; then
	echo " - already."
	exit 0
fi

### main

cd /tmp
echo " - download. : ${KAFKA_TAR_FILE}"
curl -L -O https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_TAR_FILE} >/dev/null 2>&1

echo " - install."
tar zxf ${KAFKA_TAR_FILE} -C /opt
ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

echo " - setting."
sed -i \
	-e "s/\(log\.dirs\)=.*/\1=\/data\/kafka/g" \
	/opt/kafka/config/server.properties
cp /vagrant/files/kafkaServer /opt/kafka/bin/kafkaServer
chmod +x /opt/kafka/bin/kafkaServer
mkdir -p /data/kafka


echo " - chown."
chown -R vagrant:vagrant /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
chown -R vagrant:vagrant /data/kafka

echo " - service."
cp /vagrant/files/kafka.initd /etc/init.d/kafka
chmod +x /etc/init.d/kafka
chkconfig --add kafka
chkconfig kafka on
service kafka start

# cleaning
rm -rf /tmp/${KAFKA_TAR_FILE}

exit 0
# EOF
