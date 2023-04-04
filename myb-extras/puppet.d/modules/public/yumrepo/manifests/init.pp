class yumrepo()
{

  createrepo { 'yumrepo':
    enable_update => true,
    repository_dir => '/var/yumrepos/yumrepo',
    repo_cache_dir => '/var/cache/yumrepos/yumrepo'
  }

}
