require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'

desc "Run the tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['--color', '-f d']
  t.pattern = 'spec/*/*_spec.rb'
end


PuppetLint.configuration.ignore_paths = ["pkg/**/*.pp", "spec/**/*.pp"]
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_documentation')

task :run_tests => [:spec_prep, :test, :lint, :spec_clean]