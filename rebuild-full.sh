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

# generic mandatory tools/script
MAIN_CMD="
awk
basename
cat
column
chmod
chown
chroot
chflags
cp
curl
cut
date
dd
df
find
grep
git
head
hostname
jq
ln
mkdir
mount
mv
mktemp
openssl
pw
realpath
readlink
rm
rsync
sed
sort
strings
sysctl
tar
tail
tee
touch
tr
truncate
uname
wc
whoami
"

if [ "${USE_TOR}" = "YES" ]; then
	MAIN_CMD="${MAIN_CMD} nc"
fi

case "${OS}" in
	Linux|SpaceVM)
		MAIN_CMD="${MAIN_CMD} lsblk fio"
		;;
	Liman)
		MAIN_CMD="${MAIN_CMD} camcontrol diskinfo fio"
		;;
	FreeBSD)
		MAIN_CMD="${MAIN_CMD} camcontrol diskinfo"
		;;
esac

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
if [ 1 -gt 2 ]; then
# first init

cbsd module mode=install cpr || true
${GREP_CMD} -q cpr ~cbsd/etc/modules.conf
ret=$?
if [ ${ret} -ne 0 ]; then
	echo 'cpr.d' >> ~cbsd/etc/modules.conf
	env NOINTER=1 cbsd initenv
fi

if [ ! -d /root/clonos-ports ]; then
	${GIT_CMD} clone https://github.com/clonos/clonos-ports-wip.git /root/clonos-ports
else
	cd /root/clonos-ports
	${GIT_CMD} pull
fi

if [ -d /usr/ports ]; then
	cd /usr/ports
	${GIT_CMD} reset --hard > /dev/null 2>&1 || true
fi

cbsd portsup
${RSYNC_CMD} -avz --exclude .git /root/clonos-ports/ /usr/ports/

cbsd jremove jname='cpr*'
${RM_CMD} -rf /var/cache/packages/*

[ -d /usr/ports/sysutils/cbsd-mq-api ] && ${RM_CMD} -rf /usr/ports/sysutils/cbsd-mq-api
[ -d /usr/ports/sysutils/garm ] && ${RM_CMD} -rf /usr/ports/sysutils/garm
${CP_CMD} -a /root/myb-build/ports/garm /usr/ports/sysutils/
${CP_CMD} -a /root/myb-build/ports/cbsd-mq-api /usr/ports/sysutils/

# devel CBSD
if [ -d /root/myb-build/ports/cbsd ]; then
	[ -d /usr/ports/sysutils/cbsd ] && ${RM_CMD} -rf /usr/ports/sysutils/cbsd
	${CP_CMD} -a /root/myb-build/ports/cbsd /usr/ports/sysutils/
fi

[ ! -d /root/myb-build/myb-extras ] && ${MKDIR_CMD} /root/myb-build/myb-extras

case "${OSNAME}" in
	ClonOS)
		[ -d /usr/ports/www/clonos ] && ${RM_CMD} -rf /usr/ports/www/clonos
		${CP_CMD} -a /root/clonos-ports/www/clonos /usr/ports/www/
		# deps for vncterm
		pkg install -y security/gnutls net/libvncserver

		[ -d /usr/ports/sysutils/clonos-ws ] && ${RM_CMD} -rf /usr/ports/sysutils/clonos-ws
		[ -d /usr/ports/sysutils/cbsd-plugin-wsqueue ] && ${RM_CMD} -rf /usr/ports/sysutils/cbsd-plugin-wsqueue
		${CP_CMD} -a /root/clonos-ports/sysutils/clonos-ws /usr/ports/sysutils/
		${CP_CMD} -a /root/clonos-ports/sysutils/cbsd-plugin-wsqueue /usr/ports/sysutils/
		make -C /usr/local/cbsd/modules/vncterm.d
		[ -d /root/myb-build/myb-extras/vncterm.d ] && ${RM_CMD} -rf /root/myb-build/myb-extras/vncterm.d
		${CP_CMD} -a /usr/local/cbsd/modules/vncterm.d /root/myb-build/myb-extras/
		${RM_CMD} -rf /root/myb-build/myb-extras/.git
		;;
esac

# refresh modules
[ -d /root/myb-build/myb-extras/myb.d ] && ${RM_CMD} -rf /root/myb-build/myb-extras/myb.d
[ -d /root/myb-build/myb-extras/garm.d ] && ${RM_CMD} -rf /root/myb-build/myb-extras/garm.d
[ -d /root/myb-build/myb-extras/api.d ] && ${RM_CMD} -rf /root/myb-build/myb-extras/api.d
[ -d /root/myb-build/myb-extras/k8s.d ] && ${RM_CMD} -rf /root/myb-build/myb-extras/k8s.d
[ -d /root/myb-build/myb-extras/convectix.d ] && ${RM_CMD} -rf /root/myb-build/myb-extras/convectix.d
[ -d /root/myb-build/myb-extras/puppet.d ] && ${RM_CMD} -rf /root/myb-build/myb-extras/puppet.d

# garm.d
[ -d /usr/local/cbsd/modules/garm.d ] && ${RM_CMD} -rf /usr/local/cbsd/modules/garm.d
cbsd module mode=install garm
${CP_CMD} -a /usr/local/cbsd/modules/garm.d /root/myb-build/myb-extras/
${RM_CMD} -rf /root/myb-build/myb-extras/garm.d/.git || true
date
# myb.d
[ -d /usr/local/cbsd/modules/myb.d ] && ${RM_CMD} -rf /usr/local/cbsd/modules/myb.d
cbsd module mode=install myb
${CP_CMD} -a /usr/local/cbsd/modules/myb.d /root/myb-build/myb-extras/
${RM_CMD} -rf /root/myb-build/myb-extras/myb.d/.git || true
# k8s.d
[ -d /usr/local/cbsd/modules/k8s.d ] && ${RM_CMD} -rf /usr/local/cbsd/modules/k8s.d
cbsd module mode=install k8s
${CP_CMD} -a /usr/local/cbsd/modules/k8s.d /root/myb-build/myb-extras/
${RM_CMD} -rf /root/myb-build/myb-extras/k8s.d/.git || true
[ -d /root/myb-build/myb-extras/k8s.d/share/k8s-system-default ] && ${RM_CMD} -rf /root/myb-build/myb-extras/k8s.d/share/k8s-system-default
${CP_CMD} -a /root/myb-build/myb-extras/k8s-system-default /root/myb-build/myb-extras/k8s.d/share/
# api.d
[ -d /usr/local/cbsd/modules/api.d ] && ${RM_CMD} -rf /usr/local/cbsd/modules/api.d
cbsd module mode=install api
${CP_CMD} -a /usr/local/cbsd/modules/api.d /root/myb-build/myb-extras/
${RM_CMD} -rf /root/myb-build/myb-extras/api.d/.git || true

## convectix.d
[ -d /usr/local/cbsd/modules/convectix.d ] && ${RM_CMD} -rf /usr/local/cbsd/modules/convectix.d
cbsd module mode=install convectix
${CP_CMD} -a /usr/local/cbsd/modules/convectix.d /root/myb-build/myb-extras/
${RM_CMD} -rf /root/myb-build/myb-extras/convectix.d/.git || true

# puppet.d
[ -d /usr/local/cbsd/modules/puppet.d ] && ${RM_CMD} -rf /usr/local/cbsd/modules/puppet.d
cbsd module mode=install puppet
${CP_CMD} -a /usr/local/cbsd/modules/puppet.d /root/myb-build/myb-extras/
${RM_CMD} -rf /root/myb-build/myb-extras/puppet.d/.git || true

fi		## PREPARE

# !!!
# not for half:
set -o errexit

if [ 1 -gt 2 ]; then

## cleanup
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/00_cleanup.sh
time_stats "${N1_COLOR}cleanup done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "cleanup" ${diff_time}

## srcup
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/00_srcup.sh
time_stats "${N1_COLOR}srcup done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "srcup" ${diff_time}

# not needed anymore?
#/root/myb-build/ci/10_patch-src.sh

# world
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/20_world.sh
time_stats "${N1_COLOR}world done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "world" ${diff_time}

# basepkg
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/25_base-pkg.sh
time_stats "${N1_COLOR}base-pkg done"
end_time=$( ${DATE_CMD} +%s )
fiff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "basepkg" ${diff_time}

# cpr
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/30_cpr.sh
time_stats "${N1_COLOR}cpr done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "cpr" ${diff_time}

# cpr-micro
#st_time=$( ${DATE_CMD} +%s )
#/root/myb-build/ci/35_cpr-micro.sh
#time_stats "${N1_COLOR}cpr-micro done"
#end_time=$( ${DATE_CMD} +%s )
#diff_time=$(( end_time - st_time ))
#put_prometheus_file_metrics "rebuild-full" "cprmicro" ${diff_time}

# update-repo
st_time=$( ${DATE_CMD} +%s )
/root/myb-build/ci/35_update_repo.sh
time_stats "${N1_COLOR}update_repo done"
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
put_prometheus_file_metrics "rebuild-full" "updaterepo" ${diff_time}

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
