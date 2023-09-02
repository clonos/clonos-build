# erlang apt repo
class erlang::repo::apt (
  String  $ensure = $erlang::repo_ensure,
  Erlang::RepoSource $source = $erlang::repo_source,
) inherits erlang {
  case $source {
    'erlang_solutions': {
      contain erlang::repo::apt::erlang_solutions
    }
    default: {
      fail("Only 'erlang_solutions' repo_sources is supported for Apt repos, the following is not supported: ${source}")
    }
  }
}
