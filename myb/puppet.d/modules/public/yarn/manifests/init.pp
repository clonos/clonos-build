# Install and configure Yarn
#
# @summary Install and configure Yarn
#
# @param package_ensure
#   with `present` Yarn is installed
#   with `absent` Yarn is uninstalled
# @param package_name The name of package expected to be installed with package manager provided by your OS or by npm.
# @param manage_repo
#   with `true` a new source using yarnpkg.com is added in the package manager of your OS.
#   with `false` do nothing
#   Default value: handled by hiera data of the module.
# @param install_method
#   with `source` the `source_url` is used to get and install Yarn
#   with `package` the package manager provider by OS is used to install Yarn
#   with `npm` the npm packahe manager is used to install Yarn
#   Default value: handled by hiera data of the module.
# @param source_install_dir
#   path where Yarn sources are installed with `install_method` to `source`
# @param symbolic_link the `yarn` command in the path pointing to the installed `yarn` with `install_method` to `source`
# @param user the user account on node owner of installed files with `install_method` to `source` or `npm`
# @param source_url URL where the sources are downloaded from
#
class yarn (
  Boolean $manage_repo,
  Enum['npm', 'source', 'package'] $install_method,
  Enum['present','absent'] $package_ensure = 'present',
  String[1] $package_name = 'yarn',
  Stdlib::Absolutepath $source_install_dir = '/opt',
  Stdlib::Absolutepath $symbolic_link = '/usr/local/bin/yarn',
  String[1] $user = 'root',
  Stdlib::HTTPUrl $source_url = 'https://yarnpkg.com/latest.tar.gz',
)  {

  contain yarn::repo
  contain yarn::install

  Class['yarn::repo']
  ~> Class['yarn::install']

}
