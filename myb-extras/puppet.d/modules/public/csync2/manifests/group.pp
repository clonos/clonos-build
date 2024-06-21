# @summary
#   Manages a Csync2 group.
#
# @example A simple example to sync the csync2 config itself.
#   csync2::group { 'cluster':
#     hosts  => ['node1.example.org', 'node2.example.org'],
#     blocks => [
#       {
#         'includes' => [ '/etc/csync2.cfg' ],
#       },
#     ],
#     key    => 'supersecret',
#   }
#
# @example A more complex example with two blocks and actions.
#   csync2::group { 'monitoring':
#     hosts  => ['node1.example.org', 'node2.example.org'],
#     blocks => [
#       {
#         'includes' => [ '/etc/icinga2/features-available', '/etc/icinga2/features-enabled' ],
#         'actions'  => [
#           {
#             'pattern' => [ '/etc/icinga2/features-enabled/*' ],
#             'exec'    => [ 'systemctl reload icinga2' ],
#             'logfile' => '/var/log/csync2_action.log',
#             'do'      => 'do-local',
#           },
#         ],
#       },
#       {
#         'includes' => [ '/etc/icingaweb2' ],
#         'excludes' => [ '/etc/icingaweb2/modules/director', '/etc/icingaweb2/enabledModules/director' ],
#       },
#     ],
#     key    => 'supersecret-2',
#   }
#
# @param ensure
#   Wether to use or to remove the group.
#
# @param hosts
#   All involved hosts of the group.
#
# @param key
#   The symmetric key to authenticate hosts to each other.
#
# @param group
#   Name of the group.
#
# @param key_path
#   Path to the file the key will save to.
#
# @param blocks
#   Manages blocks of config snippets. A block has to be of datatype Hash and consists of
#   'includes', 'excludes' and 'actions' as keys. The 'actions' are also an Array of Hashes
#   and has to constist of 'pattern', 'exec', 'logfile' and 'do' as keys.
#
# @param auto
#   Set resolution method if files have conflicts and doesn't know which to use.
#
define csync2::group (
  Array[Stdlib::Host]             $hosts,
  String                          $key,
  Enum['present', 'absent']       $ensure   = 'present',
  String                          $group    = $title,
  Optional[Stdlib::Absolutepath]  $key_path = undef,
  Array[Csync2::GroupBlock]       $blocks   = {},
  Enum['none', 'younger']         $auto     = 'younger',
) {
  include csync2

  $config_dir  = $csync2::globals::config_dir
  $config_path = $csync2::globals::config_path

  unless $key_path {
    $_key_path = "${config_dir}/csync2.key_${group}"
  } else {
    $_key_path = $key_path
  }

  if $ensure == 'present' {
    concat::fragment { "csync2-group-${group}":
      target  => $config_path,
      content => template('csync2/group.erb'),
    }

    $key_path_ensure = 'file'
  } else {
    $key_path_ensure = 'absent'
  }

  file { $_key_path:
    ensure  => $key_path_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "${key}\n",
  }
}
