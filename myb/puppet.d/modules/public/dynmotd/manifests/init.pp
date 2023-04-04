class dynmotd(
  $ensure = 'present',
)
{
  case $::osfamily {
    'FreeBSD': {
      file { '/usr/local/bin':
        ensure => directory,
      }
      file { '/usr/local/bin/dynmotd.sh':
        ensure => $ensure,
        mode   => '0755',
        owner  => 'root',
        group  => 'wheel',
        source => [ "puppet:///modules/dynmotd/dynmotd.sh.${::fqdn}", 'puppet:///modules/dynmotd/dynmotd.sh.FreeBSD' ]
      }
      if $ensure == 'present' {
        file_line { 'freebsd-dynmotd-profile':
          path  => '/etc/profile',
          line  => '/usr/local/bin/dynmotd.sh',
          match => '/usr/local/bin/dynmotd.sh',
        }
        file_line { 'freebsd-dynmotd-cshlogin':
          path  => '/etc/csh.login',
          line  => '/usr/local/bin/dynmotd.sh',
          match => '/usr/local/bin/dynmotd.sh',
        }
        file { '/usr/local/etc/zlogin':
          ensure  => present,
        } ->
        file_line { 'freebsd-dynmotd-zlogin':
          path  => '/usr/local/etc/zlogin',
          line  => '/usr/local/bin/dynmotd.sh',
          match => '/usr/local/bin/dynmotd.sh',
        }
      }
      file { '/etc/motd':
        ensure  => present,
        mode    => '644',
        content => "",
      }
      file { '/etc/motd.template':
        ensure  => present,
        mode => '644',
        content => "",
      }
      file { '/var/run/motd':
        ensure  => present,
        mode    => '644',
        content => "",
      }
    }
    default: {
      file { '/etc/profile.d/dynmotd.sh':
        ensure => $ensure,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
        source => 'puppet:///modules/dynmotd/dynmotd.sh',
      }
    }
  }

  if $role_config {
    file { '/tmp/puppet.info':
      ensure  => present,
      mode    => '444',
      content => "$role_config",
      #hiera('puppet::info'),
    }
  }
}
