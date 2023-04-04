#!/bin/sh

su -l git -c "cd /usr/local/www/gitlab-ce && yarn install --production --pure-lockfile"
su -l git -c "cd /usr/local/www/gitlab-ce && RAILS_ENV=production NODE_ENV=production USE_DB=false SKIP_STORAGE_VALIDATION=true NODE_OPTIONS='--max_old_space_size=3584' bundle exec rake gitlab:assets:compile"
