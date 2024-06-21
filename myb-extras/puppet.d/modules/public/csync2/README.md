# csync2


#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with csync2](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with csync2](#beginning-with-csync2)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference](#development)

## Description

Csync2 is a cluster synchronization tool. It can be used to keep files on multiple hosts in a cluster in sync. Csync2 can handle complex setups with much more than just 2 hosts, handle file deletions and can detect conflicts.

The module configures Csync2 and optionally installs the package from an preconfigured repository. For RHEL/CentOS the module is prepared to use package from [Okay](https://okay.network/blog-news/rpm-repositories-for-centos-6-and-7.html).

## Setup

### Setup Requirements

This module supports:

* [puppet] >= 4.10 < 7.0.0

And requires the following modules:

* [puppetlabs/stdlib]
* [puppetlabs/concat]
* [camptpcamp/systemd]

### Beginning with csync2

Add this declaration to your Puppetfile:
```
mod 'csync2',
  :git => 'https://github.com/lbetz/puppet-csync2.git',
  :tag => 'v0.1.0'
```
Then run:
```
bolt puppetfile csync2
```

Or do a `git clone` by hand into your modules directory:
```
git clone https://github.com/lbetz/puppet-csync2.git csync2
```
Change to `csync2` directory and check out your desired version:
```
cd csync2
git checkout v0.1.0
```

## Usage

By default the module only configures Csync2 to install the software a preconfigured repository ia needed.

### Software Installation 

Declaration will manage a package named 'csync2'.

On RHEL/CentOS 7:

```
package { 'epel-release':
  ensure => installed,
}

package { 'okay-release-1-3':
  ensure   => installed.
  provider => 'rpm',
  source   => 'http://repo.okay.com.mx/centos/7/x86_64/release/okay-release-1-3.el7.noarch.rpm'
}

class { 'csync2': }
```
To fix a bug in the package and add a missing link for using sqlite3, you've to add the followingto your code right behind package management:
```
file { '/usr/lib64/libsqlite3.so':
  ensure => link,
  target => '/usr/lib64/libsqlite3.so.0',
}
```

### Certificate

Certificate and private key can be managed by using base64 encoded strings:
```
class { 'csync2':
  ssl_cert => '-----BEGIN CERTIFICATE----- ...',
  ssl_key  => '----BEGIN RSA PRIVATE KEY----- ...',
}
```

Or can be handeld before declaring 'csync2'.

### Configuring syncing groups

To sync the config file itself between two nodes:
```
class { 'csync2':
  groups => {
    'cluster' => {
      hosts  => ['node1.example.org', 'node2.example.org'],
      blocks => [{
        'includes' => [ '/etc/csync2.cfg' ],
      }],
      key    => 'supersecret',
    },
  },
}
```

A more complex example with two blocks:
```
csync2::group { 'monitoring':
  hosts  => ['node1.example.org', 'node2.example.org'],
  blocks => [
    {
      'includes' => [ '/etc/icinga2/features-available', '/etc/icinga2/features-enabled' ],
      'actions'  => [
        {
          'pattern' => [ '/etc/icinga2/features-enabled/*' ],
          'exec'    => [ 'systemctl reload icinga2' ],
          'logfile' => '/var/log/csync2_action.log',
          'do'      => 'do-local',
        },
      ],
    },
    {
      'includes' => [ '/etc/icingaweb2' ],
      'excludes' => [ '/etc/icingaweb2/modules/director', '/etc/icingaweb2/enabledModules/director' ],
    },
  ],
  key    => 'supersecret',
}
```

### Cronjob

To trigger the sync a cronjob is needed:
```
include csync2

cron { 'csync2':
  command => "${::csync2::globals::csync2_bin} -x",
  user    => 'root',
}
```

## xinetd instead of systemd

You're able to use a xinetd instead of systemd service. If you do so, the port parameter hasn't any impact.
```
class { 'csync2':
  ensure => stopped,
  enable => false,
}

file { '/etc/xinetd.d/csync2':
  ensure  => file,
  content => "service csync2
{
        flags           = REUSE
        socket_type     = stream
        wait            = no
        user            = root
        group           = root
        server          = ${::csync2::globals::csync2_bin}
        server_args     = -i -l
        #log_on_failure += USERID
        disable         = no
        # only_from     = 192.168.199.3 192.168.199.4
}",
  owner  => 'root',
  mode   => '0644',
}

package { 'xinetd':
  ensure => installed,
  before => Service['xinetd'],
}

service { 'xinetd':
  ensure    => running,
  enable    => true,
  subscribe => File['/etc/xinetd.d/csync2'],
}
```
Maybe it's a better idea to use the [puppetlabs/xinetd] module to install, configure and manage xinetd.

## Reference

See [REFERENCE.md](https://github.com/lbetz/puppet-csync2/blob/main/REFERENCE.md)


[puppetlabs/stdlib]: https://github.com/puppetlabs/puppetlabs-stdlib
[puppetlabs/concat]: https://github.com/puppetlabs/puppetlabs-concat
[camptpcamp/systemd]: https://github.com/camptocamp/puppet-systemd
[puppetlabs/xinetd]: https://github.com/puppetlabs/puppetlabs-xinetd
