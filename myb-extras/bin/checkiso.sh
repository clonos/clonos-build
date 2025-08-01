#!/bin/sh

if [ -n "${1}" ]; then
	checkonly=1
else
	checkonly=0
fi

. /usr/local/cbsd/subr/ansiicolor.subr

ECHO="echo -e"

check="jail alma10 alma9 arch centos10 centos7 centos9 debian11 debian12 devuan5 dflybsd6 fedora39 fedora40 fedora41 fedora42 freebsd13_ufs freebsd13_zfs freebsd142_ufs freebsd142_zfs freebsd14_ufs freebsd14_zfs freebsd15_ufs freebsd15_zfs freefire14_ufs freepbx ghost24 homeass kali2024 k8s netbsd10 netbsd9 openbsd7 openbsd75 opnsense22 oracle10 oracle7 oracle8 oracle9 parrot5 rocky10 rocky9 ubuntu20 ubuntu22 ubuntu22_vdi ubuntu24 ubuntu24_vdi xigma13"

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
astra_iso="${workdir}/src/iso/cbsd-cloud-Astra-x86-1.8.raw"
alma10_iso="${workdir}/src/iso/cbsd-cloud-Alma-10.0-x86_64-cloud.raw"
alma9_iso="${workdir}/src/iso/cbsd-cloud-Alma-9.5-x86_64-cloud.raw"
arch_iso="${workdir}/src/iso/cbsd-cloud-arch-2022.09-cloud.raw"
centos10_iso="${workdir}/src/iso/cbsd-cloud-CentOS-stream-10-20250727.0-x86_64-cloud.raw"
centos7_iso="${workdir}/src/iso/cbsd-cloud-CentOS-7.9.0-x86_64-cloud.raw"
centos9_iso="${workdir}/src/iso/cbsd-cloud-CentOS-stream-9-20250303.0-x86_64-cloud.raw"
debian11_iso="${workdir}/src/iso/cbsd-cloud-Debian-x86-11.8.0.raw"
debian12_iso="${workdir}/src/iso/cbsd-cloud-Debian-x86-12.10.0.raw"
devuan5_iso="${workdir}/src/iso/cbsd-cloud-Devuan-x86-5.0.raw"
dflybsd6_iso="${workdir}/src/iso/cbsd-cloud-DragonflyBSD-hammer-x64-6.4.0.raw"
fedora39_iso="${workdir}/src/iso/cbsd-cloud-Fedora-39-x86_64-cloud.raw"
fedora40_iso="${workdir}/src/iso/cbsd-cloud-Fedora-40-x86_64-cloud.raw"
fedora41_iso="${workdir}/src/iso/cbsd-cloud-Fedora-41-x86_64-cloud.raw"
fedora42_iso="${workdir}/src/iso/cbsd-cloud-Fedora-42-x86_64-cloud.raw"
freebsd13_ufs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-ufs-13.4.0-RELEASE-amd64.raw"
freebsd13_zfs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-zfs-13.4.0-RELEASE-amd64.raw"
freebsd14_ufs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-ufs-14.3-RELEASE-amd64.raw"
freebsd14_zfs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-zfs-14.3-RELEASE-amd64.raw"
freebsd142_ufs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-ufs-14.2.0-RELEASE-amd64.raw"
freebsd142_zfs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-zfs-14.2.0-RELEASE-amd64.raw"
freebsd15_ufs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-ufs-15.0.8-CURRENT-amd64.raw"
freebsd15_zfs_iso="${workdir}/src/iso/cbsd-cloud-FreeBSD-zfs-15.0.8-CURRENT-amd64.raw"
freefire14_ufs_iso="${workdir}/src/iso/cbsd-cloud-firestarter-ufs-14.0-RELEASE-amd64.raw"
freepbx_iso="${workdir}/src/iso/cbsd-cloud-FreePBX-16.0-x86_64-cloud.raw"
ghost24_iso="${workdir}/src/iso/cbsd-cloud-GhostBSD-zfs-x64-24.07-RELEASE-amd64.raw"
homeass_iso="${workdir}/src/iso/cbsd-iso-haos_generic-x86-64-12.1.img"
kali2024_iso="${workdir}/src/iso/cbsd-cloud-cloud-Kali-2024.4-amd64.raw"
k8s_iso="${workdir}/src/iso/cbsd-cloud-cloud-kubernetes-27.1.2.raw"
netbsd10_iso="${workdir}/src/iso/cbsd-cloud-netbsd-10.1.raw"
netbsd9_iso="${workdir}/src/iso/cbsd-cloud-netbsd-9.3.raw"
openbsd7_iso="${workdir}/src/iso/cbsd-cloud-openbsd-76.raw"
opnsense22_iso="${workdir}/src/iso/cbsd-cloud-OPNSense-22.7-RELEASE-amd64.raw"
oracle10_iso="${workdir}/src/iso/cbsd-cloud-Oracle-10.0.0-x86_64-cloud.raw"
oracle7_iso="${workdir}/src/iso/cbsd-cloud-Oracle-7.9.0-x86_64-cloud.raw"
oracle8_iso="${workdir}/src/iso/cbsd-cloud-Oracle-8.8.0-x86_64-cloud.raw"
oracle9_iso="${workdir}/src/iso/cbsd-cloud-Oracle-9.3.0-x86_64-cloud.raw"
parrot5_iso="${workdir}/src/iso/cbsd-cloud-cloud-Parrot-5-amd64.raw"
rocky10_iso="${workdir}/src/iso/cbsd-cloud-Rocky-10.0-x86_64-cloud.raw"
rocky9_iso="${workdir}/src/iso/cbsd-cloud-Rocky-9.5-x86_64-cloud.raw"
ubuntu20_iso="${workdir}/src/iso/cbsd-cloud-cloud-Ubuntu-x86-20.raw"
ubuntu22_iso="${workdir}/src/iso/cbsd-cloud-cloud-Ubuntu-x86-22.04.03.raw"
ubuntu22_vdi_iso="${workdir}/src/iso/cbsd-cloud-cloud-Ubuntu-vdi-x86-22.04.raw"
ubuntu24_iso="${workdir}/src/iso/cbsd-cloud-cloud-Ubuntu-x86-24.04.raw"
ubuntu24_vdi_iso="${workdir}/src/iso/cbsd-cloud-cloud-Ubuntu-vdi-x86-24.04.raw"
windows10_ru_iso="${workdir}/src/iso/cbsd-cloud-windows10ru-cloud.raw"
xigma13_iso="${workdir}/src/iso/cbsd-cloud-XigmaNAS-13.1.0.5.9790-amd64.raw"

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
