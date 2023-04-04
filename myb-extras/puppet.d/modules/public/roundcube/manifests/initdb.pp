# Class: roundcube::initdb
#
# Init the Roundcube DB schema
#
class roundcube::initdb inherits roundcube {

  file { "/usr/local/bin/roundcube-db-initial.sh":
    mode    => '0555',
    ensure  => present,
    content => template("${module_name}/roundcube-${roundcube::db_type}-initial.sh.erb"),
  }
  -> exec { "/usr/local/bin/roundcube-db-initial.sh > /dev/null 2>&1":
      onlyif      => "test ! -f /var/db/roundcube-mysql-initial.log",
      path        => $roundcube::exec_paths,
  }
}
