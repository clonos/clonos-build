# == Class: roundcube
#
# Install and manage the Roundcube webmail application.
#
# === Parameters
#
# [*version*]
#   Set the version of the web application to be installed.
#
# [*checksum*]
#   Set the checksum of the web application's archive file.
#
# [*checksum_type*]
#   Set the type of checksum.
#
# [*process*]
#   Set the process user that is used to execute the application; in this case the php interpreter.
#
# [*package_dir*]
#   Set the directory where to keep the downloaded software packages.
#
# [*install_dir*]
#   Set the directory where to install the web application.
#
# [*exec_paths*]
#   Set the paths used to search for executables when invoking exec resources.
#
# [*composer_command_name*]
#   Set name of the composer executable. It is expected to find the executable via the `exec_paths`.
#
# [*composer_disable_git_ssl_verify*]
#   Set to `true` to disable the SSL certificate check when cloning a git repository. Only required when the CA
#   presented by the git server while installing the Roundcube dependencies is not trusted by this host.
#   See https://stackoverflow.com/q/21181231.
#
# [*document_root*]
#   Set the directory which should act as document root. It will be sym-linked to the current installation.
#
# [*document_root_manage*]
#   Whether to manage the `document_root` file resource or not: either `true` or `false`.
#
# [*archive_provider*]
#   Select which `archive` type should be used to download RoundCube from the
#   download site. There exist at least two modules that provide an `archive`
#   type: "camptocamp/archive" and "nanliu/archive" (or "puppet/archive"
#   since the module is now in the care of puppet-community). Defaults to
#   'camptocamp'. If you set this to 'nanliu' (or 'puppet') make sure you have
#   that module installed since both cannot be recorded as a dependency in
#   metadata.json at the same time.
#
# [*archive_proxy_server*]
#   Proxy server to use with archive module. Example: "https://proxy.example.com:8080"
#
# [*db_dsn*]
#   Set the database data source name (DSN) to be used when connecting to the database. Setting this parameter will
#   override the other `db_*` parameters. See http://pear.php.net/manual/en/package.database.mdb2.intro-dsn.php for
#   examples.
#
#   Note: please make sure any special characters are properly encoded (e.g. use stdlib's uriescape function).
#
# [*db_type*]
#   Set the type database (e.g. mysql or pgsql). See http://pear.php.net/manual/en/package.database.mdb2.intro-dsn.php
#   for a reference of supported types. Defaults to `pgsql`.
#
# [*db_name*]
#   Set the name of the database. Defaults to `roundcubemail`.
#
# [*db_host*]
#   Set the hostname where the database is running. Puppet can only manage databases on the local host. Defaults to
#   `localhost`.
#
# [*db_username*]
#   Set the username used to connect to the database. Defaults to `roundcube`.
#
# [*db_password*]
#   Set the password used to authenticate the database user. The module will encode any special characters. Defaults to
#   `pass`.
#
# [*imap_host*]
#   Set the IMAP mail host chosen to perform the log-in (`default_host` configuration parameter). Defaults to
#   `localhost`.
#
# [*imap_port*]
#   Set the TCP port used for IMAP connections. Defaults to `143`.
#
# [*des_key*]
#   Set key used to encrypt the users' IMAP password which is stored in the session record (and the client cookie if
#   remember password is enabled). Please provide a string of exactly 24 chars. YOUR KEY MUST BE DIFFERENT THAN THE
#   SAMPLE VALUE FOR SECURITY REASONS.
#
# [*plugins*]
#   List of plugins to be enabled. Only bundled plugins are supported and their default configuration is used. To
#   customize the configuration or to manage plugins from the plugin repository use the `roundcube::plugin` resource
#   instead.
#
# [*config_file_template*]
#   Set the path to a custom template file. By default a configuration file is generated containing only the parameters
#   listed in the `options_hash`. If this template file is set, the configuration is replace with the referenced
#   template.
#
# [*options_hash*]
#   Specify custom Roundcube configuration settings. See config/defaults.inc.php in the roundcube directory for a
#   complete list of possible configuration arguments.
#
# [*package_name*]
# The name of the package managed with the 'package' archive method.
#
# [*cronjobs_manage*]
#   Whether to manage cronjobs for Roundcube: either `true` or `false`.
#
# === Copyright
#
# Copyright 2015 Martin Meinhold, unless otherwise noted.
#
class roundcube (
  $version                         = $roundcube::params::version,
  $checksum                        = $roundcube::params::checksum,
  $checksum_type                   = $roundcube::params::checksum_type,
  $process                         = $roundcube::params::process,

  $package_dir                     = $roundcube::params::package_dir,
  $install_dir                     = $roundcube::params::install_dir,
  $exec_paths                      = $roundcube::params::exec_paths,
  $composer_command_name           = $roundcube::params::composer_command_name,
  $composer_disable_git_ssl_verify = $roundcube::params::composer_disable_git_ssl_verify,
  $composer_manage                 = $roundcube::params::composer_manage,
  $document_root                   = $roundcube::params::document_root,
  $document_root_manage            = $roundcube::params::document_root_manage,

  $archive_provider                = $roundcube::params::archive_provider,
  $archive_proxy_server            = undef,

  $db_dsn                          = undef,
  $db_type                         = 'pgsql',
  $db_name                         = 'roundcubemail',
  $db_host                         = 'localhost',
  $db_username                     = 'roundcube',
  $db_password                     = 'pass',

  $imap_host                       = 'localhost',
  $imap_port                       = 143,
  $des_key                         = 'rcmail-!24ByteDESkey*Str',
  String $package_name             = undef,
  $plugins                         = [],
  $plugins_manage                  = $roundcube::params::plugins_manage,
  $cronjobs_manage                 = $roundcube::params::cronjobs_manage,

  $config_file_template            = undef,
  $options_hash                    = {},
) inherits roundcube::params {
  validate_string($version)
  validate_string($checksum)
  validate_string($checksum_type)
  validate_string($process)
  validate_absolute_path($package_dir)
  validate_absolute_path($install_dir)
  validate_string($composer_command_name)
  validate_bool($composer_disable_git_ssl_verify)
  validate_bool($composer_manage)
  validate_absolute_path($document_root)
  validate_bool($document_root_manage)
  validate_string($archive_provider)
  validate_string($db_type)
  validate_string($db_name)
  validate_string($db_host)
  validate_string($db_username)
  validate_string($db_password)
  validate_string($imap_host)
  validate_string($des_key)
  validate_array($plugins)
  validate_bool($plugins_manage)
  validate_bool($cronjobs_manage)
  validate_hash($options_hash)

  if !empty($plugins) and $plugins_manage == false {
    fail("Class[Roundcube]: conflicting parameters - plugin configuration disabled but plugins specified: ${plugins}")
  }

  $env_git_ssl_no_verify = $composer_disable_git_ssl_verify ? {
    true    => ['GIT_SSL_NO_VERIFY=true'],
    default => [],
  }

  $composer_exec_environment = flatten([
    "HOME=${::root_home}",  # root_home is provided by stdlib
    'COMPOSER_NO_INTERACTION=1',
    $env_git_ssl_no_verify,
  ])

  class { 'roundcube::install': }
  class { 'roundcube::config': }
  ~> class { 'roundcube::service': }
  ~> class { 'roundcube::initdb': }
}
