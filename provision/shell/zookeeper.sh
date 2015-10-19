#!/bin/sh

echo "in zookeeper."

ZK_VERSION=3.4.6

# install check
if [ -d "/opt/zookeeper-${ZK_VERSION}" ] ; then
	echo " - already."
	exit 0
fi

### main

cd /tmp
echo " - download. : zookeeper-${ZK_VERSION}.tar.gz"
curl -L -O http://archive.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz >/dev/null 2>&1

echo " - install."
tar zxf zookeeper-${ZK_VERSION}.tar.gz -C /opt
ln -s /opt/zookeeper-${ZK_VERSION} /opt/zookeeper

echo " - setting."
mkdir -p /data/zookeeper
cp -p /opt/zookeeper-${ZK_VERSION}/conf/{zoo_sample.cfg,zoo.cfg}
sed -i \
	-e "s/^\(dataDir\)=.*/\1=\/data\/zookeeper/g" \
	-e "s/^#\(autopurge.snapRetainCount=.*\)/\1/g" \
	-e "s/^#\(autopurge.purgeInterval=.*\)/\1/g" \
	/opt/zookeeper-${ZK_VERSION}/conf/zoo.cfg

OUTPUT=/home/vagrant/.bashrc
if [ -f ${OUTPUT} ] ; then
	echo "" >> ${OUTPUT}
	echo "export ZOOKEEPER_HOME=/opt/zookeeper" >> ${OUTPUT}
	echo "export PATH=\${ZOOKEEPER_HOME}/bin:\${PATH}" >> ${OUTPUT}
	echo "export ZOO_LOG_DIR=/opt/zookeeper" >> ${OUTPUT}
fi

echo " - chown."
chown -R vagrant:vagrant /opt/zookeeper-${ZK_VERSION}
chown -R vagrant:vagrant /data/zookeeper

echo " - service."
cp /vagrant/files/zookeeper.initd /etc/init.d/zookeeper
chmod +x /etc/init.d/zookeeper
chkconfig --add zookeeper
chkconfig zookeeper on
service zookeeper start

# cleaning
rm -rf /tmp/zookeeper-${ZK_VERSION}.tar.gz

exit 0
# EOF
