# Erlang packagecloud yum repo
class erlang::repo::yum::erlang_solutions (
  String $ensure  = $erlang::repo::yum::ensure,
  String $baseurl = "https://packages.erlang-solutions.com/rpm/centos/\$releasever/\$basearch",
  String $gpgkey = 'https://packages.erlang-solutions.com/rpm/erlang_solutions.asc',
) inherits erlang {
  yumrepo { 'erlang-erlang_solutions':
    ensure   => $ensure,
    name     => 'erlang-erlang_solutions',
    baseurl  => $baseurl,
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => $gpgkey,
  }
}
