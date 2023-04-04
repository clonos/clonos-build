class profiles::db::elasticsearch (
  Hash $globals = {},
  #Hash[String, Hash[String, Variant[String, Boolean]]] $instance = {},
  Hash $instance = {},
){

  #? not in mod
  file { '/var/db/elasticsearch':
    ensure => directory,
    owner => 'elasticsearch',
    group => 'elasticsearch',
  }

  class { '::elasticsearch':
    * => $globals,
  }

  create_resources('::elasticsearch::instance', $instance)
}
