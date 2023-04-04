require 'spec_helper'

describe 'scl' do

  context 'on unsupported distributions' do
    let(:facts) do
      {
        os: {
          family: 'Unsupported',
        },
      }
    end

    it { is_expected.to compile.and_raise_error(%r{not supported on an Unsupported}) }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('scl') }
      it { is_expected.to contain_class('scl::config') }
      it { is_expected.to contain_class('scl::install') }
      it { is_expected.to contain_class('scl::params') }
      it { is_expected.to contain_package('scl-utils') }

      case facts[:os]['name']
      when 'CentOS'
        it { is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo') }
        it { is_expected.to contain_yumrepo('centos-sclo-rh-debuginfo') }
        it { is_expected.to contain_yumrepo('centos-sclo-rh-source') }
        it { is_expected.to contain_yumrepo('centos-sclo-rh-testing') }
        it { is_expected.to contain_yumrepo('centos-sclo-rh') }
        it { is_expected.to contain_yumrepo('centos-sclo-sclo-debuginfo') }
        it { is_expected.to contain_yumrepo('centos-sclo-sclo-source') }
        it { is_expected.to contain_yumrepo('centos-sclo-sclo-testing') }
        it { is_expected.to contain_yumrepo('centos-sclo-sclo') }
      when 'RedHat'
      else
      end
    end
  end
end
