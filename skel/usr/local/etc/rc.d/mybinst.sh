#!/bin/sh
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
/usr/sbin/daemon -o /var/log/mybinit.log /bin/sh /usr/local/myb/mybinst.sh
