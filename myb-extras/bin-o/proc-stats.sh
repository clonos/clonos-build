#!/bin/sh
DST_DIR="/usr/local/www/public/metrics"
DST_FILE="${DST_DIR}/process"
ncpu=$( /sbin/sysctl -qn hw.ncpu )
HOST=$( hostname )
OLD_LINK=

[ ! -d ${DST_DIR} ] && mkdir -p ${DST_DIR}

find ${DST_DIR}/ -type f -name proc-stats\* -delete


while [ true ]; do
	DST_FILE_TMP=$( mktemp -p ${DST_DIR} -t proc-stats )
	chmod 0444 ${DST_FILE_TMP}
	OLD_LINK=$( readlink ${DST_FILE} )


	if [ -r "${DST_FILE}" ]; then
		OLD_LINK=$( readlink ${DST_FILE} )
	fi

	ps aux | while read _user _pid _cpu _mem _vsz _rss _tty _stat _start _time _command; do
		[ "${_user}" = "USER" ] && continue
		[ "${_command}" = "[idle]" ] && continue
		echo "cpu_usage{process=\"${_command}\", pid=\"${_pid}\"} ${_cpu}"
		echo "memory_usage_vsz{process=\"${_command}\", pid=\"${_pid}\"} ${_vsz}"
		echo "memory_usage_rss{process=\"${_command}\", pid=\"${_pid}\"} ${_rss}"
	done > ${DST_FILE_TMP}

	ln -sf ${DST_FILE_TMP} ${DST_FILE}
	if [ -n "${OLD_LINK}" ]; then
		rm -f "${OLD_LINK}"
	fi

	sleep 4
done
