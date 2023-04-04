#!/bin/sh

# $FreeBSD: $
#
# PROVIDE: clonos-vnc2wss
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# Add the following lines to /etc/rc.conf.local or /etc/rc.conf
# to enable this service:
#
# clonos_vnc2wss_enable (bool):	Set to YES to enable the clonos_vnc2wss service.
#			Default: NO
# clonos_vnc2wss_config (str):	File containing clonos_vnc2wss configuration details.
#			Default: /usr/local/etc/clonos_vnc2wss/clonos_vnc2wss.yml
# clonos_vnc2wss_user (str):	The user account used to run the clonos_vnc2wss daemon.
#			Do not specifically set this to an empty string as this
#			will cause the daemon to run as root.
#			Default: root
# clonos_vnc2wss_group (str):	The group account used to run the clonos_vnc2wss daemon.
#			Do not specifically set this to an empty string as this
#			will cause the daemon to run with group wheel.
#			Default: wheel
# clonos_vnc2wss_flags (str):	Extra flags passed to clonos_vnc2wss
#			Default: ""
# clonos_vnc2wss_facility (str):	Syslog facility to use
#			Default: local0
# clonos_vnc2wss_priority (str):	Syslog priority to use
#			Default: alert

. /etc/rc.subr
name=clonos_vnc2wss
rcvar=${name}_enable
load_rc_config $name

: ${clonos_vnc2wss_enable:="NO"}
: ${clonos_vnc2wss_user:="www"}
: ${clonos_vnc2wss_group:="www"}
: ${clonos_vnc2wss_directory:="/usr/local/www/clonos/public/novnc/utils"}
: ${clonos_vnc2wss_flags:=""}
: ${clonos_vnc2wss_facility:="local0"}
: ${clonos_vnc2wss_priority:="alert"}

pidfile="/var/run/${name}/${name}.pid"
daemon_pidfile="/var/run/${name}/${name}-daemon.pid"
logdir="/var/log/${name}"
logfile="${logdir}/${name}.log"

command="/usr/sbin/daemon"
procname="/usr/local/bin/bash"
command_args="-r -P ${daemon_pidfile} -p ${pidfile} -o ${logfile} -S -l ${clonos_vnc2wss_facility} -s ${clonos_vnc2wss_priority} -T ${name} ${procname} /usr/local/www/clonos/public/novnc/utils/novnc_proxy --listen 6081 --vnc 127.0.0.1:%%PORT%%"

start_precmd="clonos_vnc2wss_precmd"
stop_cmd=${name}_stop
status_cmd="${name}_status"

clonos_vnc2wss_precmd()
{
	cbsd_workdir="/usr/jails"

	if [ ! -d ${clonos_vnc2wss_directory} ]; then
		echo "no such directory: ${clonos_vnc2wss_directory}"
		exit 1
	fi

	cd ${clonos_vnc2wss_directory}

	[ ! -d ${logdir} ] && mkdir -p ${logdir}
	touch ${logfile}
	chown ${clonos_vnc2wss_user}:${clonos_vnc2wss_group} ${logdir} ${logfile}

	if [ ! -d "/var/run/${name}" ]; then
		install -d -g ${clonos_vnc2wss_group} -o ${clonos_vnc2wss_user} -m 0700 -- "/var/run/${name}"
	fi

	if [ ! -e "${pidfile}" ]; then
		install -g ${clonos_vnc2wss_group} -o ${clonos_vnc2wss_user} -- /dev/null "${pidfile}"
	fi
}

clonos_vnc2wss_status()
{
	local _err

	if [ -f "${daemon_pidfile}" ]; then
		pids=$( pgrep -F ${daemon_pidfile} 2>&1 )
		_err=$?
		if [ ${_err} -eq  0 ]; then
			echo "${name} is running as pid ${pids}."
			return 0
		else
			echo "pgrep: ${pids}"
		fi
	else
		echo "${name} is not running."
		return 1
	fi
}

clonos_vnc2wss_stop()
{

	ps -axfw -w -o pid,ucomm,command -ww | grep "6081 127.0.0.1" | while read _pid _ucomm _cmd; do
	case "${_ucomm}" in
		python*)
			kill -9 ${_pid}
			;;
	esac
	done

	if [ -f "${daemon_pidfile}" ]; then
		pids=$( pgrep -F ${daemon_pidfile} 2>&1 )
		_err=$?
		if [ ${_err} -eq  0 ]; then
			kill -9 ${pids} && /bin/rm -f ${daemon_pidfile}
		else
			echo "pgrep: ${pids}"
			#return ${_err}
		fi
		rm -f ${daemon_pidfile}
	fi

	if [ -r "${pidfile}" ]; then
		pids=$( pgrep -F ${pidfile} 2>&1 )
		_err=$?
		if [ ${_err} -eq  0 ]; then
			kill -9 ${pids} && /bin/rm -f ${pidfile}
		else
			echo "pgrep: ${pids}"
			#return ${_err}
		fi
		rm -f ${pidfile}
	fi

	return ${_err}

}

run_rc_command "$1"
