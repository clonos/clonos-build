# Class that manages the erlang repo
class erlang::repo {
  case $facts['os']['family'] {
    'Debian': {
      contain erlang::repo::apt
    }
    'RedHat': {
      contain erlang::repo::yum
    }
    default: {
      fail("The only supported OS families are 'Debian' and 'RedHat', currently trying to install on OS family: ${$facts['os']['family']}")
    }
  }
}
