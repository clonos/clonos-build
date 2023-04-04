# define rpmbuild::env::userhome
#
# this define will create the rpmbuild dirs in the
# users home directory that is specified, It will also
# create a default rpmmacros file with the user's name, email
# and company name, or it allows a custom rpmmacros file
#
# Parameters:
# username(title) - the name of the user to set up the build environment
# usedefaultmacros - option to use a default template for the .rpmmacros file
# userfirstname - the first name of the user to set up the environment for
# userlastname - the last name of the user to set up the environment for
# companyname - the name of the company (this is optional)
# emailaddress - the email address of the user
# macrofilepath - the path to a custom .rpmmacros file
#
define rpmbuild::env::userhome (
    $username = $title,
    $usedefaultmacros = 'yes',
    $userfirstname = '',
    $userlastname = '',
    $companyname = '',
    $emailaddress = '',
    $macrofilepath = '',
){

  # validate the username which is needed for
  # both cases
  validate_string($username)

  # error check for username
  if size($username) == 0 {
    fail('ERROR: username field cant be empty')
  }

  # make sure usedefaultmacros variable is yes or no
  if ! ($usedefaultmacros in [ 'yes', 'no' ]) {
    fail('ERROR: usedefualtmacros parameter must be yes or no')
  }

  # array to create the rpmbuild dirs
  $rpm_dirs = [
    "/home/${username}/rpmbuild",
    "/home/${username}/rpmbuild/BUILD",
    "/home/${username}/rpmbuild/RPMS",
    "/home/${username}/rpmbuild/SOURCES",
    "/home/${username}/rpmbuild/SPECS",
    "/home/${username}/rpmbuild/SRPMS",
  ]

  # create the directories
  file { $rpm_dirs:
    ensure  => 'directory',
    recurse => true,
    owner   => $username,
    group   => $username,
    mode    => '0644',
  }

  if $usedefaultmacros == 'yes' {
    notify{'using the default rpmmacros template': }

    # validate needed parameters
    validate_string($userfirstname)
    validate_string($userlastname)
    validate_string($emailaddress)

  # error check for needed parameters
    if size($userfirstname) == 0 {
      fail('ERROR: userfirstname field cant be empty')
    }
    if size($userlastname) == 0 {
      fail('ERROR: userlastname field cant be empty')
    }
    if size($emailaddress) == 0 {
      fail('ERROR: email address field cant be empty')
    }

  # install the default rpmmacros via the template
    file { "/home/${username}/.rpmmacros":
      ensure  => 'present',
      owner   => $username,
      group   => $username,
      mode    => '0644',
      content => template('rpmbuild/default_macros.erb'),
    }
  }

  else {
    notify{'using the custom rpmmacros file': }

    if size($macrofilepath) == 0 {
      fail('ERROR: when using custom macro file macrofilepath cannot be empty')
    }

    file { "/home/${username}/.rpmmacros":
      ensure => 'present',
      owner  => $username,
      group  => $username,
      mode   => '0644',
      source => $macrofilepath,
    }
  }
}