#!/bin/sh

echo "in gungnir."

GUNGNIR_SERVER_FILE=gungnir-server-0.0.1-20150814.tar.gz
GUNGNIR_CLIENT_FILE=gungnir-client-0.0.1-20150814.tar.gz
GUNGNIR_VERSION=0.0.1

### main

cd /tmp

echo " - download. : ${GUNGNIR_SERVER_FILE} / ${GUNGNIR_CLIENT_FILE}"
curl -L -O https://s3-ap-northeast-1.amazonaws.com/gennai/${GUNGNIR_SERVER_FILE} >/dev/null 2>&1
curl -L -O https://s3-ap-northeast-1.amazonaws.com/gennai/${GUNGNIR_CLIENT_FILE} >/dev/null 2>&1

echo " - install."

tar zxf ${GUNGNIR_SERVER_FILE} -C /opt
tar zxf ${GUNGNIR_CLIENT_FILE} -C /opt

ln -s /opt/gungnir-server-${GUNGNIR_VERSION} /opt/gungnir-server
ln -s /opt/gungnir-client-${GUNGNIR_VERSION} /opt/gungnir-client

echo " - setting."

sed -i \
	-e "s/#.*\(storm.cluster.mode\):.*/\1: \"distributed\"/g" \
	/opt/gungnir-server/conf/gungnir.yaml

OUTPUT=/home/vagrant/.bashrc
echo "" >> ${OUTPUT}
echo "export GUNGNIR_SERVER_HOME=/opt/gungnir-server" >> ${OUTPUT}
echo "export GUNGNIR_CLIENT_HOME=/opt/gungnir-client" >> ${OUTPUT}
echo "export PATH=\${GUNGNIR_CLIENT_HOME}/bin:\${PATH}" >> ${OUTPUT}

echo " - chown."
chown -R vagrant:vagrant /opt/gungnir-server-${GUNGNIR_VERSION}
chown -R vagrant:vagrant /opt/gungnir-client-${GUNGNIR_VERSION}

echo " - service."
cp /vagrant/files/gungnir-server.initd /etc/rc.d/init.d/gungnir-server
cp /vagrant/files/tuple-store-server.initd /etc/rc.d/init.d/tuple-store-server
chmod +x /etc/rc.d/init.d/gungnir-server /etc/rc.d/init.d/tuple-store-server

chkconfig --add gungnir-server
chkconfig gungnir-server on
chkconfig --add tuple-store-server
chkconfig tuple-store-server on

service gungnir-server start
service tuple-store-server start

# cleanup
rm -rf /tmp/gungnir*

exit 0
# EOF
