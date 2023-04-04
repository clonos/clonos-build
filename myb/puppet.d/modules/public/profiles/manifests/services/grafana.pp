class profiles::services::grafana (
  Hash $cfg        = {},
  Hash $globals    = {},
  Hash $team       = {},
  Hash $dashboard  = {},
  Hash $datasource = {},
){

  # docker
#  class { '::grafana':
#    cfg => {
#        app_mode => 'production',
#        server   => {
#          http_port     => 8080,
#        },
#        database => {
#          type          => 'mysql',
#          host          => '127.0.0.1:3306',
#          name          => 'grafana',
#          user          => 'root',
#          password      => '',
#        },
#        users    => {
#          allow_sign_up => false,
#        },
#    },
#    install_method => docker,
#    version => '7.5.3',
#    container_params => {
#      'image' => 'grafana/grafana:7.5.3',
#      'ports' => '3000:3000'
#    },
##    *   => $globals,
#  }

# FreeBSD
  class { '::grafana':
    package_name => 'www/grafana8',
    cfg => {
        app_mode => 'production',
#        server   => {
#          http_port     => 8080,
#        },
#        database => {
#          type          => 'mysql',
#          host          => '127.0.0.1:3306',
#          name          => 'grafana',
#          user          => 'root',
#          password      => '',
#        },
        users    => {
          allow_sign_up => false,
        },
    },
#    install_method => docker,
#    version => '7.5.3',
#    container_params => {
#      'image' => 'grafana/grafana:7.5.3',
#      'ports' => '3000:3000'
#    },
#    *   => $globals,
  }

  if $team {
    create_resources(grafana_team, $team)
  }

  # hiera doesnt call template: https://ask.puppet.com/question/28006/set-file-content-via-hiera/
  # needed to recreate hash to append template
  if $dashboard {
    $dashboard.each | $key, $value | {
       $url = $value['grafana_url']
       $user = $value['grafana_user']
       $password = $value['grafana_password']

       $template = $value['template']
       $content = template("$template")

        grafana_dashboard { "$key":
          grafana_url       => $url,
          grafana_user      => $user,
          grafana_password  => $password,
          content           => $content,
        }
     }
  }

  if $datasource {
    create_resources(grafana_datasource, $datasource)
  }
}
