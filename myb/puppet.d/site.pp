# this is header for standalone/apply method
Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin" }
$provider = "pkgng"

# we user this hier everywhere
file { ['/root/bin', '/root/etc', '/usr/local', '/usr/local/bin', '/usr/local/etc/rc.d' ]: ensure =>directory, }

