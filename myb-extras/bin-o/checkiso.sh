#!/bin/sh

if [ -n "${1}" ]; then
	checkonly=1
else
	checkonly=0
fi

. /usr/local/cbsd/subr/ansiicolor.subr

ECHO="echo -e"

check=
. /root/bin/cbsd_checkiso.conf

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
