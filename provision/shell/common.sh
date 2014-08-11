#!/bin/sh

DEFAULT_MODE=distributed

function getMode() {
	eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
		-e 's/;.*$//' \
		-e 's/[[:space:]]*$//' \
		-e 's/^[[:space:]]*//' \
		-e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
		< /vagrant/files/config.ini \
		| sed -n -e "/^\[common\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`

	if [ -z "${mode}" ] ; then
		echo ${DEFAULT_MODE}
		return
	fi

	case ${mode} in
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
