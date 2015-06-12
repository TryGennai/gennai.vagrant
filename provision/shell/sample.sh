#!/bin/sh

echo "in sample."

. /vagrant/provision/shell/common.sh
getConfig common

# source config and override settings.
if [ -z "${sample}" -o "${sample}" != "yes" ] ; then
	echo " - not install."
	exit 0
fi

# install check
if [ -d "/home/vagrant/sample" ] ; then
	echo " - already."
	exit
fi

### main

sudo -u vagrant -i git clone https://github.com/trygennai/gennai.sample sample > /dev/null 2>&1
sudo -u vagrant -i gungnir -u root -p gennai -f sample/user.q > /dev/null 2>&1

exit 0
# EOF
