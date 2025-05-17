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
	local _conf="${workdir}/etc/api.conf"

	. ${_conf}

	[ -z "${api_env_name}" ] && api_env_name="env"

	if [ -z "${next_uid}" ]; then
		/usr/local/cbsd/misc/cbsdsysrc -qf ${_conf} next_uid="1" > /dev/null 2>&1
		echo -n "${api_env_name}1"
		exit 0
	fi

	next_uid=$(( next_uid + 1 ))
	/usr/local/cbsd/misc/cbsdsysrc -qf ${_conf} next_uid="${next_uid}" > /dev/null 2>&1
	echo -n "${api_env_name}${next_uid}"
	exit 0
}

if [ "${1}" = "lock" ]; then
	shift
	get_recomendation
	exit 0
else
	# recursive execite via lockf wrapper
	LOCKF_CMD=$( which lockf )
	if [ -x "${LOCKF_CMD}" ]; then
		_lock_str="${LOCKF_CMD} -s -t10 /tmp/freejname.lock"
	else
		FLOCK_CMD=$( which flock )
		if [ -x "${FLOCK_CMD}" ]; then
			_lock_str="${FLOCK_CMD} -w10 -x /tmp/freejname.lock"
		else
			echo "no such 'lockf' or 'flock' cmd, please install it fist"
			exit 1
		fi
	fi

	${_lock_str} /usr/local/cbsd/modules/api.d/misc/freejname.sh lock $*
fi

exit 0
