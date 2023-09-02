# Erlang packagecloud yum repo
class erlang::repo::yum::epel inherits erlang {
  # include epel instead of contain because lots of other stuff declares epel
  include epel
  # specifically declare dependency on epel repo
  Class['epel'] -> Package[$erlang::package_name]
}
