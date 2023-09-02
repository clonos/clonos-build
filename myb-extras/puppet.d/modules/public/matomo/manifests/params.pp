# This class will include all variables used in the module
#
# @summary This class will include all variables used in the module
#
# [*package_version*]
#	The version of matomo to install
#	Default = latest
#
# [*docroot*]
#	The location where matomo will be installed
#	Default = /var/www/html
# [*package_manage*]
#	Whether Matomo should be installed
#	Default = true (matomo will always be installed, that why this module exists - doh!)
# [*root_password*]
#	mysql/mariadb root password
#	Default = Crackme_iF_you_can_pleasE
# [*remove_default_accounts*]
#	Removing test accounts etc
#	Default = true
# [*matomo_db_user*]
#	mysql database user for matomo
#	Default = matomo
# [*matomo_db_password*]
#	mysql database password for matomo user	
#	Default = Crackme_iF_you_can_pleasE
# [*matomo_db_name*]
#	mysql database name for matomo	
#	Default = matomo
# [*host*]	
#	mysql database host - listener address for mysql
#	Default = localhost
# [*grant*]
#	Permissions to grant the matomo database user
#	Default = ['ALL']
# [*sql_backup_file*]
#	If you are planning to restore your database form sql file
#	Default = undef
# [*enforce_sql*]
#	Default = true
# [*site_name*]
#	Default site hostname can be webanalytics.domain.com
#	Default = 'matomo.local'
# [*listen_port*]
#	Port nginx should listen on
#	Default = 80
# [*www_root*]
#	The www folder that nginx will use to present the platform
#	Default = "${docroot}/matomo"
# [*use_default_location*]
#	
#	Default = false
# [*access_log*]
#	Default access log location
#	Default = "/var/log/nginx/${site_name}-access.log"
# [*error_log*]
#	Default error log location
#	Default = "/var/log/nginx/${site_name}-error.log"
# [*mode*]
#	Default perms for files in www
#	Default = '0755'
# [*ssl*]
#	Wnat to run your site over ssl? You should!
#	Default = false
# [*ssl_key*]
#	If SSL is 'true' above location of ssl key file
#	Default = undef
# [*ssl_cert*]
#	If SSL is 'true' above location of ssl cert file	
#	Default = undef
# [*ensure*]
#	Default = present
# [*location*]
#	Default = '~* \.php$'
# [*server*]
#	Default = $site_name
# [*fastcgi*]
#	Default = '127.0.0.1:9000'
# [*include*]
#	Default = undef
# [*fastcgi_param*]
#	Default = undef
#   include matomo::params
class matomo::params {

# matomo params

  $package_version                      = 'latest'
  $docroot                              = '/var/www/html'
  $package_manage                       = true

# mysql params

  $root_password                        = 'Crackme_iF_you_can_pleasE'
  $remove_default_accounts              = true
  $matomo_db_user                       = 'matomo'
  $matomo_db_password                   = 'Crackme_iF_you_can_pleasE'
  $matomo_db_name                       = 'matomo'
  $host                                 = 'localhost'
  $grant                                = ['ALL']
  $sql_backup_file                      = undef
  $enforce_sql                          = true

# nginx params

  $site_name                            = 'matomo.local'
  $listen_port                          = 80
  $www_root                             = "${docroot}/matomo"
  $use_default_location                 = false
  $mode                                 = '0755'
  $ssl                                  = false
  $ssl_key                              = undef
  $ssl_cert                             = undef
  $ensure                               = present
  $location                             = '~* \.php$'
  $fastcgi                              = '127.0.0.1:9000'
  $include                              = undef
  $fastcgi_param                        = undef
  $index_secure                         = false
  $location_allow                       = ['127.0.0.1']
  $ssl_redirect                         = false

}
