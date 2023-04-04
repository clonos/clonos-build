# docker wrapper
class profiles::docker (
  Hash $params = {},
  Boolean $install_kernel = false,
){

  class { 'docker':
    * => $params,
  }

  if ($install_kernel) {
    include profiles::docker::kernel
  }
}
