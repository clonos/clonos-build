# Class: roundcube::service
#
# Service management related configuration.
#
# It is a PHP-based web application. Normally, no service needs to be notified. Every change should happen instantly.
# Hence, the final step of the installation is to update the symbolic link referencing the current version.
#
# === Copyright
#
# Copyright 2015 Martin Meinhold, unless otherwise noted.
#
class roundcube::service inherits roundcube {

  if str2bool($roundcube::document_root_manage) {
    file { $roundcube::document_root:
      ensure => link,
      target => $roundcube::install::target,
      owner  => 'root',
      group  => 0,
    }
  }
}
