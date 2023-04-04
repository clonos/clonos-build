class profiles::db::mysql (
  Hash $globals = {},
  Hash $options = {},
  Hash $db = {},
  Hash $grant = {},
  Hash $user = {},
){

    $config_file = '/usr/local/etc/mysql/my.cnf'
    #$includedir  = '/usr/local/etc/mysql'

    $_options = {
      'client'     => {
        'port'     => '3306',
        'socket'   => '/tmp/mysql.sock',
#        'password' => 'super',
      },
      'mysql'       => {
        'prompt' => '\u@\h [\d]>\_',
        'no_auto_rehash' => '',
      },
      'mysqld'      => {
        'socket'                  => '/tmp/mysql.sock',
        'bind-address'            => '127.0.0.1',
        'skip-networking'         => '',   # disable TCP
        'lower_case_table_names'  => '1',  # mysql 8 def?
      },
      'mysqld_safe' => {
        'nice' => '0',
        'socket' => '/tmp/mysql.sock',
      },
    }

  class { '::mysql::server':
    *                => $globals,
    config_file      => $config_file,
    includedir       => $includedir,
    override_options => deep_merge($_options, $options),
  }

  create_resources('::mysql::db', $db)
  create_resources('mysql_user', $user)
  create_resources('mysql_grant', $grant)

# Linux:  echo -n 'xxx' | sha1sum | xxd -r -p |sha1sum | tr '[a-z]' '[A-Z]' | awk '{printf "*%s", $1}'
# (wip) FreeBSD:  echo -n "xxx" | sha1 | od -A n -t x1 | xargs | tr -d ' ' | sha1 | tr '[a-z]' '[A-Z]'
# perl -MDigest::SHA1=sha1_hex -MDigest::SHA1=sha1 -le 'print "*". uc sha1_hex(sha1("right"))'
# php -r 'echo "*" . strtoupper(sha1(sha1("right", TRUE))). "\n";'
}
