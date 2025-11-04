#!/bin/sh
DST_DIR="/usr/local/www/public/metrics"
DST_FILE="${DST_DIR}/cpu"
ncpu=$( /sbin/sysctl -qn hw.ncpu )
HOST=$( hostname )
OLD_LINK=

[ ! -d ${DST_DIR} ] && mkdir -p ${DST_DIR}
find ${DST_DIR}/ -type f -name cpu-stats\* -delete

while [ true ]; do
	DST_FILE_TMP=$( mktemp -p ${DST_DIR} -t cpu-stats )
	chmod 0444 ${DST_FILE_TMP}
	echo "cores{host=\"${HOST}\"} ${ncpu}" > ${DST_FILE_TMP}

	if [ -r "${DST_FILE}" ]; then
		OLD_LINK=$( readlink ${DST_FILE} )
	fi

	# CPU 0:  7.1% user, 85.7% nice,  0.0% system,  0.0% interrupt,  7.1% idle
	top -P 1 -d3 -b -s0.5 | grep ^CPU | tail -n ${ncpu} | while read _cpu _cpu_num _user_percent _tmp _nice_percent _tmp _system_percent _tmp _interrupt_percent _tmp _idle_percent _tmp; do
		_cpu_num=${_cpu_num%%:*}
		_idle_percent=${_idle_percent%%%*}
		_cpu_busy=$( echo "100 - ${_idle_percent}" | bc )
		cat >> ${DST_FILE_TMP}<<EOF
cores_usage{core="${_cpu_num}", host="${HOST}"} ${_cpu_busy}
EOF
	done

	ln -sf ${DST_FILE_TMP} ${DST_FILE}
	if [ -n "${OLD_LINK}" ]; then
		rm -f "${OLD_LINK}"
	fi
	sleep 10
done
