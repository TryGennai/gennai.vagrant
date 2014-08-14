#!/bin/sh

DEFAULT_MODE=distributed

function getMode() {
	if [ -z "${mode}" ] ; then
		echo ${DEFAULT_MODE}
		return
	fi

	case ${mode} in
		"minimum")
			echo ${mode}
			;;
		"local")
			echo ${mode}
			;;
		"distributed")
			echo ${mode}
			;;
		*)
			echo ${DEFAULT_MODE}
			;;
	esac
}


function getConfig() {
	if [ -f "/vagrant/config.yaml" ] ; then
		SECTION=$1
		eval `sed -e "s/[[:space:]]*\:[[:space:]]*/=/g" \
			-e "s/#.*$//" \
			-e "s/[[:space:]]*$//" \
			-e "s/^[[:space:]]*//" \
			-e "s/^\(.*\)=\([^\"']\)$/\1=\"\2\"/" \
			< /vagrant/config.yaml \
			| grep -v "^#" | grep "^${SECTION}" | sed -e "s/^${SECTION}\.//g"`
	fi
}
# EOF
