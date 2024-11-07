#!/bin/sh
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

check_tty()
{
	local _v0=
	local _ret=

	/usr/bin/w -h -n | while read _user _tty _ip _x; do
		[ "${_tty}" = "v0" ] && exit 2
	done

	_ret=$?
	return ${_ret}
}

check_tty
_ret=$?
[ ${_ret} -eq 2 ] && exit 0

. /etc/rc.conf
[ -z "${OSNAME}" ] && OSNAME="MyBee"
. /usr/local/cbsd/cbsd.conf
. /usr/local/cbsd/subr/ansiicolor.subr

CURSORRST='\033[1000D'
printf "${CURSORRST}" >> /dev/ttyv0
clear > /dev/ttyv0

check_sshflags()
{
	local _i

	for _i in ${sshd_flags}; do
		p1=${_i%%=*}
		p2=${_i##*=}
		[ "${p1}" != "-oPermitRootLogin" ] && continue
		[ "${p2}" = "yes" ] && return 0
	done

	return 1
}

# ${myb_version}
if [ -r /usr/local/myb/version ]; then
	. /usr/local/myb/version
fi

[ -z "${myb_version}" ] && myb_version="unknown"
[ -z "${producturl}" ] && producturl="https://mybee.convectix.com"

if check_sshflags; then
	myb_ssh_root_ssh="Enabled "
else
	myb_ssh_root_ssh="Disabled"
fi

case ${PUB_WL} in
	enabled)
		PUB_WL_COLOR="${H2_COLOR}"
		;;
	disabled)
		PUB_WL_COLOR="${W1_COLOR}"
		;;
esac
case ${IP_WL} in
	enabled)
		IP_WL_COLOR="${H2_COLOR}"
		;;
	disabled)
		IP_WL_COLOR="${W1_COLOR}"
		;;
esac
case ${API_FQDN} in
	disabled)
		API_FQDN_COLOR="${W1_COLOR}"
		;;
	*)
		API_FQDN_COLOR="${H2_COLOR}"
		;;
esac

if [ -n "${myb_build}" ]; then
	echo "${OSNAME} ${myb_version} (build: ${myb_build}) console." >> /dev/ttyv0
else
	echo "${OSNAME} ${myb_version} console." >> /dev/ttyv0
fi
echo >> /dev/ttyv0
printf "${CURSORRST}" >> /dev/ttyv0

case "${API_FQDN}" in
	disabled|"")
		echo -e "API address: ${W1_COLOR}http://${ip4}${N0_COLOR}" >> /dev/ttyv0
		printf "${CURSORRST}" >> /dev/ttyv0
		[ -n "${ip6}" ] && echo -e "API v6 address: ${W1_COLOR}http://${ip6}${N0_COLOR}" >> /dev/ttyv0
		printf "${CURSORRST}" >> /dev/ttyv0
		;;
	*)
		echo -e "API address: ${W1_COLOR}http://${ip4} (${H3_COLOR}https://${API_FQDN}${W1_COLOR}) ${N0_COLOR}" >> /dev/ttyv0
		printf "${CURSORRST}" >> /dev/ttyv0
		[ -n "${ip6}" ] && echo -e "API v6 address: ${W1_COLOR}http://${ip6} (${H3_COLOR}https://${API_FQDN}${W1_COLOR})${N0_COLOR}" >> /dev/ttyv0
		printf "${CURSORRST}" >> /dev/ttyv0
		;;
esac
echo -e "LAN Network IPv4 Address: ${H3_COLOR}10.0.0.1${N0_COLOR}" >> /dev/ttyv0
echo >> /dev/ttyv0
printf "${CURSORRST}" >> /dev/ttyv0
echo -e "${H2_COLOR}API ACL: ${IP_WL_COLOR}${IP_WL}${NORMAL}" >> /dev/ttyv0
printf "${CURSORRST}" >> /dev/ttyv0
echo -e "${H2_COLOR}Pubkey WhiteList: ${PUB_WL_COLOR}${PUB_WL}${NORMAL}" >> /dev/ttyv0
printf "${CURSORRST}" >> /dev/ttyv0
echo -e "${H2_COLOR}SSH root user: ${myb_ssh_root_ssh}${NORMAL}" >> /dev/ttyv0

case "${ttyd_enable}" in
	[Yy][Ee][Ss])
		case "${API_FQDN}" in
			disabled|"")
				echo -e "${H2_COLOR}Websocket CLI/Shell enabled: ${H3_COLOR}http://${ip4}/shell${NORMAL}" >> /dev/ttyv0
				printf "${CURSORRST}" >> /dev/ttyv0
				;;
			*)
				echo -e "${H2_COLOR}Websocket CLI/Shell enabled: http://${ip4}/shell (${H3_COLOR}https://${API_FQDN}/shell${H2_COLOR})${NORMAL}" >> /dev/ttyv0
				printf "${CURSORRST}" >> /dev/ttyv0
				;;
		esac
		;;
esac

echo >> /dev/ttyv0
printf "${CURSORRST}" >> /dev/ttyv0

exit 0
