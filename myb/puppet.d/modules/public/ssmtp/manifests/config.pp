# Class: ssmtp::config
#
# This module contain the configuration for sSMTP
#
# Parameters:   This module has no parameters
#
# Actions:      This module has no actions
#
# Requires:     This module has no requirements
#
# Sample Usage: include ssmtp::config
#
class ssmtp::config {
  # make parameters available in local scope for usage in templates
  $default_mta           = $ssmtp::default_mta
  $root_email            = $ssmtp::root_email
  $mail_hub              = $ssmtp::mail_hub
  $revaliases            = $ssmtp::revaliases
  $from_line_override    = $ssmtp::from_line_override
  $hostname              = $ssmtp::hostname
  $rewritedomain         = $ssmtp::rewritedomain
  $authuser              = $ssmtp::authuser
  $authpass              = $ssmtp::authpass
  $authmethod            = $ssmtp::authmethod
  $usetls                = $ssmtp::usetls
  $usestarttls           = $ssmtp::usestarttls
  $tlscert               = $ssmtp::tlscert
  $tlskey                = $ssmtp::tlskey
  $tlscafile             = $ssmtp::tlscafile
  $tlscadir              = $ssmtp::tlscadir
  $ssmtp_conf_mode       = $ssmtp::ssmtp_conf_mode
  $ssmtp_conf_owner      = $ssmtp::ssmtp_conf_owner
  $ssmtp_conf_group      = $ssmtp::ssmtp_conf_group
  $revaliases_conf_mode  = $ssmtp::revaliases_conf_mode
  $revaliases_conf_owner = $ssmtp::revaliases_conf_owner
  $revaliases_conf_group = $ssmtp::revaliases_conf_group

  # sSMTP configuration
  file {
    $ssmtp::params::config_ssmtp_conf:
      ensure  => file,
      mode    => $ssmtp_conf_mode,
      owner   => $ssmtp_conf_owner,
      group   => $ssmtp_conf_group,
      path    => $ssmtp::params::config_ssmtp_conf,
      content => template($ssmtp::params::config_ssmtp_conf_template);

    $ssmtp::params::config_revaliases_conf:
      ensure  => file,
      mode    => $revaliases_conf_mode,
      owner   => $revaliases_conf_owner,
      group   => $revaliases_conf_group,
      path    => $ssmtp::params::config_revaliases_conf,
      content => template($ssmtp::params::config_revaliases_conf_template);
  }
}
