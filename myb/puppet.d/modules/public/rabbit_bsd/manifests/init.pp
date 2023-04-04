# rabbit service
class rabbit_bsd()
{
#  yumrepo { 'erlang-solutions':
#    baseurl        => "https://packages.erlang-solutions.com/rpm/centos/\$releasever/\$basearch",
#    failovermethod => 'priority',
#    enabled        => '1',
#    gpgcheck       => '1',
#    gpgkey         => 'https://packages.erlang-solutions.com/rpm/erlang_solutions.asc',
#    descr          => "Erlang solutions official repository for RHEL and Cent OS - \$basearch",
#  }
#  ensure_resource('package', 'esl-erlang', {'ensure' => 'present' })
  # wget https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_22.2-1~centos~7_amd64.rpm

  class { 'rabbitmq':
    repos_ensure             => false,
    #package_ensure           => '3.8.3-1.el7',
    package_ensure           => 'present',
    package_name             => 'rabbitmq',
    service_restart          => false,
    #config_ranch            => false,
    service_manage           => true,
    port                     => 5672,
    delete_guest_user        => true,
    # hipe_compile: Do not use. This option is no longer supported. HiPE supported has been dropped starting with Erlang 22.
    config_variables         =>
    {
      'vm_memory_high_watermark' => 0.7,
    },
    config_kernel_variables  =>
    {
      'inet_dist_listen_min' => 19100,
      'inet_dist_listen_max' => 19105,
    },
    environment_variables    =>
    {
      'LC_ALL'                => 'en_US.UTF-8',
      'RABBITMQ_USE_LONGNAME' => true,
    },
    config_cluster           => true,
    cluster_nodes            => ['${::fqdn}'],
    cluster_node_type        => 'ram',
    erlang_cookie            => 'thisiscooka!',
    wipe_db_on_cookie_change => true,
    admin_enable             => true,
    tcp_recbuf               => 196608,
    tcp_sndbuf               => 196608,
    tcp_backlog              => 128,
    loopback_users           => [],
  }

  rabbitmq_policy { 'ha-all@stock':
    pattern    => '.*',
    priority   => 0,
    applyto    => 'all',
    definition => {
      'ha-mode'      => 'all',
      'ha-sync-mode' => 'automatic',
    },
  }

  rabbitmq_vhost { 'stock':
    ensure => present,
  }

  rabbitmq_user { 'stock_user':
    admin    => false,
    #password => hiera('rabbitmq::stock_user:password'),
    password => 'userpass',
  }
  rabbitmq_user { 'admin':
    admin    => true,
    #password => hiera('rabbitmq::stock_admin:password'),
    password => 'adminpass',
    tags     => 'admin',
  }

  rabbitmq_user_permissions { 'stock_user@stock':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }
  rabbitmq_user_permissions { 'admin@stock':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }
  rabbitmq_plugin {'rabbitmq_stomp':
    ensure => present,
  }
}
