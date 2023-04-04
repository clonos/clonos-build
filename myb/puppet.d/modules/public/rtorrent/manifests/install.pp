class rtorrent::install {

  $packages = [ "sysutils/tmux", "devel/git", "security/ca_root_nss", "archivers/unrar", "archivers/rar", "archivers/zip", "multimedia/mediainfo", "multimedia/ffmpeg", "ftp/curl", "audio/sox", "lang/python3", "net/py-cloudscraper" ]

  package { $::rtorrent::package_name:
    ensure => $::rtorrent::package_ensure,
  }

  package { $packages:
    ensure => "installed",
  }

}
