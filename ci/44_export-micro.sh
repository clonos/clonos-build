#!/bin/sh
. /etc/rc.conf          # mybbasever
jname="micro1"

pgm="${0##*/}"				# Program basename
progdir="${0%/*}"			# Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )
. ${progdir}/cmd.subr
. ${progdir}/brand.conf

[ -r ${cbsd_workdir}/export/micro1.img ] && rm -f ${cbsd_workdir}/export/micro1.img
rm -rf ${cbsd_workdir}/jails-data/micro1-data/rescue
rm -rf ${cbsd_workdir}/jails-data/micro1-data/usr/tests

cbsd jexport micro1
