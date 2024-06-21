class redmine(
  $db_name                  = "redmine",
  $db_user                  = "redmine",
  $db_password              = "redmine_password",
  $redmine_port             = 3000,
  $redmine_package          = "redmine51",
  $remove_default_accounts  = true,
  $mysql_version            = '57',
  $mysql_max_connection     = '128',
  $mysql_bind_address       = '127.0.0.1',
  $mysql_expire_logs_days   = '10',
  $mysql_max_allowed_packet = '16M',
  $mysql_key_buffer_size    = '16M',
  $mysql_max_binlog_size    = '100M',
  $mysql_thread_cache_size  = '8',
  $mysql_thread_stack       = '256K',
  $mysql_sort_buffer_size   = '8M',
) {

  contain '::redmine::install'
  contain '::redmine::mysql'
  contain '::redmine::config'

  Class['::redmine::install'] ->
  Class['::redmine::mysql'] ->
  Class['::redmine::config']

}
