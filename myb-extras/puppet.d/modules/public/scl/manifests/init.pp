# Manage Software Collection repositories and utilities.
#
# @example Declaring the class
#   include ::yum
#   include ::scl
#
# @param gpgkeys
# @param manage_gpgkeys
# @param package_name
# @param repos
#
# @see puppet_defined_types::scl::collection ::scl::collection
#
# @since 1.0.0
class scl (
  Hash[Stdlib::Absolutepath, String] $gpgkeys        = $::scl::params::gpgkeys,
  Boolean                            $manage_gpgkeys = $::scl::params::manage_gpgkeys,
  String                             $package_name   = $::scl::params::package_name,
  Hash[String, Hash[String, Any]]    $repos          = $::scl::params::repos,
) inherits ::scl::params {

  contain ::scl::install
  contain ::scl::config

  Class['::scl::install'] -> Class['::scl::config']
}
