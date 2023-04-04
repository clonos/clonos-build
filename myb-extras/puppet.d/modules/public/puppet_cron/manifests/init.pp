# manage puppet apply via cron
class puppet_cron(
  String $ensure = 'present',
) {

  # disable agent in background by default
  service { 'puppet':
    ensure     => 'stopped',
    enable     => false,
  }

  $runs_per_hour = 3

  # lets make start puppet haotic and randomize within hour
  $minutes_str = inline_template("<%-
    n = @runs_per_hour.to_i
    i = 60/n
    splay = scope.function_fqdn_rand([i]).to_i
    minutes = []
    n.times do |k|
      minute = i*k+splay
      if minute >= 60
        minute = minute - 60
      end
      minutes << minute
    end
  -%><%=minutes.join(',')%>")

  $minutes_arr = split($minutes_str, ',')

  case $::osfamily {
    'Debian': {
      ensure_resource('package', 'cron', {'ensure' => 'present'})
      $croncmd = "env PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/puppetlabs/bin timeout 360 nice -n 19 ionice -c 3 /usr/bin/flock -w1 -x /tmp/puppetd.lock /opt/puppetlabs/bin/puppet agent -t --no-daemonize --logdest syslog > /dev/null 2>&1"

      service { 'mcollective':
        ensure     => 'stopped',
        enable     => false,
      }

    }
    'RedHat': {
      $croncmd = "env PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/puppetlabs/bin timeout 360 nice -n 19 ionice -c 3 /usr/bin/flock -w1 -x /tmp/puppetd.lock /opt/puppetlabs/bin/puppet agent -t --no-daemonize --logdest syslog > /dev/null 2>&1"

      service { 'mcollective':
        ensure     => 'stopped',
        enable     => false,
      }
    }
    'FreeBSD': {
      $croncmd = "env PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin timeout 360 nice -n 19 /usr/bin/lockf -s -t0 /tmp/puppetd.lock /usr/local/bin/puppet agent -t --no-daemonize --logdest syslog > /dev/null 2>&1"
    }
  }

  cron { 'puppetd':
    command => $croncmd,
    user    => 'root',
    hour    => "*",
    minute  => $minutes_arr,
    ensure  => $ensure,
  }
}
