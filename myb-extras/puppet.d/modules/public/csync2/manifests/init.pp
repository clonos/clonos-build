# @summary Manages cluster software Csync2.
#
# @example Configures and install csync2 and also uses a preinstalled certificate and private key. Also a cronjob is needed to trigger the sync:
#   include csync2
#
#   cron { 'csync2':
#     command => "${::csync2::globals::csync2_bin} -x",
#     user    => 'root',
#   }
#
# @example The management of certificate and private key.
#   class { 'csync2':
#     ssl_cert => '-----BEGIN CERTIFICATE----- ...',
#     ssl_key  => '----BEGIN RSA PRIVATE KEY----- ...',
#   }
#
# @example Create two groups to sync. For more details have a look at defined resource 'group'.
#   class { 'csync2':
#     groups => {
#       'cluster' => {
#         hosts  => ['node1.example.org', 'node2.example.org'],
#         blocks => [{
#           'includes' => [ '/etc/csync2.cfg' ],
#         }],
#         key    => 'supersecret',
#       },
#       'monitoring' => {
#         hosts  => ['node1.example.org', 'node2.example.org'],
#         blocks => [{
#           'includes' => [ '/etc/icingaweb2' ],
#           'excludes' => [ '/etc/icingaweb2/modules/director', '/etc/icingaweb2/enabledModules/director' ],
#         }],
#         key    => 'supersecret',
#       },
#     },
#   }
#
# @param ensure
#   Whether the Csync2 service should be running or is stopped.
#
# @param enable
#   Whether to enable the Csync2 service at boot. 
#
# @param manage_package
#   Whether to install a Csync2 package.
#
# @param manage_service
#   Whether to handle the Csync2 service.
#
# @param port
#   Port ion Csync2 listens. Only effects if service is used.
#
# @param ssl_cert
#   The certificate to use for TLS connections. It will be stored into the file specified in ssl_cert_path.
#   If is set, you've also to set parameter ssl_key. Leaving both unset, you must manage the content of
#   ssl_cert_path and ssl_key_path yourself.
#
# @param ssl_key
#   The private key to use for TLS connections. It will be stored into the file specified in ssl_key_path.
#   If is set, you've also to set parameter ssl_cert. Leaving both unset, you must manage the content of
#   ssl_cert_path and ssl_key_path yourself.
#
# @param groups
#   Handles one or more groups.
#
class csync2 (
  Stdlib::Ensure::Service      $ensure         = 'running',
  Boolean                      $enable         = true,
  Boolean                      $manage_package = true,
  Boolean                      $manage_service = true,
  Stdlib::Port::Unprivileged   $port           = 30865,
  Optional[String]             $ssl_cert       = undef,
  Optional[String]             $ssl_key        = undef,
  Hash[String, Hash]           $groups         = {},
) {
  require csync2::globals

  if $ssl_cert or $ssl_key {
    unless $ssl_cert and $ssl_key {
      fail('Both of ssl_cert and ssl_key must be set.')
    }
  }

  Class['csync2::install']
  -> Class['csync2::config']
  ~> Class['csync2::service']

  contain csync2::install
  contain csync2::config
  contain csync2::service

  $groups.each |String $grp_name, Hash $grp_config| {
    csync2::group { $grp_name:
      * => $grp_config,
    }
  }
}
