# @summary Manages the Erlang repository and package installation.
#
# This class supports installing an Erlang repo on Debian/Ubuntu and CentOS/RHEL systems.
# For Debian/Ubuntu an Apt package repository is configured.
# For CentOS/RHEL a Yum package repository is configured.
#
# There are several different package repositories sources available for installing Erlang,
# each with their own pros/cons. Instead of being opinionated, we allow the user the option
# to choose which repository source they would like to enable via the `repo_source` parameter.
# This list was obtained from the official RabbitMQ documentation:
#  - https://www.rabbitmq.com/install-debian.html#erlang-repositories
#  - https://www.rabbitmq.com/install-rpm.html#install-erlang
#
# See the documentation for the `repo_source` parameter for more information.
#
# @param [String] package_name
#   Name of the erlang package to install
#
# @param [String] package_ensure
#   Determines the ensure state of the package.  Set to installed by default, but could be changed to latest.
#
# @param [Optional[Variant[Numeric, String]]] package_apt_pin
#   Whether to pin the package to a particular source.
#
# @param [Boolean] manage_repo
#   Whether or not this class should manage the erlang repository.
#
# @param [String] repo_ensure
#   Determines the ensure state of the repo.
#
# @param [Erlang::RepoSource] repo_source
#   Determines what repository source should be configured for installing Erlang.
#   For Debian/Ubuntu the choices for `repo_source` are:
#    - `'erlang_solutions'`
#
#   For CentOS/RHEL the choices for `repo_source` are:
#    - `'epel'`
#    - `'erlang_solutions'`
#    - `'packagecloud'` (default)
#
# @example Basic usage for installing Erlang quick and easy
#   include erlang
#
# @example Configuring a different repo source, Erlang Solutions
#   class { 'erlang':
#     repo_source => 'erlang_solutions',
#   }
#
# @example Configuring a different repo source, EPEL on CentOS/RHEL
#   class { 'erlang':
#     repo_source => 'epel',
#   }
#
# @example Removing the erlang package and its repository
#   class { 'erlang':
#     package_ensure => 'absent',
#     repo_ensure    => 'absent',
#   }
#
class erlang (
  String  $package_name   = 'erlang',
  String  $package_ensure = 'installed',
  Optional[Variant[Numeric, String]] $package_apt_pin = undef,
  Boolean $manage_repo    = true,
  String  $repo_ensure    = 'present',
  Erlang::RepoSource $repo_source = 'packagecloud',
) {
  if $manage_repo {
    contain erlang::repo
    Class['erlang::repo'] -> Package[$package_name]
  }

  package { $package_name:
    ensure => $package_ensure,
  }
}
