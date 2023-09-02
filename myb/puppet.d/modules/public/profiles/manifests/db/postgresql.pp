class profiles::db::postgresql (
  Hash $globals = {},
  Hash $params = {},
  Hash $recovery = {},
  Hash[String, Hash[String, Variant[String, Boolean, Integer]]] $roles = {},
  Hash[String, Hash[String, Variant[String, Boolean]]] $db_configs = {},
  Hash[String, Hash[String, Variant[String, Boolean]]] $databases = {},
  #Hash[String, String] $db_grants = {},
  Hash $db_grants = {},
  Hash $grants = {},
  Hash[String, Hash[String, String]] $extensions = {},
  Hash[String, String] $table_grants = {},
  Hash[String, Hash[String, String]] $hba_rules = {},
  Hash[String, String] $indent_rules = {},
  Optional[String] $role = undef, # 'master', 'slave'
  Optional[String] $master_host = undef,
  Optional[String] $replication_password = undef,
  Integer $master_port = 5432,
  String $replication_user = 'replication',
  String $trigger_file = '/tmp/pg_trigger.file',
){

  case $role {
    'slave': {
      $_params = {
        manage_recovery_conf => true,
      }

      if $globals['datadir'] {
        file { "${globals['datadir']}/recovery.done":
          ensure => absent,
        }
      }

      $_recovery = {
        'recovery config' => {
          standby_mode     => 'on',
          primary_conninfo => "host=${master_host} port=${master_port} user=${replication_user} password=${replication_password}",
          trigger_file     => $trigger_file,
        }
      }

      $_conf = {
        'hot_standby' => {
          value => 'on',
        },
      }

      file { $trigger_file:
        ensure => absent,
      }

    }
    'master': {
      $_conf = {
        'wal_level' => {
          value => 'replica',
        },
        'max_wal_senders' => {
          value => 5,
        },
        'wal_keep_segments' => {
          value => 32,
        },
      }

      file { $trigger_file:
        ensure => present,
      }
    }
    default: {
      $_params = {}
      $_recovery = {}
      $_conf = {}
    }
  }

  class { '::postgresql::globals':
    * => $globals,
  }

  class { '::postgresql::server':
    * => deep_merge($_params, $params),
  }

  class { 'postgresql::server::contrib': }

#  postgresql::server::role { 'listmonk':
#    password_hash => postgresql::postgresql_password('listmonk', 'mypasswd'),
#  }

  create_resources('::postgresql::server::config_entry', deep_merge($_conf, $db_configs))
  create_resources('::postgresql::server::role', $roles)
  create_resources('::postgresql::server::database', $databases)
  create_resources('::postgresql::server::database_grant', $db_grants)
  create_resources('::postgresql::server::extension', $extensions)
  create_resources('::postgresql::server::grant', $grants)
  create_resources('::postgresql::server::table_grant', $table_grants)
  create_resources('::postgresql::server::pg_hba_rule', $hba_rules)
  create_resources('::postgresql::server::pg_indent_rule', $indent_rules)
  create_resources('::postgresql::server::recovery', deep_merge($_recovery, $recovery))
}
