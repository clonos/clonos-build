#!/bin/sh
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
pgm="${0##*/}" # Program basename
progdir="${0%/*}" # Program directory

if [ -z "${1}" ]; then
	echo "usage ${pgm} domain"
	exit 1
fi

. ${progdir}/config

pdnsutil increase-serial ${1}

