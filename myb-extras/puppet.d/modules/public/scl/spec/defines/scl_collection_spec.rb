require 'spec_helper'

describe 'scl::collection' do

  let(:pre_condition) do
    'include ::scl'
  end

  let(:title) do
    'test'
  end

  let(:params) do
    {
      enable: true,
    }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file('/etc/profile.d/scl-test.sh') }
      it { is_expected.to contain_package('test') }
    end
  end
end
