# @!visibility private
class scl::config {

  if $::scl::manage_gpgkeys {
    $::scl::gpgkeys.each |Stdlib::Absolutepath $file, String $content| {
      file { $file:
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0644',
        content => $content,
      }
    }
  }

  $::scl::repos.each |$repo, $attributes| {
    yumrepo { $repo:
      * => $attributes,
    }
  }
}
