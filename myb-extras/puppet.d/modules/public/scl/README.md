# scl

Tested with Travis CI

[![Build Status](https://travis-ci.com/bodgit/puppet-scl.svg?branch=master)](https://travis-ci.com/bodgit/puppet-scl)
[![Coverage Status](https://coveralls.io/repos/bodgit/puppet-scl/badge.svg?branch=master&service=github)](https://coveralls.io/github/bodgit/puppet-scl?branch=master)
[![Puppet Forge](http://img.shields.io/puppetforge/v/bodgit/scl.svg)](https://forge.puppetlabs.com/bodgit/scl)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with scl](#setup)
    * [Beginning with scl](#beginning-with-scl)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module manages the Software Collection Yum repositories and can also
install collections.

CentOS, RHEL, Scientific and Oracle Enterprise Linux is supported using Puppet
4.6.0 or later.

## Setup

### Beginning with scl

In the very simplest case, you can just include the following which mimics the
default repositories:

```puppet
include ::scl
```

## Usage

To install a collection and permanently enable it:

```puppet
include ::scl

::scl::collection { 'rh-git29':
  enable => true,
}
```

## Reference

The reference documentation is generated with
[puppet-strings](https://github.com/puppetlabs/puppet-strings) and the latest
version of the documentation is hosted at
[https://bodgit.github.io/puppet-scl/](https://bodgit.github.io/puppet-scl/).

## Limitations

This module has been built on and tested against Puppet 4.6.0 and higher.

The module has been tested on:

* CentOS Enterprise Linux 6/7

The module could do with more thorough acceptance testing on RedHat,
Scientific and Oracle Enterprise Linux.

## Development

The module has both [rspec-puppet](http://rspec-puppet.com) and
[beaker-rspec](https://github.com/puppetlabs/beaker-rspec) tests. Run them
with:

```
$ bundle exec rake test
$ PUPPET_INSTALL_TYPE=agent PUPPET_INSTALL_VERSION=x.y.z bundle exec rake beaker:<nodeset>
```

Please log issues or pull requests at
[github](https://github.com/bodgit/puppet-scl).
