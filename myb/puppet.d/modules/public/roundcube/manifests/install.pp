# Class: roundcube::install
#
# Install the Roundcube software package.
#
# === Copyright
#
# Copyright 2015 Martin Meinhold, unless otherwise noted.
#
class roundcube::install inherits roundcube {

  if ($roundcube::composer_manage == true) {
    include composer
  }

  $archive = "roundcubemail-${roundcube::version}-complete"
  $target = "${roundcube::install_dir}/roundcubemail-${roundcube::version}"
  $download_url = "https://github.com/roundcube/roundcubemail/releases/download/${roundcube::version}/${archive}.tar.gz"
  $composer_install_cmd = "${roundcube::composer_command_name} install --no-dev"

  case $roundcube::archive_provider {
    'nanliu', 'puppet': {
      archive { "${roundcube::package_dir}/${archive}.tar.gz":
        ensure        => present,
        checksum      => $roundcube::checksum,
        checksum_type => $roundcube::checksum_type,
        source        => $download_url,
        proxy_server  => $roundcube::archive_proxy_server,
        extract_path  => $roundcube::install_dir,
        creates       => "${roundcube::package_dir}/${archive}.tar.gz",
        extract       => true,
        cleanup       => false,
        extract_flags => '-x --no-same-owner -f',
        require       => [
          File[$roundcube::install_dir],
          File[$roundcube::package_dir]
        ],
      }
      $require_archive = Archive["${roundcube::package_dir}/${archive}.tar.gz"]
    }
    'camptocamp': {
      archive { $archive:
        ensure           => present,
        digest_string    => $roundcube::checksum,
        digest_type      => $roundcube::checksum_type,
        url              => $download_url,
        proxy_server     => $roundcube::archive_proxy_server,
        follow_redirects => true,
        target           => $roundcube::install_dir,
        src_target       => $roundcube::package_dir,
        root_dir         => "roundcubemail-${roundcube::version}",
        timeout          => 600,
        require          => [
          # TODO consider using ensure_resources to avoid having to manage them explicitly
          File[$roundcube::install_dir],
          File[$roundcube::package_dir]
        ],
      }
      $require_archive = Archive[$archive]
    }
    default: {
      fail("Unsupported \$archive_provider '${roundcube::archive_provider}'. Should be 'camptocamp' or 'nanliu' (aka 'puppet').")
    }
  }

  file { ["${target}/logs", "${target}/temp"]:
    ensure  => directory,
    owner   => $roundcube::process,
    group   => $roundcube::process,
    mode    => '0640',
    require => $require_archive,
  }

  file { "${target}/installer":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
    backup  => false,
    require => $require_archive,
  }

  file { "${target}/composer.json":
    ensure  => file,
    source  => "${target}/composer.json-dist",
    replace => false,
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    require => $require_archive,
  }

  -> augeas { "${target}/composer.json__prefer-stable":
    lens    => 'Json.lns',
    incl    => "${target}/composer.json",
    changes => [
      "set dict/entry[. = 'prefer-stable'] prefer-stable",
      "set dict/entry[. = 'prefer-stable']/const true",
    ],
  }

  -> exec { $composer_install_cmd:
    unless      => "${composer_install_cmd} --dry-run 2>&1 | grep -q -F 'Nothing to install'",
    cwd         => $target,
    user        => $roundcube::composer_user,
    path        => $roundcube::exec_paths,
    environment => $roundcube::composer_exec_environment,
  }
}
