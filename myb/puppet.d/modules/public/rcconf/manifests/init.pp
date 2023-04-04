class rcconf(
) {
  $config = hiera_hash("${module_name}::config", undef, undef)

  if $config {

    $mfile="/etc/rc.conf"

    file { $mfile:
      ensure  => 'present',
      mode    => '0644',
    }

    $config.each |String $par, String $val| {
        file_line { $par:
          path     => $mfile,
          match    => $par,
          line     => "${par}=\"${val}\"",
        }
    }
  }
}
