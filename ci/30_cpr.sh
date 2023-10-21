#!/bin/sh
. /etc/rc.conf          # mybbasever
pgm="${0##*/}"				# Program basename
progdir="${0%/*}"			# Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )

. ${progdir}/brand.conf

dstdir=$( mktemp -d )

cd /usr/ports
git reset --hard || true
cbsd portsup

## "OVERLAY"
if [ -d ${progdir}/ports/cbsd ]; then
	[ -d /usr/ports/sysutils/cbsd ] && rm -rf /usr/ports/sysutils/cbsd
	cp -a ${progdir}/ports/cbsd /usr/ports/sysutils/
fi

if [ -d ${progdir}/ports/cbsd-mq-api ]; then
	[ -d /usr/ports/sysutils/cbsd-mq-api ] && rm -rf /usr/ports/sysutils/cbsd-mq-api
	cp -a ${progdir}/ports/cbsd-mq-api /usr/ports/sysutils/
fi

if [ -d ${progdir}/ports/garm ]; then
	[ -d /usr/ports/sysutils/garm ] && rm -rf /usr/ports/sysutils/garm
	cp -a ${progdir}/ports/garm /usr/ports/sysutils/
fi

if [ -d ${progdir}/ports/myb ]; then
	[ -d /usr/ports/sysutils/myb ] && rm -rf /usr/ports/sysutils/myb
	cp -a ${progdir}/ports/myb /usr/ports/sysutils/
fi

[ -d /tmp/send-fio ] && rm -rf /tmp/send-fio
git clone https://github.com/mergar/send-fio.git /tmp/send-fio
cp -a /tmp/send-fio/ports/spacevm-sendfio /usr/ports/sysutils/
rm -rf /tmp/send-fio

cpr_jname="cprc8c78"

# cleanup old pkg ?
#/var/cache/packages/pkgdir-${cpr_jname} (host) -> /tmp/packages (jail)

ver=${mybbasever%%.*}

if [ ! -h ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest ]; then
	echo "no such ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest symlink to repo"
	exit 1
fi

cbsd jstatus jname=${cpr_jname} || cbsd jremove jname=${cpr_jname}

if [ ! -r ${progdir}/${OSNAME}.list ]; then
	echo "No such ${progdir}/${OSNAME}.list"
	exit 1
fi

cp -a ${progdir}/${OSNAME}.list ${progdir}/myb.list

echo "cbsd cpr batch=1 ver=${mybbasever} pkglist=${progdir}/myb.list dstdir=${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/"

PREFETCHED_PACKAGES="\
bash \
beanstalkd \
ca_root_nss \
cdrkit \
cmake \
gmake \
gnutls \
go120 \
hw-probe \
jq \
kubectl \
mc \
mutt \
nginx \
ninja \
pkgconf \
py39-certbot \
python39 \
rsync \
sqlite3 \
sudo \
tmux \
ttyd \
"

# ClonOS brand:
PREFETCHED_PACKAGES="${PREFETCHED_PACKAGES} \
gcc12 \
git \
libvncserver \
node \
npm-node18 \
php82
php82-session \
php82-opcache \
py39-numpy \
"

# MC needs for 'mcedit' !!
#/usr/ports/net/realtek-re-kmod


cbsd cpr batch=1 makeconf=/root/myb-build/myb_make.conf ver=${mybbasever} pkglist=${progdir}/myb.list dstdir=${dstdir} package_fetch="${PREFETCHED_PACKAGES}" autoremove=1
ret=$?

if [ ${ret} -ne 0 ]; then
	echo "CPR failed: ${ret}"
	exit ${ret}
fi

cbsd jstart jname=${cpr_jname} || true

#echo "Update/run cix_upgrade: clonos_ver.conf"
#cp -a ${progdir}/scripts/cix_upgrade /usr/jails/jails-data/${cpr_jname}-data/root/
#cbsd jexec jname=${cpr_jname} /root/cix_upgrade

#echo "/root/cix_upgrade"

# original?
#case "${OSNAME}" in
#	ClonOS)
#		echo "copy /usr/jails/jails-data/${cpr_jname}-data/tmp/clonos_ver.{conf,json} -> ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/"
#		cp -a /usr/jails/jails-data/${cpr_jname}-data/tmp/clonos_ver.conf ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/
#		cp -a /usr/jails/jails-data/${cpr_jname}-data/tmp/clonos_ver.json ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/
#		;;
#	MyBee)
#		echo "copy /usr/jails/jails-data/${cpr_jname}-data/tmp/myb_ver.{conf,json} -> ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/"
#		cp -a /usr/jails/jails-data/${cpr_jname}-data/tmp/myb_ver.conf ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/
#		cp -a /usr/jails/jails-data/${cpr_jname}-data/tmp/myb_ver.json ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/
#		;;
#esac

cbsd jstop jname=${cpr_jname} || true

mv ${dstdir}/* ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/

rm -rf ${dstdir}
if [ ! -h ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/pkg.pkg ]; then
	echo "no such ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/pkg.pkg"
	exit 1
fi

cbsd jremove jname=${cpr_jname} > /dev/null 2>&1

exit 0
