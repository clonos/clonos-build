#!/bin/sh

if [ -n "${1}" ]; then
	checkonly=1
else
	checkonly=0
fi

. /usr/local/cbsd/subr/ansiicolor.subr

ECHO="echo -e"

check="jail alma9 arch22 centos7 centos8 centos9 debian11 debian12 devuan5 dflybsd6 euro9 fedora37 fedora38 fedora39 fedora40 freebsd13_ufs freebsd13_zfs freebsd14_ufs freebsd14_zfs freebsd15_ufs freebsd15_zfs freefire14_ufs freepbx ghostbsd22 homeass kali2022 k8s netbsd9 netbsd10 openbsd7 opnsense22 oracle7 oracle8 oracle9 rocky8 rocky9 ubuntu22 ubuntu22_vdi ubuntu24 xigmanas"

if [ -z "${ver}" -o "${ver}" = "native" ]; then
	tmpver=$( uname -r )
	ver=${tmpver%%-*}
	unset tmpver
fi

if [ -n "${cbsd_workdir}" ]; then
	export workdir="${cbsd_workdir}"
else
	export workdir="/usr/jails"
fi

jail_iso="${workdir}/basejail/base_amd64_amd64_${ver}/bin/sh"
alma9_iso="${workdir}/src/iso/cbsd-cloud-Alma-9.3-x86_64-cloud.raw"
arch22_iso="${workdir}/src/iso/cbsd-cloud-arch-2022.09-cloud.raw"
centos7_iso="${workdir}/src/iso/cbsd-cloud-CentOS-7.9.0-x86_64-cloud.raw"
centos8_iso="${workdir}/src/iso/cbsd-cloud-CentOS-stream-8-20231106-x86_64-cloud.raw"
centos9_iso="${workdir}/src/iso/cbsd-cloud-CentOS-stream-9-20231113-x86_64-cloud.raw"
debian11_iso="${workdir}/src/iso/cbsd-cloud-Debian-x86-11.8.0.raw"
debian12_iso="${workdir}/src/iso/cbsd-cloud-Debian-x86-12.5.0.raw"
devuan5_iso="${workdir}/src/iso/cbsd-cloud-Devuan-x86-5.0.raw"
dflybsd6_iso="${workdir}/src/iso/cbsd-cloud-DragonflyBSD-hammer-x64-6.4.0.raw"
euro9_iso="${workdir}/src/iso/cbsd-cloud-Euro-9.3-x86_64-cloud.raw"
fedora37_iso="${workdir}/src/iso/cbsd-cloud-Fedora-37-x86_64-cloud.raw"
fedora38_iso="${workdir}/src/iso/cbsd-cloud-Fedora-38-x86_64-cloud.raw"
fedora39_iso="${workdir}/src/iso/cbsd-cloud-Fedora-39-x86_64-cloud.raw"
fedora40_iso="${workdir}/src/iso/cbsd-cloud-Fedora-40-x86_64-cloud.raw"
freebsd13_ufs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-ufs-13.3.0-RELEASE-amd64.raw"
freebsd13_zfs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-zfs-13.3.0-RELEASE-amd64.raw"
freebsd14_ufs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-ufs-14.0.10-CURRENT-amd64.raw"
freebsd14_zfs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-zfs-14.0.10-CURRENT-amd64.raw"
freebsd15_ufs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-ufs-15.0.2-CURRENT-amd64.raw"
freebsd15_zfs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-zfs-15.0.2-CURRENT-amd64.raw"
freefire14_ufs_iso="${workdir}/src/iso/cbsd-cloud-firestarter-ufs-14.0-RELEASE-amd64.raw"
freepbx_iso="${workdir}/src/iso/cbsd-cloud-FreePBX-16.0-x86_64-cloud.raw"
ghostbsd22_iso="${workdir}/src/iso/cbsd-cloud-GhostBSD-ufs-x64-22.11-RELEASE-amd64.raw"
homeass_iso="${workdir}/src/iso/cbsd-iso-haos_generic-x86-64-12.1.img"
kali2022_iso="${workdir}/src/iso/cbsd-cloud-cloud-Kali-2022-amd64.raw"
k8s_iso="${workdir}/src/iso/cbsd-cloud-cloud-kubernetes-27.1.2.raw"
netbsd10_iso="${workdir}/src/iso/cbsd-cloud-netbsd-10.0.raw"
netbsd9_iso="${workdir}/src/iso/cbsd-cloud-netbsd-9.3.raw"
openbsd7_iso="${workdir}/src/iso/cbsd-cloud-openbsd-75.raw"
opnsense22_iso="${workdir}/src/iso/cbsd-cloud-OPNSense-22.7-RELEASE-amd64.raw"
oracle7_iso="${workdir}/src/iso/cbsd-cloud-Oracle-7.9.0-x86_64-cloud.raw"
oracle8_iso="${workdir}/src/iso/cbsd-cloud-Oracle-8.8.0-x86_64-cloud.raw"
oracle9_iso="${workdir}/src/iso/cbsd-cloud-Oracle-9.3.0-x86_64-cloud.raw"
rocky8_iso="${workdir}/src/iso/cbsd-cloud-Rocky-8.8-x86_64-cloud.raw"
rocky9_iso="${workdir}/src/iso/cbsd-cloud-Rocky-9.3-x86_64-cloud.raw"
ubuntu22_iso="${workdir}/src/iso/cbsd-cloud-cloud-Ubuntu-x86-22.04.03.raw"
ubuntu22_vdi_iso="${workdir}/src/iso/cbsd-cloud-cloud-Ubuntu-vdi-x86-22.04.raw"
ubuntu24_iso="${workdir}/src/iso/cbsd-cloud-cloud-Ubuntu-x86-24.04.raw"
windows10_ru_iso="${workdir}/src/iso/cbsd-cloud-windows10ru-cloud.raw"
xigmanas_iso="${workdir}/src/iso/cbsd-cloud-XigmaNAS-13.1.0.5.9790-amd64.raw"

${ECHO} "${N2_COLOR} Hint: type '<img>' to get image or 'fetch_all.sh' to warm ALL images (Warning! LOTS of traffic)${N0_COLOR}"

for i in ${check}; do
	link=
	eval link="\$${i}_iso"
	found=0
	if [ -n "${link}" ]; then
		case "${i}" in
			jail)
				[ -x ${link} ] && found=1
				;;
			*)
				if [ -h ${link} ]; then
					vol=
					vol=$( readlink ${link} )
					[ -c ${vol} ] && found=1
				elif [ -r ${link} ]; then
					${ECHO} "${W1_COLOR}warning: ${N1_COLOR}not symlink: ${N2_COLOR}${link}${N0_COLOR}"
					found=1
				fi
				;;
		esac
	fi

	if [ ${found} -eq 1 ]; then
		${ECHO} "${N1_COLOR}image for '${N2_COLOR}${i}${N1_COLOR}': ${H3_COLOR}ready${N0_COLOR}"
	else
		${ECHO} "${N1_COLOR}image for '${N2_COLOR}${i}${N1_COLOR}': ${W1_COLOR}not found${N1_COLOR}, please run as root: '${N2_COLOR}${i}${N1_COLOR}'${N0_COLOR}"
	fi
done

[ ${checkonly} -eq 0 ] && exec /bin/sh

exit 0
