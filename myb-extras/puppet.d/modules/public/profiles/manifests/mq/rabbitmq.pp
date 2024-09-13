class profiles::mq::rabbitmq (
  $globals = {},
  Hash $policy = {},
  Hash $users = {},
  Hash $instance = {},
  Hash $vhosts = {},
  Hash $user_permissions = {},
  Hash $plugins = {},
){

  case $facts['os']['family'] {
    'Debian': {
      include erlang 
    }
    'RedHat': {
      include erlang 
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

 $hahost1=lookup('rmqhaproxy::host1', String, 'first', '')
 $hahost2=lookup('rmqhaproxy::host2', String, 'first', '')
 $hahost3=lookup('rmqhaproxy::host3', String, 'first', '')
 $hahostip1=lookup('rmqhaproxy::ip1', String, 'first', '')
 $hahostip2=lookup('rmqhaproxy::ip2', String, 'first', '')
 $hahostip3=lookup('rmqhaproxy::ip3', String, 'first', '')

  host { 'localhost':
    ensure       => 'present',
    host_aliases => ['localhost.localdomain', 'localhost4', 'localhost4.localdomain4'],
    ip           => '127.0.0.1',
    target       => '/etc/hosts',
  }
if $hahost1 != '' {
  host { "$hahost1":
    ensure       => 'present',
    ip           => $hahostip1,
    target       => '/etc/hosts',
  }
} else {
  host { $facts['networking']['fqdn']:
    ensure       => 'present',
    host_aliases => [ $facts['networking']['hostname'] ],
    ip           => $facts['networking']['ip'],
    target       => '/etc/hosts',
  }
}

if $hahost2 != '' {
  host { "$hahost2":
    ensure       => 'present',
    ip           => $hahostip2,
    target       => '/etc/hosts',
  }
}

if $hahost3 != '' {
  host { "$hahost3":
    ensure       => 'present',
    ip           => $hahostip3,
    target       => '/etc/hosts',
  }
}


#rabbitmq_parameter { 'rabbitmq_prometheus-metrics-aggregation@/':
#  component_name => 'rabbitmq-prometheus',
#  ensure => 'present',
#  value          => {
#    'return_per_object_metrics' => 'true',
#  },
#}
#  value => {
#    'uri' => 'amqps://fed_user:fed_pass@upstream_server:5672/%2fdevelop',
#    'ack-mode' => 'on-confirm',
#    'max-hops' => '10',
#    'trust-user-id' => false,
#  },
#}


  exec { "rabbitmq_prometheus-metrics-aggregation":
    command => "/usr/bin/env rabbitmqctl eval 'application:set_env(rabbitmq_prometheus, return_per_object_metrics, true).'",
    #onlyif  => "/usr/bin/env test ! -r /root/powerdnsadmin/buildok",
  }


if $hahost3 != '' {

  # haproxy?
class { 'haproxy':
  global_options   => {
    'log'     => "$facts['networking']['fqdn'] local0",
    'chroot'  => '/var/lib/haproxy',
    'pidfile' => '/var/run/haproxy.pid',
    'maxconn' => '4000',
    'user'    => 'haproxy',
    'group'   => 'haproxy',
    'daemon'  => '',
    'stats'   => 'socket /var/lib/haproxy/stats',
    'ssl-default-bind-ciphers' => 'PROFILE=SYSTEM',
    'ssl-default-server-ciphers' => 'PROFILE=SYSTEM',
  },
  defaults_options => {
    'log'     => 'global',
    'stats'   => 'enable',
    'option'  => [
      'redispatch',
    ],
    'retries' => '3',
    'timeout' => [
      'http-request 10s',
      'queue 5s',
      'connect 10s',
      'client 5s',
      'server 5s',
      'check 10s',
      'http-keep-alive 10s',
    ],
    'maxconn' => '8000',
  },
}


# check port 5673 inter 2s rise 2 fall 3
#haproxy::balancermember { 'rabbitmq-backend':
#  listening_service => 'rabbitmq-backend',
#  ports             => '5673',
#  server_names      => [ 'rmqclu1.my.domain', 'rmqclu2.my.domain', 'rmqclu3.my.domain' ],
#  ipaddresses       => [ '172.16.0.11', '172.16.0.14', '172.16.0.17' ],
#  options           => [ 'check', 'port 5673', 'inter 2s', 'rise 2', 'fall 3' ],
#}

haproxy::balancermember { 'rabbitmq-backend-ui':
  listening_service => 'rabbitmq-backend-ui',
  ports             => '15673',
  server_names      => [ "$hahost1", "$hahost2", "$hahost3" ],
  ipaddresses       => [ "$hahostip1", "$hahostip2", "$hahostip3" ],
  options           => [ 'check', 'port 15673', 'inter 2s', 'rise 2', 'fall 3' ],
}

haproxy::backend { 'rabbitmq-backend':
  options => {
#    'option'  => [
#      'tcplog',
#    ],
    'balance' => 'roundrobin',
  },
}

haproxy::backend { 'rabbitmq-backend-ui':
  options => {
#    'option'  => [
#      'tcplog',
#    ],
    'balance' => 'roundrobin',
  },
}


haproxy::frontend { 'rabbitmq-backend':
  ipaddress     => $facts['networking']['fqdn'],
  ports         => '5672',
  mode          => 'tcp',
#  bind_options  => 'accept-proxy',
  options       => {
    'default_backend' => 'rabbitmq-backend',
    'timeout client'  => '30s',
#    'option'          => [
#      'tcplog',
#      'accept-invalid-http-request',
#    ],
  },
}

haproxy::frontend { 'rabbitmq-backend-ui':
  ipaddress     => $facts['networking']['fqdn'],
  ports         => '15672',
  mode          => 'tcp',
#  bind_options  => 'accept-proxy',
  options       => {
    'default_backend' => 'rabbitmq-backend-ui',
    'timeout client'  => '30s',
#    'option'          => [
#      'tcplog',
#      'accept-invalid-http-request',
#    ],
  },
}

}

}
