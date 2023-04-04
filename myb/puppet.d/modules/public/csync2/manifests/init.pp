#The base csync2 resource initialization.
#Options:
#[ensure] Set to (absent/present). Defaults to present for the csync2 resources
#
#[checkfreq] The default check frequency for all groups on the csync2 hosts
#
class csync2 (
  $ensure          = 'present',
  $checkfreq       = $::csync2::params::checkfreq,
  $csync2_package  = $::csync2::params::csync2_package,
  $inotify_package = $::csync2::params::inotify_package,
  $csync2_exec     = $::csync2::params::csync2_exec,
  $csync2_config   = $::csync2::params::configfile,
  $xinetd_group    = $::csync2::params::xinetd_group,
) inherits ::csync2::params {

  #Validate variables
  validate_re($ensure, '^present$|^absent$')
  validate_string($csync2_package)
  validate_string($inotify_package)
  validate_absolute_path($csync2_exec)
  validate_absolute_path($csync2_config)

  #Install the basic packages
  ensure_packages( [$csync2_package, $inotify_package],
    { ensure => $ensure }
  )

  #Csync2 needs xinetd
  xinetd::service { 'csync2':
    ensure      => $ensure,
    user        => 'root',
    group       => "$xinetd_group",
    port        => '30865',
    server      => $csync2_exec,
    server_args => '-i',
    flags       => 'REUSE',
    protocol    => 'tcp',
  }

}
