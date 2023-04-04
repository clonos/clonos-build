# Class: rpmbuild
#
# This module manages the creation and setup for an environment to build RPMs.
# This will install the basic needed packages to build RPMs and will have
# macros to setup the build environment for each user needed
#
# Parameters:
# rpmbuild_packages - An array of packages that are needed to build rpms
# optional_packages - Any additional packages that need to be install
#
# Actions: Installs needed packages to build RPMs and configures the build
# environment for each user that is needed
#
# Requires: see Modulefile
#
#
class rpmbuild (
  $rpmbuild_packages = $rpmbuild::params::rpmbuild_packages,
  $optional_packages = $rpmbuild::params::optional_packages,
  ) inherits rpmbuild::params {

  # validate params
  validate_array($rpmbuild_packages)
  validate_array($optional_packages)

  # install the packages
  ensure_packages($rpmbuild_packages, {'ensure' => 'latest'})

  # if there are optional packages provided install them to the latest version
  if ! empty($optional_packages) {
    ensure_packages($optional_packages, {'ensure' => 'latest'})
  }

  # if the operating system is fedora install the extra packages
  if $::operatingsystem == 'Fedora' {

    # install fedora-packager to the latest version
    ensure_packages('fedora-packager', {'ensure' => 'latest'})

    # install rpm-sign to the latest version
    ensure_packages('rpm-sign', {'ensure' => 'latest'})
  }
}
