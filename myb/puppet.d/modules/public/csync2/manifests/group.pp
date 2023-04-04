#Resource definition for a csync2 GROUP. This is the core resource realized on
#each node in the csync2 cluster.
#Options:
#[group_key] This defines the name of the group-key to utilize for the defined
#group. By default it will be based off of the NAME of the defined resource.
#[key_source] Defines the location (local or from puppet-server) of the key
#to use for syncing this particular group
#[includes] The list of folders, or single folders to use with a sync group.
#Defaults to a test path.
#[excludes] A default list of files or folders to EXCLUDE from syncing. This
#defaults to everything so make sure to modify this option!
#[configfile] The default config-file to use for csync2. You probably
#shouldn't modify.
#[configpath] The default config-path to use for csync2.
#[auto] The logic to use for syncing of conflicts. This defaults to none. You
#can choose from:
#none, first, younger, older, bigger, smaller, left, right. Probably younger or
#none is what you want.
#[checkfreq] The amount of sleep timing to wait after a file modification has
#been detected. Default to 5s.

#Base resource definition for a csync2 group.
define csync2::group (
  $group_key      = "csync2.${name}.key",
  $key_source     = $::csync2::params::default_key,
  $includes       = $::csync2::params::default_includes,
  $excludes       = $::csync2::params::default_excludes,
  $configfile     = $::csync2::csync2_config,
  $configpath     = $::csync2::params::configpath,
  $auto           = $::csync2::params::default_auto,
  $checkfreq      = $::csync2::checkfreq,
  $csync2_exec    = $::csync2::csync2_exec,
  $csync2_package = $::csync2::csync2_package,
) {
  include ::csync2
  include ::csync2::params

  #Variable validators
  validate_string($group_key)
  validate_string($key_source)
  validate_array($includes)
  validate_absolute_path($configfile)
  validate_absolute_path($configpath)
  validate_string($auto)
  validate_string($checkfreq)
  validate_absolute_path($csync2_exec)
  validate_string($csync2_package)

  #Copy the key to the host
  file { "${configpath}/${group_key}":
    ensure  => present,
    source  => $key_source,
    replace => true,
    group   => '0',
    owner   => '0',
    mode    => '0600',
  }

  #Build a very basic concat csync2 file
  concat { $configfile:
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Package[$csync2_package],
    notify  => Exec['csync2_checksync'],
  }
  concat::fragment{ 'csync2-header':
    target  => $configfile,
    order   => '01',
    content => "#This file managed by Puppet\nnossl * *;\n",
  }

  #Define the csync2 group
  concat::fragment { "${name}_csync2_header":
    order   => "10-${name}",
    target  => $configfile,
    content => "group ${name}\n{\n\n",
  }

  #Replaced cron-job with inotify script
  class { 'csync2::inotify':
    syncfolders => $includes,
    sleeptimer  => $checkfreq,
  }

  #Bring in the cluster members
  Csync2::Groupnode <<| group == $name |>>

  #The main csync2 config body as defined by template and concat.
  concat::fragment { "${name}_csync2_body":
    order   => "255-${name}",
    target  => $configfile,
    content => template('csync2/csync2_body.erb'),
  }

  #Once we have created the concatinated csync2 configuration file, do an initial sync
  exec { 'csync2_checksync':
    command     => "${csync2_exec} -TUI",
    path        => ['/sbin','/bin','/usr/bin','/usr/sbin'],
    timeout     => 300,
    refreshonly => true,
    returns     => ['0','2'],
    require     => Concat[$configfile],
    notify      => Exec['csync2_sync_nodes'],
  }
  exec { 'csync2_sync_nodes':
    command     => "${csync2_exec} -u",
    path        => ['/sbin','/bin','/usr/bin','/usr/sbin'],
    timeout     => 3600,
    refreshonly => true,
  }

}
