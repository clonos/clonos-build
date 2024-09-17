#!/bin/sh
pgm="${0##*/}"                          # Program basename
progdir="${0%/*}"                       # Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )

. /etc/rc.conf          # mybbasever
set +e
. ${progdir}/cmd.subr
. ${progdir}/brand.conf

if [ -z "${mybbasever}" ]; then
	echo "Please specify mybbasever= via /etc/rc.conf, e.g.: sysrc -q mybbasever=\"14.1\""
	exit 1
fi

ver_w_point=$( echo ${mybbasever} | tr -d '.' )

# re-check before upload
case "${OSNAME}" in
	MyBee)
		eval UP_STRING="\$MYB_UPLOAD_${ver_w_point}"
		if [ -z "${UP_STRING}" ]; then
			echo "no such MYB_UPLOAD_${ver_w_point} string in rc.conf, e.g.: sysrc -q MYB_UPLOAD_${ver_w_point}=\"rsync://FQDN/xxxx/\""
			exit 1
		fi
		;;
	ClonOS)
		eval UP_STRING="\$CLONOS_UPLOAD_${ver_w_point}"
		if [ -z "${UP_STRING}" ]; then
			echo "no such CLONOS_UPLOAD_${ver_w_point} string in rc.conf, e.g.: sysrc -q CLONOS_UPLOAD_${ver_w_point}=\"rsync://FQDN/xxxx/\""
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
	${RM_CMD} -rf ${progdir}/cbsd
fi

if [ -d /usr/src ]; then
	cd /usr/src
	${GIT_CMD} reset --hard
fi

if [ -d ~cbsd/src/src_${mybbasever} ]; then
	cd ~cbsd/src/src_${mybbasever}
	${GIT_CMD} reset --hard
fi

cd /tmp
${MKDIR_CMD} ${progdir}/cbsd

for i in cpr3e421 cprd07dc cpr9ca75 mybee1 micro1; do
	cbsd jremove ${i}
done

echo "remove kernel/base"
cbsd removebase
cbsd removekernel

exit 0
