# @!visibility private
class scl::params {

  case $::facts['os']['family'] {
    'RedHat': {
      $package_name = 'scl-utils'

      case $::facts['os']['name'] {
        'CentOS': {
          $gpgkeys        = {
            '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo' => file("${module_name}/RPM-GPG-KEY-CentOS-SIG-SCLo"),
          }
          $manage_gpgkeys = true
          $repos          = {
            'centos-sclo-sclo'           => {
              'ensure'   => 'present',
              'baseurl'  => "http://mirror.centos.org/centos/${::facts['os']['release']['major']}/sclo/\$basearch/sclo/",
              'descr'    => "CentOS-${::facts['os']['release']['major']} - SCLo sclo",
              'enabled'  => 1,
              'gpgcheck' => 1,
              'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo',
            },
            'centos-sclo-sclo-debuginfo' => {
              'ensure'   => 'present',
              'baseurl'  => "http://debuginfo.centos.org/centos/${::facts['os']['release']['major']}/sclo/\$basearch/",
              'descr'    => "CentOS-${::facts['os']['release']['major']} - SCLo sclo Debuginfo",
              'enabled'  => 0,
              'gpgcheck' => 1,
              'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo',
            },
            'centos-sclo-sclo-source'    => {
              'ensure'   => 'present',
              'baseurl'  => "http://vault.centos.org/centos/${::facts['os']['release']['major']}/sclo/Source/sclo/",
              'descr'    => "CentOS-${::facts['os']['release']['major']} - SCLo sclo Sources",
              'enabled'  => 0,
              'gpgcheck' => 1,
              'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo',
            },
            'centos-sclo-sclo-testing'   => {
              'ensure'   => 'present',
              'baseurl'  => "http://buildlogs.centos.org/centos/${::facts['os']['release']['major']}/sclo/\$basearch/sclo/",
              'descr'    => "CentOS-${::facts['os']['release']['major']} - SCLo sclo Testing",
              'enabled'  => 0,
              'gpgcheck' => 0,
              'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo',
            },
            'centos-sclo-rh'             => {
              'ensure'   => 'present',
              'baseurl'  => "http://mirror.centos.org/centos/${::facts['os']['release']['major']}/sclo/\$basearch/rh/",
              'descr'    => "CentOS-${::facts['os']['release']['major']} - SCLo rh",
              'enabled'  => 1,
              'gpgcheck' => 1,
              'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo',
            },
            'centos-sclo-rh-debuginfo'   => {
              'ensure'   => 'present',
              'baseurl'  => "http://debuginfo.centos.org/centos/${::facts['os']['release']['major']}/sclo/\$basearch/",
              'descr'    => "CentOS-${::facts['os']['release']['major']} - SCLo rh Debuginfo",
              'enabled'  => 0,
              'gpgcheck' => 1,
              'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo',
            },
            'centos-sclo-rh-source'      => {
              'ensure'   => 'present',
              'baseurl'  => "http://vault.centos.org/centos/${::facts['os']['release']['major']}/sclo/Source/rh/",
              'descr'    => "CentOS-${::facts['os']['release']['major']} - SCLo rh Sources",
              'enabled'  => 0,
              'gpgcheck' => 1,
              'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo',
            },
            'centos-sclo-rh-testing'     => {
              'ensure'   => 'present',
              'baseurl'  => "http://buildlogs.centos.org/centos/${::facts['os']['release']['major']}/sclo/\$basearch/rh/",
              'descr'    => "CentOS-${::facts['os']['release']['major']} - SCLo rh Testing",
              'enabled'  => 0,
              'gpgcheck' => 0,
              'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo',
            },
          }
        }
        default: {
          $gpgkeys        = {} # FIXME
          $manage_gpgkeys = false
          $repos          = {} # FIXME
        }
      }
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::facts['os']['family']} based system.")
    }
  }
}
