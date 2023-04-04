# standalone redis server
class profiles::db::redis (
  Hash $config = {},
  String $output_buffer_limit_slave = '256mb 64mb 60',
) {
  # https://redis.io/topics/faq#background-saving-fails-with-a-fork-error-under-linux-even-if-i-have-a-lot-of-free-ram
  sysctl { 'vm.overcommit_memory':
    ensure => present,
    value  => '1',
  }

  class { '::redis':
    * => $config,
  }
}
