require 'spec_helper'

describe 'phpldapadmin', :type => :module do

  shared_examples 'a unix OS' do
    it { should compile }
    it { should contain_class('phpldapadmin') }
    it { should contain_class('phpldapadmin::params') }
    it { should contain_class('phpldapadmin::package') }
    it { should contain_class('phpldapadmin::config') }
    it { should contain_anchor('phpldapadmin::begin').that_comes_before('Class[phpldapadmin::package]') }
    it { should contain_anchor('phpldapadmin::end').that_requires('Class[phpldapadmin::config]') }
  end

  %w{Debian RedHat FreeBSD}.each do |os|
    context "On a #{os} OS with valid params" do
      let(:params) { {
        :ldap_suffix => 'dc=example,dc=com',
        :ldap_host => 'localhost',
        :ldap_bind_id => 'username',
        :ldap_bind_pass => 'password',
      } }
      let(:facts) { {
        :osfamily => os,
      } }
      it_behaves_like 'a unix OS'
    end

    context "On a #{os} OS with invalid params" do
      let(:params) { {
        :ldap_host => 'localhost',
        :ldap_bind_id => 'username',
        :ldap_bind_pass => 'password',
      } }
      let(:facts) { {
        :osfamily => os,
      } }
      it 'should fail if params not valid' do
        expect { should raise_error(/Invalid param/) }
      end
    end
  end

  context 'On other OS' do
    let(:facts) { {
      :operatingsystem => 'xxx',
      :osfamily => 'xxx',
    } }
    it 'should fail if OS not supported' do
      expect { should compile }.to raise_error(/Unsupported OS family/)
    end
  end
end
