# == Define: roundcube:plugin
#
# Install and configure the given Roundcube plugin.
#
# === Parameters
#
# [*ensure*]
#   Set the package state of the plugin. Should be `present` for bundled plugins and the version string for plugins
#   sourced from the plugin repository.
#
# [*config_file_template*]
#   Set the path to a custom template file. By default, the default configuration shipped by with plugin is used and
#   only parameters listed in the `options_hash` are overriden. If this template file is set, default configuration is
#   replace with the referenced template.
#
# [*options_hash*]
#   Specify custom configuration settings. Please check the plugin's default configuration file for available settings.
#   Note: Some plugins do not offer any configuration settings at all.
#
# === Copyright
#
# Copyright 2015 Martin Meinhold, unless otherwise noted.
#
define roundcube::plugin (
  $ensure = present,
  $config_file_template = undef,
  $options_hash = {},
) {
  include roundcube
  if $roundcube::plugins_manage == false {
    fail("Roundcube::Plugin[${name}]: conflicting parameters - plugin configuration disabled but plugin resource defined")
  }
  if ($roundcube::composer_manage == true) {
    include composer
  }

  $application_dir = $roundcube::install::target
  $config_file = $roundcube::config::config_file
  $title_array = split($title, '/')
  $system_plugin = size($title_array) == 1

  if $system_plugin {
    $plugin_name = $name
  }
  else
  {
    $plugin_name = $title_array[1]
  }

  $plugin_config_file = "${application_dir}/plugins/${plugin_name}/config.inc.php"
  $plugin_config_template_file = "${plugin_config_file}.dist"
  $options = $options_hash

if ($roundcube::archive_provider == package) {
  concat::fragment { "${config_file}__plugins_${plugin_name}":
    target  => $config_file,
    content => "  '${plugin_name}',\n",
    order   => '55',
  }
} else {

  if !$system_plugin {
    exec { "${roundcube::composer_command_name} require ${name}:${ensure} --update-no-dev --ignore-platform-reqs":
      unless      => "${roundcube::composer_command_name} show --installed ${name} ${ensure}",
      cwd         => $application_dir,
      path        => $roundcube::exec_paths,
      environment => $roundcube::composer_exec_environment,
      require     => Class['roundcube::install'],
      before      => File[$plugin_config_template_file],
    }
  }

  # Provide a default configuration file in case the plugin doesn't ship any
  file { $plugin_config_template_file:
    ensure  => file,
    content => '<?php /* This file is just a placeholder; the plugin does not provide any configuration options. */',
    replace => false,
    require => Class['roundcube::install'],
  }

  # Some config files have a closing php tag; this would break the injection of our custom configuration options. Unable
  # to replace the line with a newline, an opening tag is added instead.
  file_line { $plugin_config_template_file:
    path    => $plugin_config_template_file,
    match   => '^\?>\s*$',
    line    => '?><?php',
    require => File[$plugin_config_template_file],
  }

  if empty($config_file_template) {
    concat { $plugin_config_file:
      ensure => present,
      owner  => $roundcube::process,
      group  => $roundcube::process,
      mode   => '0440',
    }

    concat::fragment { "${plugin_config_file}__default_config":
      target  => $plugin_config_file,
      source  => "${plugin_config_file}.dist",
      order   => '10',
      require => File_line[$plugin_config_template_file],
    }


    if !empty($options_hash) {
      concat::fragment { "${plugin_config_file}__custom_config":
        target  => $plugin_config_file,
        content => template('roundcube/config/options.php.erb'),
        order   => '20',
      }
    }
  }
  else {
    file { $plugin_config_file:
      ensure  => file,
      content => template($config_file_template),
      owner   => $roundcube::process,
      group   => $roundcube::process,
      mode    => '0440',
      require => File_line[$plugin_config_template_file],
    }
  }

  concat::fragment { "${config_file}__plugins_${plugin_name}":
    target  => $config_file,
    content => "  '${plugin_name}',\n",
    order   => '55',
  }
}
  # ensure plugins are executed before the symlink is updated
  Roundcube::Plugin[$title] ~> Class['roundcube::service']
}
