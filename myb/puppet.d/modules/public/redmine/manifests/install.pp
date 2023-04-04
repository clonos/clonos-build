# install redmine
class redmine::install {

  ensure_resource('package', $redmine::redmine_package, {'ensure' => 'present'})

}
