class redmine::config inherits redmine {

  file { "/usr/local/www/redmine/config/database.yml":
    mode    => '0444',
    ensure  => present,
    content => template("${module_name}/database.yml.erb"),
    owner   => "www",
  } -> file { "/usr/local/etc/rc.d/redmine":
    mode => '0555',
    ensure  => present,
    content => template("${module_name}/redmine.erb"),
    #notify  => Service['redmine'],
  } -> file { "/usr/local/bin/redmine-helper.sh":
    mode => '0555',
    ensure  => present,
    content => template("${module_name}/redmine-helper.sh.erb"),
  } -> service { 'redmine':
    #ensure => running,
    enable => true,
  } -> exec { 'redmine-helper.sh':
      command => "/usr/local/bin/redmine-helper.sh",
  }

}
