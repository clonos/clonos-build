#!/bin/sh
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
clear
service netif start > /dev/null 2>&1
echo
echo " *** ClonOS post-install script *** "
echo

cd /clonos/Latest
tar xfz pkg.txz
mkdir -p /usr/local/sbin
cp -a /clonos/Latest/usr/local/sbin/pkg-static /usr/local/sbin
/usr/local/sbin/pkg-static add -f /clonos/Latest/pkg.txz
rehash
hash -r
cd /clonos/
pkg add *.txz
pkg add clonos.txz > /dev/null 2>&1
sleep 2

echo "=== Initial CBSD setup ==="

hostname=$( sysrc -n 'hostname' )

auto_iface=$( /sbin/route -n get 0.0.0.0 | /usr/bin/awk '/interface/{print $2}' )

if [ -z "${auto_iface}" ]; then
	for i in $( ifconfig -l ); do
		case "${i}" in
			lo*)
				continue
				;;
			*)
				auto_iface="${i}"
				;;
		esac
	done

fi

ip4_addr=$( ifconfig ${auto_iface} 2>/dev/null | /usr/bin/awk '/inet [0-9]+/ { print $2}' | /usr/bin/head -n 1 )

cat > /tmp/initenv.conf <<EOF
nodename="${hostname}"
nodeip="${ip4_addr}"
jnameserver="8.8.8.8 8.8.4.4"
nodeippool="10.0.0.0/24"
natip="${ip4_addr}"
nat_enable="pf"
mdtmp="8"
ipfw_enable="1"
zfsfeat="1"
hammerfeat="0"
fbsdrepo="1"
repo="http://bsdstore.ru"
workdir="/usr/jails"
jail_interface="${auto_iface}"
parallel="5"
stable="0"
statsd_bhyve_enable="1"
statsd_jail_enable="1"
statsd_hoster_enable="1"
EOF

env workdir=/usr/jails /usr/local/cbsd/sudoexec/initenv inter=0 /tmp/initenv.conf

echo "=== Initial ClonOS setup ==="

[ ! -h /usr/local/bin/python ] && ln -s /usr/local/bin/python2.7 /usr/local/bin/python

cp /usr/local/etc/sudoers_10_www.clonos.sample /usr/local/etc/sudoers.d/10_www
chmod 0440 /usr/local/etc/sudoers.d/10_www

cp /usr/local/etc/nginx/nginx.conf.clonos.sample /usr/local/etc/nginx/nginx.conf
cp /usr/local/etc/nginx/sites-enabled/cbsdweb.conf.clonos.sample /usr/local/etc/nginx/sites-enabled/cbsdweb.conf

cp /usr/local/etc/supervisor.d/program_vnc2wss.conf.clonos.sample /usr/local/etc/supervisor.d/program_vnc2wss.conf
cp /usr/local/etc/supervisor.d/program_ws.conf.clonos.sample /usr/local/etc/supervisor.d/program_ws.conf
cp /usr/local/etc/supervisord.conf.clonos.sample /usr/local/etc/supervisord.conf

cp /usr/local/etc/php.ini.clonos.sample /usr/local/etc/php.ini
cp /usr/local/etc/php-fpm.d/www-php-fpm.conf.clonos.sample /usr/local/etc/php-fpm.d/www.conf

[ ! -d  /var/log/supervisor ] && mkdir -p  /var/log/supervisor

sysrc nginx_enable="YES"
sysrc php_fpm_enable="YES"
sysrc supervisord_enable="YES"
sysrc cbsdd_enable="YES"
sysrc clear_tmp_enable="YES"
sysrc beanstalkd_enable="YES"
sysrc beanstalkd_flags="-l 127.0.0.1 -p 11300"
sysrc cbsd_statsd_jail_enable="YES"
sysrc cbsd_statsd_hoster_enable="YES"
sysrc cbsd_statsd_bhyve_enable="YES"
sysrc kld_list="if_bridge if_tap nmdm linux linux64"

sysrc ntpdate_enable="YES"
sysrc ntpd_enable="YES"
sysrc ntpd_sync_on_start="YES"

[ ! -d /var/db/clonos ] && mkdir -p /var/db/clonos
[ ! -d /usr/jails/modules ] && mkdir -p /usr/jails/modules
[ ! -d /usr/local/cbsd/modules ] && mkdir -p /usr/local/cbsd/modules
[ ! -d /usr/local/cbsd/forms.d ] && mkdir -p /usr/local/cbsd/forms.d
#mv /usr/local/www/clonos/vncterm.d /usr/local/cbsd/modules/
#mv /usr/local/www/clonos/cbsd_queue.d /usr/local/cbsd/modules/
#mv /usr/local/www/clonos/clonos_database /usr/local/cbsd/modules/forms.d/clonos_database

[ ! -d /usr/jails/etc ] && mkdir /usr/jails/etc
cat > /usr/jails/etc/modules.conf <<EOF
pkg.d
bsdconf.d
zfsinstall.d
puppet.d
vncterm.d
convectix.d
tui.d
cbsd_queue.d
EOF

/usr/local/bin/cbsd initenv inter=0
chown -R www:www /usr/local/www
pw groupmod cbsd -M www

sh /usr/local/cbsd/modules/forms.d/clonos_database/initforms.sh
chown -R www:www /var/db/clonos

#!/bin/sh
cat > /etc/rc.local << EOF
# insurance for DHCP-based ifaces
for i in \$( egrep -E '^ifconfig_[aA-zZ]+[0-9]+="DHCP"' /etc/rc.conf | tr "_=" " " | awk '{printf \$2" "}' ); do
	/sbin/dhclient \${i}
done

# restore motd
if ! grep -q /root/bin/motd.sh /etc/csh.login 2>/dev/null; then
	echo 'sh /root/bin/motd.sh' >> /etc/csh.login
fi

EOF

# tmp: update CBSD code to latest
#rm -rf /usr/local/cbsd
#echo "/usr/local/bin/rsync -avz /clonos/bases/cbsd/ /usr/local/cbsd/"
#/usr/local/bin/rsync -az /clonos/bases/cbsd/ /usr/local/cbsd/
#/usr/local/bin/cbsd initenv inter=0

mv /clonos/bases/base_* /usr/jails/basejail/
/usr/local/bin/cbsd register_base arch=amd64 target_arch=amd64 ver=12.0 stable=0
chflags -R noschg /clonos
echo "Importing cbsdpuppet jail..."
/usr/local/bin/cbsd version
/usr/local/bin/cbsd jimport fs_feat=0 jname=/clonos/bases/cbsdpuppet1.img
/usr/local/bin/cbsd jset jname=cbsdpuppet1 protected=1
/usr/local/bin/cbsd jset jname=cbsdpuppet1 hidden=1
rm -rf /clonos

mkdir /var/coredumps
chmod 0777 /var/coredumps

# temporary fix perms for CBSD 12.0.2 (remove it after 12.0.3 released)
#mkdir /usr/jails/formfile
#chown cbsd:cbsd /usr/jails/formfile
#chmod 0775 /usr/jails/formfile

uplink_iface4=$( /sbin/route -n -4 get 0.0.0.0 2>/dev/null | /usr/bin/awk '/interface/{print $2}' )
ip=$( /sbin/ifconfig ${uplink_iface4} | /usr/bin/awk '/inet [0-9]+/{print $2}'| /usr/bin/head -n1 )
cat > /etc/issue <<EOF

 === Welcome to ClonOS 18.11 BETA1 ===
 * UI: http://${ip}
 * SSH: ${ip}:22222

EOF
