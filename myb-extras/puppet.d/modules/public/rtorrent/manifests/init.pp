# Class: rtorrent
class rtorrent (
  $package_name   = $::rtorrent::params::package_name,
  $package_ensure = $::rtorrent::params::package_ensure,
  $service_name   = $::rtorrent::params::service_name,
  $user           = $::rtorrent::params::user,
  $group          = $::rtorrent::params::group,
) inherits rtorrent::params {

  contain '::rtorrent::setenv'
  contain '::rtorrent::install'
  contain '::rtorrent::users'
  contain '::rtorrent::dir'

  Class['::rtorrent::setenv'] ->
  Class['::rtorrent::install'] ->
  Class['::rtorrent::users'] ->
  Class['::rtorrent::dir']

  service { 'rtorrent':
    ensure => running,
    enable => true,
  }

}
