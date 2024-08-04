#!/bin/sh

mydesk_reroot()
{
#	_source="/dev/ada1"
#	/usr/sbin/zdb -l ${_source} | /usr/bin/grep pool_guid

#	_pool_guid=$( /usr/sbin/zdb -l ${_source} | /usr/bin/grep "pool_guid:" | /usr/bin/awk '{printf $2}' )

#	echo "to test:"
#	echo "/sbin/zpool import -f -R /mnt ${_pool_guid}"

	# root replacenment: need to kill all services
	#/sbin/zpool import -f getdesk

	case "${GETDESK_REROOT}" in
		1)
			/sbin/zpool import -f -R /mnt getdesk
			_newroot=/mnt
			;;
		0)
			_newroot=
			/sbin/zpool import -f getdesk
			;;
	esac

	/sbin/zfs mount getdesk/ROOT/default-install || true
	/sbin/zfs mount -a
	/sbin/umount -f /dev || true
	# это надо даже если devfs уже смонтирован (todo: попробовать размонтировать старый ?)
	/sbin/mount -t devfs devfs ${_newroot}/dev
	case "${GETDESK_REROOT}" in
		1)
			#exec /bin/sh ${_newroot}/etc/rc
			/bin/sh ${_newroot}/etc/rc
			;;
		0)
			#exec /bin/sh /etc/rc
			/bin/sh /etc/rc
			;;
	esac

	exit 0
}

if [ "$1" = "new" ]; then
	export GETDESK_REROOT=1
else
	export GETDESK_REROOT=0
fi

mydesk_reroot
exit 0
