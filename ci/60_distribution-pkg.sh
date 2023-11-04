#!/bin/sh
set +e
. /etc/rc.conf          # mybbasever
jname="mybee1"

pgm="${0##*/}"				# Program basename
progdir="${0%/*}"			# Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )

. ${progdir}/brand.conf

: ${distdir="/usr/local/cbsd"}
[ ! -r "${distdir}/subr/cbsdbootstrap.subr" ] && exit 1
. ${distdir}/subr/cbsdbootstrap.subr || exit 1

mount -t devfs devfs /tmp/mybase/dev

[ ! -d /tmp/mybase/usr/local/etc/pkg/repos ] && mkdir -p /tmp/mybase/usr/local/etc/pkg/repos
cp -a ${progdir}/myb-extras/pkg/${OSNAME}-latest.conf /tmp/mybase/usr/local/etc/pkg/repos/

# for ClonOS + MyBee
chroot /tmp/mybase /bin/sh <<EOF
pkg update -f
pkg install -y myb nginx cbsd cbsd-mq-router cbsd-mq-api curl jq cdrkit-genisoimage ca_root_nss beanstalkd bash dmidecode hw-probe rsync smartmontools sudo tmux mc ttyd
EOF

# ClonOS only
case "${OSNAME}" in
	ClonOS)
		chroot /tmp/mybase /bin/sh <<EOF
pkg install -y clonos
EOF
	;;
esac


echo "Update/run cix_upgrade: clonos_ver.conf"
cp -a ${progdir}/scripts/cix_upgrade /tmp/mybase/root/
chroot /tmp/mybase /root/cix_upgrade
rm -f /tmp/mybase/root/cix_upgrade

echo "/root/cix_upgrade"

ver=${mybbasever%%.*}

if [ ! -h ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest ]; then
	echo "no such ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest symlink to repo"
	exit 1
fi

# original?
echo "copy /tmp/mybase/tmp/cbsd_ver.{conf,json} -> ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/"
cp -a /tmp/mybase/tmp/cbsd_ver.conf ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/
cp -a /tmp/mybase/tmp/cbsd_ver.json ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/
# back compat, tech depth: get rid of !'cbsd_ver.{conf,json}':
cp -a /tmp/mybase/tmp/cbsd_ver.conf ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/clonos_ver.conf
cp -a /tmp/mybase/tmp/cbsd_ver.json ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/clonos_ver.json
cp -a /tmp/mybase/tmp/cbsd_ver.conf ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/myb_ver.conf
cp -a /tmp/mybase/tmp/cbsd_ver.json ${progdir}/cbsd/FreeBSD:${ver}:amd64/latest/myb_ver.json


# extra check
umount -f /tmp/mybase/dev

CHECK_FILES="/tmp/mybase/usr/local/bin/tmux \
/tmp/mybase/usr/local/bin/mc \
/tmp/mybase/usr/local/bin/curl \
/tmp/mybase/usr/local/myb/mybinst.sh \
/tmp/mybase/usr/local/sbin/nginx \
/tmp/mybase/usr/local/bin/cbsd \
/tmp/mybase/usr/local/bin/cbsd-mq-api \
/tmp/mybase/usr/local/bin/cbsd-mq-router \
/tmp/mybase/usr/local/bin/ttyd"

# todo:
# ClonOS CHECK_FILES+=


failed=0
for i in ${CHECK_FILES}; do
	if [ ! -x ${i} ]; then
	echo "pkg install failed: no such ${i}"
	exit 1
	fi
done

cbsd mkdistribution ver=${mybbasever} distribution="base" sourcedir=/tmp/mybase destdir="${workdir}/jails-data/${jname}-data/usr/freebsd-dist"
ret=$?
if [ ${ret} -ne 0 ]; then
	echo "cbsd mkdistribution failed"
	exit ${ret}
fi

exit 0
