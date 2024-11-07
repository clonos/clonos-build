#!/bin/sh
pgm="${0##*/}"                          # Program basename
progdir="${0%/*}"                       # Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )

. /etc/rc.conf		# mybbasever
set +e
. ${progdir}/cmd.subr
. ${progdir}/brand.conf

echo "Build ${OSNAME} base version: ${mybbasever}"

case "${ver}" in
	15*)
		cbsd srcup ver=${mybbasever} rev=65691b2dafd
		;;
	14*)
		cbsd srcup ver=${mybbasever}
		;;
esac

src_dir_makefile="${cbsd_workdir}/src/src_${mybbasever}/src/Makefile"

if [ ! -r "${src_dir_makefile}" ]; then
	echo "no such source: ${src_dir_makefile}"
	exit 1
fi

cd ${cbsd_workdir}/src/src_${mybbasever}/src/
git reset --hard

cd ${cbsd_workdir}/src/src_${mybbasever}/src/usr.sbin/bhyve
patch < /usr/local/cbsd/upgrade/patch/iov-15.0/patch-usr-sbin-bhyve-block_if.h || true
patch < /usr/local/cbsd/upgrade/patch/iov-15.0/patch-usr-sbin-bhyve-virtio.c || true
cd /
# snapshot

exit 0
