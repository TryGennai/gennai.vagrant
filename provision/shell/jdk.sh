#!/bin/sh

USER=vagrant

echo "in jdk."

if [ -d /usr/java/jdk1.7.0_71 ] ; then
	echo " - already."
	exit 0
fi

cd /tmp
echo " - download."
curl -L -O -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.rpm >/dev/null 2>&1

echo " - install."
rpm -ivh ./jdk-7u80-linux-x64.rpm >/dev/null 2>&1
ln -s /usr/java/default/bin/jps /usr/bin/jps

# environment
OUTPUT=/home/${USER}/.bashrc
echo >> ${OUTPUT}
echo "export JAVA_HOME=/usr/java/default" >> ${OUTPUT}
echo "export PATH=\${JAVA_HOME}/bin:\${PATH}" >> ${OUTPUT}

# cleanup
rm /tmp/jdk-7u80-linux-x64.rpm

#EOF
