#!/bin/sh
pgm="${0##*/}"                          # Program basename
progdir="${0%/*}"                       # Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )

. /etc/rc.conf		# mybbasever
set +e

. ${progdir}/brand.conf

echo "Build MyBee base version: ${mybbasever}"
cbsd srcup ver=${mybbasever} rev=1d2ff563992

src_dir_makefile="/usr/jails/src/src_${mybbasever}/src/Makefile"

if [ ! -r ${src_dir_makefile} ]; then
	echo "no such source: ${src_dir_makefile}"
	exit 1
fi

exit 0
