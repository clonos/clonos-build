require 'spec_helper'

describe 'phpldapadmin', :type => :module do

  shared_examples 'a unix OS' do |os|
    case os
    when "FreeBSD"
      path = "/usr/local/www/phpldapadmin"
      group = "www"
    when "Debian"
      path = "/etc/phpldapadmin"
      group = "www-data"
    when "RedHat"
      path = "/etc/phpldapadmin"
      group = "apache"
    else
      group = "apache"
      path = "/usr/local/www/phpldapadmin"
    end

    it { should compile }
    it { should contain_class("phpldapadmin::config") }
    it { should contain_file("#{path}/config.php") }
    it { should contain_file("#{path}/config.php").with_ensure("file") }
    it { should contain_file("#{path}/config.php").with_mode("0640") }
    it { should contain_file("#{path}/config.php").with_owner("root") }
    it { should contain_file("#{path}/config.php")
      .with_content(/\$servers->setValue\('server','host', 'localhost'\);/)
    }
    it { should contain_file("#{path}/config.php")
      .with_content(/\$servers->setValue\('server','base',array\('dc=spantree,dc=com'\)\)/)
    }
    it { should contain_file("#{path}/config.php")
      .with_content(/\$servers->setValue\('login','bind_id','cn=admin,dc=spantree,dc=com'\);/)
    }
    it { should contain_file("#{path}/config.php")
      .with_content(/\$servers->setValue\('login','bind_pass','the_password'\);/) }
    it { should contain_file("#{path}/config.php").with_group(group) }
  end

  describe 'config' do
    %w{Debian RedHat FreeBSD}.each do |os|
      context "On #{os} with valid params" do
        let(:params) { {
            :ldap_suffix => 'dc=spantree,dc=com',
            :ldap_host => 'localhost',
            :ldap_bind_id => 'cn=admin,dc=spantree,dc=com',
            :ldap_bind_pass => 'the_password',
        } }
        let(:facts) { {
            :osfamily => os,
        } }
        it_behaves_like 'a unix OS', os
      end

      context "On #{os} with invalid params" do
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
          :osfamily => 'xxx',
      } }
      it 'should fail if OS not supported' do
        expect { should compile }.to raise_error(/Unsupported OS family/)
      end
    end
  end
end
