#!/bin/sh

echo "in sample."

# source config and override settings.
if [ -f "/vagrant/config.ini" ] ; then
	eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
		-e 's/;.*$//' \
		-e 's/[[:space:]]*$//' \
		-e 's/^[[:space:]]*//' \
		-e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
		< /vagrant/config.ini \
		| sed -n -e "/^\[common\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`

	if [ -z "${sample}" -o "${sample}" != "yes" ] ; then
		echo " - not install."
		exit 0
	fi
fi

# install check
if [ -d "/home/vagrant/sample" ] ; then
	echo " - already."
	exit
fi

### main

sudo -u vagrant -i git clone https://github.com/siniida/gennai.sample sample > /dev/null 2>&1
sudo -u vagrant -i gungnir -u root -p gennai -f sample/user.q > /dev/null 2>&1

exit 0
# EOF
