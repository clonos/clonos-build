#!/bin/sh

MYROOT="/rel"

if [ ! -r "${MYROOT}/clonos.txz" ]; then
	echo "Put clonos.txz here"
	exit
fi

if [ ! -r "${MYROOT}/auto" ]; then
	echo "Put auto here"
	exit
fi

[ -r /scratch/usr/obj/usr/src/amd64.amd64/release/disc1.iso ] && rm -f /scratch/usr/obj/usr/src/amd64.amd64/release/disc1.iso
[ -r /scratch/usr/obj/usr/src/amd64.amd64/release/memstick.img ] && rm -f /scratch/usr/obj/usr/src/amd64.amd64/release/memstick.img

set -o xtrace

#[ ! -d /scratch/usr/src/sys/amd64/conf ] && mkdir -p /scratch/usr/src/sys/amd64/conf
#[ ! -d /scratch/dev ] && mkdir /scratch/dev
#mount -t devfs devfs /scratch/dev
#cp -a /usr/jails/etc/defaults/FreeBSD-kernel-GENERIC-amd64-12 /scratch/usr/src/sys/amd64/conf/CBSD

if [ ! -x /scratch/bin/sh ]; then
	echo "NEW"
	echo "sh /rel/release.sh -c /rel/release.conf"
	sh /rel/release.sh -c /rel/release.conf
	cp -a /usr/jails/etc/defaults/FreeBSD-kernel-GENERIC-amd64-12 /scratch/usr/src/sys/amd64/conf/CBSD
else
	cp -a /usr/jails/etc/defaults/FreeBSD-kernel-GENERIC-amd64-12 /scratch/usr/src/sys/amd64/conf/CBSD
	[ ! -d /scratch/usr/obj/usr/src/amd64.amd64/release ] && mkdir -p /scratch/usr/obj/usr/src/amd64.amd64/release
	cp -a ${MYROOT}/clonos.txz /scratch/usr/obj/usr/src/amd64.amd64/release/clonos.txz
	cd /scratch/usr/obj/usr/src/amd64.amd64/release
	#/usr/jails/src/src_12/src/release/scripts/make-manifest.sh *.txz > MANIFEST
	/rel/scripts/make-manifest.sh *.txz > MANIFEST

	cp -a /scratch/usr/obj/usr/src/amd64.amd64/release/*.txz /scratch/usr/obj/usr/src/amd64.amd64/release/disc1/usr/freebsd-dist/
	cp -a /scratch/usr/obj/usr/src/amd64.amd64/release/MANIFEST /scratch/usr/obj/usr/src/amd64.amd64/release/disc1/usr/freebsd-dist/
	cp -a ${MYROOT}/auto /scratch/usr/obj/usr/src/amd64.amd64/release/disc1/usr/libexec/bsdinstall/auto
	cp -a ${MYROOT}/rc.local /scratch/usr/obj/usr/src/amd64.amd64/release/disc1/etc/

	for i in cloninst.sh loader.conf motd.sh rc.local; do
		cp -a ${MYROOT}/${i} /scratch/usr/obj/usr/src/amd64.amd64/release/disc1/usr/freebsd-dist/
	done

	echo "sh /rel/release-second.sh -c /rel/release.conf-second"
	sh /rel/release-second.sh -c /rel/release.conf-second
fi

#umount /scratch/dev || true

set +o xtrace
