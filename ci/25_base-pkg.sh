#!/bin/sh
. /etc/rc.conf          # mybbasever

pgm="${0##*/}"				# Program basename
progdir="${0%/*}"			# Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )

. ${progdir}/brand.conf

export OSNAME="${OSNAME}"
cbsd packages ver=${mybbasever} destdir="${progdir}/cbsd" name=CBSD
ret=$?
exit ${ret}
