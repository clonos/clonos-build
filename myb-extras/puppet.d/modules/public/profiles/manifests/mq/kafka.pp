class profiles::mq::kafka (
  $globals = {},
  $broker = {},
  $producer = {},
  Hash $topics = {},
){

  class { '::kafka':
    * => $globals,
  }

  class { 'kafka::broker':
    * => $broker,
  }

  # Console Producer is not supported on systemd
#  class { 'kafka::producer':
#    input => 'test',
#    * => $producer,
#  }

  create_resources(kafka::topic, $topics)
}
