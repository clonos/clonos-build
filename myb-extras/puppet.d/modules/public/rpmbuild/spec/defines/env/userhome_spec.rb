require 'spec_helper'

describe 'rpmbuild::env::userhome', :type => :define do 
  
  let :title do 
    'testuser'
  end
  
  let :params do
    {
      :userfirstname => 'test',
      :userlastname => 'user',
      :emailaddress => 'testuser@example.com',
      :companyname => 'Example Company LLC',
    }
  end
  
  rpmdirs = [
    "/home/testuser/rpmbuild",
    "/home/testuser/rpmbuild/BUILD",
    "/home/testuser/rpmbuild/RPMS",
    "/home/testuser/rpmbuild/SOURCES",
    "/home/testuser/rpmbuild/SPECS",
    "/home/testuser/rpmbuild/SRPMS", ]
    
    rpmdirs.each do |dir|
      it { should 
      contain_file(dir).with(
        'ensure' => 'directory',
        'owner' => 'testuser',
        'group' => 'testuser',
        'mode' => '0644',
      )}
    end
    
    it { should 
      contain_file('/home/testuser/.rpmmacros').with(
       'ensure' => 'present',
       'owner' => 'testuser',
       'group' => 'testuser',
       'mode' => '0644',
    )}
    
end 