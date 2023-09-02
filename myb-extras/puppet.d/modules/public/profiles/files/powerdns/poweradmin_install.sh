#!/bin/sh
# $1 can be:
#   'install_only' ( install without enabling/migrates )
OS=$( uname -s )

# Python version (e.g. pyXX-pip )
PY_VER="39"
# also see ln -s below
# PostgresQL version (e.g. postgresXX-client)
PG_VER="13"

# MySQL version (e.g. mysqlXX-client)
# should be in sync with
# grep ^MYSQL_DEFAULT /usr/ports/Mk/bsd.default-versions.mk
MY_VER="80"
# OpenLDAP version (e.g. openldapXX-client)
LDAP_VER="26"

case "${OS}" in
	Linux)
		echo "not for linux"
		exit 0
		;;
	FreeBSD)
		date
		;;
esac

MODE="${1}"
DST_DIR="/root/powerdnsadmin"
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/root/bin

if [ -r ${DST_DIR}/buildok ]; then
	echo "build ok"
	exit 0
fi

my_packages="python${PY_VER} py${PY_VER}-pip git yarn-node19 node19 npm-node19 libxml2 libxslt openldap${LDAP_VER}-client py${PY_VER}-ldap3 mysql${MY_VER}-client postgresql${PG_VER}-client xmlsec1 py${PY_VER}-xmlsec"
# most of pip/py- module version is hardcoded in requirenments.txt, but several module not strictly ( >= ): install from the pkg:
my_packages="${my_packages} py${PY_VER}-bcrypt py${PY_VER}-dnspython py${PY_VER}-python3-saml py${PY_VER}-pillow openjpeg py${PY_VER}-sqlite3"

# notes: py-bcrypt and py-cryptography require rust via pip install
my_packages="${my_packages} rust"

# use pyXX-ldap from pkg due to we need to remove 'ldap_r' deps: /usr/ports/net/py-ldap/files/patch-setup.py
my_packages="${my_packages} py${PY_VER}-ldap"


# append PostgresQL support via py-psycopg2:
my_packages="${my_packages} py${PY_VER}-psycopg2"

pkg install -y ${my_packages} || true
if [ ! -r ${DST_DIR}/.git/config ]; then
	git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git ${DST_DIR}
fi

if [ ! -r ${DST_DIR}/requirements.txt ]; then
	echo "unable to git clone? no such ${DST_DIR}/requirements.txt"
	exit 1
fi

cd ${DST_DIR}

# change fixed 'python-ldap==3.4.0' to python-ldap to use pyXX-ldap port
sed -i' ' "s/^python-ldap=.*\$/python-ldap/g" requirements.txt

# for py-openldap:
echo 'psycopg2' >> ${DST_DIR}/requirements.txt

export CFLAGS="-I/usr/include -I/usr/local/include"
export LDFLAGS="-L/lib -L/usr/lib -L/usr/local/lib"

/usr/bin/env pip install --global-option=build_ext --global-option="-I/usr/local/include" --global-option="-L/usr/local/lib" -r ${DST_DIR}/requirements.txt || true
/usr/bin/env pip install --global-option=build_ext --global-option="-I/usr/local/include" --global-option="-L/usr/local/lib" -r ${DST_DIR}/requirements.txt
ret=$?

if [ ${ret} -ne 0 ]; then
	echo "pip install error"
	exit ${ret}
fi

/usr/bin/env yarn install --pure-lockfile || true

# work-around for: 
# XXX: Unexpected token \u0000 in JSON at position 0
yarn cache clean || true
/usr/bin/env yarn install --pure-lockfile
ret=$?

if [ ${ret} -ne 0 ]; then
	echo "yarn install error"
	exit ${ret}
fi

export FLASK_APP=${DST_DIR}/powerdnsadmin/__init__.py
/usr/bin/env flask assets build
ret=$?

if [ ${ret} -ne 0 ]; then
	echo "flask assets build"
	exit ${ret}
fi


if [ ! -r /root/powerdns/rc.d/powerdnsadmin ]; then
	echo "no such rc.d script /root/powerdns/rc.d/powerdnsadmin"
	exit 1
fi

ln -sf /usr/local/bin/python3.9 /usr/local/bin/python3
ln -sf /usr/local/bin/python3.9 /usr/local/bin/python
[ ! -d /usr/local/etc/rc.d ] && mkdir -p /usr/local/etc/rc.d
cp -a /root/powerdns/rc.d/powerdnsadmin /usr/local/etc/rc.d

pkg clean -ya

date > ${DST_DIR}/buildok

[ "${MODE}" = "install_only" ] && exit 0

if [ ! -r /usr/local/etc/powerdnsadmin/default_config.py ]; then
	echo "no such config /usr/local/etc/powerdnsadmin/default_config.py"
	exit 1
fi

# migration
cd ${DST_DIR}
#export FLASK_APP=${DST_DIR}/powerdnsadmin/__init__.py
export FLASK_CONF=/usr/local/etc/powerdnsadmin/default_config.py
/usr/bin/env flask db upgrade || true
/usr/bin/env flask db upgrade
ret=$?

if [ ${ret} -ne 0 ]; then
	echo "migration error"
	exit ${ret}
fi

exit 0
