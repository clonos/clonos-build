class profile::custom_facts(
  String $ensure = 'present',
) {

  file { '/etc/facter':
    ensure => directory,
    mode   => '0755',
  }

  file { '/etc/facter/facts.d':
    ensure  => directory,
    mode    => '0755',
    require => File['/etc/facter'],
  }

  file { '/etc/facter/facts.d/ipaddress':
    source => "puppet:///modules/${module_name}/facts.d/ipaddress",
    owner  => 0,
    group  => 0,
    mode   => '0555',
  }
}
