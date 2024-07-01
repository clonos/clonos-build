#!/bin/sh
. /etc/rc.conf          # mybbasever
jname="mybee1"

pgm="${0##*/}"				# Program basename
progdir="${0%/*}"			# Program directory
progdir=$( realpath ${progdir} )
progdir=$( dirname ${progdir} )
. ${progdir}/cmd.subr
. ${progdir}/brand.conf

${CP_CMD} /root/clonos-build/skel/usr/local/etc/pkg/repos/MyBee-latest.conf /usr/local/etc/pkg/repos/MyBee-latest.conf

cbsd destroy cbsdfile=${progdir}/mybee-CBSDfile || true
cbsd destroy cbsdfile=${progdir}/micro-CBSDfile || true

cbsd up cbsdfile=${progdir}/mybee-CBSDfile

${MKDIR_CMD} /usr/jails/jails-data/mybee1-data/dev /usr/jails/jails-data/mybee1-data/tmp

${CHMOD_CMD} 0777 /usr/jails/jails-data/mybee1-data/tmp
${CHMOD_CMD} u+t /usr/jails/jails-data/mybee1-data/tmp

${MOUNT_CMD} -t devfs devfs /usr/jails/jails-data/mybee1-data/dev

env ASSUME_ALWAYS_YES=yes SIGNATURE_TYPE=none IGNORE_OSVERSION=yes pkg -r /usr/jails/jails-data/mybee1-data install -r MyBee-latest FreeBSD-acpi FreeBSD-utilities FreeBSD-bhyve FreeBSD-bootloader FreeBSD-bsdinstall FreeBSD-caroot FreeBSD-certctl FreeBSD-certctl-man FreeBSD-clibs FreeBSD-console-tools FreeBSD-csh FreeBSD-devd FreeBSD-devmatch FreeBSD-dhclient FreeBSD-efi-tools FreeBSD-elftoolchain FreeBSD-fetch FreeBSD-geom FreeBSD-inetd FreeBSD-ipfw FreeBSD-iscsi FreeBSD-jail FreeBSD-lib9p FreeBSD-libarchive FreeBSD-libbegemot FreeBSD-libblocksruntime FreeBSD-libbsm FreeBSD-libbz2 FreeBSD-libcasper FreeBSD-libdwarf FreeBSD-libevent1 FreeBSD-libexecinfo FreeBSD-libldns FreeBSD-liblzma FreeBSD-libmagic FreeBSD-libpathconv FreeBSD-libsqlite3 FreeBSD-libstdbuf FreeBSD-libstdthreads FreeBSD-libthread_db FreeBSD-libucl FreeBSD-libvmmapi FreeBSD-lld FreeBSD-locales FreeBSD-mlx-tools FreeBSD-mtree FreeBSD-natd FreeBSD-newsyslog FreeBSD-nfs FreeBSD-nvme-tools FreeBSD-openssl FreeBSD-periodic FreeBSD-pf FreeBSD-rc FreeBSD-resolvconf FreeBSD-runtime FreeBSD-ssh FreeBSD-syscons FreeBSD-syslogd FreeBSD-ufs FreeBSD-netmap FreeBSD-vi FreeBSD-zfs FreeBSD-zoneinfo FreeBSD-openssl-lib FreeBSD-kerberos-lib FreeBSD-tcpd FreeBSD-kernel-cbsd.cbsd pkg
cbsd jstart jname=mybee1

cbsd jexec jname=mybee1 /bin/sh <<EOF
pkg install -y myb nginx cbsd cbsd-mq-router cbsd-mq-api curl jq cdrkit-genisoimage ca_root_nss beanstalkd bash dmidecode hw-probe rsync smartmontools sudo tmux mc ttyd fio spacevm-sendfio
hash -r
/usr/local/cbsd/sudoexec/initenv /usr/local/cbsd/share/initenv.conf
/usr/local/myb/mybinst.sh
EOF

for i in /usr/local/sbin/nginx /usr/local/myb/myb/version /usr/local/bin/cbsd /usr/local/bin/cbsd-mq-api /usr/local/bin/cbsd-mq-router /usr/local/bin/curl /usr/local/bin/jq /usr/local/bin/genisoimage /usr/local/bin/beanstalkd /usr/local/bin/bash /usr/local/sbin/dmidecode /usr/local/bin/ttyd /usr/local/bin/spacevm-perf-fio-run; do
	if [ ! -r "/usr/jails/jails-data/mybee1-data${i}" ]; then
		echo "error: No such ${i}"
		exit 1
	fi
done

cbsd jstop jname=mybee1

${RM_CMD} -f /usr/jails/jails-data/mybee1-data/var/cache/pkg/*
${RM_CMD} -rf /usr/jails/jails-data/mybee1-data/tmp/*
${RM_CMD} -rf /usr/jails/jails-data/mybee1-data/var/run/*

${FIND_CMD} /usr/jails/jails-data/mybee1-data/ -type f -name \*.pkgsave -delete

${RSYNC_CMD} -avz /root/clonos-build/skel/ /usr/jails/jails-data/mybee1-data/

[ ! -d /usr/jails/jails-data/mybee1-data/root/bin ] && ${MKDIR_CMD} -p /usr/jails/jails-data/mybee1-data/root/bin
${RSYNC_CMD} -avz /usr/jails/jails-data/mybee1-data/usr/local/myb/bin/ /usr/jails/jails-data/mybee1-data/root/bin/ || true

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
sysrc -qf /usr/jails/jails-data/mybee1-data/etc/rc.conf \
	producturl="${producturl}" \
	bugreporturl="${bugreporturl}" > /dev/null 2>&1

[ ! -d /usr/jails/jails-data/mybee1-data/boot ] && ${MKDIR_CMD} /usr/jails/jails-data/mybee1-data/boot

${CAT_CMD} >> /usr/jails/jails-data/mybee1-data/boot/loader.conf <<EOF
module_path="/boot/kernel;/boot/modules;/boot/dtb;/boot/dtb/overlays"
loader_menu_title="Welcome to ${OSNAME} Project"
cryptodev_load="YES"
EOF

cd /usr/jails/jails-data/mybee1-data/

env  XZ_OPT="-9 -T8" tar -cJf /root/base.txz .

#cbsd up cbsdfile=${progdir}/micro-CBSDfile ver="${mybbasever}"
