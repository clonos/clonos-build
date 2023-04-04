Puppet Csync2 
=============

Here is what it can do, followed by an example configuration.
You can use csync2 much like other tools (Unison, rsync, etc.), but what is nice about Csync2 is it is
very fast and maintains a sqlite database of all file changes.
This means it is capable of managing several hundred thousand files to be synced between multiple systems
with very little lag between results (essentially a few seconds most of the time). Unlike rsync you can do
multi-write style replication which is a requirement if you have several web-servers all being written to.

This module utilizes a resource collector on each defined node to build a sync configuration.

Example usage below, all configs go into your node configuration:

    class {'csync2': }

    @@csync2::groupnode { $::fqdn:
      group       => 'default', }

    csync2::group { 'default':
      includes => ["path1", "path2"],
      excludes => ['*.svn'],
      auto     => 'younger',
    }

Additionally, you will need to define a csync2 GROUP key. To do this you will need to have a csync2
installation somewhere. You will then use 'csync2 -k <keyfile>' to write the key. Define this key on your puppet 
master or as a local file and define it in the key_source variable in the csync2::group.

For more general csync2 documentation, please refer to: http://oss.linbit.com/csync2/
