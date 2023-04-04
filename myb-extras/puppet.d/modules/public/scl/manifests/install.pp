# @!visibility private
class scl::install {

  package { $::scl::package_name:
    ensure => present,
  }
}
