require 'spec_helper'

describe 'ssmtp', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts)  { facts }
      let(:params) { { :default_mta => 'ssmtp', :root_email => 'test@example.local', :mail_hub => 'mh.example.local' } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('ssmtp::package') }
      it { is_expected.to contain_class('ssmtp::params') }
      it { is_expected.to contain_class('ssmtp::config') }
      it { is_expected.to contain_class('ssmtp::service') }

      it { is_expected.to contain_package('ssmtp') }

      # operating system specific tests
      case facts[:osfamily]
      when 'RedHat'
        it { is_expected.to contain_file('/etc/ssmtp/ssmtp.conf').with('ensure' => 'file', 'owner' => 'root', 'group' => 'mail', 'mode' => '0640') }
        it { is_expected.to contain_file('/etc/ssmtp/revaliases').with('ensure' => 'file', 'owner' => 'root', 'group' => 'root', 'mode' => '0644') }
        it { is_expected.to contain_exec('alternatives --set mta /usr/sbin/sendmail.ssmtp') }
        it 'should generate valid content for ssmtp.conf' do
          content = catalogue.resource('file', '/etc/ssmtp/ssmtp.conf').send(:parameters)[:content]
          expect(content).to match('ssmtp')
          expect(content).to match('test@example.local')
          expect(content).to match('mh.example.local')
          expect(content).to match('YES')
        end
      when 'Debian'
        it { is_expected.to contain_file('/etc/ssmtp/ssmtp.conf').with('ensure' => 'file', 'owner' => 'root', 'group' => 'mail', 'mode' => '0640') }
        it { is_expected.to contain_file('/etc/ssmtp/revaliases').with('ensure' => 'file', 'owner' => 'root', 'group' => 'root', 'mode' => '0644') }
        it 'should generate valid content for ssmtp.conf' do
          content = catalogue.resource('file', '/etc/ssmtp/ssmtp.conf').send(:parameters)[:content]
          expect(content).to match('ssmtp')
          expect(content).to match('test@example.local')
          expect(content).to match('mh.example.local')
          expect(content).to match('YES')
        end
      when 'FreeBSD'
        it { is_expected.to contain_file('/usr/local/etc/ssmtp/ssmtp.conf').with('ensure' => 'file', 'owner' => 'root', 'group' => 'ssmtp', 'mode' => '0640') }
        it { is_expected.to contain_file('/usr/local/etc/ssmtp/revaliases').with('ensure' => 'file', 'owner' => 'root', 'group' => 'ssmtp', 'mode' => '0644') }
        it { is_expected.to contain_file('/etc/mail/mailer.conf').with('ensure' => 'file', 'owner' => 'root', 'group' => 'root', 'mode' => '0644') }
        it 'should generate valid content for ssmtp.conf' do
          content = catalogue.resource('file', '/usr/local/etc/ssmtp/ssmtp.conf').send(:parameters)[:content]
          expect(content).to match('ssmtp')
          expect(content).to match('test@example.local')
          expect(content).to match('mh.example.local')
          expect(content).to match('YES')
        end
      end
    end
  end
end
