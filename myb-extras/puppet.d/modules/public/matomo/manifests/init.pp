# == Class: matomo
#
# Module to install an up-to-date version of Matomo from https://builds.matomo.org.
#
# kisakye@gmail.com
#
class matomo (

  $package_version                      = $matomo::params::package_version,
  $docroot                              = $matomo::params::docroot,
  $package_manage                       = $matomo::params::package_manage,

) inherits matomo::params {

    include matomo::install

}
