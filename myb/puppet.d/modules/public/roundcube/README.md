# roundcube

[![License](https://img.shields.io/github/license/tohuwabohu/puppet-roundcube.svg)](https://github.com/tohuwabohu/puppet-roundcube/blob/master/LICENSE.txt)
[![build-and-test](https://github.com/tohuwabohu/puppet-roundcube/actions/workflows/main.yml/badge.svg)](https://github.com/tohuwabohu/puppet-roundcube/actions/workflows/main.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/tohuwabohu/roundcube.svg)](https://forge.puppetlabs.com/tohuwabohu/roundcube)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/tohuwabohu/roundcube.svg)](https://forge.puppetlabs.com/tohuwabohu/roundcube)

## Overview

Puppet module to install and manage Roundcube. Roundcube webmail...

> is a browser-based multilingual IMAP client with an application-like user interface.

(source: [Roundcube website](https://roundcube.net/)).

## Usage

The module uses [composer](https://getcomposer.org/) to install 3rd party dependencies specified by Roundcube and to
download additional plugins from the [Roundcube Plugin Repository](http://plugins.roundcube.net/).

Note: At the moment, the module relies on `git` being installed without explicitly requiring it. Git is to checkout
several pacakge repositories listed in Roundcube's `composer.json`.

To install Roundcube with all defaults simply use

```
class { 'roundcube': }
```

Specify a certain mail server

```
class { 'roundcube':
  imap_host => 'ssl://localhost',
  imap_port => 993,
}
```

Specify the database to be used by Roundcube

```
class { 'roundcube':
  db_type     => 'pgsql',
  db_name     => 'roundcube',
  db_host     => 'localhost',
  db_username => 'roundcube',
  db_password => 'secret',
}
```

or specify the database DSN directly (e.g. when using SQLite)

```
class { 'roundcube':
  db_dsn => 'sqlite:////var/lib/database/roundcube.db?mode=0646',
}
```

Specify a couple of plugins to activate

```
class { 'roundcube':
  plugins => [
    'emoticons',
    'markasjunk',
    'password',
  ],
}
```
(see below for more information)

## Archive Module
This module supports both well-known `archive` modules. This allows you to use your favorite archive module (either https://github.com/voxpupuli/puppet-archive or https://github.com/camptocamp/puppet-archive). Please make sure that the required archive module is installed and that you have set the parameter `archive_provider` to either `camptocamp` (default) or `puppet`.


## Advanced usage

Specify advanced parameters

```
class { 'roundcube':
  options_hash {
    'language'    => 'en_US', # override auto-detection
    'support_url' => 'http://example.com/helpdesk',
  },
}
```

or even use your own configuration file template

```
class { 'roundcube':
  config_file_template => 'path/to/config_file.erb.',
  options_hash         => {
    'some_param_1' => '...',
  },
}
```

You can then use `<%= @options['some_param_1'] %>` in your template. See `config/defaults.inc.php` in the Roundcube
directory for a complete list of possible configuration arguments.

## Roundcube plugins

Roundcube ships a couple of very useful plugins. If you're happy with the default settings, you can enable plugins by
simply adding the plugin names to the `plugins` list:

```
class { 'roundcube':
  plugins => [
    'password',
  ],
}
```

If you want to override the default configuration, you should declare a `roundcube::plugin` resource instead and provide
the custom configuration values

```
$db_password_encoded = uriescape($db_password)
$password_db_dsn = "pgsql://${db_username}:${db_password_encoded}@localhost/${db_name}"

roundcube::plugin { 'password':
  options_hash => {
    'password_minimum_length'   => 16,
    'password_require_nonalpha' => true,
    'password_force_new_user'   => true,
    'password_db_dsn'           => $password_db_dsn,
  },
}
```

To install a plugin from the [Roundcube plugin repository](https://plugins.roundcube.net/), you only need to specify
the package name and the desired version, e.g.

```
roundcube::plugin { 'johndoh/markasjunk2':
  ensure => 'dev-release-1.9',
  options_hash => {
    # override the default options
  },
}
```

## Limitations

The module has been tested on the following operating systems. Testing and patches for other platforms are welcome.

* Debian 9.0 (Stretch)
* Debian 10.0 (Buster)
* Ubuntu 18.04 (Bionic Beaver)
* Ubuntu 20.04 (Focal Fossa)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Development

This project uses rspec-puppet and beaker to ensure the module works as expected and to prevent regressions.

```
gem install bundler
bundle install

bundle exec rake spec
bundle exec rake beaker
```
(note: see [Beaker - Supported ENV variables](https://github.com/puppetlabs/beaker-rspec/blob/master/README.md) for a
list of environment variables to control the default behaviour of Beaker)
