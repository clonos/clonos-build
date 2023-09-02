# Matomo - The Web Analytics Platform

## Module description

The Matomo Module downloads and installs Matomo (formally Piwiki) it goes ahead and installs Nginx and MariaDB to complete the requirements to run a Matomo server.
The module will take care of other OS requirements such as permissions and PHP.

## Setup

### Beginning with Matomo

By using the classes below, you can install matomo, configure MariaDB/MySQL and Nginx with defaults as listed below :

```puppet

class { 'matomo': }

class { 'matomo::web::web':
 site_name       => 'matomo.local'
 }

class { 'matomo::mysql::db': }

```
The classes above will install Matomo with the defaults below

### matomo default params

```puppet
  $package_version                      = 'latest'
  $docroot                              = '/var/www/html'
  $package_manage                       = true
```

### mysql default params
```puppet
  $root_password                        = 'Crackme_iF_you_can_pleasE'
  $remove_default_accounts              = true
  $matomo_db_user                       = 'matomo'
  $matomo_db_password                   = 'Crackme_iF_you_can_pleasE'
  $matomo_db_name                       = 'matomo'
  $host                                 = 'localhost'
  $grant                                = ['ALL']
  $sql_backup_file                      = undef
  $enforce_sql                          = true
```

### nginx default params
```puppet
  $site_name                            = 'matomo.local'
  $listen_port                          = 80
  $www_root                             = "${docroot}/matomo"
  $use_default_location                 = false
  $access_log                           = "/var/log/nginx/${site_name}-access.log"
  $error_log                            = "/var/log/nginx/${site_name}-error.log"
  $mode                                 = '0755'
  $ssl                                  = false
  $ssl_key                              = undef
  $ssl_cert                             = undef
  $ssl_redirect				= false
  $ensure                               = present
  $location                             = '~* \.php$'
  $server                               = $site_name
  $fastcgi                              = '127.0.0.1:9000'
  $include                              = undef
  $fastcgi_param                        = undef
  $index_secure				= false
  $location_allow			= ['127.0.0.1']

```

## Advanced Usage

All parameters for the Matomo module can be defined within the 3 different classes. See the common usages below for examples.

### Install and enable Matomo

The example below specifies the version of Matomo to install (default is 'latest') and the default location of www root for the web server. 

```puppet
class { 'matomo':
 package_manage 	=> true,
 package_version	=> '3.8.1',
 docroot		=> '/var/www/html/',
 }
```

### Install and enable MariaDB

```puppet
class { 'matomo::mysql::db':

  root_password 	=> 'Crackme_iF_you_can_pleasE',
  matomo_db_user        => 'matomo',
  matomo_db_password    => 'Crackme_iF_you_can_pleasE',
  matomo_db_name        => 'matomo',

}
```

### Install and enable Nginx

```puppet
class { 'matomo::web::web':

  site_name                            => 'matomo.local',
  listen_port                          => 80,
  www_root                             => "/var/www/html/matomo",
  mode                                 => '0755',
  ssl                                  => false,
  ssl_key                              => undef,
  ssl_cert                             => undef,

 }
```

### Running Nginx with SSL (which you should)

```puppet
class { 'matomo::web::web':

  site_name                            => 'matomo.local',
  listen_port                          => 80,
  www_root                             => "/var/www/html/matomo",
  mode                                 => '0755',
  ssl                                  => true,
  ssl_key                              => /path/to/the/cert/key,
  ssl_cert                             => /path/to/the/cert,
  ssl_redirect			       => true,
 }

```

## Accessing the Web interface

Once installation is done, Matomo web interface can be accessed using the url to complete setup e.g. matomo.local

## Limitations

This module has been tested on CentOS and Ubuntu but should in theory work on All derivatives of Redhat and Debian.
 
## Development

This module is open source, feel free to contribute changes

Project is hosted [here For more information.](https://github.com/akisakye/matomo)

### Contributors

Always welcome.
