require 'spec_helper_acceptance'

describe 'ssmtp' do
  let(:manifest) {
<<-CLASSPARAMETER
class { 'ssmtp':
  default_mta => 'ssmtp',
  root_email  => 'test@example.local',
  mail_hub    => 'mh.example.local',
}
CLASSPARAMETER
  }

  it 'should apply without errors' do
    apply_manifest(manifest, :catch_failures => true)
  end

  it 'should apply a second time without changes' do
    @result = apply_manifest(manifest)
    expect(@result.exit_code).to be_zero
  end

  describe file('/etc/ssmtp/ssmtp.conf') do
    it { should be_file }
    it { should exist }
  end

  describe file('/etc/ssmtp/revaliases') do
    it { should be_file }
    it { should exist }
  end

  describe package('ssmtp') do
    it { should be_installed }
  end
end
