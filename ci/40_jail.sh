#!/bin/sh
. /etc/rc.conf          # mybbasever
jname="mybee1"

pgm="${0##*/}"				# Program basename
progdir="${0%/*}"			# Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )
. ${progdir}/cmd.subr
OSNAME="MyBee"
. ${progdir}/brand.conf
tmpver=$( ${UNAME_CMD} -r )
ver=${tmpver%%-*}
unset tmpver
#${CP_CMD} -a ${progdir}/skel/usr/local/etc/pkg/repos/${OSNAME}-latest.conf /usr/local/etc/pkg/repos/${OSNAME}-latest.conf

cbsd destroy cbsdfile=${progdir}/mybee-CBSDfile || true
cbsd destroy cbsdfile=${progdir}/micro-CBSDfile || true

cbsd up cbsdfile=${progdir}/mybee-CBSDfile ver="${mybbasever}"
cbsd jset ver=${mybbasever} jname=${jname}

${MKDIR_CMD} ${cbsd_workdir}/jails-data/${jname}-data/dev ${cbsd_workdir}/jails-data/${jname}-data/tmp
${CHMOD_CMD} 0777 ${cbsd_workdir}/jails-data/${jname}-data/tmp
${CHMOD_CMD} u+t ${cbsd_workdir}/jails-data/${jname}-data/tmp
${MOUNT_CMD} -t devfs devfs ${cbsd_workdir}/jails-data/${jname}-data/dev

PKG_BASE="FreeBSD-runtime"

basejail_conf=

if [ -r "${progdir}/profiles/${OSNAME}/basejail-${mybbasever}.conf" ]; then
	basejail_conf="${progdir}/profiles/${OSNAME}/basejail-${mybbasever}.conf"
	echo "found: ${basejail_conf}"
else
	echo "no such: ${progdir}/profiles/${OSNAME}/basejail-${mybbasever}.conf"
	if [ -r "${progdir}/profiles/${OSNAME}/basejail.conf" ]; then
		basejail_conf="${progdir}/profiles/${OSNAME}/basejail.conf"
	fi
fi

if [ -n "${basejail_conf}" ]; then
	echo "GET PKG FROM: ${basejail_conf}"
	. "${basejail_conf}"
else
	echo "no such PKG_BASE profiles: ${progdir}/profiles/${OSNAME}/basejail.conf"
fi

env ASSUME_ALWAYS_YES=yes SIGNATURE_TYPE=none IGNORE_OSVERSION=yes pkg -C /root/clonos-build/etc/pkg/pkg.conf update -f -r ${OSNAME}-latest

echo "env ASSUME_ALWAYS_YES=yes SIGNATURE_TYPE=none IGNORE_OSVERSION=yes pkg -C /root/clonos-build/etc/pkg/pkg.conf -r ${cbsd_workdir}/jails-data/${jname}-data install -r ${OSNAME}-latest ${PKG_BASE}"
env ASSUME_ALWAYS_YES=yes SIGNATURE_TYPE=none IGNORE_OSVERSION=yes pkg -C /root/clonos-build/etc/pkg/pkg.conf -r ${cbsd_workdir}/jails-data/${jname}-data install -r ${OSNAME}-latest ${PKG_BASE}

#_rpath=$( realpath ${cbsd_workdir}/jails-data/${jname}-data )
#make -C /usr/src installworld DESTDIR="${_rpath}"
#make -C /usr/src distribution DESTDIR="${_rpath}"

cbsd jstart jname=${jname}

fetch -o ${cbsd_workdir}/jails-data/${jname}-data/bin/distribution https://pkg.convectix.com/FreeBSD:14:amd64/latest/distribution
chmod +x ${cbsd_workdir}/jails-data/${jname}-data/bin/distribution

[ ! -d ${cbsd_workdir}/jails-data/${jname}-data/usr/local/etc/pkg/repos ] && ${MKDIR_CMD} -p ${cbsd_workdir}/jails-data/${jname}-data/usr/local/etc/pkg/repos
${CAT_CMD} > ${cbsd_workdir}/jails-data/${jname}-data/usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
FreeBSD: {
  url: "pkg+https://pkg.FreeBSD.org/\${ABI}/latest",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
EOF

#spacevm-sendfio

cbsd jexec jname=${jname} /bin/sh <<EOF
echo "Install MyBee packages"
pkg update -f
echo "env ASSUME_ALWAYS_YES=yes SIGNATURE_TYPE=none IGNORE_OSVERSION=yes pkg install -r ${OSNAME}-latest -y myb nginx cbsd cbsd-mq-router cbsd-mq-api curl jq cdrkit-genisoimage ca_root_nss beanstalkd bash dmidecode hw-probe rsync smartmontools sudo tmux mc ttyd fio"
env ASSUME_ALWAYS_YES=yes SIGNATURE_TYPE=none IGNORE_OSVERSION=yes pkg install -r ${OSNAME}-latest -y myb nginx cbsd cbsd-mq-router cbsd-mq-api curl jq cdrkit-genisoimage ca_root_nss beanstalkd bash dmidecode hw-probe rsync smartmontools sudo tmux mc ttyd fio
hash -r
EOF

# /usr/local/bin/spacevm-perf-fio-run
for i in /boot/kernel/kernel /usr/local/myb/mybinst.sh /usr/local/sbin/nginx /usr/local/myb/version /usr/local/bin/cbsd /usr/local/bin/cbsd-mq-api /usr/local/bin/cbsd-mq-router /usr/local/bin/curl /usr/local/bin/jq /usr/local/bin/genisoimage /usr/local/bin/beanstalkd /usr/local/bin/bash /usr/local/sbin/dmidecode /usr/local/bin/ttyd; do
	if [ ! -r "${cbsd_workdir}/jails-data/${jname}-data${i}" ]; then
		echo "error: No such: ${cbsd_workdir}/jails-data/${jname}-data${i}"
		exit 1
	fi
done

# ClonOS extra
if [ "${OSNAME}" = "ClonOS" ]; then

cbsd jexec jname=${jname} /bin/sh <<EOF
echo "Install ClonOS packages"
	pkg install -y lang/python311 lang/php85 net/libvncserver security/gnutls sqlite3 shells/bash www/node24 www/nginx \
sysutils/cbsd security/ca_root_nss security/sudo net/beanstalkd git devel/pkgconf tmux py311-numpy www/php85-session \
archivers/php85-zip databases/php85-sqlite3 databases/php85-pdo_sqlite security/php85-filter www/php85-opcache www/npm-node24 clonos clonos-ws
pkg remove -y go125
EOF
for i in /usr/local/www/clonos/version /usr/local/bin/node /usr/local/bin/php; do
	if [ ! -r "${cbsd_workdir}/jails-data/${jname}-data${i}" ]; then
		echo "error: No such: ${cbsd_workdir}/jails-data/${jname}-data${i}"
		exit 1
	fi
done
fi

# first init
cbsd jexec jname=${jname} /bin/sh <<EOF
unset workdir cbsd_workdir data path
/usr/local/cbsd/sudoexec/initenv /usr/local/cbsd/share/initenv.conf
/usr/local/myb/mybinst.sh
/usr/local/bin/cbsd get-profiles src=cloud json=1 > /usr/local/www/public/profiles.html
EOF


${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/var/cache/pkg/*
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/tmp/*
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/var/run/*
${FIND_CMD} ${cbsd_workdir}/jails-data/${jname}-data/ -type f -name \*.pkgsave -delete
${RSYNC_CMD} -avz /root/clonos-build/skel/ ${cbsd_workdir}/jails-data/${jname}-data/

[ ! -d ${cbsd_workdir}/jails-data/${jname}-data/root/bin ] && ${MKDIR_CMD} -p ${cbsd_workdir}/jails-data/${jname}-data/root/bin
${RSYNC_CMD} -avz ${cbsd_workdir}/jails-data/${jname}-data/usr/local/myb/bin/ ${cbsd_workdir}/jails-data/${jname}-data/root/bin/ || true

${cbsd_workdir}/jails-data/${jname}-data/bin/distribution init ${cbsd_workdir}/jails-data/${jname}-data

# replace pkg by pkg-static
${RM_CMD} ${cbsd_workdir}/jails-data/${jname}-data/usr/sbin/pkg
${CP_CMD} -a ${cbsd_workdir}/jails-data/${jname}-data/usr/local/sbin/pkg-static ${cbsd_workdir}/jails-data/${jname}-data/usr/sbin/pkg


### HOME
#echo "OK: ${progdir}/profiles/${OSNAME}/skel"
#[ -d "${progdir}/profiles/${OSNAME}/skel" ] && ${RSYNC_CMD} -avz ${progdir}/profiles/${OSNAME}/skel/ ${cbsd_workdir}/jails-data/${jname}-data/

#cbsd jexec jname=${jname} /bin/sh <<EOF
#pkg add /root/*.pkg
#pkg clean -ya
#rm -f /root/*.pkg
#EOF

cbsd jstop jname=${jname}

case "${OSNAME}" in
	ClonOS)
		producturl="https://clonos.convectix.com"
		bugreporturl="https://github.com/clonos/clonos-build"
	;;
	MyBee)
		producturl="https://mybee.convectix.com"
		bugreporturl="https://github.com/myb-project/myb-build"
	;;
esac

# set brand
/usr/local/cbsd/misc/cbsdsysrc -qf ${cbsd_workdir}/jails-data/${jname}-data/etc/rc.conf \
	producturl="${producturl}" \
	bugreporturl="${bugreporturl}" > /dev/null 2>&1

[ ! -d ${cbsd_workdir}/jails-data/${jname}-data/boot ] && ${MKDIR_CMD} ${cbsd_workdir}/jails-data/${jname}-data/boot

#${CAT_CMD} >> ${cbsd_workdir}/jails-data/${jname}-data/boot/loader.conf <<EOF
#module_path="/boot/kernel;/boot/modules;/boot/dtb;/boot/dtb/overlays"
#loader_menu_title="Welcome to ${OSNAME} Project"
#cryptodev_load="YES"
#EOF

## for firmware
${CAT_CMD} >> ${cbsd_workdir}/jails-system/${jname}/loader.conf <<EOF
module_path="/boot/kernel;/boot/modules;/boot/dtb;/boot/dtb/overlays"
loader_menu_title="Welcome to ${OSNAME} Project"

accf_data_load="YES"
accf_dns_load="YES"
accf_http_load="YES"
aesni_load="YES"
autoboot_delay="10"
cc_htcp_load="YES"
coretemp_load="YES"
cpu_microcode_load="YES"
cpu_microcode_name="/boot/firmware/intel-ucode.bin"
cpuctl_load="YES"
cryptodev_load="YES"
debug.acpi.disabled="thermal"
fib_dxr_load="YES
hw.efi.poweroff="0"
hw.em.rx_process_limit="-1"
hw.ibrs_disable="1"
hw.igb.rx_process_limit="-1"
hw.ix.rx_process_limit="-1"
hw.mfi.mrsas_enable="1"
hw.usb.no_pf="1"
hw.usb.no_shutdown_wait="1"
hw.vmm.amdvi.enable=1
if_bnxt_load="YES"
if_qlnxe_load="YES"
impi_load="YES"
ipfw_load="YES"
ipfw_nat_load="YES"
kern.geom.label.disk_ident.enable="0"
kern.geom.label.gptid.enable="0"
kern.racct.enable="1"
libalias_load="YES"
net.inet.ip.fw.default_to_accept="1"
net.isr.maxqlimit="1000000"
net.link.ifqmaxlen="16384"
opensolaris_load="YES"
pf_load="YES"
#pptdevs="1/0/0"
sem_load="YES"
vm.pmap.pti="0"
vmm_load="YES"
zfs_load="YES"
EOF

${PW_CMD} -R ${cbsd_workdir}/jails-data/${jname}-data usermod root -s /bin/csh
echo "cbsd" | ${PW_CMD} -R ${cbsd_workdir}/jails-data/${jname}-data usermod "root" -h 0

${FIND_CMD} ${cbsd_workdir}/jails-data/${jname}-data/ -type f -name \*.a -delete
${FIND_CMD} ${cbsd_workdir}/jails-data/${jname}-data/ -type f -name \*.o -delete
${CHFLAGS_CMD} -R noschg ${cbsd_workdir}/jails-data/${jname}-data
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/lib32
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/tests
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/include
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/share/man
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/share/doc
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/share/nls
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/share/games
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/share/examples

${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/atf-check
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/kcm
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/dma
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/smrsh
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/tftp-proxy
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/mail.local
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/ftpd
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/flua

${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/cpp
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/clang-cpp
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/clang++
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/clang
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/cc
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/c++
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/lldb
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/ld.lld
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/lldb-server
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/objdump
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-objdump
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-nm
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-ranlib
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-ar
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-readobj
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-readelf
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-profdata
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-symbolizer
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-addr2line
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-cov
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/gcov
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-strip
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-objcopy
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-size
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/kyua

${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/lib/libpmc.so.5

${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/sbin/cxgbetool
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/sbin/tcpdump
${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/usr/sbin/wpa_supplicant

${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/bin/tcsh
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/lib/debug

${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/etc/issue

echo "Convert ${jname} to bhyve image into /tmp..."
## convert to bhyve

# use BSDBOOT instead. we need only base.txz
#cbsd jail2iso jname=${jname} dstdir=/tmp media=mfs freesize=2m ver=${ver} efi=1
#cbsd jail2iso name=CBSD jname=${jname} dstdir=/tmp media=bhyve freesize=2m ver=${ver} efi=1
#cbsd jail2iso name=CBSD jname=${jname} dstdir=/tmp media=mfs freesize=2m ver=${ver} efi=1 mfs_struct_only=1

#cp -a ${cbsd_workdir}/basejail/FreeBSD-kernel_CBSD_amd64_15.0/boot/kernel/kernel.gz 
#echo "cbsd jail2iso name=CBSD jname=${jname} dstdir=/tmp media=mfs freesize=2m ver=${my_ver} efi=1 mfs_struct_only=1"
#cbsd jail2iso name=CBSD jname=${jname} dstdir=/tmp media=mfs freesize=2m ver=${my_ver} efi=1 mfs_struct_only=1
#ret=$?

cd ${cbsd_workdir}/jails-data/${jname}-data/

# remove hw_probe_enabled
cp -a ${cbsd_workdir}/jails-data/${jname}-data/etc/rc.conf /tmp
grep -v hw_probe /tmp/rc.conf > ${cbsd_workdir}/jails-data/${jname}-data/etc/rc.conf

echo "env XZ_OPT=\"-9 -T8\" ${TAR_CMD} -cJf /root/base.txz ."
env XZ_OPT="-9 -T8" ${TAR_CMD} -cJf /root/base.txz .

#cbsd up cbsdfile=${progdir}/micro-CBSDfile ver="${mybbasever}"
