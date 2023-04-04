require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

#run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
run_puppet_install_helper

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'ssmtp')
    hosts.each do |host|
      ['puppetlabs-stdlib'].each do |mod|
        on host, puppet('module', 'install', mod), { :acceptable_exit_codes => [0,1] }
      end
    end
  end
end
