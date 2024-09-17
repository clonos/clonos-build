#!/bin/sh
## check for best compress/size/speed val:
. /etc/rc.conf          # mybbasever
jname="mybee1"

pgm="${0##*/}"                          # Program basename
progdir="${0%/*}"                       # Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )
: ${distdir="/usr/local/cbsd"}
[ ! -r "${distdir}/subr/cbsdbootstrap.subr" ] && exit 1
. ${distdir}/subr/cbsdbootstrap.subr || exit 1

# lookup for RSYNC
. /etc/rc.conf
. ${progdir}/cmd.subr
OSNAME="FreeBSD"
. ${progdir}/brand.conf

ver_w_point=$( echo ${mybbasever} | tr -d '.' )
eval UP_STRING="\$MYB_QT_UPLOAD_${ver_w_point}"
if [ -z "${UP_STRING}" ]; then
	echo "no such MYB_QT_UPLOAD_${ver_w_point} string in rc.conf"
	exit 1
fi

RSYNC_DST="${UP_STRING}"

ver=${mybbasever%%.*}

if [ ! -h ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest ]; then
	echo "no such ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest symlink to repo"
	exit 1
fi

[ -z "${PKG_CMD}" ] && PKG_CMD="/usr/sbin/pkg"

if [ ! -r ${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest/meta.conf ]; then
	echo "no such ${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest/meta.conf"
	exit 1
fi

cd ${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest

${PKG_CMD} repo .

${RSYNC_CMD} -avz --delete ./ ${RSYNC_DST}latest/

# retcode
