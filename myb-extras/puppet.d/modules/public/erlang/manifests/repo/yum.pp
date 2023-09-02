# erlang yum repo
class erlang::repo::yum (
  String $ensure = $erlang::repo_ensure,
  Erlang::RepoSource $source = $erlang::repo_source,
) inherits erlang {
  case $source {
    'epel': {
      contain erlang::repo::yum::epel
    }
    'erlang_solutions': {
      # erlang_solutions package requires things from EPEL
      contain erlang::repo::yum::epel
      contain erlang::repo::yum::erlang_solutions
    }
    'packagecloud': {
      contain erlang::repo::yum::packagecloud
    }
    default: {
      fail("Only 'packagecloud', 'epel' repo_source are supported for Yum repos, the following is not supported: ${source}")
    }
  }
}
