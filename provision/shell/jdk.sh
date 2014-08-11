#!/bin/sh

USER=vagrant

echo "in jdk."

if [ -d /usr/java/jdk1.6.0_45 ] ; then
	echo " - already."
	exit 0
fi

cd /tmp
echo " - download."
curl -L -O https://s3-ap-northeast-1.amazonaws.com/gennai/binary/jdk-6u45-linux-x64-rpm.bin >/dev/null 2>&1

echo " - install."
chmod +x ./jdk-6u45-linux-x64-rpm.bin
./jdk-6u45-linux-x64-rpm.bin >/dev/null 2>&1

# environment
OUTPUT=/home/${USER}/.bashrc
echo >> ${OUTPUT}
echo "export JAVA_HOME=/usr/java/default" >> ${OUTPUT}
echo "export PATH=\${JAVA_HOME}/bin:\${PATH}" >> ${OUTPUT}

# cleanup
rm /tmp/jdk-6u45-linux-x64-rpm.bin
rm /tmp/jdk-6u45-linux-amd64.rpm
rm sun-javadb-*.rpm

#EOF
