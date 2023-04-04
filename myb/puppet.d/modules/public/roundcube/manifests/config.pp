# Class: roundcube::config
#
# Manage the Roundcube configuration files.
#
# === Copyright
#
# Copyright 2015 Martin Meinhold, unless otherwise noted.
#
class roundcube::config inherits roundcube {

  if ($roundcube::archive_provider == package) {
    $application_dir = $roundcube::document_root
  } else {
    $application_dir = $roundcube::install::target
  }
  $config_file = "${application_dir}/config/config.inc.php"

  if empty($roundcube::db_dsn) {
    $password = uriescape($roundcube::db_password)
    $db_dsnw = "${roundcube::db_type}://${roundcube::db_username}:${password}@${roundcube::db_host}/${roundcube::db_name}"
  }
  else {
    $db_dsnw = $roundcube::db_dsn
  }

  $options_defaults = {
    'db_dsnw'      => $db_dsnw,
    'default_host' => $roundcube::imap_host,
    'default_port' => $roundcube::imap_port,
    'des_key'      => $roundcube::des_key,
  }

  $options = merge($options_defaults, $roundcube::options_hash)

  concat { $config_file:
    owner => $roundcube::process,
    group => $roundcube::process,
    mode  => '0440',
  }

  Concat::Fragment {
    target  => $config_file,
  }

  if empty($roundcube::config_file_template) {
    concat::fragment { "${config_file}__header":
      content => template('roundcube/config/header.php.erb'),
      order   => '10',
    }

    if !empty($options) {
      concat::fragment { "${config_file}__options":
        content => template('roundcube/config/options.php.erb'),
        order   => '20',
      }
    }
  }
  else {
    concat::fragment { "${config_file}__header":
      content => template($roundcube::config_file_template),
      order   => '10',
    }
  }

  if $roundcube::plugins_manage == true {
    concat::fragment { "${config_file}__plugins_head":
      content => "\$config[\'plugins\'] = array(\n",
      order   => '50',
    }

    concat::fragment { "${config_file}__plugins_tail":
      content => ");\n",
      order   => '60',
    }
  }

  roundcube::plugin { $roundcube::plugins: }

  if $roundcube::cronjobs_manage == true {
    file { '/etc/cron.daily/roundcube-cleandb':
      ensure => absent,
    }

    cron { 'roundcube-cleandb':
      ensure  => present,
      command => "${application_dir}/bin/cleandb.sh > /dev/null",
      user    => 'root',
      hour    => fqdn_rand(24),
      minute  => fqdn_rand(60),
    }
  }
}
