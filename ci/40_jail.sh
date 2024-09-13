#!/bin/sh
. /etc/rc.conf          # mybbasever
jname="mybee1"

pgm="${0##*/}"				# Program basename
progdir="${0%/*}"			# Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )
. ${progdir}/cmd.subr
. ${progdir}/brand.conf

tmpver=$( ${UNAME_CMD} -r )
ver=${tmpver%%-*}
unset tmpver
#${CP_CMD} -a ${progdir}/skel/usr/local/etc/pkg/repos/MyBee-latest.conf /usr/local/etc/pkg/repos/MyBee-latest.conf

cbsd destroy cbsdfile=${progdir}/mybee-CBSDfile || true
cbsd destroy cbsdfile=${progdir}/micro-CBSDfile || true

cbsd up cbsdfile=${progdir}/mybee-CBSDfile
cbsd jset ver=${ver} jname=${jname}

${MKDIR_CMD} ${cbsd_workdir}/jails-data/${jname}-data/dev ${cbsd_workdir}/jails-data/${jname}-data/tmp
${CHMOD_CMD} 0777 ${cbsd_workdir}/jails-data/${jname}-data/tmp
${CHMOD_CMD} u+t ${cbsd_workdir}/jails-data/${jname}-data/tmp
${MOUNT_CMD} -t devfs devfs ${cbsd_workdir}/jails-data/${jname}-data/dev

PKG_BASE="FreeBSD-runtime"

if [ -r "${progdir}/profiles/${OSNAME}/basejail.conf" ]; then
	echo "GET PKG FROM: ${progdir}/profiles/${OSNAME}/basejail.conf"
	. "${progdir}/profiles/${OSNAME}/basejail.conf"
else
	echo "no such PKG_BASE profiles: ${progdir}/profiles/${OSNAME}/basejail.conf"
fi

env ASSUME_ALWAYS_YES=yes SIGNATURE_TYPE=none IGNORE_OSVERSION=yes pkg -C /root/clonos-build/etc/pkg/pkg.conf update -f -r MyBee-latest
env ASSUME_ALWAYS_YES=yes SIGNATURE_TYPE=none IGNORE_OSVERSION=yes pkg -C /root/clonos-build/etc/pkg/pkg.conf -r ${cbsd_workdir}/jails-data/${jname}-data install -r MyBee-latest ${PKG_BASE}

#_rpath=$( realpath ${cbsd_workdir}/jails-data/${jname}-data )
#make -C /usr/src installworld DESTDIR="${_rpath}"
#make -C /usr/src distribution DESTDIR="${_rpath}"

cbsd jstart jname=${jname}

[ ! -d ${cbsd_workdir}/jails-data/${jname}-data/usr/local/etc/pkg/repos ] && ${MKDIR_CMD} -p ${cbsd_workdir}/jails-data/${jname}-data/usr/local/etc/pkg/repos
${CAT_CMD} > ${cbsd_workdir}/jails-data/${jname}-data/usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
FreeBSD: {
  url: "pkg+https://pkg.FreeBSD.org/\${ABI}/quarterly",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
EOF

#spacevm-sendfio
cbsd jexec jname=${jname} /bin/sh <<EOF
pkg update -f
pkg install -y myb nginx cbsd cbsd-mq-router cbsd-mq-api curl jq cdrkit-genisoimage ca_root_nss beanstalkd bash dmidecode hw-probe rsync smartmontools sudo tmux mc ttyd fio
hash -r
/usr/local/cbsd/sudoexec/initenv /usr/local/cbsd/share/initenv.conf
/usr/local/myb/mybinst.sh
EOF


# /usr/local/bin/spacevm-perf-fio-run
for i in /usr/local/sbin/nginx /usr/local/myb/version /usr/local/bin/cbsd /usr/local/bin/cbsd-mq-api /usr/local/bin/cbsd-mq-router /usr/local/bin/curl /usr/local/bin/jq /usr/local/bin/genisoimage /usr/local/bin/beanstalkd /usr/local/bin/bash /usr/local/sbin/dmidecode /usr/local/bin/ttyd; do
	if [ ! -r "${cbsd_workdir}/jails-data/${jname}-data${i}" ]; then
		echo "error: No such: ${cbsd_workdir}/jails-data/${jname}-data${i}"
		exit 1
	fi
done

${RM_CMD} -f ${cbsd_workdir}/jails-data/${jname}-data/var/cache/pkg/*
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/tmp/*
${RM_CMD} -rf ${cbsd_workdir}/jails-data/${jname}-data/var/run/*
${FIND_CMD} ${cbsd_workdir}/jails-data/${jname}-data/ -type f -name \*.pkgsave -delete
${RSYNC_CMD} -avz /root/clonos-build/skel/ ${cbsd_workdir}/jails-data/${jname}-data/

[ ! -d ${cbsd_workdir}/jails-data/${jname}-data/root/bin ] && ${MKDIR_CMD} -p ${cbsd_workdir}/jails-data/${jname}-data/root/bin
${RSYNC_CMD} -avz ${cbsd_workdir}/jails-data/${jname}-data/usr/local/myb/bin/ ${cbsd_workdir}/jails-data/${jname}-data/root/bin/ || true

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
sysrc -qf ${cbsd_workdir}/jails-data/${jname}-data/etc/rc.conf \
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

## ROOTFS IMG:
cbsd sysrc jname=${jname} \
	sshd_flags="-oUseDNS=no -oPermitRootLogin=without-password -oPort=22222"
	root_rw_mount="YES" \
	sshd_enable="YES" \
	rc_startmsgs="YES"

#        ifconfig_DEFAULT="inet ${myip} up" \
#        defaultrouter="${mygw}" \


pw -R ${cbsd_workdir}/jails-data/${jname}-data usermod root -s /bin/csh
echo "cbsd" | pw -R ${cbsd_workdir}/jails-data/${jname}-data usermod "root" -h 0

#cp -a /root/bhyve-mydesk/init-part.sh ${cbsd_workdir}/jails-data/${jname}-data/root/
#cp -a /root/bhyve-mydesk/base.txz ${cbsd_workdir}/jails-data/${jname}-data/root/

find  ${cbsd_workdir}/jails-data/${jname}-data/ -type f -name \*.a -delete
find  ${cbsd_workdir}/jails-data/${jname}-data/ -type f -name \*.o -delete
chflags -R noschg ${cbsd_workdir}/jails-data/${jname}-data
rm -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/lib32
rm -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/tests
rm -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/include
rm -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/share/man
rm -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/share/doc
rm -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/share/nls
rm -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/share/games
rm -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/share/examples

rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/atf-check
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/kcm
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/dma
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/smrsh
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/tftp-proxy
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/mail.local
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/ftpd
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/libexec/flua

rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/cpp
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/clang-cpp
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/clang++
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/clang
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/cc
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/c++
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/lldb
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/ld.lld
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/lldb-server
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/objdump
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-objdump
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-nm
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-ranlib
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-ar
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-readobj
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-readelf
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-profdata
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-symbolizer
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-addr2line
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-cov
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/gcov
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-strip
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-objcopy
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/llvm-size
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/bin/kyua

rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/lib/libpmc.so.5

rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/sbin/cxgbetool
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/sbin/iasl
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/sbin/tcpdump
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/sbin/wpa_supplicant
rm -f ${cbsd_workdir}/jails-data/${jname}-data/usr/sbin/ntpd

rm -f ${cbsd_workdir}/jails-data/${jname}-data/bin/tcsh
rm -rf ${cbsd_workdir}/jails-data/${jname}-data/usr/lib/debug

echo "Convert ${jname} to bhyve image into /tmp..."
## convert to bhyve

#cbsd jail2iso jname=${jname} dstdir=/tmp media=mfs freesize=2m ver=${ver} efi=1
#cbsd jail2iso jname=${jname} dstdir=/tmp media=bhyve freesize=2m ver=${ver} efi=1
#cbsd jail2iso jname=${jname} dstdir=/tmp media=mfs freesize=2m ver=${ver} efi=1 mfs_struct_only=1

#cp -a ${cbsd_workdir}/basejail/FreeBSD-kernel_CBSD_amd64_15.0/boot/kernel/kernel.gz 
#echo "cbsd jail2iso name=CBSD jname=${jname} dstdir=/tmp media=mfs freesize=2m ver=${my_ver} efi=1 mfs_struct_only=1"
#cbsd jail2iso name=CBSD jname=${jname} dstdir=/tmp media=mfs freesize=2m ver=${my_ver} efi=1 mfs_struct_only=1
#ret=$?

cd ${cbsd_workdir}/jails-data/${jname}-data/
env XZ_OPT="-9 -T8" tar -cJf /root/base.txz .

#cbsd up cbsdfile=${progdir}/micro-CBSDfile ver="${mybbasever}"
