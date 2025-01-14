#!/bin/sh
pgm="${0##*/}"                          # Program basename
progdir="${0%/*}"                       # Program directory
progdir=$( realpath ${progdir} )

export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
### SET version in /root/myb-build/ports/myb/Makefile
### + /root/myb-build/skel/usr/local/etc/mybee/version

# Brand, used in sysinstall/bsdconfig...
#export OSNAME="home.olevole.ru"
#export OSNAME="mother.olevole.ru"
#export OSNAME="FreeBSD"
export OSNAME="MyBee"
#export OSNAME="ClonOS"

cd /

OS=$( uname -s )

echo "Platform: ${OS}"

# Init CMD Macros
UNAME_CMD=$( which uname )
if [ ! -x "${UNAME_CMD}" ]; then
	echo "error: no such command: uname"
	exit 1
fi

TR_CMD=$( which tr )
if [ ! -x "${TR_CMD}" ]; then
	echo "error: no such command: tr"
	exit 1
fi

TRUNCATE_CMD=$( which truncate )
if [ ! -x "${TRUNCATE_CMD}" ]; then
	echo "error: no such command: truncate"
	exit 1
fi

CAT_CMD=$( which cat )
if [ ! -x "${CAT_CMD}" ]; then
	echo "error: no such command: cat"
	exit 1
fi

SORT_CMD=$( which sort )
if [ ! -x "${SORT_CMD}" ]; then
	echo "error: no such command: sort"
	exit 1
fi

if [ -r "${progdir}/cmd.${OS}.conf" ]; then
	. ${progdir}/cmd.${OS}.conf
else
	. ${progdir}/cmd.conf
fi

if [ "${USE_TOR}" = "YES" ]; then
	MAIN_CMD="${MAIN_CMD} nc"
fi

${TRUNCATE_CMD} -s0 ${progdir}/cmd.subr

${CAT_CMD} > ${progdir}/cmd.subr <<EOF
if [ ! "\$_CBSD_CMD_SUBR" ]; then
_CBSD_CMD_SUBR=1
###
EOF

MAIN_CMD=$( echo ${MAIN_CMD} | ${SORT_CMD} )
OPTIONAL_CMD=$( echo ${OPTIONAL_CMD} | ${SORT_CMD} )

for i in ${MAIN_CMD}; do
	mycmd=
	mycmd=$( which ${i} || true )           # true for 'set -e' case
	if [ ! -x "${mycmd}" ]; then
		echo "${pgm} error: no such executable dependency/requirement: ${i}"
		${CAT_CMD} >> ${progdir}/cmd.subr <<EOF
###
fi
EOF
		exit 1
	fi

	MY_CMD=$( echo ${i} | ${TR_CMD} '\-[:lower:]' '_[:upper:]' )
	MY_CMD="${MY_CMD}_CMD"
	eval "${MY_CMD}=\"${mycmd}\""
	echo "${MY_CMD}=\"${mycmd}\"" >> ${progdir}/cmd.subr
done

${CAT_CMD} >> ${progdir}/cmd.subr <<EOF
###
fi
EOF

set -e
. ${progdir}/cmd.subr
. ${progdir}/system.subr
set +e

FULL_ST_TIME=$( ${DATE_CMD} +%s )

#### PREPARE
if [ 3 -gt 2 ]; then
	if [ -r "${progdir}/rebuild-prepare.${OS}.subr" ]; then
		/bin/sh ${progdir}/rebuild-prepare.${OS}.subr
	else
		/bin/sh ${progdir}/rebuild-prepare.subr
	fi
fi

# !!!
# not for half:
set -o errexit

if [ 3 -gt 2 ]; then
	if [ -r "${progdir}/rebuild-buildenv.${OS}.subr" ]; then
		/bin/sh ${progdir}/rebuild-buildenv.${OS}.subr
	else
		/bin/sh ${progdir}/rebuild-buildenv.subr
	fi
fi
### HALF-build
#fi
# half build
#fi
# jail

st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/40_jail.sh
time_stats "${N1_COLOR}jail done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "jail" ${diff_time}

exit 0


# export-micro
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/44_export-micro.sh
time_stats "${N1_COLOR}export micro jail done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "exportmicrojail" ${diff_time}

# purgejail
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/50_purgejail.sh
time_stats "${N1_COLOR}purgejail done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "purgejail" ${diff_time}

# purge_distribution
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/55_purge_distribution.sh
time_stats "${N1_COLOR}purge_distribution done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "purgedistribution" ${diff_time}

# purge_distribution-base
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/60_distribution-base.sh
time_stats "${N1_COLOR}purge_distribution_base done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "purge_distribution_base" ${diff_time}

# distribution-pkg
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/60_distribution-pkg.sh
time_stats "${N1_COLOR}distribution_pkg done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "distribution_pkg" ${diff_time}

# manifests
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/70_manifests.sh
time_stats "${N1_COLOR}manifests done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "manifests" ${diff_time}

# conv
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/90_conv.sh
time_stats "${N1_COLOR}conv done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "conv" ${diff_time}

# updaterepo
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/95_updaterepo.sh
time_stats "${N1_COLOR}updaterepo done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "updaterepo" ${diff_time}

set +o errexit

full_diff_time=$(( full_end_time - full_st_time ))

chmod 0644 /tmp/mybee1-14.1_amd64.img
chmod 0644 /usr/jails/jails-data/mybee1-data/usr/freebsd-dist/*

echo "----------------------------------"
echo "scp /tmp/mybee1-14.1_amd64.img oleg@172.16.0.3:mybee1-14.1_amd64.img"
echo
echo "cd /usr/jails/jails-data/mybee1-data/usr/freebsd-dist"
echo "sftp -oPort=222 oleg@www.bsdstore.ru   -> /usr/local/www/myb.convectix.com/"
echo "or"
echo "scp -oPort=222 /usr/jails/jails-data/mybee1-data/usr/freebsd-dist/MANIFEST oleg@www.bsdstore.ru:/usr/local/www/myb.convectix.com/"
echo "scp -oPort=222 /usr/jails/jails-data/mybee1-data/usr/freebsd-dist/base.txz oleg@www.bsdstore.ru:/usr/local/www/myb.convectix.com/"
echo "scp -oPort=222 /usr/jails/jails-data/mybee1-data/usr/freebsd-dist/cbsd.txz oleg@www.bsdstore.ru:/usr/local/www/myb.convectix.com/"
echo "scp -oPort=222 /usr/jails/jails-data/mybee1-data/usr/freebsd-dist/kernel.txz oleg@www.bsdstore.ru:/usr/local/www/myb.convectix.com/"
echo
