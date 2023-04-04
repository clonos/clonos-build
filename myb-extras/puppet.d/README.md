# modules-puppet
Puppet module for CBSD jails

To install:

  - cbsd module mode=install puppet
  - echo 'puppet.d' >> ~cbsd/etc/modules.conf
  - cbsd initenv
