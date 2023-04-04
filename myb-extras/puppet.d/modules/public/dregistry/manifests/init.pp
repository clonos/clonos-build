class dregistry {

  class { '::docker_distribution':
    log_fields               => {
      service     => 'registry',
      environment => 'production'
    }
    ,
    log_hooks_mail_disabled  => true,
    log_hooks_mail_levels    => ['panic', 'error'],
    log_hooks_mail_to        => 'root@localhost',
    filesystem_rootdirectory => '/var/lib/registry',
    http_addr                => ':5000',
    http_tls                 => true,
  }

}
