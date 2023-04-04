#If additional OS versions are to be added eventually for support the config
#path and file will have to be changed to something else.
#
class csync2::params {

  #Some class defaults
  $checkfreq        = '5'
  $default_includes = ['/var/tmp']
  $default_excludes = undef
  $default_auto     = 'none'
  $default_key      = 'puppet:///modules/csync2/keys/default.key'

  case $::osfamily {
    'RedHat': {
      $configpath      = '/etc/csync2'
      $configfile      = '/etc/csync2/csync2.cfg'
      $csync2_exec     = '/usr/sbin/csync2'
      $csync2_package  = 'csync2'
      $inotify_package = 'inotify-tools'
      $xinetd_group    = 'root'
    }
    'Debian': {
      $configpath      = '/etc'
      $configfile      = '/etc/csync2.cfg'
      $csync2_exec     = '/usr/sbin/csync2'
      $csync2_package  = 'csync2'
      $inotify_package = 'inotify-tools'
      $xinetd_group    = 'root'
    }
    'FreeBSD': {
      $configpath      = '/usr/local/etc'
      $configfile      = '/usr/local/etc/csync2.cfg'
      $csync2_exec     = '/usr/local/sbin/csync2'
      $csync2_package  = 'net/csync2'
      $inotify_package = 'sysutils/inotify-tools'
      $xinetd_group    = 'wheel'
    }
    default: {
      fail("Class['csync2::params']: Unsupported OS: ${::osfamily}")
    }
  }

}
