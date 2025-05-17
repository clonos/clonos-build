#!/bin/sh
: ${distdir="/usr/local/cbsd"}

# MAIN
if [ -z "${workdir}" ]; then
	[ -z "${cbsd_workdir}" ] && . /etc/rc.conf
	[ -z "${cbsd_workdir}" ] && exit 0
	workdir="${cbsd_workdir}"
fi

[ ! -f "${distdir}/cbsd.conf" ] && exit 1

get_recomendation()
{
	local _cid="${1}"
	if [ ! -d /var/db/cbsd-api/${_cid} ]; then
		echo -n "vm1"
		exit 0
	fi

	for i in $( seq 1 255 ); do
		[ -r /var/db/cbsd-api/${_cid}/vm-vm${i} ] && continue
		echo -n "vm${i}"
		exit 0
	done
	exit 0
}

if [ "${1}" = "lock" ]; then
	shift
	get_recomendation "${1}"
	exit 0
else
	# recursive execite via lockf wrapper
	LOCKF_CMD=$( which lockf )
	if [ -x "${LOCKF_CMD}" ]; then
		_lock_str="${LOCKF_CMD} -s -t10 /tmp/freeid.lock"
	else
		FLOCK_CMD=$( which flock )
		if [ -x "${FLOCK_CMD}" ]; then
			_lock_str="${FLOCK_CMD} -w10 -x /tmp/freeid.lock"
		else
			echo "no such 'lockf' or 'flock' cmd, please install it fist"
			exit 1
		fi
	fi

	${_lock_str} /usr/local/cbsd/modules/api.d/misc/freeid.sh lock $*
fi

exit 0
