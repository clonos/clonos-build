#!/bin/sh
. /etc/rc.conf          # mybbasever

pgm="${0##*/}"				# Program basename
progdir="${0%/*}"			# Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )

. ${progdir}/brand.conf
. ${progdir}/cmd.subr
export OSNAME="${OSNAME}"
cbsd world ver=${mybbasever}

world_test_file="${cbsd_workdir}/basejail/base_amd64_amd64_${mybbasever}/bin/sh"

if [ ! -r ${world_test_file} ]; then
	echo "no such source: ${world_test_file}"
	exit 1
fi

kernel_test_file="${cbsd_workdir}/basejail/FreeBSD-kernel_CBSD_amd64_${mybbasever}/boot/kernel/kernel"

cbsd kernel ver=${mybbasever} name=CBSD
kernel_test_file="${cbsd_workdir}/basejail/FreeBSD-kernel_CBSD_amd64_${mybbasever}/boot/kernel/kernel"

if [ ! -r ${kernel_test_file} ]; then
	echo "no such source: ${kernel_test_file}"
	exit 1
fi

#[ -d ${cbsd_workdir}/basejail/FreeBSD-kernel_GENERIC_amd64_${mybbasever} ] && rm -rf ${cbsd_workdir}/basejail/FreeBSD-kernel_GENERIC_amd64_${mybbasever}
#cp -a ${cbsd_workdir}/basejail/FreeBSD-kernel_CBSD_amd64_${mybbasever} ${cbsd_workdir}/basejail/FreeBSD-kernel_GENERIC_amd64_${mybbasever}

#[ -d ${workdir}/basejail/base_amd64_amd64_${mybbasever}/rescue ] && rm -rf ${workdir}/basejail/base_amd64_amd64_${mybbasever}/rescue

exit 0
