#!/bin/sh

su -l postgres -c "psql -d template1 -U postgres -c \"ALTER USER git WITH NOSUPERUSER;\""
service gitlab enable
service gitlab restart
