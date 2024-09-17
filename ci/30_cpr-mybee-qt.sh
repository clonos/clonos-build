#!/bin/sh
. /etc/rc.conf          # mybbasever
pgm="${0##*/}"				# Program basename
progdir="${0%/*}"			# Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )
. ${progdir}/cmd.subr
OSNAME="FreeBSD"
. ${progdir}/brand.conf
dstdir=$( ${MKTEMP_CMD} -d )

cd /usr/ports
${GIT_CMD} reset --hard || true
cbsd portsup

## "OVERLAY"
if [ -d ${progdir}/ports/mybee-qt ]; then
	[ -d /usr/ports/emulators/mybee-qt ] && rm -rf /usr/ports/emulators/mybee-qt
	cp -a ${progdir}/ports/mybee-qt /usr/ports/emulators/
fi

DT=$( date "+%d%H" )
#. ${progdir}/myb-extras/version
myb_version="0.2.0"
VER="${myb_version}.${DT}"
${SED_CMD} "s:%%VER%%:${VER}:g" /usr/ports/emulators/mybee-qt/Makefile-tpl > /usr/ports/emulators/mybee-qt/Makefile

make -C /usr/ports/emulators/mybee-qt makesum

cpr_jname="cprc8c78"

# cleanup old pkg ?
#/var/cache/packages/pkgdir-${cpr_jname} (host) -> /tmp/packages (jail)

ver=${mybbasever%%.*}

#if [ ! -h ${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest ]; then
#	echo "no such ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest symlink to repo"
#	exit 1
#fi

cbsd jstatus jname=${cpr_jname} || cbsd jremove jname=${cpr_jname}

if [ ! -r ${progdir}/mybee-qt.list ]; then
	echo "No such ${progdir}/mybee-qt.list"
	exit 1
fi

[ ! -d "${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest" ] && mkdir -p ${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest

echo "cbsd cpr batch=1 ver=${mybbasever} jname="${cpr_jname}" pkglist=${progdir}/mybee-qt.list dstdir=${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest/"

PREFETCHED_PACKAGES="\
cmake \
curl \
gmake \
freerdp \
libvncserver \
qt6-multimedia \
llvm15 \
"

# MC needs for 'mcedit' !!
#/usr/ports/net/realtek-re-kmod


echo "cbsd cpr batch=1 makeconf=/root/myb-build/myb_make.conf jname=\"${cpr_jname}\" ver=${mybbasever} pkglist=${progdir}/mybee-qt.list dstdir=${dstdir} package_fetch=\"${PREFETCHED_PACKAGES}\" autoremove=1"
read p
cbsd cpr batch=1 makeconf=/root/myb-build/myb_make.conf jname="${cpr_jname}" ver=${mybbasever} pkglist=${progdir}/mybee-qt.list dstdir=${dstdir} package_fetch="${PREFETCHED_PACKAGES}" autoremove=1 pause=1

ret=$?

if [ ${ret} -ne 0 ]; then
	echo "CPR failed: ${ret}"
	exit ${ret}
fi

cbsd jstart jname=${cpr_jname} || true

#echo "Update/run cix_upgrade: clonos_ver.conf"
#cp -a ${progdir}/scripts/cix_upgrade ${cbsd_workdir}/jails-data/${cpr_jname}-data/root/
#cbsd jexec jname=${cpr_jname} /root/cix_upgrade

#echo "/root/cix_upgrade"

# original?
#case "${OSNAME}" in
#	ClonOS)
#		echo "copy ${cbsd_workdir}/jails-data/${cpr_jname}-data/tmp/clonos_ver.{conf,json} -> ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/"
#		cp -a ${cbsd_workdir}/jails-data/${cpr_jname}-data/tmp/clonos_ver.conf ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/
#		cp -a ${cbsd_workdir}/jails-data/${cpr_jname}-data/tmp/clonos_ver.json ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/
#		;;
#	MyBee)
#		echo "copy ${cbsd_workdir}/jails-data/${cpr_jname}-data/tmp/myb_ver.{conf,json} -> ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/"
#		cp -a ${cbsd_workdir}/jails-data/${cpr_jname}-data/tmp/myb_ver.conf ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/
#		cp -a ${cbsd_workdir}/jails-data/${cpr_jname}-data/tmp/myb_ver.json ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/
#		;;
#esac

cbsd jstop jname=${cpr_jname} || true

echo "${MV_CMD} ${dstdir}/* ${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest/"
read p
${MV_CMD} ${dstdir}/* ${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest/

# jstop done in 1 seconds
# mv: rename /tmp/tmp.mRuXt44qrV/Latest to /root/clonos-build/cbsd/mybee-qt/FreeBSD:15:amd64/latest/Latest: Directory not empty


${RM_CMD} -rf ${dstdir}
if [ ! -h ${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest/pkg.pkg ]; then
	echo "no such ${progdir}/cbsd/mybee-qt/FreeBSD:${ver}:amd64/latest/pkg.pkg"
	exit 1
fi

cbsd jremove jname=${cpr_jname} > /dev/null 2>&1

exit 0
