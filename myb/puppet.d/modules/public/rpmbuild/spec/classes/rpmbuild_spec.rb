require 'spec_helper'

describe 'rpmbuild', :type => :class do 
  
  #describe 'with no parameters' do
   # it { should include_class("rpmbuild::params") }
    #it { should include_class("rpmbuild") }
  #end
  
  context "with default packages" do 
    
    rpmbuild_packages = [
      'make',
      'automake', 
      'autoconf', 
      'gcc', 
      'gcc-c++', 
      'rpm-build', 
      'redhat-rpm-config', 
      'rpmdevtools', 
      'yum', 
      'yum-utils', 
      'createrepo', 
      'gnupg2', ]
      
      rpmbuild_packages.each do |rpmpkg|
        it { should contain_package(rpmpkg).with_ensure('latest') }
      end
  end
  
  context "On fedora" do
    
    let(:facts) {{ :operatingsystem => 'fedora' }}
      
    fedora_packages = [
      'fedora-packager',
      'rpm-sign', ]
      
    fedora_packages.each do |fedpkg|
      it { should contain_package(fedpkg).with_ensure('latest') }
    end 
  end
  
end
  