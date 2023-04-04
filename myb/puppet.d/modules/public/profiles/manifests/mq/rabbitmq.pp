class profiles::mq::rabbitmq (
  $globals = {},
  Hash $policy = {},
  Hash $users = {},
  Hash $instance = {},
  Hash $vhosts = {},
  Hash $user_permissions = {},
  Hash $plugins = {},
){

  case $::osfamily {
    'FreeBSD': {

      # avoid collisiin in package name: 'rabbitmq' from rabbitmq::install
      package { 'net/rabbitmq':
        ensure => installed,
      } -> file { '/usr/local/etc/rc.d/rabbitmq':
             ensure => present,
             mode   => '0755',
             owner  => 'root',
             group  => 'wheel',
             source => 'puppet:///modules/profiles/rabbitmq',
           } -> file { '/root/.erlang.cookie':
                  ensure => link,
                  target => '/var/db/rabbitmq/.erlang.cookie',
                } -> file { '/tmp/.erlang.cookie':
                       ensure => link,
                       target => '/var/db/rabbitmq/.erlang.cookie',
                     }
        file_line { 'rabbitmq_enable':
          path     => '/etc/rc.conf',
          match    => 'rabbitmq_enable',
          line     => "rabbitmq_enable=\"YES\"",
        }

     }
  }
  class { '::rabbitmq':
    * => $globals,
  }
  create_resources(rabbitmq_vhost, $vhosts)
  create_resources(rabbitmq_user, $users)
  create_resources(rabbitmq_user_permissions, $user_permissions)
  create_resources(rabbitmq_plugin, $plugins)

  # should be after vhost
  # loop + timeout when vhost not exist
  create_resources(rabbitmq_policy, $policy)

}
