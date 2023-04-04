# Software Collection install helper.
#
# @example Install a collection and permanently enable it
#   ::scl::collection { 'rh-git29':
#     enable => true,
#   }
#
# @param collection The name of the collection, which is itself a metapackage
#   to install.
# @param enable Drop a fragment in `/etc/profile.d` to permanently enable the
#   collection.
# @param ensure
#
# @see puppet_classes::scl ::scl
#
# @since 1.0.0
define scl::collection (
  String                    $collection = $title,
  Boolean                   $enable     = false,
  Enum['present', 'absent'] $ensure     = 'present',
) {

  if ! defined(Class['::scl']) {
    fail('You must include the scl base class before using any scl defined resources')
  }

  package { $collection:
    ensure => $ensure,
  }

  if $ensure == 'present' and $enable {
    file { "/etc/profile.d/scl-${collection}.sh":
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0644',
      content => @("EOS"/L),
        source scl_source enable ${collection}
        | EOS
      require => Package[$collection],
    }
  } else {
    file { "/etc/profile.d/scl-${collection}.sh":
      ensure => absent,
    }
  }
}
