#!/bin/sh
## check for best compress/size/speed val:
. /etc/rc.conf          # mybbasever
jname="mybee1"

pgm="${0##*/}"                          # Program basename
progdir="${0%/*}"                       # Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )

: ${distdir="/usr/local/cbsd"}
if [ ! -r "${distdir}/subr/cbsdbootstrap.subr" ]; then
	echo "no such ${distdir}/subr/cbsdbootstrap.subr"
	exit 1
fi
. ${distdir}/subr/cbsdbootstrap.subr
if [ $? -ne 0 ]; then
	echo "cbsdbootstrap.subr failed"
	exit 1
fi

# lookup for RSYNC
. /etc/rc.conf
. ${progdir}/cmd.subr

OSNAME="MyBee"
. ${progdir}/brand.conf
date
echo "UPDATE_REPO for ${OSNAME}"

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

RSYNC_DST="${UP_STRING}"

ver=${mybbasever%%.*}

if [ ! -h ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest ]; then
	echo "no such ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest symlink to repo"
	exit 1
fi

[ -z "${PKG_CMD}" ] && PKG_CMD="/usr/sbin/pkg"
date
# save package list
[ ! -d ${progdir}/myb ] && ${MKDIR_CMD} -p ${progdir}/myb
${GREP_CMD} -v '^#' ${progdir}/myb.list | ${SED_CMD} 's:/usr/ports/::g' > ${progdir}/myb/myb.list

${TOUCH_CMD} ${progdir}/myb/brand.conf
sysrc -qf ${progdir}/myb/brand.conf OSNAME="${OSNAME}"
${RSYNC_CMD} -avz ${progdir}/myb-extras/ ${progdir}/myb/
${RSYNC_CMD} -avz ${progdir}/skel/ ${workdir}/jails-data/${jname}/

# in kubernetes bootsrap!
#cp -a ${cbsd_workdir}/export/micro1.img ${progdir}/myb/

[ -d ${progdir}/myb/skel ] && ${RM_CMD} -rf ${progdir}/myb/skel
${CP_CMD} -a ${progdir}/skel ${progdir}/myb/

${RM_CMD} -rf /usr/ports/packages/All
DT=$( date "+%d%H" )

myb_build=
myb_version=
if [ -r ${progdir}/myb-extras/version ]; then
	. ${progdir}/myb-extras/version
fi
[ -z "${myb_build}" ] && myb_build=0
[ -z "${myb_version}" ] && myb_build="0.1"

myb_build=$(( myb_build + 1 ))

VER="${myb_version}.${myb_build}"
${SED_CMD} "s:%%VER%%:${VER}:g" /root/myb-build/ports/myb/Makefile-tpl > /root/myb-build/ports/myb/Makefile

sysrc -qf ${progdir}/myb-extras/version myb_build="${myb_build}"

make -C /root/myb-build/ports/myb clean
make -C /root/myb-build/ports/myb package
#cd /usr/ports/packages/All

${MV_CMD} /usr/ports/packages/All/*.pkg ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/

#cp -a ${progdir}/cbsd/*.pkg /usr/ports/packages/All/

cd ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest
${PKG_CMD} repo .

sysrc -qf ${progdir}/myb/myb_ver.conf myb_ver_new="${VER}"

# original?
case "${OSNAME}" in
	ClonOS)
		sysrc -qf ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/clonos_ver.conf myb_ver_new="${VER}"
		cp -a ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/clonos_ver.json ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/clonos_ver.json-o
jq ".installed + {
  \"myb\": \"${VER}\"
}" ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/clonos_ver.json-o > ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/clonos_ver.json
		;;
	MyBee)
		sysrc -qf ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/myb_ver.conf myb_ver_new="${VER}"
		cp -a ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/myb_ver.json ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/myb_ver.json-o
jq ".installed + {
  \"myb\": \"${VER}\"
}" ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/myb_ver.json-o > ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/myb_ver.json

		rm -f ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/myb_ver.json-o
	;;
esac

echo "update_repo: check ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/"

#cd ${progdir}/cbsd/FreeBSD:${ver}:amd64/

echo "${RSYNC_CMD} -avz ./ ${RSYNC_DST}latest/"
${RSYNC_CMD} -avz --delete ./ ${RSYNC_DST}latest/
_ret=$?

echo "update_repo: rsync errcode: ${_ret}"

case ${_ret} in
	0|6|24|25)
		# rsync good codes
		_ret=0
		;;
	*)
		true
		;;
esac

exit ${_ret}
