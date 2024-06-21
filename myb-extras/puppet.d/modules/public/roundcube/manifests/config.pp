# Class: roundcube::config
#
# Manage the Roundcube configuration files.
#
# === Copyright
#
# Copyright 2015 Martin Meinhold, unless otherwise noted.
#
class roundcube::config inherits roundcube {

  $application_dir = $roundcube::install::target
  $config_file = "${application_dir}/config/config.inc.php"

  if empty($roundcube::db_dsn) {
    $password = uriescape($roundcube::db_password)
    $db_dsnw = "${roundcube::db_type}://${roundcube::db_username}:${password}@${roundcube::db_host}/${roundcube::db_name}"
  }
  else {
    $db_dsnw = $roundcube::db_dsn
  }

  $options_defaults = {
    'db_dsnw' => $db_dsnw,
    'des_key' => $roundcube::des_key,
  }

  if versioncmp($roundcube::version, '1.6.0') < 0 {
    $imap_defaults = {
      'default_host' => $roundcube::imap_host,
      'default_port' => $roundcube::imap_port,
    }
  } else {
    # see https://github.com/roundcube/roundcubemail/releases/tag/1.6.0
    $imap_defaults = {
      'imap_host' => "${$roundcube::imap_host}:${$roundcube::imap_port}",
    }

    if 'smtp_server' in $roundcube::options_hash {
      fail('As of 1.6, the \'smtp_server\' configuration option has been renamed to \'smtp_host\'. Please update your resource.')
    }
    if 'smtp_port' in $roundcube::options_hash {
      fail('As of 1.6, the \'smtp_port\' configuration option has merged into \'smtp_host\'. Please update your resource.')
    }
  }

  $options = merge($options_defaults, $imap_defaults, $roundcube::options_hash)

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
