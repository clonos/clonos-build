require 'spec_helper_acceptance'

describe 'scl' do

  it 'should work with no errors' do

    pp = <<-EOS
      include ::yum
      include ::scl

      ::scl::collection { 'rh-git29':
        enable => true,
      }
    EOS

    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes:  true)
  end

  describe package('rh-git29') do
    it { is_expected.to be_installed }
  end

  describe file('/etc/profile.d/scl-rh-git29.sh') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { is_expected.to be_mode 644 }
    its(:content) { is_expected.to eq "source scl_source enable rh-git29\n" }
  end

  describe command('scl --list') do
    its(:stdout) { is_expected.to match %r{(?mx) ^ rh-git29 $} }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('which git') do
    its(:stdout) { is_expected.to eq "/opt/rh/rh-git29/root/usr/bin/git\n" }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
