# dir hier
class rtorrent::dir {

  file { "/usr/local/etc/rc.d/rtorrent":
    mode => '0555',
    ensure  => present,
    content => template("${module_name}/rtorrent.erb"),
  }

  file { [ '/home/web' ]:
    ensure => directory,
    owner => "${::rtorrent::user}",
    group => "${::rtorrent::user}",
  } ->
  exec { "clone_cp":
    command => "/usr/bin/su -m ${::rtorrent::user} -c '/usr/local/bin/git clone https://github.com/Novik/ruTorrent.git /home/web/rutorrent'",
    onlyif => "/bin/test ! -d /home/web/rutorrent",
    require => File['/home/web'],
  } ->
  file { [ '/home/web/downloads' ]:
    ensure => directory,
    owner => "${::rtorrent::user}",
    group => "${::rtorrent::user}",
    require => File['/home/web'],
  } ->
  file { [ '/home/web/session' ]:
    ensure => directory,
    owner => "${::rtorrent::user}",
    group => "${::rtorrent::user}",
    require => File['/home/web'],
  }

  file { "/home/web/rutorrent/conf/config.php":
    mode => '0664',
    owner => "${::rtorrent::user}",
    group => "${::rtorrent::user}",
    ensure  => present,
    content => template("${module_name}/config.php.erb"),
  }

  file { "/home/web/.rtorrent.rc":
    mode => '0664',
    owner => "${::rtorrent::user}",
    group => "${::rtorrent::user}",
    ensure  => present,
    content => template("${module_name}/.rtorrent.rc.erb"),
    require => File['/home/web'],
  }
}
