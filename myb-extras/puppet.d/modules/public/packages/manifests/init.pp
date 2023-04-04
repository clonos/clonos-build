class packages {

    $packages = hiera('packages::packages')
    $ensure = hiera('packages::ensure')

    package { $packages:
        ensure => $ensure,
    }

}
