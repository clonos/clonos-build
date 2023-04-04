# manage gitlab
# based on https://gitlab.fechner.net/mfechner/Gitlab-docu/blob/master/install/13.7-freebsd.md
class profiles::services::gitlab (
  Optional[String[1]] $db_root_password     = undef,
  Optional[String[1]] $db_password          = undef,
  Optional[String[1]] $db_name              = 'gitlabhq_production',
  Optional[String[1]] $db_username          = 'git',
  Optional[String[1]] $gitlab_root_password = undef,
){

  accounts::user { 'git':
    uid      => '211',
    gid      => '211',
    group    => 'git',
    comment  => 'git user',
    home  => '/usr/local/git',
    shell    => '/bin/sh',
    password => '!!',
    locked   => false,
  }

  # manage packages in params
  package { 'gitlab-ce':
    ensure => installed,
  }

  class { 'postgresql::globals':
    encoding            => 'UTF-8',
    locale              => 'en_US.UTF-8',
    manage_package_repo => false,
    version             => '12',
  }

  class { '::postgresql::server':
    postgres_password => $db_root_password,
    service_provider  => 'freebsd',
  }

  postgresql::server::role { $db_username:
    password_hash => postgresql::postgresql_password($db_username, $db_password),
    superuser     => true,
  }

  postgresql::server::db { $db_name:
    user     => $db_name,
    owner    => $db_username,
    # (auth_method - md5):
    #password => $db_password,
    # (auth_method - password):
    password => postgresql_password($db_username, $db_password),
    grant    => 'all',
  } ->
  postgresql::server::pg_hba_rule { 'allow git user to postgres database':
    order       => '002',
    description => "Open up PostgreSQL for access from $db_username -> postgres",
    type        => 'host',
    database    => 'postgres',
    user        => $db_username,
    address     => '0.0.0.0/0',
    #auth_method => 'md5',
    auth_method => 'password',
  }
  postgresql::server::pg_hba_rule { 'allow application network to access app database':
    order       => '003',
    description => "Open up PostgreSQL for access from $db_username -> $db_name",
    type        => 'host',
    database    => $db_name,
    user        => $db_username,
    # insecure? facts for private? in params?
    address     => '0.0.0.0/0',
    #auth_method => 'md5',
    auth_method => 'password',
  }

  class { '::postgresql::server::contrib': }

  postgresql::server::extension { 'pg_trgm':
    database => $db_name,
    require  => Postgresql::Server::Db[$db_name],
  }
  postgresql::server::extension { 'btree_gist':
    database => $db_name,
    require  => Postgresql::Server::Db[$db_name],
  }

  class { '::redis':
    # insecure? facts for private? in params?
    #bind           => '10.0.1.2',
    bind           => '0.0.0.0',
    # into params
    masterauth     => 'secret',
    unixsocketperm => '0777',		# /var/run/redis/redis.sock root:wheel - freebsd bug?
    unixsocket     => '/var/run/redis/redis.sock',
  }
  accounts::user { 'redis':
    groups  => [ 'redis', 'git' ],
  }

  file { '/root/gitlab':
    ensure  => directory,
    mode    => '0700',
    source  => "puppet:///modules/${module_name}/gitlab",
    owner   => 0,
    group   => 0,
    recurse => true,
  }

  exec { "config_git.sh":
    command => "/root/gitlab/config_git.sh",
    # default 300 sec too small for install
    #timeout => 1500,
    #onlyif  => "/usr/bin/env test ! -r /usr/local/etc/rc.d/powerdnsadmin",
  }

  file { '/usr/local/git/repositories':
    ensure => directory,
    mode   => '2770',
    owner  => 'git',
    group  => 'git',
  }

  file_line { '/usr/local/www/gitlab-ce/config/database.yml-password':
    path     => '/usr/local/www/gitlab-ce/config/database.yml',
    line     => "  password: \"${db_password}\"",
    match    => '^  password: "secure password"',
    multiple => true,
  }


# run /root/gitlab/init_gitlab_db.sh  ( interactive )
# ^^ DISABLE_DATABASE_ENVIRONMENT_CHECK=1 to disable database existance ( script failed if db already exist )
# Type 'yes' to create the database tables.

#+ /root/gitlab/compile_assets.sh
#+ /root/gitlab/final.sh

# # Make sure we undo the temporary permission fix again
# chown root /usr/local/share/gitlab-shell

#Note: You can set the Administrator/root password by supplying it in environmental variable GITLAB_ROOT_PASSWORD as seen below. If you don't set the password (and it is set to the default one) please wait with exposing GitLab to the public internet until the installation is done and you've logged into the server the first time. During the first login you'll be forced to change the default password.
#su -l git -c "cd /usr/local/www/gitlab-ce && rake gitlab:setup RAILS_ENV=production =yourpassword"

# Check if GitLab and its environment are configured correctly:
#su -l git -c "cd /usr/local/www/gitlab-ce && rake gitlab:env:info RAILS_ENV=production"

# + pkg insatll -y nginx
#add into  /usr/local/etc/nginx/nginx.conf
#include       /usr/local/www/gitlab-ce/lib/support/nginx/gitlab;
#or
#include       /usr/local/www/gitlab-ce/lib/support/nginx/gitlab-ssl; 

# fix ipv6 :: if necessary in '/usr/local/www/gitlab-ce/lib/support/nginx/gitlab'
# service enable nginx
# service restart nginx

# exit 0


# compile_assets.sh:
#su -l git -c "cd /usr/local/www/gitlab-ce && yarn install --production --pure-lockfile"
#su -l git -c "cd /usr/local/www/gitlab-ce && RAILS_ENV=production NODE_ENV=production USE_DB=false SKIP_STORAGE_VALIDATION=true NODE_OPTIONS='--max_old_space_size=3584' bundle exec rake gitlab:assets:compile"

# final.sh:
#Remove Superuser rights from database user
#psql -d template1 -U postgres -c "ALTER USER git WITH NOSUPERUSER;"
# start service: service gitlab start

}
