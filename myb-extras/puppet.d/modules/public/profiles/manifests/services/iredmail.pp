class profiles::services::iredmail (
  String $ver                       = '1.6.2',
  String $storage_base_dir          = '/var/vmail',
  String $web_server                = 'NGINX',
  String $backend_orig              = 'MARIADB',
  String $backend                   = 'MYSQL',
  String $vmail_db_bind_passwd      = 'qwerty',
  String $vmail_db_admin_passwd     = 'qwerty',
  String $mlmmjadmin_api_auth_token = 'qwerty',
  String $netdata_db_passwd         = 'qwerty',
  String $mysql_root_passwd         = 'qwerty',
  String $first_domain              = 'example.com',
  String $domain_admin_passwd_plain = 'qwerty',
  String $use_iredadmin             = 'YES',
  String $use_roundcube             = 'YES',
  String $amavisd_db_passwd         = 'qwerty',
  String $iredadmin_db_passwd       = 'qwerty',
  String $rcm_db_passwd             = 'qwerty',
  String $sogo_db_passwd            = 'qwerty',
  String $sogo_sieve_master_passwd  = 'qwerty',
  String $iredapd_db_passwd         = 'qwerty',
  String $fail2ban_db_passwd        = 'qwerty',
){

# via profile::package::entries
#  package { 'bash':
#    ensure => present,
#  }

  file { '/tmp/iredmail-install.sh':
    ensure  => present,
    mode    => '0400',
    content => template("${module_name}/iredmail-install.erb"),
    owner   => 0,
    group   => 0,
  }
  -> exec { 'iredmail-install.sh':
    command => '/bin/sh /tmp/iredmail-install.sh',
    path    =>  ["/usr/bin","/usr/sbin", "/bin", "/usr/local/bin", "/usr/local/sbin" ],
    onlyif  => "test -r /tmp/iredmail-install.sh && echo 0",
  }

  exec { 'chk_iredmail_distr_exist':
    command => 'true',
    path    =>  ["/usr/bin","/usr/sbin", "/bin"],
    onlyif  => "test -f /root/iRedMail-${ver} && echo 0",
    before  => File["/root/iRedMail-${ver}/config"],
  }
  file { "/root/iRedMail-${ver}/config":
    ensure  => present,
    mode    => '0600',
    require => Exec['chk_iredmail_distr_exist'],
    content => template("${module_name}/iredmail-config.erb"),
    owner   => 0,
    group   => 0,
  }

  file { '/tmp/iredmail-install-new.sh':
    ensure  => present,
    mode    => '0400',
    content => template("${module_name}/iredmail-install-new.erb"),
    owner   => 0,
    group   => 0,
  }

#  -> exec { 'iredmail-install.sh':
#    command => '/bin/sh /tmp/iredmail-install.sh',
#    path    =>  ["/usr/bin","/usr/sbin", "/bin", "/usr/local/bin", "/usr/local/sbin" ],
#    onlyif  => "test -r /tmp/iredmail-install.sh && echo 0",
#  }


}
