#!/bin/sh
pgm="${0##*/}"                          # Program basename
progdir="${0%/*}"                       # Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )

. /etc/rc.conf          # mybbasever
set +e

. ${progdir}/brand.conf

if [ -z "${mybbasever}" ]; then
	echo "Please specify mybbasever= via /etc/rc.conf, e.g: sysrc -q mybbasever=\"14.0\""
	exit 1
fi

# re-check before upload
case "${OSNAME}" in
	MyBee)
		if [ -z "${MYB_UPLOAD_140}" ]; then
			echo "no such MYB_UPLOAD_140 string in rc.conf"
			exit 1
		fi
		;;
	ClonOS)
		if [ -z "${CLONOS_UPLOAD_140}" ]; then
			echo "no such CLONOS_UPLOAD_140 string in rc.conf"
			exit 1
		fi
		;;
	*)
		echo "invalid brand, who are you?"
		exit 1
esac

service ntpd stop > /dev/null 2>&1 || true
ntpdate 0.freebsd.pool.ntp.org
service ntpd start

# cleanup old data
if [ -d ${progdir}/cbsd ]; then
	echo "remove old artifact dir: ${progdir}/cbsd"
	rm -rf ${progdir}/cbsd
fi

if [ -d /usr/src ]; then
	cd /usr/src
	git reset --hard
fi

if [ -d ~cbsd/src/src_${mybbasever} ]; then
	cd ~cbsd/src/src_${mybbasever}
	git reset --hard
fi

cd /tmp
mkdir ${progdir}/cbsd

for i in cpr3e421 cprd07dc cpr9ca75 mybee1 micro1; do
	cbsd jremove ${i}
done

echo "remove kernel/base"
cbsd removebase
cbsd removekernel

exit 0
