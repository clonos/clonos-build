# Download and installation of matomo happens here
#
# @summary Download and installation of matomo happens here
#
# @api private
#include matomo::install
class matomo::install {

  if $matomo::package_manage == true {

  exec{'www_folder':
    command => "mkdir -p ${matomo::docroot}",
    unless  => "test -d ${matomo::docroot}",
    path    => ['/bin', '/usr/bin',],
  }

  archive { "/opt/matomo-${matomo::package_version}.tar.gz":
        ensure       => present,
        extract      => true,
        extract_path => $matomo::docroot,
        source       => "https://builds.matomo.org/matomo-${matomo::package_version}.tar.gz",
        creates      => "/opt/matomo-${matomo::package_version}.tar.gz",
        cleanup      => false,
        require      => Exec['www_folder'],
    }
  }

}
