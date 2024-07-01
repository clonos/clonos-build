require 'spec_helper'

describe 'phpldapadmin', :type => :module do

  shared_examples 'a unix OS' do
    it { should compile }
    it { should contain_class('phpldapadmin::package') }
  end

  describe 'package' do

    %w{Debian RedHat FreeBSD}.each do |os|
      context "On a #{os} OS" do
        let(:facts) { {
          :osfamily => os,
        } }
        it_behaves_like 'a unix OS'
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
end
