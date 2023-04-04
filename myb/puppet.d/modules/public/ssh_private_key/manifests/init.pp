
define ssh_private_key( $ensure=present,
    $user="",
    $group="",
    $key="",
    $keypath="",
    ) {

    if $user == "" {
        fail("$module_name: user is empty")
    }

    if $key == "" {
        fail("$module_name: key is empty")
    }

    if $group == "" {
        $ssh_private_key_group="$user"
    } else {
        $ssh_private_key_group="$group"
    }

    if $keypath == "" {
        $sshkeys_keypath="/home/$user/.ssh/$key"

#        file { "ssh_private_key_homedir_for_$key":
#            name => "/home/$user",
#            ensure => directory,
#            owner   => "$user",
#            group   => "$group",
#        }

#        file { "ssh_private_key_sshdir_for_$key":
#            name => "/home/$user/.ssh",
#            ensure => directory,
#            owner   => "$user",
#            group   => "$group",
#            mode    => '0700',
#            require=> File["/home/$user"]
#        }

    } else {
        $sshkeys_keypath="$keypath"
    }

    file { "$sshkeys_keypath":
            ensure  => $ensure,
            owner   => "$user",
            group   => "$ssh_private_key_group",
            mode    => '0400',
            source => "puppet://${server}/modules/${module_name}/$key",
    }
}
