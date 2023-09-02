# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include matomo::db
class matomo::mysql::db (

  $root_password                        = $matomo::params::root_password,
  $remove_default_accounts              = $matomo::params::remove_default_accounts,
  $matomo_db_user                       = $matomo::params::matomo_db_user,
  $matomo_db_password                   = $matomo::params::matomo_db_password,
  $matomo_db_name                       = $matomo::params::matomo_db_name,
  $host                                 = $matomo::params::host,
  $grant                                = $matomo::params::grant,
  $sql_backup_file                      = $matomo::params::sql_backup_file,
  $enforce_sql                          = $matomo::params::enforce_sql,

) {

class { '::mysql::server':
  root_password           => $root_password,
  remove_default_accounts => $remove_default_accounts,
  override_options        => {
        mysqld => {
        max_allowed_packet => '64M',
            },
        }
    }
    mysql::db { $matomo_db_name:
        user        => $matomo_db_user,
        password    => $matomo_db_password,
        host        => $host,
        grant       => $grant,
        sql         => $sql_backup_file,
        enforce_sql => $enforce_sql,
    }

}
