class es_bsd {

#future versions of Elasticsearch will require Java 11; your Java version from [/usr/local/openjdk8/jre] does not meet this requirement
#future versions of Elasticsearch will require Java 11; your Java version from [/usr/local/openjdk8/jre] does not meet this requirement

#  moved to hiera
  class { 'java':
    distribution => 'jre',
    #package      => 'openjdk8-jre',
    package => 'openjdk11-jre'
  }

  class { 'elasticsearch':
#    manage_repo => false,
    package_name => 'elasticsearch7',

    # ml is not supported on FreeBSD
    #xpack.ml.enabled: false

    # Enum['init', 'openbsd', 'openrc', 'systemd']    $service_provider,
    service_provider => 'freebsd',
    restart_on_change => true,
    #autoupgrade => true,
    #repo_version => '2.x',
    config => { 'cluster.name' => "${hostname}" },
    #datadir => '/var/db/elasticsearch',
    elasticsearch_group => 'elasticsearch',
    elasticsearch_user => 'elasticsearch',
    #homedir => '/usr/local/etc/elasticsearch',
    homedir => '/usr/local/etc/elasticsearch',
    package_dir => '/tmp',
  }

  elasticsearch::instance { "$hostname":
    #datadir => "/var/lib/elasticsearch/$fqdn",
    config => {
      'node.name' => "$hostname",
      #'threadpool.search.queue_size' => 10000,
      'http.bind_host' => '0.0.0.0',
      'http.port' => '9200',
      'http.cors.enabled' => 'false',
      # ml is not supported on FreeBSD
      'xpack.ml.enabled' => 'false',
    }
  }

#  moved to  hiera
#  class { 'kibana':
#    config => {
#      'server.port' => '8082',
#    }
#  }

}
