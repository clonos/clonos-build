#!/bin/sh
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
pgm="${0##*/}" # Program basename
progdir="${0%/*}" # Program directory

if [ -z "${1}" ]; then
	echo "usage ${pgm} <zone> <record> <type> <val>"
	echo "e.g:"
	echo "${pgm} home.local ea A 300 10.0.0.72"
	echo "${pgm} home.local @ NS ns1.home.local"
	echo "${pgm} home.local @ NS ns2.home.local"
	exit 1
fi

. ${progdir}/config

pdnsutil add-record ${*}
