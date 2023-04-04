# == Class: roundcube::params
#
# Default configuration values for the `roundcube` class.
#
# === Copyright
#
# Copyright 2016 Martin Meinhold, unless otherwise noted.
#
class roundcube::params {
  $version = '1.6.0'
  $checksum = '2b8923836a0f83f9806fffc6dfa245705968a0005deab66c1056570eae11c7d7'  # complete edition
  $checksum_type = 'sha256'

  # deprecated: 'camptocamp' will be replaced with 'puppet' in the next major release
  $archive_provider = 'camptocamp'
  $package_dir = '/var/cache/puppet/archives'
  $install_dir = '/opt'

  $document_root_manage = true
  $document_root = '/var/www/roundcubemail'
  $process = 'www-data'

  $exec_paths = ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
  $composer_command_name = 'composer'
  $composer_disable_git_ssl_verify = false
  $composer_manage = true

  $plugins_manage = true
  $cronjobs_manage = true
}
