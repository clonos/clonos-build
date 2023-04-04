#!/bin/sh


# gitlab need write access to create a symlink
chown git /usr/local/share/gitlab-shell

# make sure you are still using the root user and in /usr/local/www/gitlab-ce
su -l git -c "cd /usr/local/www/gitlab-ce && rake gitlab:setup RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1"
#su -l git -c "cd /usr/local/www/gitlab-ce && rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=yourpassword"

# Type 'yes' to create the database tables.

# Make sure we undo the temporary permission fix again
chown root /usr/local/share/gitlab-shell

# When done you see 'Administrator account created:'

service postgresql enable
