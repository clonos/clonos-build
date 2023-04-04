require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

hosts.each do |host|
  # Just assume the OpenBSD box has Puppet installed already
  if host['platform'] !~ /^openbsd-/i
    run_puppet_install_helper_on(host)
  end
end

install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  c.formatter = :documentation
end
