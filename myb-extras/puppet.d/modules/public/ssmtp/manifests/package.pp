# Class: ssmtp::package
#
# This module contain the service configuration for sSMTP
#
# Parameters:   This module has no parameters
#
# Actions:      This module has no actions
#
# Requires:     This module has no requirements
#
# Sample Usage: include ssmtp::package
#
class ssmtp::package {
  package { $ssmtp::params::package_ssmtp: ensure => installed; }
}
