require 'coveralls'
Coveralls.wear! do
  add_filter '/pkg/'
  add_filter '/spec/'
  add_filter '/tests/'
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

add_custom_fact :lsbdistid, 'CentOS', :confine => 'redhat-7-x86_64'
add_custom_fact :lsbmajdistrelease, '7', :confine => 'redhat-7-x86_64'

require 'simplecov'
require 'simplecov-console'

SimpleCov.start do
  add_filter '/spec'
  add_filter '/vendor'
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
end

RSpec.configure do |c|
  c.hiera_config = File.expand_path(File.join(__FILE__, '../fixtures/hiera.yaml'))
end
