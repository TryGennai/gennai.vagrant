#!/bin/sh

echo "in storm."

STORM_VERSION=0.9.4
STORM_TAR_FILE=apache-storm-${STORM_VERSION}.tar.gz

# install check.
if [ -d ${STORM_INSTALL_DIR}/apache-storm-${STORM_VERSION} ] ; then
	echo " - already."
	exit 0
fi

### main

cd /tmp
echo " - download. : ${STORM_TAR_FILE}"
curl -L -O https://archive.apache.org/dist/storm/apache-storm-${STORM_VERSION}/${STORM_TAR_FILE} >/dev/null 2>&1

echo " - instal."
tar zxf ${STORM_TAR_FILE} -C /opt
ln -s /opt/apache-storm-${STORM_VERSION} /opt/storm

echo " - setting."
mkdir -p /data/storm
mkdir -p /opt/storm/logs

sed -i \
	-e "s/^#.*\(storm.zookeeper.servers\):.*/\1:\n  - \"localhost\"/g" \
	-e "s/^#.*\(nimbus.host\):.*/\1: \"localhost\"/g" \
	/opt/storm/conf/storm.yaml

echo "storm.local.dir: /data/storm" >> /opt/storm/conf/storm.yaml

echo " - chown."
chown -R vagrant:vagrant /opt/apache-storm-${STORM_VERSION}
chown -R vagrant:vagrant /data/storm
chown -R vagrant:vagrant /opt/storm/logs

echo " - service."

cp /vagrant/files/storm-nimbus.initd /etc/rc.d/init.d/storm-nimbus
chmod +x /etc/rc.d/init.d/storm-nimbus

cp /vagrant/files/storm-supervisor.initd /etc/rc.d/init.d/storm-supervisor
chmod +x /etc/rc.d/init.d/storm-supervisor

cp /vagrant/files/storm-ui.initd /etc/rc.d/init.d/storm-ui
chmod +x /etc/rc.d/init.d/storm-ui

cp /vagrant/files/storm-logviewer.initd /etc/rc.d/init.d/storm-logviewer
chmod +x /etc/rc.d/init.d/storm-logviewer

chkconfig --add storm-nimbus
chkconfig storm-nimbus on
chkconfig --add storm-supervisor
chkconfig storm-supervisor on
chkconfig --add storm-ui
chkconfig storm-ui off
chkconfig --add storm-logviewer
chkconfig storm-logviewer off

service storm-nimbus start
service storm-supervisor start

# cleaning
rm -rf /tmp/${STORM_TAR_FILE}

exit 0
# EOF
