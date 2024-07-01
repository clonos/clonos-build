class redmine::mysql inherits redmine {

  $config_file = '/usr/local/etc/mysql/my.cnf'

  class { '::mysql::server':
    remove_default_accounts => $redmine::remove_default_accounts,
    package_name            => "mysql${redmine::mysql_version}-server",
    create_root_my_cnf      => false,
    restart                 => true,
    config_file             => $config_file,
    override_options        => {
      'client'     => {
        'port'     => '3306',
        'socket'   => '/tmp/mysql.sock',
      },
      'mysql'       => {
        'prompt' => '\u@\h [\d]>\_',
        'no_auto_rehash' => '',
      },
      'mysqld'      => {
        'socket'                  => '/tmp/mysql.sock',
        'bind-address'            => $redmine::mysql_bind_address,
        'skip-networking'         => 'false',
        'lower_case_table_names'  => '1',
        'expire_logs_days'        => $redmine::mysql_expire_logs_days,
        'key_buffer_size'         => $redmine::mysql_key_buffer_size,
        'max_allowed_packet'      => $redmine::mysql_max_allowed_packet,
        'max_binlog_size'         => $redmine::mysql_max_binlog_size,
        'max_connections'         => $redmine::mysql_max_connection,
        'thread_cache_size'       => $redmine::mysql_thread_cache_size,
        'thread_stack'            => $redmine::mysql_thread_stack,
        'sort_buffer_size'        => $redmine::mysql_sort_buffer_size,

      },
      'mysqld_safe' => {
        'nice' => '0',
        'socket' => '/tmp/mysql.sock',
      },
    }
  }

  mysql::db { $redmine::db_name:
    user        => $redmine::db_user,
    password    => $redmine::db_password,
    host        => '%',
    grant       => 'ALL',
  }
}
