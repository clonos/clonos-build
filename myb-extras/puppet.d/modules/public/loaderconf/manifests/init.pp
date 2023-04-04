class loaderconf(
) {
  $config = lookup("${module_name}::config", undef, undef, undef)

  if $config {
    $mfile="/boot/loader.conf"

    file { $mfile:
      ensure  => 'present',
      mode    => '0644',
    }

    hiera_hash('loaderconf::config').each |String $par, String $val| {
      file_line { $par:
        path     => $mfile,
        match    => $par,
        line     => "${par}=\"${val}\"",
      }
    }
  }
}

