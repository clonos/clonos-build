#!/bin/sh
. /etc/rc.conf
. /etc/rc.subr
export workdir="${cbsd_workdir}"
. /usr/local/cbsd/cbsd.conf
. /usr/local/cbsd/subr/ansiicolor.subr
. /usr/jails/nc.inventory
. /usr/local/cbsd/subr/nc.subr
. /usr/jails/cmd.subr

# MAIN
web=0
check_for_updates=0

while getopts "c:w:" opt; do
	case "${opt}" in
		c) check_for_updates="${OPTARG}" ;;
		w) web="${OPTARG}:" ;;
	esac
	shift $(($OPTIND - 1))
done

export PATH=/usr/local/bin:/usr/local/sbin:$PATH
clear

[ -z "${1}" ] && check_for_updates=1

cur_time=$( ${DATE_CMD} +%s )
last_check_update=
[ -r /var/spool/myb/state.conf ] && . /var/spool/myb/state.conf

PKG_CMD=$( which pkg )
echo

${ECHO} "${H1_COLOR} *** [Check for updates] *** ${N0_COLOR}"

if [ -n "${last_check_update}" ]; then
	check_diff=$(( cur_time - last_check_update ))
else
	  check_diff=99999
fi

if [ ${check_diff} -lt 1200 -a -r /var/spool/myb/last_result.txt ]; then
	${CAT_CMD} /var/spool/myb/last_result.txt
	exit 0
fi

logfile=$( ${MKTEMP_CMD} )
trap "[ -r ${logfile} ] && ${RM_CMD} -f ${logfile}" HUP INT ABRT BUS TERM EXIT
env IGNORE_OSVERSION=yes SIGNATURE_TYPE=none ASSUME_ALWAYS_YES=yes timeout 30 ${PKG_CMD} update -f > ${logfile} 2>&1
ret=$?

if [ ${ret} -ne 0 ]; then
	${ECHO} "${W1_COLOR}check-upgrade error:${N0_COLOR}"
	${CAT_CMD} ${logfile}
	exit 0
fi

[ ! -d /var/spool/myb ] && mkdir /var/spool/myb
echo "last_check_update=\"${cur_time}\"" > /var/spool/myb/state.conf

env IGNORE_OSVERSION=yes SIGNATURE_TYPE=none ${PKG_CMD} upgrade -n -U > /var/spool/myb/last_result.txt

if [ ${check_for_updates} -eq 1 ]; then
	[ -r /var/spool/myb/last_result.txt ] && ${CAT_CMD} /var/spool/myb/last_result.txt
	exit 0
fi

${ECHO} "${H1_COLOR} *** [Upgrade] *** ${N0_COLOR}"
echo
env ASSUME_ALWAYS_YES=yes IGNORE_OSVERSION=yes pkg upgrade -U -y

# todo: check for version changes
echo
${ECHO} "${H2_COLOR} update modules ${N0_COLOR}"
echo

/usr/local/myb/mybinst.sh -w ${web}
ret=$?

# save timestamp for last upgrade?

exit 0
