#Defines a csync2 group single node. Implemented as a resource collection
#Options:
#[group] The default group-name of this defined node in which to tag the entry.
#This is used in resource collection on the group
#[hostname] This specifies the hostname to use for the defined node. By default
#the hostname of the system.
#[ipaddress] The IP address to use to actually connect to the server. This
#could ALSO be a separate hostname. By default it's the primary IP on the
#system/server.
#[configfile] You probably shouldn't touch this.
#[slave] Set this node in master or slave status with csync2.
#If slave it will pull from defined master(s).

define csync2::groupnode (
  $group      = 'default',
  $hostname   = $::hostname,
  $ipaddress  = $::ipaddress,
  $configfile = $::csync2::csync2_config,
  $slave      = false,
) {
  include ::csync2

  #Variable validators
  validate_string($group)
  validate_string($hostname)
  validate_string($ipaddress)
  validate_absolute_path($configfile)
  validate_bool($slave)

  #Set this node as a slave if defined
  $hostname_true = $slave ? {
    true    => "(${hostname})",
    default => $hostname,
  }

  #The concat library is used here
  #Node is realized as the hostname and IP address for now
  #Will add an 'if' eventually so you can specify only via hostname, etc.
  concat::fragment { "${group}_csync2_member_${name}":
    order   => "20-${group}-${name}",
    target  => $configfile,
    content => "  host ${hostname_true}@${ipaddress};\n",
  }
}
