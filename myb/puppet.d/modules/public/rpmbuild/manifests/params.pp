# class rpmbuild::params
#
# This class contains default params for rpmbuild module
#
class rpmbuild::params {

  $rpmbuild_packages = ['make','automake', 'autoconf', 'gcc', 'gcc-c++', 'rpm-build', 'redhat-rpm-config', 'rpmdevtools', 'yum', 'yum-utils', 'createrepo', 'gnupg2', ]
  $optional_packages = []
}

