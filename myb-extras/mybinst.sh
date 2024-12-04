#!/bin/sh
# TODO: sync with upgrade.sh
#
OPATH="${PATH}"
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

# grafefull restart for WEB services?
web=0

while getopts "w:" opt; do
	case "${opt}" in
		w) web="1" ;;
	esac
	shift $(($OPTIND - 1))
done

myb_firstboot="1"				# already initialized ?
[ -r /etc/rc.conf ] && . /etc/rc.conf
[ -r /usr/local/myb/brand.conf ] && . /usr/local/myb/brand.conf
[ -z "${OSNAME}" ] && OSNAME="CBSD"
if [ -z "${myb_default_network}" ]; then
	myb_default_network="10.0.101"
	sysrc -qf /etc/rc.conf myb_default_network="${myb_default_network}" > /dev/null 2>&1
fi

if [ ${myb_firstboot} -eq 1 ]; then
	clear
	service netif restart > /dev/null 2>&1
	service routing restart > /dev/null 2>&1
	echo
	echo " *** [${OSNAME} post-install script] *** "
	echo

	# change password root shell
	pw usermod -s /bin/csh -n root

	users_num=$( grep -v '^#' /etc/master.passwd | wc -l | awk '{printf $1}' )

	users_num_root=0

	case "${OSNAME}" in
		MyBee)
			users_num_root=28
			;;
		ClonOS)
			users_num_root=29
			;;
	esac

#	if [ "${users_num}" != "${users_num_root}" ]; then
#		SSH_ROOT_ENABLED=0
#		echo "[${users_num}/${users_num_root}] ${OSNAME} default SSH ROOT access: disabled" | tee -a /var/log/mybinst.log
#	else
		SSH_ROOT_ENABLED=1
#		echo "[${users_num}/${users_num_root}] ${OSNAME} default SSH ROOT access: enabled" | tee -a /var/log/mybinst.log
#	fi
	echo

	if [ "${myb_manage_loaderconf}" != "NO" ]; then
		# tune loader.conf
		cat >> /boot/loader.conf <<EOF
loader_menu_title="Welcome to ${OSNAME} Project"

module_path="/boot/kernel;/boot/modules;/boot/dtb;/boot/dtb/overlays"
vmm_load="YES"
#vfs.zfs.arc_max = "512M"
aesni_load="YES"
ipfw_load="YES"
net.inet.ip.fw.default_to_accept=1
cpuctl_load="YES"
pf_load="YES"
kern.racct.enable=1
ipfw_nat_load="YES"
libalias_load="YES"
sem_load="YES"
coretemp_load="YES"
cc_htcp_load="YES"
#aio_load="YES"

kern.ipc.semmnu=120
kern.ipc.semume=40
kern.ipc.semmns=240
kern.ipc.semmni=40
kern.ipc.shmmaxpgs=65536

net.inet.tcp.syncache.hashsize=1024
net.inet.tcp.syncache.bucketlimit=512
net.inet.tcp.syncache.cachelimit=65536
net.inet.tcp.hostcache.hashsize=16384
net.inet.tcp.hostcache.bucketlimit=100
net.inet.tcp.hostcache.cachelimit=65536

kern.nbuf=128000
net.inet.tcp.tcbhashsize=524288
net.inet.tcp.hostcache.bucketlimit=120
net.inet.tcp.tcbhashsize=131072

impi_load="YES"
accf_data_load="YES"
accf_dns_load="YES"
accf_http_load="YES"

vm.pmap.pti="0"
hw.ibrs_disable="1"
crypto_load="YES"

#
if_bnxt_load="YES"
if_qlnxe_load="YES"

### Use next-gen MRSAS drivers in place of MFI for device supporting it
# This solves lot of [mfi] COMMAND 0x... TIMEOUT AFTER ## SECONDS
hw.mfi.mrsas_enable="1"

### Tune some global values ###
hw.usb.no_pf="1"        # Disable USB packet filtering

# Load The DPDK Longest Prefix Match (LPM) modules
dpdk_lpm4_load="YES"
dpdk_lpm6_load="YES"

# Load DXR: IPv4 lookup algo
fib_dxr_load="YES"

# Loading newest Intel microcode
cpu_microcode_load="YES"
cpu_microcode_name="/boot/firmware/intel-ucode.bin"

### Intel NIC tuning ###
# https://bsdrp.net/documentation/technical_docs/performance#nic_drivers_tuning
# Don't limit the maximum of number of received packets to process at a time
hw.igb.rx_process_limit="-1"
hw.em.rx_process_limit="-1"
hw.ix.rx_process_limit="-1"
# Allow unsupported SFP
hw.ix.unsupported_sfp="1"
hw.ix.allow_unsupported_sfp="1"

### Chelsio NIC tuning ###
# Prevent to reserve ASIC ressources unused on a router/firewall,
# improve performance when we will reach 10Mpps or more
hw.cxgbe.toecaps_allowed="0"
hw.cxgbe.rdmacaps_allowed="0"
hw.cxgbe.iscsicaps_allowed="0"
hw.cxgbe.fcoecaps_allowed="0"

# Under network heavy usage, network critical traffic (mainly
# non-RSS traffic like ARP, LACP) could be droped and flaping LACP links.
# To mitigate this situation, Chelsio could reserves one TX queue for
# non-RSS traffic with this tuneable:
# hw.cxgbe.rsrv_noflowq="1"
# But compensate the number of TX queue by increasing it by one.
# As example, if you had 8 queues, uses now 9:
# hw.cxgbe.ntxq="9"

### link tunning ###
# Increase interface send queue length
# lagg user: This value should be at minimum the sum of txd buffer of each NIC in the lagg
# hw.ix.txd: 2048 by default, then use x4 here (lagg with 4 members)
net.link.ifqmaxlen="16384"

# Avoid message netisr_register: epair requested queue limit 688128 capped to net.isr.maxqlimit 1024
net.isr.maxqlimit=1000000

# Use all cores for netisr processing
net.isr.maxthreads=-1
EOF
	fi
fi

# Upgrade area

[ ! -d /usr/local/etc/pkg/repos ] && mkdir -p /usr/local/etc/pkg/repos
cp -a /usr/local/myb/pkg/${OSNAME}-latest.conf /usr/local/etc/pkg/repos/
# when no network?
pkg info cbsd > /dev/null 2>&1
remote_install=$?

if [ ${remote_install} -eq 1 ]; then
	echo "Remote upgrade: pkg update -f ..."
	env IGNORE_OSVERSION=yes SIGNATURE_TYPE=none pkg update -f
fi

## Remote install by list
if [ -r /usr/local/myb/${OSNAME}.list ]; then

	install_list=$( grep -v '^#' /usr/local/myb/${OSNAME}.list | sed 's:/usr/ports/::g' | while read _pkg; do
		pkg info ${_pkg} > /dev/null 2>&1 || printf "${_pkg} "
	done )

	if [ -n "${install_list}" ]; then
		echo "Remote upgrade: install dependencies: ${install_list} ..."
		env SIGNATURE_TYPE=none ASSUME_ALWAYS_YES=yes IGNORE_OSVERSION=yes pkg install -y -f cbsd ${install_list}
		env SIGNATURE_TYPE=none ASSUME_ALWAYS_YES=yes IGNORE_OSVERSION=yes pkg upgrade -r ${OSNAME}-latest -y

	fi
fi

if [ ${myb_firstboot} -eq 0 ]; then
	# upgrade from repo
	env SIGNATURE_TYPE=none ASSUME_ALWAYS_YES=yes IGNORE_OSVERSION=yes pkg upgrade -r ${OSNAME}-latest -y
fi

[ -d /usr/local/cbsd/modules/api.d ] && rm -rf /usr/local/cbsd/modules/api.d
cp -a /usr/local/myb/api.d /usr/local/cbsd/modules/

[ -d /usr/local/cbsd/modules/myb.d ] && rm -rf /usr/local/cbsd/modules/myb.d
cp -a /usr/local/myb/myb.d /usr/local/cbsd/modules/

case "${OSNAME}" in
		MyBee)
				[ -d /usr/local/cbsd/modules/garm.d ] && rm -rf /usr/local/cbsd/modules/garm.d
				cp -a /usr/local/myb/garm.d /usr/local/cbsd/modules/
				;;
		ClonOS)
				[ -d /usr/local/cbsd/modules/vncterm.d ] && rm -rf /usr/local/cbsd/modules/vncterm.d
				cp -a /usr/local/myb/vncterm.d /usr/local/cbsd/modules/
				[ -d /usr/local/cbsd/modules/clonosdb.d ] && rm -rf /usr/local/cbsd/modules/clonosdb.d
				cp -a /usr/local/myb/clonosdb.d /usr/local/cbsd/modules/
				;;
esac

[ -d /usr/local/cbsd/modules/k8s.d ] && rm -rf /usr/local/cbsd/modules/k8s.d
cp -a /usr/local/myb/k8s.d /usr/local/cbsd/modules/

[ -d /usr/local/cbsd/modules/convectix.d ] && rm -rf /usr/local/cbsd/modules/convectix.d
cp -a /usr/local/myb/convectix.d /usr/local/cbsd/modules/

[ -d /usr/local/cbsd/modules/puppet.d ] && rm -rf /usr/local/cbsd/modules/puppet.d
cp -a /usr/local/myb/puppet.d /usr/local/cbsd/modules/

[ ! -d /var/log/cbsdmq ] && mkdir -p /var/log/cbsdmq

## Upgrade area
echo "=== Initial ${OSNAME} setup ==="

hostname=$( /usr/sbin/sysrc -n hostname 2>/dev/null | awk '{printf $1}' )

auto_iface=$( /sbin/route -n get 0.0.0.0 | /usr/bin/awk '/interface/{print $2}' )

if [ -z "${auto_iface}" ]; then
	for i in $( ifconfig -l ); do
		case "${i}" in
			lo*)
				continue
				;;
			*)
				auto_iface="${i}"
				break
				;;
		esac
	done
fi

ip4_addr=$( ifconfig ${auto_iface} 2>/dev/null | /usr/bin/awk '/inet [0-9]+/ { print $2}' | /usr/bin/head -n 1 )

## when no IP?
[ -z "${ip4_addr}" ] && ip4_addr="${myb_default_network}.1"

echo "CBSD setup"

# always set root user to /bin/csh
pw usermod root -s /bin/csh

#pw useradd cbsd -s /bin/sh -d /usr/jails -c "cbsd user"
pw groupmod cbsd -M www

cat > /tmp/initenv.conf <<EOF
nodename="${hostname}"
nodeip="${ip4_addr}"
jnameserver="8.8.8.8 8.8.4.4"
nodeippool="${myb_default_network}.0/24"
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
default_vs="1"
EOF

# todo:on-demand
# todo: hoster core dump
#statsd_bhyve_enable="1"
#statsd_jail_enable="1"
#statsd_hoster_enable="1"

cp -a /tmp/initenv.conf /root

echo "SETUP CBSD"
export NOINTER=1
export workdir=/usr/jails

/usr/local/cbsd/sudoexec/initenv /tmp/initenv.conf >> /var/log/cbsd_init.log 2>&1

[ ! -r ~cbsd/etc/cbsd-pf.conf ] && /usr/bin/touch ~cbsd/etc/cbsd-pf.conf
/usr/sbin/sysrc -qf ~cbsd/etc/cbsd-pf.conf cbsd_nat_skip_natip_network=0

# Command 'hyperv_fattach' not found: FreeBSD-hyperv-tools
[ -r /etc/devd/hyperv.conf ] && rm -f /etc/devd/hyperv.conf

/usr/sbin/sysrc -qf /usr/jails/etc/global.conf configure_default_cbsd_vs_cidr4="${myb_default_network}.1/24"

/usr/sbin/sysrc \
 utx_enable="NO" \
 netwait_enable="YES" \
 nginx_enable="YES" \
 cbsdd_enable="YES" \
 clear_tmp_enable="YES" \
 beanstalkd_enable="YES" \
 beanstalkd_flags="-l 127.0.0.1 -p 11300 -z 104856" \
 kld_list="if_bridge vmm nmdm if_vether ipfw pf aesni cryptodev cpuctl ipfw_nat libalias coretemp crypto if_bnxt if_qlnxe" \
 ntpdate_enable="YES" \
 ntpd_enable="YES" \
 ntpd_sync_on_start="YES" \
 cbsd_mq_router_enable="YES" \
 cbsd_mq_api_enable="YES" \
 cbsd_mq_api_flags="-listen 127.0.0.1:65531 -cluster_limit=10" \
 sshd_enable="YES" \
 syslogd_enable="NO" \
 sendmail_enable="NO" \
 sendmail_submit_enable="NO" \
 sendmail_outbound_enable="NO" \
 sendmail_msp_queue_enable="NO" \
 osrelease_enable="NO" \
 mybosrelease_enable="YES" \
 moused_nondefault_enable="NO" \
 mixer_enable="NO" \
 rc_startmsgs="NO" \
 linux_mounts_enable="NO" \
 rctl_enable="YES" \
 cbsd_workdir="/usr/jails" \
 ttyd_enable="YES" \
 ttyd_flags="-i /var/run/ttyd.sock -d 3 -T xterm-256color -m 8 -P 300 -t fontSize=15 -t titleFixed=${OSNAME} -W --socket-owner www:www" \
 ttyd_command="/usr/bin/login" \
 ttyd_user="root" \
 OSNAME="${OSNAME}"

# ttyd
cp -a /usr/local/myb/etc/pam.d/login /etc/pam.d/login
[ ! -d /etc/rc.d/rc.conf.d ] && mkdir -p /etc/rc.d/rc.conf.d
cp -a /usr/local/myb/usr/local/etc/rc.d/ttyd /usr/local/etc/rc.d/ttyd

# re-run ttyd if necessary
if [ ${myb_firstboot} -eq 0 ]; then
	/usr/sbin/service ttyd status >/dev/null 2>&1 || /usr/sbin/service ttyd restart
fi

if [ "${myb_manage_nginx}" != "NO" ]; then
	/usr/sbin/sysrc nginx_enable="YES"
fi

if [ ${myb_firstboot} -eq 1 ]; then
	if [ ${SSH_ROOT_ENABLED} -eq 0 ]; then
		echo "extra users exist, disable SSH root login by default"
		/usr/sbin/sysrc -qf /etc/rc.conf sshd_flags="-oUseDNS=no -oPermitRootLogin=no -oPort=22" > /dev/null 2>&1
	else
		echo "extra users does not exist, enable SSH root login by default"
		/usr/sbin/sysrc -qf /etc/rc.conf sshd_flags="-oUseDNS=no -oPermitRootLogin=yes -oPort=22" > /dev/null 2>&1
	fi
	/usr/sbin/service sshd restart >/dev/null 2>&1
fi


cat > /etc/sysctl.conf <<EOF
security.bsd.see_other_uids = 0
kern.init_shutdown_timeout = 900
security.bsd.see_other_gids = 0
net.inet.icmp.icmplim = 0
net.inet.tcp.fast_finwait2_recycle = 1
net.inet.tcp.recvspace = 262144
net.inet.tcp.sendspace = 262144
kern.ipc.shm_use_phys = 1
kern.ipc.shmall = 262144
kern.ipc.shmmax = 1073741824
kern.maxfiles = 2048000
kern.maxfilesperproc = 200000
net.inet.ip.intr_queue_maxlen = 2048
net.inet.ip.portrange.first = 1024
net.inet.ip.portrange.last = 65535
net.inet.ip.portrange.randomized = 0
net.inet.tcp.maxtcptw = 40960
net.inet.tcp.msl = 10000
net.inet.tcp.nolocaltimewait = 1
net.inet.tcp.syncookies = 1
net.inet.udp.maxdgram = 18432
net.local.stream.recvspace = 262144
net.local.stream.sendspace = 262144
vfs.zfs.prefetch.disable = 1
kern.corefile = /var/coredumps/%N.core
kern.sugid_coredump = 1
kern.ipc.shm_allow_removed = 1
kern.shutdown.poweroff_delay = 500
kern.vt.enable_bell = 0
dev.netmap.buf_size = 24576
net.inet.ip.forwarding = 1
net.inet6.ip6.forwarding = 1
net.inet6.ip6.rfc6204w3 = 1
vfs.nfsd.enable_stringtouid = 1
vfs.nfs.enable_uidtostring = 1
vfs.zfs.min_auto_ashift = 12
security.bsd.see_jail_proc = 0
security.bsd.unprivileged_read_msgbuf = 0
net.bpf.zerocopy_enable = 1
net.inet.raw.maxdgram = 16384
net.inet.raw.recvspace = 16384
net.route.netisr_maxqlen = 2048
net.bpf.optimize_writers = 1
net.inet.ip.redirect = 0
net.inet6.ip6.redirect = 0
hw.intr_storm_threshold = 9000
hw.pci.do_power_nodriver = 3
net.inet.icmp.reply_from_interface = 1
kern.ipc.maxsockbuf = 16777216
EOF

if [ "${myb_manage_nginx}" != "NO" ]; then
	if [ ${myb_firstboot} -eq 1 ]; then
		case "${OSNAME}" in
			ClonOS)
					cp /usr/local/etc/nginx/nginx.conf.clonos.sample /usr/local/etc/nginx/nginx.conf
					;;
			*)
					rm -rf /usr/local/etc/nginx
					cp -a /usr/local/myb/nginx /usr/local/etc/
					;;
		esac
	fi
fi

[ ! -d /usr/jails/src/iso ] && mkdir -p /usr/jails/src/iso

[ ! -d /usr/jails/etc ] && mkdir /usr/jails/etc
cat > /usr/jails/etc/modules.conf <<EOF
pkg.d				# ${OSNAME} auto-setup
bsdconf.d			# ${OSNAME} auto-setup
zfsinstall.d			# ${OSNAME} auto-setup
api.d				# ${OSNAME} auto-setup
myb.d				# ${OSNAME} auto-setup
k8s.d				# ${OSNAME} auto-setup
puppet.d			# ${OSNAME} auto-setup
convectix.d			# ${OSNAME} auto-setup
cbsd_queue.d			# ${OSNAME} auto-setup
vncterm.d			# ${OSNAME} auto-setup
garm.d				# ${OSNAME} auto-setup
clonosdb.d			# ${OSNAME} auto-setup
EOF

# for DFLY
[ ! -r /usr/jails/etc/cloud-init-extras.conf ] && touch /usr/jails/etc/cloud-init-extras.conf
sysrc -qf /usr/jails/etc/cloud-init-extras.conf cbsd_cloud_init=1

env NOINTER=1 /usr/local/bin/cbsd initenv

if [ "${myb_manage_rclocal}" != "NO" ]; then
cat > /etc/rc.local << EOF
# insurance for DHCP-based ifaces
for i in \$( egrep -E '^ifconfig_[aA-zZ]+[0-9]+="DHCP"' /etc/rc.conf | tr "_=" " " | awk '{printf \$2" "}' ); do
        /sbin/dhclient \${i}
done

truncate -s0 /etc/motd /var/run/motd /etc/motd.template
EOF
fi

cp -a /usr/local/myb/myb-os-release /usr/local/etc/rc.d/myb-os-release
cp -a /usr/local/myb/api.d/etc/api.conf ~cbsd/etc/
cp -a /usr/local/myb/bhyve-api.conf ~cbsd/etc/
cp -a /usr/local/myb/api.d/etc/jail-api.conf ~cbsd/etc/

cp -a /usr/local/myb/cbsd_api_cloud_images.json /usr/local/etc/cbsd_api_cloud_images.json
cp -a /usr/local/myb/syslog.conf /etc/syslog.conf

# dup ?
[ ! -r ~cbsd/etc/cbsd-pf.conf ] && /usr/bin/touch -s0 ~cbsd/etc/cbsd-pf.conf
/usr/sbin/sysrc -qf ~cbsd/etc/cbsd-pf.conf cbsd_nat_skip_natip_network=0

/usr/sbin/sysrc -qf ~cbsd/etc/api.conf server_list="${hostname}"
/usr/sbin/sysrc -qf ~cbsd/etc/bhyve-api.conf ip4_gw="${myb_default_network}.1"

tube_name=$( echo ${hostname} | tr '.' '_' )

/usr/sbin/pw usermod root -c "${OSNAME} ${hostname}"

cat > /usr/local/etc/cbsd-mq-router.json <<EOF
{
    "cbsdenv": "/usr/jails",
    "cbsdcolor": false,
    "broker": "beanstalkd",
    "logfile": "/dev/stdout",
    "beanstalkd": {
      "uri": "127.0.0.1:11300",
      "tube": "cbsd_${tube_name}",
      "reply_tube_prefix": "cbsd_${tube_name}_result_id",
      "reconnect_timeout": 5,
      "reserve_timeout": 5,
      "publish_timeout": 5,
      "logdir": "/var/log/cbsdmq"
    }
}
EOF

cat > /usr/jails/etc/k8s.conf <<EOF
ZPOOL=zroot
ZFS_K8S="${ZPOOL}/k8s"
ZFS_K8S_MNT="/k8s"
api_env_name="env"
server_list="${tube_name}"
PV_SPEC_SERVER="${myb_default_network}.1"

ZPOOL="zroot"
ZFS_K8S="\${ZPOOL}/k8s"
ZFS_K8S_MNT="/k8s"
ZFS_K8S_PV_ROOT="\${ZFS_K8S}/pv"                         # zpool root PV
ZFS_K8S_PV_ROOT_MNT="\${ZFS_K8S_MNT}/pv"                 # zpool mnt root PV

EOF

cat > /usr/jails/etc/k8world.conf <<EOF
K8S_MK_JAIL="1"
EOF

chown cbsd:cbsd ~cbsd/etc/api.conf ~cbsd/etc/k8s.conf /usr/jails/etc/k8world.conf
[ ! -d /var/db/cbsd-api ] && mkdir -p /var/db/cbsd-api
[ ! -d /usr/jails/var/db/api/map ] && mkdir -p /usr/jails/var/db/api/map
chown -R cbsd:cbsd /var/db/cbsd-api /usr/jails/var/db/api/map

[ ! -d /var/coredumps ] && mkdir /var/coredumps
chmod 0777 /var/coredumps

uplink_iface4=$( /sbin/route -n -4 get 0.0.0.0 2>/dev/null | /usr/bin/awk '/interface/{print $2}' )
ip=$( /sbin/ifconfig ${uplink_iface4} | /usr/bin/awk '/inet [0-9]+/{print $2}'| /usr/bin/head -n1 )

# set IP for API/public.html/..
[ ! -d /usr/local/www/public ] && mkdir -p /usr/local/www/public
rsync -avz --exclude nubectl /usr/local/myb/myb-public/public/ /usr/local/www/public/
rsync -avz /usr/local/myb/bin/ /root/bin/
[ -x /root/bin/auto_ip.sh ] && /root/bin/auto_ip.sh

cat > ~cbsd/etc/bhyve-default-default.conf <<EOF
skip_bhyve_init_warning=1
create_cbsdsystem_tap=0
ci_gw4="${myb_default_network}.1"
EOF

if [ "${myb_manage_nginx}" != "NO" ]; then
	[ ! -d /var/nginx ] && mkdir /var/nginx
fi
[ ! -d /usr/local/www/status ] && mkdir /usr/local/www/status

if [ "${myb_manage_sudo}" != "NO" ]; then
	[ ! -d /usr/local/etc/sudoers.d ] && mkdir -m 0755 -p /usr/local/etc/sudoers.d
		cat > /usr/local/etc/sudoers.d/10_wheelgroup <<EOF
%wheel ALL=(ALL) NOPASSWD: ALL
EOF

	chmod 0440 /usr/local/etc/sudoers.d/10_wheelgroup

	# delete?
	/usr/local/bin/rsync -avz /usr/local/myb/skel/ /
fi

# k8s
mkdir -p /var/db/cbsd-k8s /usr/jails/var/db/k8s/map
chown -R cbsd:cbsd /var/db/cbsd-k8s /usr/jails/var/db

# hooks/status update
ln -sf /root/bin/update_cluster_status.sh /usr/jails/share/bhyve-system-default/master_poststop.d/update_cluster_status.sh
ln -sf /root/bin/update_cluster_status.sh /usr/jails/share/bhyve-system-default/master_poststart.d/update_cluster_status.sh
ln -sf /root/bin/route_del.sh /usr/jails/share/bhyve-system-default/master_poststop.d/route_del.sh
ln -sf /root/bin/route_add.sh /usr/jails/share/bhyve-system-default/master_poststart.d/route_add.sh

# in kubernetes bootsrap
#/usr/local/bin/cbsd jimport /usr/local/myb/micro1.img
#rm -f /usr/local/myb/micro1.img

/usr/local/cbsd/sudoexec/initenv > /var/log/cbsd_init2.log 2>&1

/usr/local/cbsd/modules/k8s.d/scripts/install.sh up > /dev/null 2>&1

if [ "${myb_manage_resolv}" != "NO" ]; then
	grep -q 'nameserver' /etc/resolv.conf
	ret=$?
	if [ ${ret} -ne 0 ]; then
		cat >> /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 2001:4860:4860::8888
nameserver 2001:4860:4860::8844
EOF
	fi
fi

/usr/sbin/sysrc -qf /etc/rc.conf myb_firstboot="0" > /dev/null 2>&1


# ClonOS
if [ "${OSNAME}" = "ClonOS" ]; then
	sysrc cbsd_statsd_hoster_enable=YES \
		cbsd_statsd_jail_enable=YES \
		cbsd_statsd_bhyve_enable=YES
	service cbsd-statsd-hoster restart
	service cbsd-statsd-jail restart
	service cbsd-statsd-bhyve restart

	cp -a /usr/local/etc/php-fpm.d/www-php-fpm.conf.clonos.sample /usr/local/etc/php-fpm.d/www.conf
	cp -a /usr/local/etc/php.ini.clonos.sample /usr/local/etc/php.ini
	cp /usr/local/etc/php-fpm.conf.clonos.sample /usr/local/etc/php-fpm.conf

	grep -q kern.racct.enable /boot/loader.conf > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "kern.racct.enable=\"1\"" >> /boot/loader.conf
	fi

	install -o root -g wheel -m 0440 /usr/local/etc/sudoers_10_www.clonos.sample /usr/local/etc/sudoers.d/10_www

	touch /var/log/nginx/php.err
	chown www:www /var/log/nginx/php.err

	chown www:www /usr/local/www/clonos/media_import
	chmod 0700 /usr/local/www/clonos/media_import

	sysrc php_fpm_enable="YES"
	if [ ${web} -eq 0 ]; then
		echo "Restart php-fpm service"
		service php-fpm restart
	fi

	service clonos-ws enable
	if [ ${web} -eq 0 ]; then
		echo "Restart clonos-ws service"
		service clonos-ws restart
	fi

	service clonos-node-ws enable
	if [ ${web} -eq 0 ]; then
		echo "Restart clonos-node-ws service"
		service clonos-node-ws restart
	fi

	sysrc clonos_vnc2wss_enable="YES"

	cp -a /usr/local/cbsd/modules/cbsd_queue.d/etc-sample/cbsd_queue.conf ~cbsd/etc/
	ln -sf /usr/local/bin/python3.11 /usr/local/bin/python3

	/usr/local/bin/cbsd clonosdb
fi

if [ "${myb_manage_loaderconf}" != "NO" ]; then
	### LOADER.CONF - todo: external helper + dynamic drv finder
	sysrc -qf /boot/loader.conf module_path="/boot/kernel;/boot/modules;/boot/dtb;/boot/dtb/overlays" \
		loader_menu_title="Welcome to ${OSNAME} Project" \
		aesni_load="YES" \
		ipfw_load="YES" \
		cpuctl_load="YES" \
		pf_load="YES" \
		vmm_load="YES" \
		ipfw_nat_load="YES" \
		libalias_load="YES" \
		sem_load="YES" \
		coretemp_load="YES" \
		cc_htcp_load="YES" \
		impi_load="YES" \
		accf_data_load="YES" \
		accf_dns_load="YES" \
		accf_http_load="YES" \
		crypto_load="YES" \
		if_bnxt_load="YES" \
		if_qlnxe_load="YES" \
		fib_dxr_load="YES" \
		cpu_microcode_load="YES" \
		cpu_microcode_name="/boot/firmware/intel-ucode.bin"

	#aio_load="YES"
	#vfs.zfs.arc_max = "512M"

	# sysrc: hw.cxgbe.fcoecaps_allowed: name contains characters not allowed in shell (dot)
	# kern.ipc.semmnu=120
	# kern.ipc.semume=40
	# kern.ipc.semmns=240
	# kern.ipc.semmni=40
	# kern.ipc.shmmaxpgs=65536

	# net.inet.tcp.syncache.hashsize=1024
	# net.inet.tcp.syncache.bucketlimit=512
	# net.inet.tcp.syncache.cachelimit=65536
	# net.inet.tcp.hostcache.hashsize=16384
	# net.inet.tcp.hostcache.bucketlimit=100
	# net.inet.tcp.hostcache.cachelimit=65536

	# kern.nbuf=128000
	# net.inet.tcp.tcbhashsize=524288
	# net.inet.tcp.hostcache.bucketlimit=120
	# net.inet.tcp.tcbhashsize=131072

	# vm.pmap.pti="0"
	# hw.ibrs_disable="1"

	### Use next-gen MRSAS drivers in place of MFI for device supporting it
	# This solves lot of [mfi] COMMAND 0x... TIMEOUT AFTER ## SECONDS
	# hw.mfi.mrsas_enable="1"

	### Tune some global values ###
	# hw.usb.no_pf="1"        # Disable USB packet filtering

	# Load The DPDK Longest Prefix Match (LPM) modules
	# dpdk_lpm4_load="YES"
	# dpdk_lpm6_load="YES"


	### Intel NIC tuning ###
	# https://bsdrp.net/documentation/technical_docs/performance#nic_drivers_tuning
	# Don't limit the maximum of number of received packets to process at a time
	# hw.igb.rx_process_limit="-1"
	# hw.em.rx_process_limit="-1"
	# hw.ix.rx_process_limit="-1"
	# Allow unsupported SFP
	# hw.ix.unsupported_sfp="1"
	# hw.ix.allow_unsupported_sfp="1"

	### Chelsio NIC tuning ###
	# Prevent to reserve ASIC ressources unused on a router/firewall,
	# improve performance when we will reach 10Mpps or more
	# hw.cxgbe.toecaps_allowed="0"
	# hw.cxgbe.rdmacaps_allowed="0"
	# hw.cxgbe.iscsicaps_allowed="0"
	# hw.cxgbe.fcoecaps_allowed="0"

	# Under network heavy usage, network critical traffic (mainly
	# non-RSS traffic like ARP, LACP) could be droped and flaping LACP links.
	# To mitigate this situation, Chelsio could reserves one TX queue for
	# non-RSS traffic with this tuneable:
	# hw.cxgbe.rsrv_noflowq="1"
	# But compensate the number of TX queue by increasing it by one.
	# As example, if you had 8 queues, uses now 9:
	# hw.cxgbe.ntxq="9"

	### link tunning ###
	# Increase interface send queue length
	# lagg user: This value should be at minimum the sum of txd buffer of each NIC in the lagg
	# hw.ix.txd: 2048 by default, then use x4 here (lagg with 4 members)
	# net.link.ifqmaxlen="16384"

	# Avoid message netisr_register: epair requested queue limit 688128 capped to net.isr.maxqlimit 1024
	# net.isr.maxqlimit="1000000"
	# net.isr.maxthreads="-1"
	####
	grep -q net.inet.ip.fw.default_to_accept /boot/loader.conf
	if [ $? -ne 0 ]; then
		echo "net.inet.ip.fw.default_to_accept=1" >> /boot/loader.conf
	fi

	grep -q kern.racct.enable /boot/loader.conf
	if [ $? -ne 0 ]; then
		echo "kern.racct.enable=1" >> /boot/loader.conf
	fi
fi

# legacy firstboot instasll
[ -r /usr/local/etc/rc.d/mybinst.sh ] && rm -f /usr/local/etc/rc.d/mybinst.sh

if [ ${myb_firstboot} -eq 1 ]; then
/usr/bin/wall <<EOF
	${OSNAME} setup complete, reboot host!
EOF
sync
#/sbin/reboot
else
	echo "Restart API, Router, Beanstalkd"
	/usr/sbin/service cbsd-mq-api stop
	/usr/sbin/service cbsd-mq-router stop
	/usr/sbin/service beanstalkd stop
	# 
	/usr/sbin/service beanstalkd start
	/usr/sbin/service cbsd-mq-router start
	/usr/sbin/service cbsd-mq-api start

	/usr/local/etc/rc.d/cbsd-statsd-bhyve stop
	/usr/local/etc/rc.d/cbsd-statsd-hoster stop
	/usr/local/etc/rc.d/cbsd-statsd-jail stop

	/usr/local/etc/rc.d/cbsd-statsd-bhyve start
	/usr/local/etc/rc.d/cbsd-statsd-hoster start
	/usr/local/etc/rc.d/cbsd-statsd-jail start
fi

# drop cache
if [ "${OSNAME}" = "ClonOS" ]; then
	[ -r /usr/jails/tmp/bhyve-vm.json ] && /bin/rm -f /usr/jails/tmp/bhyve-vm.json
	[ -r /usr/jails/tmp/bhyve-cloud.json ] && rm -f /usr/jails/tmp/bhyve-cloud.json

	/usr/local/bin/cbsd get_bhyve_profiles src=cloud
	/usr/local/bin/cbsd get_bhyve_profiles src=vm clonos=1

	/usr/sbin/service nginx reload

	/usr/sbin/service stop clonos-ws > /dev/null 2>&1 || true
	/usr/sbin/service stop clonos-node-ws > /dev/null 2>&1 || true
	/usr/sbin/service start clonos-node-ws
	/usr/sbin/service start clonos-ws
fi

[ ! -h /usr/local/etc/rc.d/tty.sh ] && ln -sf /root/bin/tty.sh /usr/local/etc/rc.d/tty.sh
echo "mybinst.sh done"

exit 0
